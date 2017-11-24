
'use strict';

(function () {
  GameEvents.Subscribe("toggle_boss_bar", ToggleBossBar);
  GameEvents.Subscribe("update_boss_bar", UpdateBossBar);
}());

function ToggleBossBar (data) {
  $("#BossBar").SetHasClass("Visible", data.showBossBar);
}

function UpdateBossBar (data) {
  $("#BossProgressBar").value = data.bossHP / data.bossMaxHP;
  $("#BossHPLabel").text = data.bossHP + "/" + data.bossMaxHP;
}
