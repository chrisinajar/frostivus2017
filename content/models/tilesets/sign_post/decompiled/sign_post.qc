// Created by Crowbar 0.24.0.0

$modelname "props_downtown/sign_post.mdl"

$staticprop

$bodygroup "body"
{
	studio "sign_post_reference.smd"
}


$cdmaterials "models\props_downtown\"

$surfaceprop "metal"

$contents "solid"


// NOTE: The following commented-out $definebone lines might be needed, as is often the case for view models. When needed, simply remove the two slashes '//' from the start of each line.
// $definebone "static_prop" "" 0 0 0 0 0 0 0 0 0 0 0 0




$sequence "ref" "sign_post_anims\ref.smd" {
	fps 30
}

$collisionmodel "sign_post_physics.smd"
{
	$mass 8.865515
	$inertia 1
	$damping 0
	$rotdamping 1
	$concave

}

