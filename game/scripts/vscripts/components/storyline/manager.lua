StorylineManager = StorylineManager or class({})

Debug.EnabledModules['storyline:manager'] = true

local VictoryPhase = {}
function VictoryPhase:Start()
  StorylineManager:Victory()
end

local STORY_STATES = {
  -- {
  --   comic = ComicData.act1,
  --   phase = PhaseOne,
  --   name = "repair"
  -- },
  -- {
  --   comic = ComicData.act2,
  --   phase = PhaseTwo,
  --   name = "forest"
  -- },
  {
    comic = ComicData.act3,
    phase = PhaseThree,
    name = "payload"
  },
  {
    comic = ComicData.act4,
    phase = BossFight,
    name = "boss fight"
  },
  {
    comic = ComicData.victory,
    phase = VictoryPhase,
    name = "victory"
  }
}

function StorylineManager:Init()
  DebugPrint('Initializing storyline manager')
  self.currentState = 0
  -- do things to make sure the players don't see their heroes until after the comic
  GameEvents:OnPreGame(function()
    -- start story!
    DebugPrint('Starting storyline')
    self:Next()
  end)

  DebugOverlay:AddGroup("root", {
    Name = "StorylinePhases",
    DisplayName = "Storyline Phases",
  })
  DebugOverlay:AddEntry("StorylinePhases", {
    Name = "currentPhase",
    DisplayName = "current Phase",
    Value = "phases not initialized"
  })
  for i,v in pairs(STORY_STATES) do
    DebugOverlay:AddGroup("StorylinePhases", {
      Name = "Phase_" .. v.name,
      DisplayName = "Phase " .. tostring(i) .. " " .. v.name,
    })
  end
end

function StorylineManager:ShowComic(comicData, callback)
  local function finished (data)
    -- do something when the cinematic is done?
    callback(data)
  end
  ComicManager:Show(comicData, finished)
end

function StorylineManager:Victory()
  GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
end

function StorylineManager:Next()
  self.currentState = self.currentState + 1
  local state = STORY_STATES[self.currentState]

  DebugPrint("Starting storyline act: " .. state.name)

  DebugOverlay:Update("currentPhase", {
    Value = state.name,
    forceUpdate = true
  })

  local function startPhase (data)
    HordeDirector:Resume()
    state.phase:Start(function()
      Timers:CreateTimer(1, function()
        self:Next()
      end)
    end)
  end

  local function showComicAndStart ()
    if state.comic then
      HordeDirector:Pause()
      self:ShowComic(state.comic, startPhase)
    else
      Timers:CreateTimer(1, function()
        startPhase({})
      end)
    end
  end

  if state.phase.Prepare then
    Timers:CreateTimer(1, function()
      state.phase:Prepare()
      showComicAndStart()
    end)
  else
    showComicAndStart()
  end
end
