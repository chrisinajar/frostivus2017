// Created by Crowbar 0.24.0.0

$modelname "props_normandy\mill_water_wheel.mdl"

$staticprop

$bodygroup "Body"
{
	studio "mill_water_wheel_reference.smd"
}


$cdmaterials "models\props_normandy\"

$surfaceprop "wood"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "mill_water_wheel_anims\idle.smd" {
	fps 30
	activity "act_idle" 1
}

