# autoloads/GameData.gd
extends Node

# On déclare le signal qui sera envoyé quand un nom est mis à jour
signal arc_name_updated(arc_index, new_name)

var arc_names: Array[String] = [
	"Arc I", "Arc II", "Arc III", "Arc IV", "Arc V", "Arc VI",
	"Arc VII", "Arc VIII", "Arc IX", "Arc X", "Arc XI", "Arc XII"
]

const SAVE_PATH = "user://gamedata.json"

func _ready():
	load_data()

# NOUVELLE FONCTION : C'est le seul moyen de modifier un nom d'Arc
func update_arc_name(index: int, name: String):
	if index >= 0 and index < arc_names.size():
		arc_names[index] = name
		# On envoie le signal pour prévenir tout le monde
		emit_signal("arc_name_updated", index, name)
		save_data()

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data_to_save = {"arc_names": arc_names}
		file.store_string(JSON.stringify(data_to_save, "\t"))
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var loaded_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if loaded_data and loaded_data.has("arc_names"):
			var loaded_array = loaded_data["arc_names"]
			if loaded_array is Array:
				arc_names = []
				for item in loaded_array:
					if typeof(item) == TYPE_STRING:
						arc_names.append(item)
