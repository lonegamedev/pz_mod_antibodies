require("timedActions.is_apply_bandage")
require("timedActions.is_comfrey_cataplasm")
require("timedActions.is_disinfect")
require("timedActions.is_garlic_cataplasm")
require("timedActions.is_plantain_cataplasm")

local Antibodies = require("antibodies")
local AntibodiesEnum = require("antibodies_enum")
local AntibodiesUtils = require("antibodies_utils")
local AntibodiesMedicalFile = require("antibodies_medical_file")
local AntibodiesConfig = require("antibodies_config")

local AntibodiesClient = {}
AntibodiesClient.__index = AntibodiesClient
AntibodiesClient.__name = "AntibodiesClient"

function AntibodiesClient.updatePlayers()
	local players = AntibodiesUtils.getLocalPlayers()
	for _, player in ipairs(players) do
		local medicalFile = AntibodiesMedicalFile.of(player)
		medicalFile:update(player, AntibodiesConfig.getCurrent())
	end
end

function AntibodiesClient.validateIncoming(module, command, data)
	if module ~= Antibodies.info.modId then
		return false
	end
	if command == AntibodiesEnum.Network.SHARE_MEDICAL_FILE then
		if not data or not data.medicalFile then
			return false
		end
		return command
	end
	return false
end

function AntibodiesClient.sendMedicalFiles()
	local players = AntibodiesUtils.getLocalPlayers()
	for _, player in ipairs(players) do
		local md = Antibodies.getNamespacedModData(player)
		sendClientCommand(
			player,
			Antibodies.info.modId,
			AntibodiesEnum.Network.SHARE_MEDICAL_FILE,
			{ medicalFile = md.medicalFile }
		)
	end
end

function AntibodiesClient.recieveMedicalFile(medicalFile)
	local player = getPlayerFromUsername(medicalFile.userName)
	if not player then
		return
	end
	local md = Antibodies.getNamespacedModData(player)
	md.medicalFile = AntibodiesMedicalFile.rehydrate(medicalFile)
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onGameStart()
	AntibodiesConfig.setCurrent(nil)
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
	AntibodiesConfig.setCurrent(nil)
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onServerCommand(module, command, data)
	local op = AntibodiesClient.validateIncoming(module, command, data)
	if op == AntibodiesEnum.Network.SHARE_MEDICAL_FILE then
		AntibodiesClient.recieveMedicalFile(data.medicalFile)
	end
end
Events.OnServerCommand.Add(onServerCommand)

local function onEveryOneMinute()
	AntibodiesClient.updatePlayers()
	if isClient() then
		AntibodiesClient.sendMedicalFiles()
	end
end
Events.EveryOneMinute.Add(onEveryOneMinute)

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

return AntibodiesClient
