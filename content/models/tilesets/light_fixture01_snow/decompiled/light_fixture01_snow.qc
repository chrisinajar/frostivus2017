// Created by Crowbar 0.24.0.0

$modelname "props_urban\light_fixture01_snow.mdl"

$staticprop

$bodygroup "Body"
{
	studio "light_fixture01_snow_reference.smd"
}


$cdmaterials "models\props_urban\"

$texturegroup "skinfamilies"
{
	{
		"light_fixture01.vmt"
	}
	{
		"light_fixture01_on.vmt"
	}
}

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "light_fixture01_snow_anims\idle.smd" {
	fps 30
}

$collisionmodel "light_fixture01_snow_physics.smd"
{
	$mass 300
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

