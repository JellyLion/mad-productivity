extends Control

signal toggle_time_tracking_bar(really)

var dragging : = false
var mouse_drag_beg : Vector2
var orig_position : Vector2
var drag_amount : Vector2

var initial_mouse_pos : Vector2

var maximized : bool = false
var minimized_size : Vector2
var minimized_pos : Vector2

func _ready() -> void:
	Defaults.connect("view_changed", self, "on_view_changed")
	Defaults.connect("theme_changed", self, "on_theme_changed")

	on_theme_changed()
	set_process_input(false)
	var res = load(Defaults.TIMETRACKS_SAVE_PATH + Defaults.TIMETRACKS_SAVE_NAME)	# TODO: access this resource in some more elegant way
#	$Right/Maximize.pressed = Defaults.settings_res.window_maximized
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		drag_amount += event.relative
	OS.window_position.x = clamp(drag_amount.x - orig_position.x, 0, OS.get_screen_size().x - OS.window_size.x)
	OS.window_position.y = clamp(drag_amount.y - orig_position.y, 0, OS.get_screen_size().y - OS.window_size.y)


func _on_TopArea_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true

			if OS.window_maximized:
				OS.window_maximized = false
				OS.window_size = Vector2(1100, 700)
				OS.window_position.y = 0
				$Right/Maximize.pressed = false

#			mouse_drag_beg = get_viewport().get_mouse_position()
			orig_position = get_viewport().get_mouse_position() - OS.window_position
			drag_amount = get_viewport().get_mouse_position()
#			print(get_global_mouse_position())
#			initial_mouse_pos = get_local_mouse_position()
			initial_mouse_pos = get_global_mouse_position()
			Input.set_mouse_mode(2)


			set_process_input(true)
		else:
			dragging = false
			set_process_input(false)
			Input.set_mouse_mode(0)
			Input.warp_mouse_position(initial_mouse_pos)


func _on_Minimuze_pressed() -> void:
	OS.window_minimized = true


func _on_Exit_pressed() -> void:
	Defaults.quit()


func _on_Maximize_toggled(button_pressed: bool) -> void:
	if button_pressed:
		Defaults.settings_res.minimized_window_size = OS.window_size
		Defaults.settings_res.minimized_window_position = OS.window_position
		Defaults.settings_res.window_maximized = true
		Defaults.save_settings_resource()
		OS.window_maximized = button_pressed
	else:
		OS.window_maximized = false
		Defaults.settings_res.window_maximized = false
		OS.window_size = Defaults.settings_res.minimized_window_size
		OS.window_position = Defaults.settings_res.minimized_window_position
		Defaults.save_settings_resource()
		

func change_window_title(_name : String) -> void:
	$ViewLabel.text = _name
#	$Tween.stop_all()
#	$Tween.interpolate_property($Right/ViewLabel, "percent_visible", $Right/ViewLabel.percent_visible, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.0)
#	$Tween.interpolate_property($Right/ViewLabel, "percent_visible", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
#	$Tween.start()
#	yield(get_tree().create_timer(0.5), "timeout")
#	$Right/ViewLabel.text = _name 


# IMPORTANT: This func sets up the top area according to how to the new view
func on_view_changed(_name : String, _button : bool, _input_field : bool) -> void:
	change_window_title(_name)
	if _name == "Time tracking":
		$Left/NewBtn.hide()
		$Left/LineEdit.hide()
	else:
		$Left/LineEdit.visible = _input_field
		$Left/NewBtn.visible = _button


func _on_Button_pressed() -> void:
	if Defaults.active_view_pointer and Defaults.active_view_pointer.has_method("on_new_top_bar_button"):
		var message : Dictionary = {}
		if $Left/LineEdit.text != "":
			message.text = $Left/LineEdit.text
			$Left/LineEdit.clear()
		Defaults.active_view_pointer.on_new_top_bar_button(message)


func _on_Shortcuts_shortcut_use() -> void:
	_on_Button_pressed()


func _on_Shortcuts_shortcut_focus() -> void:
	if $Left/LineEdit.visible:
		$Left/LineEdit.grab_focus()


func on_theme_changed() -> void:
	$Left/TimeTrackPanel.update_colours()


func _on_TimeTrackPanel_toggled(button_pressed: bool) -> void:
	emit_signal("toggle_time_tracking_bar", button_pressed)


func _on_Shortcuts_shortcut_timetrack_panel() -> void:
	$Left/TimeTrackPanel.pressed = !$Left/TimeTrackPanel.pressed
