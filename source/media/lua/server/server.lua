local function onClientCommand(module, command, player, data)
	if module == "{{MOD_ID}}" then
		if command == "shareMedicalFile" then
			local medicalFile = data.medicalFile
			local playerOnlineId = data.playerOnlineId
			sendServerCommand(
				"{{MOD_ID}}",
				"shareMedicalFile",
				{ playerOnlineId = playerOnlineId, medicalFile = medicalFile }
			)
		end
	end
end
Events.OnClientCommand.Add(onClientCommand)
