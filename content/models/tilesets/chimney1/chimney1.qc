// Created by Crowbar 0.24.0.0

$modelname "props_exteriors/chimney1.mdl"

$staticprop

$bodygroup "studio"
{
	studio "chimney1_reference.smd"
}


$cdmaterials "models\props_exteriors\"

$surfaceprop "concrete"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "chimney1_anims\idle.smd" {
	fps 30
}

