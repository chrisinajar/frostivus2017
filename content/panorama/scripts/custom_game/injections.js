
'use strict';

(function () {
  InjectPickscreenMinimap();
}());

function InjectPickscreenMinimap() {
  var pickMinimapContainer = FindDotaHudElement('PreMinimapContainer');
  var pickMinimap = pickMinimapContainer.FindChildTraverse('HeroPickMinimap');

  pickMinimap.enabled = false;
  pickMinimap.visible = false;

  var newMinimap = $.CreatePanel("Panel", pickMinimapContainer, "newHeroPickMinimap")
  newMinimap.BLoadLayout("file://{resources}/layout/custom_game/injections/pickscreen_minimap.xml", false, false);
}
