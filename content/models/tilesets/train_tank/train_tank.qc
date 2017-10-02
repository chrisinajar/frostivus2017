// Created by Crowbar 0.24.0.0

$modelname "props_vehicles\train_tank.mdl"

$staticprop

$bodygroup "Body"
{
	studio "train_tank_reference.smd"
}


$cdmaterials "models\props_vehicles\"

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "train_tank_anims\idle.smd" {
	fps 30
}

$collisionmodel "train_tank_physics.smd"
{
	$mass 1875.498
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

