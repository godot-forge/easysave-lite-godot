# EasySave Lite — drop-in Save & Load for Godot 4 (free)

Save and load your Godot 4 game with **two lines of code**. No boilerplate.

```gdscript
EasySave.set_value("gold", 100)
EasySave.save_game()      # writes to user://saves/slot_0.save

# ...later, or on next launch:
EasySave.load_game()
print(EasySave.get_value("gold"))   # 100
```

Any node can persist itself automatically — just add it to the `easy_save`
group and give it `_save_state()` / `_load_state()`:

```gdscript
func _save_state() -> Dictionary:
    return {"x": position.x, "y": position.y}

func _load_state(data: Dictionary) -> void:
    position = Vector2(data.x, data.y)
```

That's it. Run the included demo (`demo/demo.tscn`): move with the arrow keys,
press SPACE for gold, **F5** to save, **F9** to load, **F8** to delete.

## Install
1. Copy the `addons/easy_save` folder into your project.
2. Enable **EasySave Lite** in *Project → Project Settings → Plugins*.
3. Call `EasySave.save_game()` / `EasySave.load_game()` from anywhere.

## Lite vs PRO

| Feature | Lite (free) | **PRO** |
|---|:---:|:---:|
| Key/value save data | ✅ | ✅ |
| Auto node-group persistence | ✅ | ✅ |
| Save / load / delete | ✅ | ✅ |
| **Multiple save slots** | — | ✅ |
| **Automatic autosave (timer)** | — | ✅ |
| **Encrypted save files** | — | ✅ |
| **`list_saves()` for load menus** | — | ✅ |

PRO is the same API — just drop it in. **Get EasySave PRO:**
👉 https://godot-forge.itch.io/easysave-godot

## License
MIT — free for commercial and personal projects. See `LICENSE.txt`.

Made by **GodotForge** · more Godot tools: https://godot-forge.itch.io
