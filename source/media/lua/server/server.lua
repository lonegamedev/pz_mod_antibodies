require("AntibodiesShared")

AntibodiesServer = {}
AntibodiesServer.__index = AntibodiesServer

AntibodiesServer.timeAccumlator = 0
AntibodiesServer.medicalFile = {}

local function ensureServerInitialization()
	if AntibodiesServer.timeAccumlator == nil then
		AntibodiesServer.timeAccumlator = 0
	end
	if AntibodiesServer.medicalFile == nil then
		AntibodiesServer.medicalFile = {}
	end
end

local function onClientCommand(module, command, player, data)
	if module == AntibodiesShared.info.modId then
		if command == AntibodiesShared.networkCommand.shareMedicalFile then
			AntibodiesServer.medicalFile[data.playerOnlineId] = data.medicalFile
		end
	end
end
Events.OnClientCommand.Add(onClientCommand)

local function onEveryOneMinute()
	if isServer() then
		ensureServerInitialization()
		AntibodiesServer.timeAccumlator = AntibodiesServer.timeAccumlator + getGameTime():getInvMultiplier()
		if AntibodiesServer.timeAccumlator >= 1.0 then
			for playerOnlineId in pairs(AntibodiesServer.medicalFile) do
				local medicalFile = AntibodiesServer.medicalFile[playerOnlineId]
				sendServerCommand(
					AntibodiesShared.info.modId,
					AntibodiesShared.networkCommand.shareMedicalFile,
					{ playerOnlineId = playerOnlineId, medicalFile = medicalFile }
				)
			end
			AntibodiesServer.timeAccumlator = 0.0
		end
	end
end
Events.EveryOneMinute.Add(onEveryOneMinute)
