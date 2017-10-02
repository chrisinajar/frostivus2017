PhaseOne = PhaseOne or {}

local FinishedEvent = Event()

function PhaseOne:Start(callback)
  FinishedEvent.once(callback)
  -- phase one starts the director
  HordeDirector:Init()

  -- do stuff?
  -- call FinishedEvent.broadcast({}) when we're done
end
