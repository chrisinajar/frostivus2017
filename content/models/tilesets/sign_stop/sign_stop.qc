// Created by Crowbar 0.24.0.0

$modelname "props_downtown/sign_stop.mdl"

$staticprop

$bodygroup "Body"
{
	studio "sign_stop_reference.smd"
}


$cdmaterials ""

$surfaceprop "Metal_Box"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "sign_stop_anims\idle.smd" {
	fps 30
}

$collisionmodel "sign_stop_physics.smd"
{
	$mass 5.944331
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

