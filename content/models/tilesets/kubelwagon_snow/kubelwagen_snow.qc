// Created by Crowbar 0.24.0.0

$modelname "props_vehicles\kubelwagen_snow.mdl"

$staticprop

$bodygroup "Body"
{
	studio "kubelwagen_snow_reference.smd"
}


$cdmaterials "models\props_vehicles\"

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "kubelwagen_snow_anims\idle.smd" {
	fps 30
}

$collisionmodel "kubelwagen_snow_physics.smd"
{
	$mass 5000
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}

