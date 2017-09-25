// Created by Crowbar 0.24.0.0

$modelname "props_misc\bollard_snow.mdl"

$staticprop

$bodygroup "Body"
{
	studio "bollard_snow_reference.smd"
}


$cdmaterials "models\props_misc\"

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "bollard_snow_anims\idle.smd" {
	fps 30
}

$collisionmodel "bollard_snow_physics.smd"
{
	$mass 900
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

