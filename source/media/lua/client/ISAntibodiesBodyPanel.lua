require("ISUI/ISPanel")
ISAntibodiesBodyPanel = ISPanel:derive("ISAntibodiesBodyPanel")

ISAntibodiesBodyPanel.View = {
	["Wounds"] = "wounds",
	["Infections"] = "infections",
	["Hygiene"] = "hygiene",
}

ISAntibodiesBodyPanel.getProgressBarWidth = function(viewId)
	local refValue = ISAntibodiesWindow.conditionProgressBar
	if viewId == ISAntibodiesBodyPanel.View.Wounds then
		refValue = ISAntibodiesWindow.woundsProgressBar
	end
	if viewId == ISAntibodiesBodyPanel.View.Infections then
		refValue = ISAntibodiesWindow.infectionsProgressBar
	end
	if viewId == ISAntibodiesBodyPanel.View.Hygiene then
		refValue = ISAntibodiesWindow.hygieneProgressBar
	end
	return refValue
end

local function drawEntry(panel, x, y, width, entry, viewId)
	local start_y = y
	local percent = entry.value / ISAntibodiesBodyPanel.getProgressBarWidth(viewId)
	panel:drawText(entry.label, x, y, 1, 1, 1, 1, UIFont.Small)
	y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	y = y + AntibodiesUI.drawProgressBar(panel, x, y, width, 10, percent)
	y = y + AntibodiesUI.LINE_MARGIN
	local start_x = x
	local breakdownCount = #entry.breakdown
	for i, str in ipairs(entry.breakdown) do
		local text = str
		if i < breakdownCount then
			text = text .. ","
		end
		local textWidth = getTextManager():MeasureStringX(UIFont.Small, text)
		if x + textWidth >= width then
			x = start_x
			y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
		end
		panel:drawText(
			text,
			x,
			y,
			AntibodiesUI.GREY.r,
			AntibodiesUI.GREY.g,
			AntibodiesUI.GREY.b,
			AntibodiesUI.GREY.a,
			UIFont.Small
		)
		x = x + textWidth + AntibodiesUI.TEXT_SEP
	end
	if breakdownCount > 0 then
		y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	end
	y = y + AntibodiesUI.ROW_MARGIN
	return y - start_y
end

local function drawEntryEmpty(panel, x, y, width, entry, viewId)
	local start_y = y
	y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	y = y + AntibodiesUI.ROW_MARGIN
	local start_x = x
	local breakdownCount = #entry.breakdown
	for i, str in ipairs(entry.breakdown) do
		local text = str
		if i < breakdownCount then
			text = text .. ","
		end
		local textWidth = getTextManager():MeasureStringX(UIFont.Small, text)
		if x + textWidth >= width then
			x = start_x
			y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
		end
		x = x + textWidth + AntibodiesUI.TEXT_SEP
	end
	if breakdownCount > 0 then
		y = y + AntibodiesUI.FONT_HGT_SMALL + AntibodiesUI.LINE_MARGIN
	end
	y = y + AntibodiesUI.ROW_MARGIN
	return y - start_y
end

local function predrawEntries(panel, entries, viewId)
	local y = AntibodiesUI.CONTENT_PADDING_Y
	local drawFunc = drawEntryEmpty
	local numEntries = #entries
	for i, entry in ipairs(entries) do
		y = y + drawFunc(panel, AntibodiesUI.CONTENT_PADDING, y, panel:getAvailableWidth(), entry, viewId)
		if i < numEntries then
			y = y + AntibodiesUI.ROW_MARGIN
		end
	end
	y = y + AntibodiesUI.CONTENT_PADDING_Y
	return y
end

local function drawEntries(panel, entries, contentHeight, viewId)
	local drawFunc = drawEntry
	local y = AntibodiesUI.CONTENT_PADDING_Y
	if panel.height > contentHeight then
		y = y + ((panel.height - contentHeight) / 2)
	end
	local numEntries = #entries
	for _, entry in ipairs(entries) do
		y = y + drawFunc(panel, AntibodiesUI.CONTENT_PADDING, y, panel:getAvailableWidth(), entry, viewId)
		if i < numEntries then
			y = y + AntibodiesUI.ROW_MARGIN
		end
	end
	y = y + AntibodiesUI.CONTENT_PADDING_Y
	return y
end

function ISAntibodiesBodyPanel:getAvailableWidth()
	return self.width - (AntibodiesUI.CONTENT_PADDING * 2.0) - self.vscroll.width
end

function ISAntibodiesBodyPanel:composeBreakdown(part_key)
	if self.view == ISAntibodiesBodyPanel.View.Wounds then
		return self:composeBreakdownWounds(part_key)
	elseif self.view == ISAntibodiesBodyPanel.View.Infections then
		return self:composeBreakdownInfections(part_key)
	elseif self.view == ISAntibodiesBodyPanel.View.Hygiene then
		return self:composeBreakdownHygiene(part_key)
	end
	return {}
