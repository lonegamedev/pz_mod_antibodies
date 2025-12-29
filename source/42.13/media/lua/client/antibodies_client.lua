local AntibodiesClient = {}
AntibodiesClient.__index = AntibodiesClient
AntibodiesClient.__name = "AntibodiesClient"

AntibodiesClient.timeAccumlator = 0

require("timedActions.is_apply_bandage")
require("timedActions.is_comfrey_cataplasm")
require("timedActions.is_disinfect")
require("timedActions.is_garlic_cataplasm")
require("timedActions.is_plantain_cataplasm")

local Antibodies = require("antibodies")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesConfig = require("antibodies_config")

print("ANTIBODIES CLIENT FILE LOADED", isServer(), isClient())
print("MOD ID:", Antibodies.info.modId)
print("CMD:", Antibodies.networkCommand.shareMedicalFile)

function AntibodiesClient.ensureInitialization(player)
	if AntibodiesConfig.current == nil then
		AntibodiesConfig.current = AntibodiesConfig.new()
	end
	if AntibodiesClient.timeAccumlator == nil then
		AntibodiesClient.timeAccumlator = 0
	end
end

function AntibodiesClient.updatePlayers()
	local players = AntibodiesUtils.getLocalPlayers()
	for _, player in ipairs(players) do
		local medicalFile = AntibodiesMedicalFile.of(player)
		medicalFile:update(player, AntibodiesConfig.current)
	end
end

function AntibodiesClient.networkSync()
	if isClient() then
		AntibodiesClient.timeAccumlator = AntibodiesClient.timeAccumlator + getGameTime():getInvMultiplier()
		if AntibodiesClient.timeAccumlator >= 1.0 then
			local players = AntibodiesUtils.getLocalPlayers()
			for _, player in ipairs(players) do
				local md = Antibodies.getNamespacedModData(player)
				print("CLIENT SENDING MEDICAL FILE: ", player:getUsername())
				sendClientCommand(
					player,
					Antibodies.info.modId,
					Antibodies.networkCommand.shareMedicalFile,
					{ medicalFile = md.medicalFile }
				)
			end
		end
		AntibodiesClient.timeAccumlator = 0.0
	end
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onGameStart()
	--applyOptions(nil)
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
	--applyOptions(nil)
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onServerCommand(module, command, arguments)
	if module ~= Antibodies.info.modId then
		return
	end
	if command ~= Antibodies.networkCommand.shareMedicalFile then
		return
	end
	local player = getPlayerFromUsername(arguments.medicalFile.userName)
	if not player then
		return
	end
	local md = Antibodies.getNamespacedModData(player)
	md.medicalFile = AntibodiesMedicalFile.rehydrate(arguments.medicalFile)
	--print("GOT FROM SERVER: ", md.medicalFile:toString())
end
Events.OnServerCommand.Add(onServerCommand)

local function onEveryOneMinute()
	AntibodiesClient.ensureInitialization()
	AntibodiesClient.updatePlayers()
	AntibodiesClient.networkSync()
end
Events.EveryOneMinute.Add(onEveryOneMinute)

return AntibodiesClient
