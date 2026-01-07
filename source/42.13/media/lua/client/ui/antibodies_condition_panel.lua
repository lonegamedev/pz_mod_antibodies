require("ISUI/ISPanel")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesConfig = require("antibodies_config")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEffectListPanel = require("ui/antibodies_effect_list_panel")

local AntibodiesConditionPanel = AntibodiesEffectListPanel:derive("AntibodiesConditionPanel")

function AntibodiesConditionPanel:composeEntries()
	local effects = self.medicalFile.condition.effects
	local sortedKeys = effects:getOrder()
	local maxMagnitude = AntibodiesConfig.computeMaxMagnitude(
		AntibodiesConfig.getCurrent()[AntibodiesEnum.Config.CONDITION]
	) or 1

	for _, key in pairs(sortedKeys) do
		local value = effects:get(key)
		local label = getText(AntibodiesEnum.getConditionTranslationKey(key), AntibodiesUtils.formatFloat(value, 2))
		local percent = AntibodiesUtils.clamp(value / maxMagnitude, -1.0, 1.0)
		table.insert(self.entries, {
			key = key,
			label = label,
			value = value,
			percent = percent,
			breakdown = {},
		})
	end
end

return AntibodiesConditionPanel
