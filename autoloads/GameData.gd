# autoloads/GameData.gd
extends Node

signal arc_name_updated(arc_index, new_name)

var arc_names: Array[String] = []
var milestones_data: Array[Dictionary] = []   # tableau typé

const SAVE_PATH = "user://gamedata.json"

func _ready():
	load_data()

func update_arc_name(index: int, name: String):
	if index >= 0 and index < arc_names.size():
		arc_names[index] = name
		emit_signal("arc_name_updated", index, name)
		save_data()

# --- Fonctions pour les Paliers (Milestones) ---
func add_milestone(arc_index: int):
	var new_milestone: Dictionary = {
		"id": Time.get_unix_time_from_system(),
		"arc_index": arc_index,
		"description": "Nouveau palier...",
		"difficulty": 1,
		"completed": false
	}
	milestones_data.append(new_milestone)
	save_data()

func update_milestone_data(milestone_id: int, field: String, value):
	for i in range(milestones_data.size()):
		if milestones_data[i]["id"] == milestone_id:
			milestones_data[i][field] = value
			save_data()
			return

# --- Sauvegarde et Chargement ---
func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data_to_save = {
			"arc_names": arc_names,
			"milestones": milestones_data
		}
		file.store_string(JSON.stringify(data_to_save, "\t"))
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		arc_names = [
			"Arc I","Arc II","Arc III","Arc IV","Arc V","Arc VI",
			"Arc VII","Arc VIII","Arc IX","Arc X","Arc XI","Arc XII"
		]
		milestones_data.clear()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var loaded_data = JSON.parse_string(file.get_as_text())
		file.close()

		if loaded_data:
			# Chargement des noms d’Arcs
			if loaded_data.has("arc_names"):
				var loaded_arc_names = loaded_data["arc_names"]
				if loaded_arc_names is Array:
					arc_names.clear()
					for item in loaded_arc_names:
						if typeof(item) == TYPE_STRING:
							arc_names.append(item)

			# Chargement des paliers
			if loaded_data.has("milestones"):
				var loaded_milestones = loaded_data["milestones"]
				if loaded_milestones is Array:
					milestones_data.clear()
					for m in loaded_milestones:
						if m is Dictionary:
							milestones_data.append(m)
