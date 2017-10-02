// Created by Crowbar 0.24.0.0

$modelname "props_normandy\logpile_snow.mdl"

$staticprop

$bodygroup "Body"
{
	studio "logpile_snow_reference.smd"
}


$cdmaterials "models\props_normandy\"

$surfaceprop "wood_solid"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "logpile_snow_anims\idle.smd" {
	fps 30
	activity "act_idle" 1
}

$collisionmodel "logpile_snow_physics.smd"
{
	$mass 500
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

