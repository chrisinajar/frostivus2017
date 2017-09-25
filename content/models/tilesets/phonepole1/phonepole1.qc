// Created by Crowbar 0.24.0.0

$modelname "props_urban\phonepole1.mdl"

$staticprop

$bodygroup "Body"
{
	studio "phonepole1_reference.smd"
}


$cdmaterials "models\props_urban\"

$surfaceprop "wood"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "phonepole1_anims\idle.smd" {
	fps 30
}

$collisionmodel "phonepole1_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

