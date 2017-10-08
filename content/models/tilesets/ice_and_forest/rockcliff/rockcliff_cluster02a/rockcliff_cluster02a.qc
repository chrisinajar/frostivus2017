// Created by Crowbar 0.24.0.0

$modelname "props_wasteland\rockcliff_cluster02a.mdl"

$staticprop

$bodygroup "Body"
{
	studio "rockcliff_cluster02a_reference.smd"
}


$cdmaterials "models\props_wasteland\"

$texturegroup "skinfamilies"
{
	{
		"rockcliff02a.vmt"
	}
	{
		"rockcliff02b.vmt"
	}
}

$surfaceprop "boulder"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "idle" "rockcliff_cluster02a_anims\idle.smd" {
	fps 30
}

