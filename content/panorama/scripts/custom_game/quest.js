var ID = Players.GetLocalPlayer();
var playerHero = Players.GetPlayerSelectedHero(ID);

var currentAct = 1

CustomNetTables.SubscribeNetTableListener( "info", UpdateQuestHud);

function UpdateQuestHud(arg){
	var actInfo = CustomNetTables.GetTableValue( "info", "game_state" )
	var actProgress = actInfo["act_progress"]
	if(currentAct != actInfo["current_act"]){
		currentAct = actInfo["current_act"]
		$("#QuestObjectiveLabel").text =  $.Localize( "#QuestObjectiveTextAct"+currentAct, $("#QuestObjectiveLabel") );
	}
	if(actProgress != null){
		$("#QuestProgressLabel").SetDialogVariableInt( "objective", actProgress );
		$("#QuestProgressLabel").text =  $.Localize( "#QuestProgressTextAct"+currentAct, $("#QuestProgressLabel") );
	}
	$("#QuestProgressLabel").SetHasClass("Hidden", actProgress == null)
}


(function()
{
	var actInfo = CustomNetTables.GetTableValue( "info", "game_state" )
	currentAct = actInfo["current_act"] || 1
	var actProgress = actInfo["act_progress"] || 0
	$("#QuestObjectiveLabel").text =  $.Localize( "#QuestObjectiveTextAct"+currentAct, $("#QuestObjectiveLabel") );
	if(actProgress != null){
		$("#QuestProgressLabel").SetDialogVariableInt( "objective", actProgress );
		$("#QuestProgressLabel").text =  $.Localize( "#QuestProgressTextAct"+currentAct, $("#QuestProgressLabel") );
	} else {
		$("#QuestProgressLabel").SetHasClass("Hidden", actProgress != null)
	}
	
})();