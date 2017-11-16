(function () {
  CustomNetTables.SubscribeNetTableListener("comics", OnTableChange);
  OnTableChange();
}());

function OnTableChange(arg) {
  var comicData = CustomNetTables.GetTableValue("comics", "state");
  if (!comicData) {
    return;
  }
  UpdateComic(comicData);
}

function UpdateComic(comicData) {
  if (comicData.shown !== 1) {
    $("#ComicBookOverlay").SetHasClass('Shown', false);
    return;
  }
  $("#ComicBookOverlay").SetHasClass('Shown', true);
  $("#SkipPanel").style.visibility = !comicData.isSplashing ? 'visible' : 'collapse';
  $("#ComicBookOverlay").Children().forEach(function (comicImage) {
    if (!comicImage.BHasClass('Comic')) {
      return
    }
    comicImage.style.visibility = comicImage.BHasClass(comicData.image) ? 'visible' : 'collapse';
    comicImage.SetScaling('stretch-to-fit-preserve-aspect')
  });

  $("#SkipVoteLabel").text = comicData.votes + '/' + comicData.maxVotes;
}

function VoteToSkip () {
  GameEvents.SendCustomGameEventToServer('vote_skip', {
    playerId: Players.GetLocalPlayer(),
  });
}
