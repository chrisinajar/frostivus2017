Quests = Quests or class({})

QUESTS_ACT_GAMESTART = 0
QUESTS_ACT_ONE = 1
QUESTS_ACT_TWO = 2
QUESTS_ACT_THREE = 3
QUESTS_ACT_FOUR = 4
QUESTS_LAST_ACT = QUESTS_ACT_FOUR
DEFAULT_MAX_PROGRESS = 100

function Quests:Init()
   CustomNetTables:SetTableValue("game_state", "act_info", {})
   print("Quests have been initialized")
   self.currentAct = 0
   self.currentProgress = 0
   self.maxProgress = DEFAULT_MAX_PROGRESS
end


function Quests:NextAct(entryData)
  local internalTable = entryData or {}
  self.currentAct = internalTable.nextAct or math.min(QUESTS_LAST_ACT, self.currentAct + 1)
  local gameStateInfo = CustomNetTables:GetTableValue("game_state", "act_info") or {}
  if self.currentAct < QUESTS_ACT_THREE then
	  self.currentProgress = internalTable.initialProgress or 0
  else
    self.currentProgress = nil
  end
  self.maxProgress = internalTable.maxProgress or self.maxProgress
  gameStateInfo["current_act"] = self.currentAct
  gameStateInfo["act_progress"] = self.currentProgress
  gameStateInfo["max_progress"] = self.maxProgress

  Notifications:TopToAll({text="#Act" .. self.currentAct .. "Title", duration=10.0, style={["font-size"]="110px"}})
  Notifications:TopToAll({text="#Act" .. self.currentAct .. "SubTitle", duration=10.0})

  CustomNetTables:SetTableValue("game_state", "act_info", gameStateInfo)
end

function Quests:UpdateProgress(newVal)
  self.currentProgress = newVal
  local gameStateInfo = CustomNetTables:GetTableValue("game_state", "act_info") or {}
  gameStateInfo["act_progress"] = self.currentProgress
  CustomNetTables:SetTableValue("game_state", "act_info", gameStateInfo)
end

function Quests:ModifyProgress(amt)
  self.currentProgress = math.min(self.maxProgress, (self.currentProgress or 0) + amt)
  local gameStateInfo = CustomNetTables:GetTableValue("game_state", "act_info") or {}
  gameStateInfo["act_progress"] = self.currentProgress
  CustomNetTables:SetTableValue("game_state", "act_info", gameStateInfo)
end
