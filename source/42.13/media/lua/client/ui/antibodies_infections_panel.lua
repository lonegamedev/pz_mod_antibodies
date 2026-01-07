require("ISUI/ISPanel")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesConfig = require("antibodies_config")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesEffectListPanel = require("ui/antibodies_effect_list_panel")

local AntibodiesInfectionsPanel = AntibodiesEffectListPanel:derive("AntibodiesInfectionsPanel")

function AntibodiesInfectionsPanel:new(x, y, width, height)
	local instance = AntibodiesEffectListPanel.new(self, x, y, width, height)
	return instance
end

function AntibodiesInfectionsPanel:composeBreakdownEntries(effects)
	local sortedKeys = effects:getOrder()
	local res = {}
	for _, key in pairs(sortedKeys) do
		local value = effects:get(key)
		local label = getText(AntibodiesEnum.getInfectionTranslation(key), AntibodiesUtils.formatFloat(value, 2))
		table.insert(res, {
			key = key,
			label = label,
			value = value,
		})
	end
	return res
end

function AntibodiesInfectionsPanel:composeEntries()
	local bodyParts = self.medicalFile.body.bodyParts
	local bodyPartMinMagnitude = 0.01
	local maxMagnitude = AntibodiesConfig.computeMaxMagnitude(
		AntibodiesConfig.getCurrent()[AntibodiesEnum.Config.INFECTION]
	) or 1
	for key, bodyPart in pairs(bodyParts) do
		local value = bodyPart.infectionEffects:getTotal()
		if math.abs(value) > bodyPartMinMagnitude then
			local label = getText(AntibodiesEnum.getBodyPartTranslationKey(key), AntibodiesUtils.formatFloat(value, 2))
			local percent = AntibodiesUtils.clamp(value / maxMagnitude, -1.0, 1.0)
			local breakdown = self:composeBreakdownEntries(bodyPart.infectionEffects)
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

return AntibodiesInfectionsPanel
