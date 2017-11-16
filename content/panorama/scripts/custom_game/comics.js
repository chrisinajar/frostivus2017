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
  // $("#ComicBookOverlay").style.backgroundImage = 'file://{images}/custom_game/comics/' + comicData.image + '.png';
  // act1_1.png
  $("#ComicBookOverlay").Children().forEach(function (comicImage) {
    if (!comicImage.BHasClass('Comic')) {
      return
    }
    $.Msg(comicData.image + ': ' + comicImage.BHasClass(comicData.image))
    comicImage.style.visibility = comicImage.BHasClass(comicData.image) ? 'visible' : 'collapse';
    comicImage.SetScaling('stretch-to-fit-preserve-aspect')
  });

  $.Msg(comicData);
}
