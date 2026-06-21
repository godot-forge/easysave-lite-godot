extends Node
## EasySave LITE — free drop-in save/load for Godot 4.
##
## Quick start:
##   1. Enable the plugin (Project > Project Settings > Plugins).
##   2. Add nodes you want persisted to the group "easy_save" and give each a
##      _save_state() -> Dictionary and _load_state(data: Dictionary) method.
##   3. Call EasySave.save_game() and EasySave.load_game() from anywhere.
##
## For data not tied to a node (gold, settings, story flags) use
## EasySave.set_value("gold", 100) / EasySave.get_value("gold", 0).
##
## ─────────────────────────────────────────────────────────────────────────
## This is the FREE Lite edition: single save slot, key/value + node groups.
## EasySave PRO adds: multiple save slots, automatic autosave, encrypted save
## files, and a list_saves() helper for building load-game menus — same API,
## just drop it in. Get it here:  https://godot-forge.itch.io/easysave-godot
## ─────────────────────────────────────────────────────────────────────────

signal saved
signal loaded
signal save_failed(reason: String)
signal load_failed(reason: String)

const GROUP := "easy_save"
const SAVE_DIR := "user://saves"
const SAVE_FILE := "slot_0.save"
const VERSION := 1

var _globals: Dictionary = {}


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


# --- Global key/value data (not tied to nodes) ----------------------------

func set_value(key: String, value: Variant) -> void:
	_globals[key] = value


func get_value(key: String, default: Variant = null) -> Variant:
	return _globals.get(key, default)


func has_value(key: String) -> bool:
	return _globals.has(key)


func erase_value(key: String) -> void:
	_globals.erase(key)


func clear_globals() -> void:
	_globals.clear()


# --- Save / Load (single slot in Lite) ------------------------------------

func save_game() -> bool:
	var payload := {
		"version": VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"globals": _globals.duplicate(true),
		"nodes": _collect_node_states(),
	}

	var path := _save_path()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var reason := "could not open file for writing: %s" % path
		push_error("EasySave: " + reason)
		save_failed.emit(reason)
		return false

	file.store_var(payload, false)
	file.close()
	saved.emit()
	return true


func load_game() -> bool:
	var path := _save_path()
	if not FileAccess.file_exists(path):
		var reason := "no save found"
		load_failed.emit(reason)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var reason := "could not open save file: %s" % path
		push_error("EasySave: " + reason)
		load_failed.emit(reason)
		return false

	var payload: Variant = file.get_var(false)
	file.close()

	if typeof(payload) != TYPE_DICTIONARY:
		var reason := "corrupted save file: %s" % path
		push_error("EasySave: " + reason)
		load_failed.emit(reason)
		return false

	_globals = payload.get("globals", {})
	_apply_node_states(payload.get("nodes", {}))
	loaded.emit()
	return true


func has_save() -> bool:
	return FileAccess.file_exists(_save_path())


func delete_save() -> void:
	var path := _save_path()
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


# --- Internals ------------------------------------------------------------

func _collect_node_states() -> Dictionary:
	var states: Dictionary = {}
	for node in get_tree().get_nodes_in_group(GROUP):
		if not node.has_method("_save_state"):
			push_warning("EasySave: node %s is in group but has no _save_state()" % node)
			continue
		var id := _node_id(node)
		if states.has(id):
			push_warning("EasySave: duplicate save id '%s' — overwriting" % id)
		states[id] = node._save_state()
	return states


func _apply_node_states(states: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group(GROUP):
		if not node.has_method("_load_state"):
			continue
		var id := _node_id(node)
		if states.has(id):
			node._load_state(states[id])


func _node_id(node: Node) -> String:
	if node.has_method("_save_id"):
		return str(node._save_id())
	return str(node.get_path())


func _save_path() -> String:
	return SAVE_DIR.path_join(SAVE_FILE)
