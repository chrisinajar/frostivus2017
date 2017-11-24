Ping = Ping or class({})

function Ping:SendPing(location)
  CustomGameEventManager:Send_ServerToAllClients("ping_minimap", {
    location = location
  })
end
