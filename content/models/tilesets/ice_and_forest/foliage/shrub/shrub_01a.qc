// Created by Crowbar 0.24.0.0

$modelname "props_foliage/shrub_01a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "shrub_01a_reference.smd"
}


$cdmaterials "models\props_foliage\"

$surfaceprop "foliage"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "shrub_01a_anims\idle.smd" {
	fps 30
}

