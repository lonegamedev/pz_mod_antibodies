local function onClientCommand(module, command, player, args)
  if module == AntibodiesShared.modId then
  	if command == "getOptions" then
	  	sendServerCommand(
	  		player, 
	  		AntibodiesShared.modId, 
	  		"postOptions", 
	  		AntibodiesShared.getCurrentOptions()
	  	)
		end
		if command == "saveOptions" then
			if player:getAccessLevel() == "Admin" then
        AntibodiesShared.applyOptions(args)
        AntibodiesShared.saveOptions(args)
			end
		end
  end
end
Events.OnClientCommand.Add(onClientCommand)