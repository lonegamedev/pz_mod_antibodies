require("ISUI/ISPanelJoypad")
local AntibodiesUI = require("ui/antibodies_ui")

local AntibodiesEffectListPanel = ISPanelJoypad:derive("AntibodiesEffectListPanel")

function AntibodiesEffectListPanel:new(x, y, width, height)
	local instance = ISPanelJoypad:new(x, y, width, height)
	setmetatable(instance, self)
	self.__index = self

	instance.doStencilRender = true
	instance.borderColor.a = 0.0
	instance.backgroundColor.a = 0.0

	instance.medicalFile = nil

	instance.lastUpdateTS = 0
	instance.entries = {}
	instance.contentHeight = 0

	return instance
end

function AntibodiesEffectListPanel:scrollUp()
	self:setYScroll(self:getYScroll() + self.height * 0.2)
end

function AntibodiesEffectListPanel:scrollDown()
	self:setYScroll(self:getYScroll() - self.height * 0.2)
end

function AntibodiesEffectListPanel:initialise()
	ISPanelJoypad.initialise(self)
end

function AntibodiesEffectListPanel:createChildren()
	ISPanelJoypad.createChildren(self)
	self:addScrollBars()
	self.vscroll:setHeight(self.height - 1)
	self.vscroll:setX(self.width - self.vscroll.width)
	self.vscroll:setVisible(true)
end

function AntibodiesEffectListPanel:prerender()
	ISPanelJoypad.prerender(self)
	self.vscroll:setX(self.width - self.vscroll.width)
	if self.medicalFile and self:isVisible() then
		if self.medicalFile.timestamp ~= self.lastUpdateTS then
			self.entries = {}
			self:composeEntries()
			self.lastUpdateTS = self.medicalFile.timestamp
		end
		self.contentHeight = self:drawEntries(true)
		self:setScrollHeight(self.contentHeight)
	end
end

function AntibodiesEffectListPanel:render()
	ISPanelJoypad.render(self)
	if self.medicalFile and self:isVisible() then
		if #self.entries == 0 then
			self:drawTextCentre(
				getText("UI_Antibodies_KnoxInfection_NoEffect"),
				self.width / 2,
				self.height / 2 - AntibodiesUI.FONT_HGT_SMALL / 2,
				1,
				1,
				1,
				1,
				UIFont.Small
			)
		else
			self:setStencilRect(0, 0, self.width - self.vscroll.width, self.height)
			self:drawEntries()
			self:clearStencilRect()
		end
	end
end

function AntibodiesEffectListPanel:getAvailableWidth()
	return self.width - (AntibodiesUI.CONTENT_PADDING_X * 2.0) - self.vscroll.width
end

function AntibodiesEffectListPanel:composeEntries()
	--- Override this method in subclasses to populate `self.entries`.
	--- The base implementation does nothing.
	---
	--- Example entry structure (optional, for reference):
	---[[
	--- table.insert(self.entries, {
	---     key = key,       -- unique identifier
	---     label = label,   -- display text
	---     value = value,   -- numeric value
	---     percent = percent, -- optional float between -1.0 and 1.0
	--- 	breakdown = breakdown -- optional table of strings
	--- })
	---]]
end

function AntibodiesEffectListPanel:drawProgressBar(x, y, width, height, percent, predraw)
	if not predraw then
		self:drawRect(x, y, width, height, 0.25, 0.0, 0.0, 0.0)
	end

	percent = math.min(1.0, math.max(-1.0, percent))
	local barWidth = (width * 0.5) * percent

	if barWidth > 0.0 and barWidth < 1.0 then
		barWidth = 1.0
	elseif barWidth < 0.0 and barWidth > -1.0 then
		barWidth = -1.0
	end

	local color = percent >= 0 and AntibodiesUI.GREEN or AntibodiesUI.RED
	if not predraw then
		self:drawRect(x + (width * 0.5), y, barWidth, height, 1.0, color.r, color.g, color.b)
		self:drawRectBorder(x, y, width, height, 0.25, AntibodiesUI.GREY.r, AntibodiesUI.GREY.g, AntibodiesUI.GREY.b)
	end

	return height
end

function AntibodiesEffectListPanel:drawEntry(x, y, width, entry, predraw)
	local start_y = y
	if not predraw then
		self:drawText(entry.label, x, y, 1, 1, 1, 1, UIFont.Small)
	end
	y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	y = y + self:drawProgressBar(x, y, width, 10, entry.percent, predraw)

	local breakdown = entry.breakdown or {}
	if #breakdown > 0 then
		local walker_x = x
		y = y + AntibodiesUI.LINE_MARGIN
		for i, entry in ipairs(entry.breakdown) do
			local text = entry.label
			if i < #breakdown then
				text = text .. ","
			end
			local textWidth = getTextManager():MeasureStringX(UIFont.Small, text)
			if walker_x + textWidth >= width then
				walker_x = x
				y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
			end
			self:drawText(
				text,
				walker_x,
				y,
				AntibodiesUI.GREY.r,
				AntibodiesUI.GREY.g,
				AntibodiesUI.GREY.b,
				AntibodiesUI.GREY.a,
				UIFont.Small
			)
			walker_x = walker_x + textWidth + AntibodiesUI.TEXT_SEP
		end
		y = y + (AntibodiesUI.LINE_MARGIN * 6)
	end
	return y - start_y
end

function AntibodiesEffectListPanel:drawEntries(predraw)
	local y = AntibodiesUI.CONTENT_PADDING_Y
	if self.height > self.contentHeight then
		y = y + ((self.height - self.contentHeight) / 2)
	end
	for i, entry in ipairs(self.entries) do
		y = y + self:drawEntry(AntibodiesUI.CONTENT_PADDING_X, y, self:getAvailableWidth(), entry, predraw)
		y = y + AntibodiesUI.ROW_MARGIN
	end
	y = y + AntibodiesUI.CONTENT_PADDING_Y
	return y
end

return AntibodiesEffectListPanel
