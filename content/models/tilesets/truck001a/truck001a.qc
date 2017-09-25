// Created by Crowbar 0.24.0.0

$modelname "props_vehicles/truck001a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "truck001a_reference.smd"
}


$cdmaterials "models\props_vehicles\"

$texturegroup "skinfamilies"
{
	{
		"truck001c_01.vmt"
	}
	{
		"truck001c_02.vmt"
	}
}

$surfaceprop "metalvehicle"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "truck001a_anims\idle.smd" {
	fps 30
}

$collisionmodel "truck001a_physics.smd"
{
	$mass 5000
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

