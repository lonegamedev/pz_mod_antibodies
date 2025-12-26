local Antibodies = {}
Antibodies.__index = Antibodies
Antibodies.__name = "Antibodies"

Antibodies.info = {
	["version"] = "{{MOD_VERSION}}",
	["optionsVersion"] = "{{MOD_OPTIONS_VERSION}}",
	["author"] = "lonegamedev.com",
	["modName"] = "{{MOD_NAME}}",
	["modId"] = "{{MOD_ID}}",
	["modWorkshopId"] = "{{MOD_WORKSHOP_ID}}",
}

Antibodies.networkCommand = {
	["shareMedicalFile"] = "shareMedicalFile",
}

function Antibodies.getNamespacedModData(player)
	local md = player:getModData()
	md.Antibodies = md.Antibodies or {}
	return md.Antibodies
end

return Antibodies
