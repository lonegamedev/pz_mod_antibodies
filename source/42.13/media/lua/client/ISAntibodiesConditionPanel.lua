require("ISUI/ISPanel")
ISAntibodiesConditionPanel = ISPanel:derive("ISAntibodiesConditionPanel")

local function drawEntry(panel, x, y, width, entry)
	local start_y = y
	local percent = entry.value / ISAntibodiesWindow.conditionProgressBar
	panel:drawText(entry.label, x, y, 1, 1, 1, 1, UIFont.Small)
	y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	y = y + AntibodiesUI.drawProgressBar(panel, x, y, width, 10, percent)
	return y - start_y
end

local function drawEntryEmpty(panel, x, y, width, entry)
	local start_y = y
	y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	y = y + AntibodiesUI.ROW_MARGIN
	return y - start_y
end

local function predrawEntries(panel, entries)
	local y = AntibodiesUI.CONTENT_PADDING_Y
	local drawFunc = drawEntryEmpty
	local numEntries = #entries
	for i, entry in ipairs(entries) do
		y = y + drawFunc(panel, AntibodiesUI.CONTENT_PADDING, y, panel:getAvailableWidth(), entry)
		y = y + AntibodiesUI.ROW_MARGIN
	end
	y = y + AntibodiesUI.CONTENT_PADDING_Y
	return y
end

local function drawEntries(panel, entries, contentHeight)
	local drawFunc = drawEntry
	local y = AntibodiesUI.CONTENT_PADDING_Y
	if panel.height > contentHeight then
		y = y + ((panel.height - contentHeight) / 2)
	end
	local numEntries = #entries
	for _, entry in ipairs(entries) do
		y = y + drawFunc(panel, AntibodiesUI.CONTENT_PADDING, y, panel:getAvailableWidth(), entry)
		y = y + AntibodiesUI.ROW_MARGIN
	end
	y = y + AntibodiesUI.CONTENT_PADDING_Y
	return y
end

function ISAntibodiesConditionPanel:getAvailableWidth()
	return self.width - (AntibodiesUI.CONTENT_PADDING * 2.0) - self.vscroll.width
end

function ISAntibodiesConditionPanel:compose()
	local result = {}
	local effect = self.medicalFile.status.condition.effect
	local sorted_keys = self.medicalFile.status.condition.sorted_keys
	for _, key in pairs(sorted_keys) do
		local value = effect[key]
		local label = getText("UI_Antibodies_Condition_" .. key, AntibodiesUtils.format_float(value, 2))
		local percent = value / ISAntibodiesWindow.conditionProgressBar
		if percent > 1.0 then
			percent = 1.0
		end
		if percent < -1.0 then
			percent = -1.0
		end
		table.insert(result, {
			key = key,
			label = label,
			value = value,
			percent = percent,
		})
	end
	return result
end

function ISAntibodiesConditionPanel:scrollUp()
	self:setYScroll(self:getYScroll() + self.height * 0.2)
end

function ISAntibodiesConditionPanel:scrollDown()
	self:setYScroll(self:getYScroll() - self.height * 0.2)
end

function ISAntibodiesConditionPanel:initialise()
	ISPanel.initialise(self)
end

function ISAntibodiesConditionPanel:new(x, y, width, height)
	local o = {}
	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	return o
end

function ISAntibodiesConditionPanel:createChildren()
	ISPanel.createChildren(self)
	self.doStencilRender = true
	self.borderColor.a = 0.0
	self.backgroundColor.a = 0.0
	self:addScrollBars()
	self.vscroll:setHeight(self.height)
	self.vscroll:setX(self.width - self.vscroll.width)
	self.vscroll:setVisible(true)
end

function ISAntibodiesConditionPanel:prerender()
	ISPanel.prerender(self)
	self.vscroll:setX(self.width - self.vscroll.width)
	if self.medicalFile and self:isVisible() then
		self.entries = self:compose()
		self.contentHeight = predrawEntries(self, self.entries)
		self:setScrollHeight(self.contentHeight)
	end
end

function ISAntibodiesConditionPanel:render()
	ISPanel.render(self)
	if self.medicalFile and self:isVisible() then
		if AntibodiesUtils.is_table_empty(self.entries) then
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
			drawEntries(self, self.entries, self.contentHeight)
			self:clearStencilRect()
		end
	end
end
