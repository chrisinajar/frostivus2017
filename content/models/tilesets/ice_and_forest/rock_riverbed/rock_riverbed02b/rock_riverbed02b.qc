// Created by Crowbar 0.24.0.0

$modelname "props_canal\rock_riverbed02b.mdl"

$staticprop

$bodygroup "Body"
{
	studio "rock_riverbed02b_reference.smd"
}


$cdmaterials "models\props_canal\"

$surfaceprop "boulder"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "rock_riverbed02b_anims\idle.smd" {
	fps 30
}

