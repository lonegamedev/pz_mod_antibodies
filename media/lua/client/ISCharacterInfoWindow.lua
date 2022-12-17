local ISCharacterInfoWindow_bringToTop = ISCharacterInfoWindow.bringToTop
function ISCharacterInfoWindow:bringToTop()
    if self.antibodiesPanel then
        self.antibodiesPanel:bringToTop()
    end
    ISCharacterInfoWindow_bringToTop(self)
end

local ISCharacterInfoWindow_createChildren = ISCharacterInfoWindow.createChildren
function ISCharacterInfoWindow:createChildren()
    ISCharacterInfoWindow_createChildren(self)
    local player = getSpecificPlayer(self.playerNum)
    self.antibodiesPanel = AntibodiesPanel.createPanel(player)
end

local ISCharacterInfoWindow_onPreUIDraw = function()
    local players = AntibodiesUtils.getLocalPlayers()
    for key, player in ipairs(players) do
        local infoPanel = getPlayerInfoPanel(player:getPlayerNum())
        if infoPanel then
            local shouldShow = infoPanel.healthView:isReallyVisible()
            if shouldShow then
                infoPanel.antibodiesPanel:updateDiagnosis(
                    infoPanel.healthView.otherPlayer or infoPanel.healthView.character,
                    infoPanel.healthView.character
                )
                infoPanel.antibodiesPanel:updatePlacement(infoPanel.healthView)
            end
            infoPanel.antibodiesPanel:setVisible(shouldShow)
        end
    end
end
Events.OnPreUIDraw.Add(ISCharacterInfoWindow_onPreUIDraw)
