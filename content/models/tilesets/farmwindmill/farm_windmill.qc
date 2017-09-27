// Created by Crowbar 0.24.0.0

$modelname "props_skybox\farm_windmill.mdl"

$staticprop

$bodygroup "Body"
{
	studio "farm_windmill_reference.smd"
}


$cdmaterials "models\props_skybox\"

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "farm_windmill_anims\idle.smd" {
	fps 30
}

