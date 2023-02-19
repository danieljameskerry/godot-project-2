extends Control
class_name SpeedController

onready var pauseButton = $ColorRect/Buttons/PauseButton
onready var playButton = $ColorRect/Buttons/PlayButton
onready var speedButton = $ColorRect/Buttons/SpeedButton
onready var current_button = playButton
onready var time_label = $ColorRect2/Label

var current_day: int = 0
var current_time: int = 0
var raid_warning_time = 270
var raid_start_time = 300
var raid_times = [[180, 210],[150,180],[90,120],[60,90]]

func _ready():
	pauseButton.connect("pressed", self, "on_button_pressed", [pauseButton])
	playButton.connect("pressed", self, "on_button_pressed", [playButton])
	speedButton.connect("pressed", self, "on_button_pressed", [speedButton])

func _on_clock_tick():
	current_time += 1
	time_label.set_text("Day "+ str(current_day + 1) + ": " + str(current_time / 60).pad_zeros(2) + ":" + str(current_time % 60).pad_zeros(2))
	if current_time == raid_warning_time:
		$ColorRect2/Label/AnimationPlayer.play("flash")
		Globals.game_world.generate_active_portals(current_day)
	if current_time == raid_start_time:
		$ColorRect2/Label/AnimationPlayer.play("RESET")
		$ColorRect2/Label/AnimationPlayer.stop()
		time_label.set_modulate(Color(1.0, 0.19, 0.19))
		time_label.set_text("RAID IN PROGRESS")
		Globals.game_world.enter_raid(current_day)
		return
	$Clock.start(1)

func next_day():
	if current_day == 3:
		return
	time_label.set_modulate(Color(1.0, 1.0, 1.0))
	current_time = 0
	raid_warning_time = raid_times[current_day][0]
	raid_start_time = raid_times[current_day][1]
	current_day += 1
	time_label.set_text("Day "+ str(current_day + 1) + ": 00:00")
	$Clock.start(1)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().set_input_as_handled()
		if current_button == pauseButton:
			on_button_pressed(playButton)
			return
		on_button_pressed(pauseButton)

func on_button_pressed(button: TextureButton):
	current_button.set_disabled(false)
	#if current_button == pauseButton:
		#get_tree().set_pause(false)
	current_button = button
	current_button.set_disabled(true)
	if current_button == pauseButton:
		MusicManager.button_back.play()
		Globals.adjust_speed(0)
		#get_tree().set_pause(true)
	elif current_button == playButton:
		MusicManager.play.play()
		if Globals.game_speed != 1:
			Globals.adjust_speed(1)
	elif current_button == speedButton:
		MusicManager.speed_up.play()
		if Globals.game_speed != 2:
			Globals.adjust_speed(2)
