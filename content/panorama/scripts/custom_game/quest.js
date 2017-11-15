var ID = Players.GetLocalPlayer();
var playerHero = Players.GetPlayerSelectedHero(ID);

var currentAct = 1

CustomNetTables.SubscribeNetTableListener( "game_state", UpdateQuestHud);

function UpdateQuestHud(arg){
	var actInfo = CustomNetTables.GetTableValue( "game_state", "act_info" );
	
	$.Msg(actInfo)
	if(actInfo != null){
		var actProgress = actInfo["act_progress"];
		var maxProgress = actInfo["max_progress"];
		if(currentAct != actInfo["current_act"]){
			currentAct = actInfo["current_act"];
			$("#QuestObjectiveLabel").text =  $.Localize( "#QuestObjectiveTextAct"+currentAct, $("#QuestObjectiveLabel") );
		}
		if(actProgress != null){
			$("#QuestProgressLabel").SetDialogVariableInt( "objective", actProgress );
			if(maxProgress != null){$("#QuestProgressLabel").SetDialogVariableInt( "maxObjective", maxProgress );}
			
			$("#QuestProgressLabel").text =  $.Localize( "#QuestProgressTextAct"+currentAct, $("#QuestProgressLabel") );
		}
		$("#QuestProgressLabel").SetHasClass("Hidden", actProgress == null);
	}
}


(function()
{
	var actInfo = CustomNetTables.GetTableValue( "game_state", "act_info" ) || {};
	if(actInfo != null){
		currentAct = actInfo["current_act"] || 1;
		var actProgress = actInfo["act_progress"] || 0;
    var maxProgress = actInfo["max_progress"];
		$("#QuestObjectiveLabel").text =  $.Localize( "#QuestObjectiveTextAct"+currentAct, $("#QuestObjectiveLabel") );
		if(actProgress != null){
			$("#QuestProgressLabel").SetDialogVariableInt( "objective", actProgress );
      if(maxProgress != null){$("#QuestProgressLabel").SetDialogVariableInt( "maxObjective", maxProgress );}
			$("#QuestProgressLabel").text =  $.Localize( "#QuestProgressTextAct"+currentAct, $("#QuestProgressLabel") );
		} else {
			$("#QuestProgressLabel").SetHasClass("Hidden", actProgress != null)
		}
	}
})();
