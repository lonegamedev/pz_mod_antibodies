require("ISUI/ISPanel")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesConfig = require("antibodies_config")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEffects = require("antibodies_effects")
local AntibodiesEffectListPanel = require("ui/antibodies_effect_list_panel")

local AntibodiesWoundsPanel = AntibodiesEffectListPanel:derive("AntibodiesWoundsPanel")

function AntibodiesWoundsPanel:new(x, y, width, height)
	local instance = AntibodiesEffectListPanel.new(self, x, y, width, height)
	return instance
end

function AntibodiesWoundsPanel:composeBreakdownEntries(effects)
	local sortedKeys = effects:getOrder()
	local res = {}
	for _, key in pairs(sortedKeys) do
		local value = effects:get(key)
		local label =
			getText(AntibodiesEnum.getWoundOrTreatmentTranslationKey(key), AntibodiesUtils.formatFloat(value, 2))
		table.insert(res, {
			key = key,
			label = label,
			value = value,
		})
	end
	return res
end

function AntibodiesWoundsPanel:composeEntries()
	local bodyParts = self.medicalFile.body.bodyParts
	local bodyPartMinMagnitude = 0.01
	local maxMagnitude = math.max(
		AntibodiesConfig.computeMaxMagnitude(AntibodiesConfig.getCurrent()[AntibodiesEnum.Config.WOUND]) or 1,
		AntibodiesConfig.computeMaxMagnitude(AntibodiesConfig.getCurrent()[AntibodiesEnum.Config.TREATMENT]) or 1
	)
	for key, bodyPart in pairs(bodyParts) do
		local value = bodyPart:getWoundTreatmentEffect()
		if math.abs(value) > bodyPartMinMagnitude then
			local label = getText(AntibodiesEnum.getBodyPartTranslationKey(key), AntibodiesUtils.formatFloat(value, 2))
			local percent = AntibodiesUtils.clamp(value / maxMagnitude, -1.0, 1.0)
			local breakdownEffects = AntibodiesEffects:newFromEffects(bodyPart.woundEffects, bodyPart.treatmentEffects)
			local breakdown = self:composeBreakdownEntries(breakdownEffects)
			table.insert(self.entries, {
				key = key,
				label = label,
				value = value,
				percent = percent,
				breakdown = breakdown,
			})
		end
	end
end

return AntibodiesWoundsPanel
