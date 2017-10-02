StorylineManager = StorylineManager or class({})

Debug.EnabledModules['storyline:manager'] = true

local VictoryPhase = {}
function VictoryPhase:Start()
  StorylineManager:Victory()
end

local STORY_STATES = {
  {
    comic = ComicData.act1,
    phase = PhaseOne,
    name = "repair"
  },
  -- {
  --   comic = ComicData.act2,
  --   phase = PhaseTwo,
  --   name = "forest"
  -- },
  -- {
  --   comic = ComicData.act3,
  --   phase = PhaseThree,
  --   name = "payload"
  -- },
  -- {
  --   comic = ComicData.act4,
  --   phase = BossFight,
  --   name = "boss fight"
  -- },
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

  local function startPhase (data)
    state.phase:Start(function()
      self:Next()
    end)
  end

  if state.comic then
    self:ShowComic(state.comic, startPhase)
  else
    startPhase({})
  end
end
