// Created by Crowbar 0.24.0.0

$modelname "props_street\firehydrant.mdl"

$staticprop

$bodygroup "Body"
{
	studio "firehydrant_reference.smd"
}


$cdmaterials "models\props_street\"

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "firehydrant_anims\idle.smd" {
	fps 30
}

$collisionmodel "firehydrant_physics.smd"
{
	$mass 10
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

