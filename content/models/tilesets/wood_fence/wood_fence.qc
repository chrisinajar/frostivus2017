// Created by Crowbar 0.24.0.0

$modelname "props_urban\wood_fence.mdl"

$staticprop

$bodygroup "Body"
{
	studio "wood_fence_reference.smd"
}


$cdmaterials "models\props_urban\"

$surfaceprop "wood_solid"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "wood_fence_anims\idle.smd" {
	fps 30
	activity "act_idle" 1
}

$collisionmodel "wood_fence_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