end

function ISAntibodiesBodyPanel:composeBreakdownWounds(part_key)
	local result = {}
	local part_wounds = self.medicalFile.status.parts[part_key].wounds
	for key in pairs(part_wounds) do
		local treatmentMod = 1
		if AntibodiesUtils.has_value(Antibodies.WoundTreatmentMods, key) then
			treatmentMod = self.medicalFile.status.parts[part_key].treatment[key]
		end
		local val = (
			AntibodiesUtils.bool_to_number(part_wounds[key])
			* AntibodiesUtils.number_or_zero(Antibodies.currentOptions.wounds[key])
			* treatmentMod
		)
		if math.abs(val) > 0.01 then
			table.insert(result, getText("UI_Antibodies_Wounds_" .. key, AntibodiesUtils.format_float(val, 2)))
		end
	end
	return result
end

function ISAntibodiesBodyPanel:composeBreakdownInfections(part_key)
	local result = {}
	local part_infections = self.medicalFile.status.parts[part_key].infections
	for key in pairs(part_infections) do
		local val = (
			AntibodiesUtils.bool_to_number(part_infections[key])
			* AntibodiesUtils.number_or_zero(Antibodies.currentOptions.infections[key])
		)
		if math.abs(val) > 0.01 then
			table.insert(result, getText("UI_Antibodies_Infections_" .. key, AntibodiesUtils.format_float(val, 2)))
		end
	end
	return result
end

function ISAntibodiesBodyPanel:composeBreakdownHygiene(part_key)
	local result = {}
	local part_hygiene = self.medicalFile.status.parts[part_key].hygiene
	for wound_key, wound_mod in pairs(part_hygiene.mods) do
		local wound_mod = part_hygiene.mods[wound_key]
		local part_blood_effect = (part_hygiene.blood * wound_mod)
			* -AntibodiesUtils.number_or_zero(Antibodies.currentOptions.hygiene.bloodEffect)
		local part_dirt_effect = (part_hygiene.dirt * wound_mod)
			* -AntibodiesUtils.number_or_zero(Antibodies.currentOptions.hygiene.dirtEffect)
		local val = part_blood_effect + part_dirt_effect
		if math.abs(val) > 0.01 then
			table.insert(result, getText("UI_Antibodies_Wounds_" .. wound_key, AntibodiesUtils.format_float(val, 2)))
		end
	end
	return result
end

function ISAntibodiesBodyPanel:compose()
	local result = {}
	local values = self.medicalFile.parts_effects[self.view].values
	local keys = self.medicalFile.parts_effects[self.view].sorted_keys
	for _, key in pairs(keys) do
		local value = values[key]
		local breakdown = self:composeBreakdown(key)
		table.insert(result, {
			key = key,
			label = getText("UI_Antibodies_BodyParts_" .. key, AntibodiesUtils.format_float(value, 2)),
			value = value,
			breakdown = breakdown,
		})
	end
	return result
end

function ISAntibodiesBodyPanel:scrollUp()
	self:setYScroll(self:getYScroll() + self.height * 0.2)
end

function ISAntibodiesBodyPanel:scrollDown()
	self:setYScroll(self:getYScroll() - self.height * 0.2)
end

function ISAntibodiesBodyPanel:initialise()
	ISPanel.initialise(self)
end

function ISAntibodiesBodyPanel:new(x, y, width, height, view)
	local o = {}
	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self
	o.view = view
	o.entries = {}
	return o
end

function ISAntibodiesBodyPanel:createChildren()
	ISPanel.createChildren(self)
	self.doStencilRender = true
	self.borderColor.a = 0.0
	self.backgroundColor.a = 0.0
	self:addScrollBars()
	self.vscroll:setHeight(self.height)
	self.vscroll:setX(self.width - self.vscroll.width)
	self.vscroll:setVisible(true)
end

function ISAntibodiesBodyPanel:prerender()
	ISPanel.prerender(self)
	self.vscroll:setX(self.width - self.vscroll.width)
	if self.medicalFile and self:isVisible() then
		self.entries = self:compose()
		if AntibodiesUtils.is_table_empty(self.entries) then
			self:setScrollHeight(self.height)
		else
			self.contentHeight = predrawEntries(self, self.entries, self.view)
			self:setScrollHeight(self.contentHeight)
		end
	end
end

function ISAntibodiesBodyPanel:render()
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
			drawEntries(self, self.entries, self.contentHeight, self.view)
			self:clearStencilRect()
		end
		--self:drawRect(0, 0, self.width, self.height, 0.25, 0, 0, 0);
	end
end
