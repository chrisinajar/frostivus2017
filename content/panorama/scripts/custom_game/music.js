/* global $, CustomNetTables */

var musicPlaying = true;
$.GetContextPanel().FindChildTraverse('ToggleMusic').AddClass('MusicOn');
CustomNetTables.SubscribeNetTableListener('music', SetMusic);
SetMusic(null, 'info', CustomNetTables.GetTableValue('music', 'info'));

function ToggleMusic () {
  if (musicPlaying) {
    musicPlaying = false;
    // TURN OFF MUSIC(VOLUME)
    $.GetContextPanel().FindChildTraverse('ToggleMusic').RemoveClass('MusicOn');
    $.GetContextPanel().FindChildTraverse('ToggleMusic').AddClass('MusicOff');
    GameEvents.SendCustomGameEventToServer('music_mute', {
      playerID: Players.GetLocalPlayer(),
      mute: 1
    });
  } else {
    musicPlaying = true;
    // TURN ON MUSIC(VOLUME)
    $.GetContextPanel().FindChildTraverse('ToggleMusic').RemoveClass('MusicOff');
    $.GetContextPanel().FindChildTraverse('ToggleMusic').AddClass('MusicOn');
    GameEvents.SendCustomGameEventToServer('music_mute', {
      playerID: Players.GetLocalPlayer(),
      mute: 0
    });
  }
}

function SetMusic (table, key, data) {
  $.Msg(data);
  if (!data) {
    return;
  }
  if (key === 'info') {
    $.GetContextPanel().FindChildTraverse('MusicTitle').text = data.title;
    $.GetContextPanel().FindChildTraverse('MusicSubTitle').text = 'by ' + data.subtitle;
  }
}

if (typeof module !== 'undefined' && module.exports) {
  module.exports = ToggleMusic;
}
