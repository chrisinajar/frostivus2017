// Created by Crowbar 0.24.0.0

$modelname "props_buildings/row_res_1.mdl"

$staticprop

$bodygroup "Body"
{
	studio "row_res_1_reference.smd"
}


$cdmaterials "models\props_buildings\"

$surfaceprop "concrete"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "row_res_1_anims\idle.smd" {
	fps 30
}

