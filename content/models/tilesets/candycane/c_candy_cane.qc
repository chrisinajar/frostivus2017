// Created by Crowbar 0.24.0.0

$modelname "weapons\c_models\c_candy_cane\c_candy_cane.mdl"

$bodygroup "Body"
{
	studio "c_candy_cane_reference.smd"
}


$cdmaterials "\models\weapons\c_items\"
$cdmaterials ""

$texturegroup "skinfamilies"
{
	{
		"models\weapons\c_items\c_candy_cane_red.vmt"
		"models\weapons\c_items\c_candy_cane_bow_red.vmt"
	}
	{
		"c_candy_cane_blue.vmt"
		"c_candy_cane_bow_blue.vmt"
	}
}

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "weapon_bone" "" 0 0 0 0 0.256318 0 0 0 0 0 0 0




$sequence "idle" "c_candy_cane_anims\idle.smd" {
	fps 30
}

