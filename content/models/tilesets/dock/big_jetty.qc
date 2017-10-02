// Created by Crowbar 0.24.0.0

$modelname "props_swamp\big_jetty.mdl"

$staticprop

$bodygroup "mybody"
{
	studio "big_jetty_reference.smd"
}


$cdmaterials "models\props_swamp\"

$surfaceprop "wood"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "big_jetty_anims\idle.smd" {
	fps 15
	loop
}

