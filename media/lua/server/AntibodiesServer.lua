local function onClientCommand(module, command, player, args)
  if module == AntibodiesShared.modId then
  	if command == "getOptions" then
  		if not AntibodiesShared.hasOptions() then
  			AntibodiesShared.applyOptions(
  				AntibodiesShared.getLocalOptions()
  			)
  		end
	  	sendServerCommand(
	  		player, 
	  		AntibodiesShared.modId, 
	  		"postOptions", 
	  		AntibodiesShared.currentOptions
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