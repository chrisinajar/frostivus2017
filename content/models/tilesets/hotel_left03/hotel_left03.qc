// Created by Crowbar 0.24.0.0

$modelname "facade_germany\hotel_left03.mdl"

$staticprop

$bodygroup "Body"
{
	studio "hotel_left03_reference.smd"
}


$cdmaterials "models\facade_germany\"

$surfaceprop "stone"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "hotel_left03_anims\idle.smd" {
	fps 30
}

$collisionmodel "hotel_left03_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

