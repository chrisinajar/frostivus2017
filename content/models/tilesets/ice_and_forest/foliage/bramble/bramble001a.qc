// Created by Crowbar 0.24.0.0

$modelname "props_foliage\bramble001a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "bramble001a_reference.smd"
}


$cdmaterials "models\props_foliage\"

$surfaceprop "wood"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "bramble001a_anims\idle.smd" {
	fps 30
}

