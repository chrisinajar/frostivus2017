
if DebugInfos == nil then
  DebugPrint( 'creating new DebugInfos object' )
  DebugInfos = class({})
end

function DebugInfos:Init()
  DebugOverlay:AddEntry("root", {
    Name = "MapName",
    DisplayName = "Map",
    Value = GetMapName()
  })
  DebugOverlay:AddGroup("root", {
    Name = "PlayerList",
    DisplayName = "Players",
    Color = "#FFFF00"
  })
  for playerID=0,4 do
    local groupName = "Player" .. playerID
    DebugOverlay:AddGroup("PlayerList", {
      Name = groupName,
      DisplayName = "Player " .. playerID
    })
    DebugOverlay:AddEntry(groupName, {
      Name = groupName .. "Name",
      DisplayName = "Name",
      Value = PlayerResource:GetPlayerName(playerID)
    })
    DebugOverlay:AddEntry(groupName, {
      Name = groupName .. "SteamID",
      DisplayName = "SteamID",
      Value = PlayerResource:GetSteamID(playerID)
    })
    DebugOverlay:AddEntry(groupName, {
      Name = groupName .. "Hero",
      DisplayName = "Selected Hero",
      Value = PlayerResource:GetSelectedHeroName(playerID)
    })
    DebugOverlay:AddEntry(groupName, {
      Name = groupName .. "Level",
      DisplayName = "Level"
    })
    Timers:CreateTimer(0, function()
      DebugOverlay:Update(groupName .. "Level", {
        Value = PlayerResource:GetLevel(playerID),
        forceUpdate = true
      })
      return 5
    end)
  end
end
