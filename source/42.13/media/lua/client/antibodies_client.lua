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
local AntibodiesNetwork = require("antibodies_network")
local AntibodiesTime = require("antibodies_time")

local AntibodiesClient = {}
AntibodiesClient.__index = AntibodiesClient
AntibodiesClient.__name = "AntibodiesClient"

function AntibodiesClient.ensureInitialization()
	return AntibodiesUtils.isSinglePlayer()
		and AntibodiesConfig.getCurrent() ~= nil
		and AntibodiesTime.getInstance() ~= nil
end

function AntibodiesClient.updatePlayers()
	local minutesElapsed = AntibodiesTime.getInstance():getMinutesDelta()
	if minutesElapsed > 0.0 then
		local players = AntibodiesUtils.getLocalPlayers()
		local config = AntibodiesConfig.getCurrent()
		for _, player in ipairs(players) do
			local medicalFile = AntibodiesMedicalFile.of(player)
			medicalFile:update(player, minutesElapsed, config)
		end
	end
end

function AntibodiesClient.recieveMedicalFile(medicalFile)
	if not medicalFile then
		return
	end
	local player = getPlayerFromUsername(medicalFile.userName)
	if not player then
		return
	end
	local md = Antibodies.getNamespacedModData(player)
	medicalFile = AntibodiesMedicalFile.rehydrate(medicalFile)
	if not medicalFile then
		return
	end
	md.medicalFile = medicalFile
end

-----------------------------------------------------
--CALLBACKS------------------------------------------
-----------------------------------------------------

local function onGameStart()
	AntibodiesConfig.setCurrent(nil)
	if AntibodiesUtils.isSinglePlayer() then
		AntibodiesTime.getInstance():reset()
	end
end
Events.OnGameStart.Add(onGameStart)

local function onMainMenuEnter()
	AntibodiesConfig.setCurrent(nil)
end
Events.OnMainMenuEnter.Add(onMainMenuEnter)

local function onServerCommand(module, command, data)
	if AntibodiesNetwork.isAntibodiesCommand(module, command) then
		if command == AntibodiesEnum.Network.SHARE_MEDICAL_FILE then
			AntibodiesClient.recieveMedicalFile(data.medicalFile or nil)
		end
	end
end
Events.OnServerCommand.Add(onServerCommand)

local function onEveryOneMinute()
	if AntibodiesClient.ensureInitialization() then
		AntibodiesTime.getInstance():step()
		AntibodiesClient.updatePlayers()
	end
end
Events.EveryOneMinute.Add(onEveryOneMinute)

-----------------------------------------------------
-----------------------------------------------------
-----------------------------------------------------

return AntibodiesClient
