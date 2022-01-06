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
  end
end
Events.OnClientCommand.Add(onClientCommand)