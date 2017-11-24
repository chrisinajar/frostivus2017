-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

GAME_VERSION = "1.0.0"
CustomNetTables:SetTableValue("info", "version", { value = GAME_VERSION })
-- lets do this here too
local mode = ""
if IsInToolsMode() then
  mode = "Tools Mode"
elseif GameRules:IsCheatMode() then
  mode = "Cheat Mode"
end
CustomNetTables:SetTableValue("info", "mode", { value = mode })
CustomNetTables:SetTableValue("info", "datetime", { value = GetSystemDate() .. " " .. GetSystemTime() })

require('internal/vconsole')
require('internal/eventwrapper')

require('internal/util')
require('gamemode')
require('precache')
-- DotaStats
-- require("statcollection/init")

function Precache( context )
--[[
  This function is used to precache resources/units/items/abilities that will be needed
  for sure in your game and that will not be precached by hero selection.  When a hero
  is selected from the hero selection screen, the game will precache that hero's assets,
  any equipped cosmetics, and perform the data-driven precaching defined in that hero's
  precache{} block, as well as the precache{} block for any equipped abilities.

  See GameMode:PostLoadPrecache() in gamemode.lua for more information
  ]]

  DebugPrint("[BAREBONES] Performing pre-load precache")

  for _,Item in pairs( g_ItemPrecache ) do
    PrecacheItemByNameSync( Item, context )
  end

   for _,Unit in pairs( g_UnitPrecache ) do
    PrecacheUnitByNameAsync( Unit, function( unit ) end )
  end

   for _,Model in pairs( g_ModelPrecache ) do
    PrecacheResource( "model", Model, context  )
  end

  for _,Particle in pairs( g_ParticlePrecache ) do
    PrecacheResource( "particle", Particle, context  )
  end

  for _,ParticleFolder in pairs( g_ParticleFolderPrecache ) do
    PrecacheResource( "particle_folder", ParticleFolder, context )
  end

  for _,Sound in pairs( g_SoundPrecache ) do
    PrecacheResource( "soundfile", Sound, context )
  end
end

-- Create the game mode when we activate
function Activate()
  GameRules.GameMode = GameMode()
  GameRules.GameMode:_InitGameMode()
end
