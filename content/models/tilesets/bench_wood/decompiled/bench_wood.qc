// Created by Crowbar 0.24.0.0

$modelname "props_urban\bench_wood.mdl"

$staticprop

$bodygroup "Body"
{
	studio "bench_wood_reference.smd"
}


$cdmaterials "models\props_urban\"

$surfaceprop "wood_plank"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "bench_wood_anims\idle.smd" {
	fps 30
	activity "act_idle" 1
}

$collisionmodel "bench_wood_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

