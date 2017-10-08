// Created by Crowbar 0.24.0.0

$modelname "props_foliage/tree_cliff_02a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "tree_cliff_02a_reference.smd"
}


$cdmaterials "models\props_foliage\"

$texturegroup "skinfamilies"
{
	{
		"tree_deciduous_01a_branches.vmt"
	}
	{
		"tree_deciduous_01a_leaves.vmt"
	}
}

$surfaceprop "wood_solid"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "tree_cliff_02a_anims\idle.smd" {
	fps 30
}

