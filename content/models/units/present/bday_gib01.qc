// Created by Crowbar 0.24.0.0

$modelname "effects/bday_gib01.mdl"

$bodygroup "Body"
{
	studio "bday_gib01_reference.smd"
}


$cdmaterials "models\effects\"

$texturegroup "skinfamilies"
{
	{
		"bday_gift01.vmt"
	}
	{
		"bday_gift01_blue.vmt"
	}
}

$surfaceprop "paper"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "polymsh" "" 0 0 0 1.570796 0 0 0 0 0 0 0 0




$sequence "idle" "bday_gib01_anims\idle.smd" {
	fps 30
}


$keyvalues
{
	prop_data 
	{
	}
	world_interactions 
	{
		"onworldimpact" "bloodsplat"
	}
}
