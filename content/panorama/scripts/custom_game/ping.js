'use strict';

(function () {
  GameEvents.Subscribe("ping_minimap", PingMinimap);
}());

function PingMinimap (data) {
  GameUI.PingMinimapAtLocation(data.location)
}
