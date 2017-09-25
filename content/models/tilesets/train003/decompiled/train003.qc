// Created by Crowbar 0.24.0.0

$modelname "props_trainstation\train003.mdl"

$staticprop

$bodygroup "Body"
{
	studio "train003_reference.smd"
}


$cdmaterials "models\props_trainstation\"

$surfaceprop "metalvehicle"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "train003_anims\idle.smd" {
	fps 30
}

$collisionmodel "train003_physics.smd"
{
	$mass 2000
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

