extends Node2D

func heads_up():
	$HeadsUpArrow.set_visible(true)
	$AnimationPlayer.play("HeadsUp")

func activate():
	$HeadsUpArrow.set_visible(false)
	$AnimationPlayer.play("Active")

func deactivate():
	$AnimationPlayer.play("Inactive")
