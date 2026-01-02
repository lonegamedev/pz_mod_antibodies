require("ISUI/ISPanel")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesConfig = require("antibodies_config")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEffectListPanel = require("ui/antibodies_effect_list_panel")

local AntibodiesWoundsPanel = AntibodiesEffectListPanel:derive("AntibodiesWoundsPanel")

function AntibodiesWoundsPanel:new(x, y, width, height)
	local instance = AntibodiesEffectListPanel.new(self, x, y, width, height)
	return instance
end

function AntibodiesWoundsPanel:composeEntries()
	local effects = self.medicalFile.condition.effects
	local sortedKeys = effects:getOrder()
	local maxMagnitude = AntibodiesConfig.computeMaxMagnitude(
		AntibodiesConfig.getCurrent()[AntibodiesEnum.Config.CONDITION]
	) or 1

	for _, key in pairs(sortedKeys) do
		local value = effects:get(key)
		local label = getText("UI_Antibodies_Condition_" .. key, AntibodiesUtils.formatFloat(value, 2))
		local percent = AntibodiesUtils.clamp(value / maxMagnitude, -1.0, 1.0)
		table.insert(self.entries, {
			key = key,
			label = label,
			value = value,
			percent = percent,
		})
	end
end

return AntibodiesWoundsPanel
