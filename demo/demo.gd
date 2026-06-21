extends Node2D
## EasySave Lite demo: move with arrow keys, collect gold with SPACE,
## then F5 = save, F9 = load, F8 = delete. Quit and reopen — your
## position and gold come back.

@onready var player: Node2D = $Player
@onready var info: Label = $UI/Info

const SPEED := 220.0


func _ready() -> void:
	# Player is in the "easy_save" group (set in the scene) and implements
	# _save_state/_load_state below, so EasySave persists it automatically.
	EasySave.saved.connect(func(): _flash("Saved"))
	EasySave.loaded.connect(func(): _flash("Loaded"))
	EasySave.load_failed.connect(func(reason): _flash("Load failed: %s" % reason))
	_refresh()


func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.position += dir * SPEED * delta
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):  # SPACE
		EasySave.set_value("gold", EasySave.get_value("gold", 0) + 1)
		_refresh()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F5:
				EasySave.save_game()
			KEY_F9:
				EasySave.load_game()
			KEY_F8:
				EasySave.delete_save()
				_flash("Deleted save")


func _refresh() -> void:
	info.text = "Gold: %d   Pos: (%d, %d)\n\nArrows = move   SPACE = +gold\nF5 = save   F9 = load   F8 = delete\n\nLite = 1 slot. PRO = slots + autosave + encryption." % [
		EasySave.get_value("gold", 0), int(player.position.x), int(player.position.y)
	]


func _flash(msg: String) -> void:
	print("[EasySave] ", msg)
