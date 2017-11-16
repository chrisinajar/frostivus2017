Debug.EnabledModules['comics:manager'] = true

ComicManager = ComicManager or class({})

function ComicManager:Init()
  self.votes = {}
  self.state = {}
  self.isSplashing = true
  self:ShowSlide('splash')
  self:VoteSkip()
  CustomGameEventManager:RegisterListener("vote_skip", function (num, keys)
    DebugPrint('Number is ' .. num)
    DebugPrintTable(keys)
    self:VoteSkip(keys)
  end)
end

function ComicManager:Show(comicData, callback)
  if not self.hasSplashed then
    self:ShowSlide('splash')
    self.hasSplashed = true
    Timers:CreateTimer(2, function()
      self.isSplashing = false
      self:Show(comicData, callback)
    end)
    return
  end
  -- show comic, callback when it's done
  -- it either ends when the comic is over or when all users click skip
  self.callback = callback
  self.running = true
  local currentIndex = 0
  self:ClearVotes()
  Timers:CreateTimer(function()
    if not self.running then
      return
    end
    currentIndex = currentIndex + 1
    if not comicData[currentIndex] then
      self:EndComic()
      return
    end
    self:ShowSlide(comicData[currentIndex].image)
    return comicData[currentIndex].duration
  end)
end

function ComicManager:VoteSkip(keys)
  if keys then
    self.votes[keys.playerId] = true
  end
  local function checkVote (count, playerId)
    if self.votes[playerId] then
      return count + 1
    end
    return count
  end
  local allPlayerIDs = PlayerResource:GetAllTeamPlayerIDs()
  local totalPlayers = allPlayerIDs:length()
  local totalVotes = foldl(checkVote, 0, allPlayerIDs)
  self.state.votes = totalVotes
  self.state.maxVotes = totalPlayers

  self:UpdateState()

  if totalVotes == totalPlayers and not self.isSplashing then
    self:EndComic()
  end
end

function ComicManager:ClearVotes ()
  local function disableVote (playerId)
    self.votes[playerId] = false
  end
  each(disableVote, PlayerResource:GetAllTeamPlayerIDs())
  self.state.votes = 0
end

function ComicManager:EndComic()
  self.running = false
  self:Hide()
  if self.callback then
    self.callback({})
    self.callback = nil
  end
end

function ComicManager:Hide ()
  self.state.shown = false
  self:UpdateState()
end

function ComicManager:ShowSlide (image)
  DebugPrint('Showing slide: ' .. image)
  self.state.shown = true
  self.state.image = image
  self:UpdateState()
end

function ComicManager:UpdateState()
  self.state.isSplashing = self.isSplashing
  CustomNetTables:SetTableValue("comics", "state", self.state)
end
