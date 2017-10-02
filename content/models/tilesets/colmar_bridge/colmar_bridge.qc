// Created by Crowbar 0.24.0.0

$modelname "props_exteriors\colmar_bridge.mdl"

$staticprop

$bodygroup "Body"
{
	studio "colmar_bridge_reference.smd"
}


$cdmaterials "models\props_exteriors\"

$surfaceprop "stone"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "colmar_bridge_anims\idle.smd" {
	fps 30
}

