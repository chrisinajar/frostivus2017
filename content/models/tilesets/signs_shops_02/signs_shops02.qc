// Created by Crowbar 0.24.0.0

$modelname "props_urban\signs_shops02.mdl"

$staticprop

$bodygroup "Body"
{
	studio "signs_shops02_reference.smd"
}


$cdmaterials "models\props_urban\"

$texturegroup "skinfamilies"
{
	{
		"signs_shops.vmt"
	}
	{
		"signs_shops_01.vmt"
	}
	{
		"signs_shops_02.vmt"
	}
}

$surfaceprop "wood"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "signs_shops02_anims\idle.smd" {
	fps 30
}

$collisionmodel "signs_shops02_physics.smd"
{
	$mass 300
	$inertia 1
	$damping 0
	$rotdamping 0
	$concave

}


$keyvalues
{
	prop_data 
	{
		"base" "Wooden.Medium"
		"dmg.bullets" "0.05"
	}
}
