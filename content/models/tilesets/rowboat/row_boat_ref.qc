// Created by Crowbar 0.24.0.0

$modelname "props_swamp\row_boat_ref.mdl"

$staticprop

$bodygroup "Body"
{
	studio "row_boat_ref_reference.smd"
}


$cdmaterials "Models\props_swamp\"

$texturegroup "skinfamilies"
{
	{
		"row_boat_diffuse.vmt"
	}
	{
		"row_boat_diffuse2.vmt"
	}
	{
		"row_boat_diffuse3.vmt"
	}
}

$surfaceprop "wood"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "row_boat_ref_anims\idle.smd" {
	fps 15
	loop
}

