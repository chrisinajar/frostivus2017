// Created by Crowbar 0.24.0.0

$modelname "props_street\watertower01.mdl"

$staticprop

$bodygroup "Body"
{
	studio "watertower01_reference.smd"
}


$cdmaterials "models\props_street\"

$surfaceprop "default"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "watertower01_anims\idle.smd" {
	fps 30
}

$collisionmodel "watertower01_physics.smd"
{
	$mass 104924.8
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

