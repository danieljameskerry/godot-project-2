extends Node2D
class_name MainMenu

func _process(delta):
	$ParallaxBackground.scroll_offset.x += 50 * delta

func open_options():
	MusicManager.button_forward.play()
	$CanvasLayer/Main.hide()
	$CanvasLayer/Options.show()

func close_options():
	MusicManager.button_back.play()
	$CanvasLayer/Options.hide()
	$CanvasLayer/Main.show()


func start():
	MusicManager.button_forward.play()
	$CanvasLayer/Main.hide()
	$WorldMenu.set_visible(true)
	$WorldMenu/CanvasLayer.show()


func exit():
	MusicManager.menu_music.stop()
	MusicManager.start.play()
	yield(MusicManager.start, "finished")
	get_tree().quit()


func goto_main():
	MusicManager.button_back.play()
	$WorldMenu.set_visible(false)
	$WorldMenu/CanvasLayer.hide()
	$CanvasLayer/Main.show()

func change_music_vol(value: float):
	MusicManager.change_music_vol(value)

func change_sfx_vol(value: float):
	MusicManager.change_sfx_vol(value)
