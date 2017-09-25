// Created by Crowbar 0.24.0.0

$modelname "props_skybox/italian_house01.mdl"

$staticprop

$bodygroup "studio"
{
	studio "italian_house01_reference.smd"
}


$cdmaterials "models\props_skybox\"

$surfaceprop "default"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "italian_house01_anims\idle.smd" {
	fps 15
	loop
}

// The PHY file's checksum value is not the same as the MDL file's checksum value.
$collisionmodel "italian_house01_physics.smd"
{
	$mass 1
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

