// Created by Crowbar 0.24.0.0

$modelname "props_misc/well-1.mdl"

$staticprop

$bodygroup "studio"
{
	studio "well-1_reference.smd"
}


$cdmaterials "models\props_misc\"

$surfaceprop "default"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "well-1_anims\idle.smd" {
	fps 15
	loop
}

$collisionmodel "well-1_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

