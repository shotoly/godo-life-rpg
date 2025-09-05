# autoloads/GameData.gd
extends Node

# --- Signaux ---
signal arc_name_updated(arc_index, new_name)
signal player_stats_updated   # Signal pour mettre à jour l'UI en temps réel

# --- Données ---
var arc_names: Array[String] = []
var milestones_data: Array[Dictionary] = []
var player_data: Dictionary = {
	"name": "Aventurier",
	"xp": 0,
	"level": 1,
	"start_date": Time.get_datetime_string_from_system()
}

const SAVE_PATH = "user://gamedata.json"

func _ready():
	load_data()

# --- Fonctions Publiques ---
func update_arc_name(index: int, name: String):
	if index >= 0 and index < arc_names.size():
		arc_names[index] = name
		emit_signal("arc_name_updated", index, name)
		save_data()

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

# --- Gestion du joueur ---
func add_player_xp(amount: int):
	player_data["xp"] += amount
	
	var xp_needed_for_next_level = XpTable.get_xp_for_level(player_data["level"])
	while player_data["xp"] >= xp_needed_for_next_level:
		player_data["xp"] -= xp_needed_for_next_level
		player_data["level"] += 1
		xp_needed_for_next_level = XpTable.get_xp_for_level(player_data["level"])
	
	emit_signal("player_stats_updated")
	save_data()

# --- Sauvegarde et Chargement ---
func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data_to_save = {
			"arc_names": arc_names,
			"milestones": milestones_data,
			"player": player_data
		}
		file.store_string(JSON.stringify(data_to_save, "\t"))
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		arc_names = [
			"Arc I", "Arc II", "Arc III", "Arc IV",
			"Arc V", "Arc VI", "Arc VII", "Arc VIII",
			"Arc IX", "Arc X", "Arc XI", "Arc XII"
		]
		milestones_data.clear()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var loaded_data = JSON.parse_string(file.get_as_text())
		file.close()
		if loaded_data:
			# Charger les noms d’Arcs
			if loaded_data.has("arc_names"):
				var loaded_arc_names = loaded_data["arc_names"]
				if loaded_arc_names is Array:
					arc_names.clear()
					for item in loaded_arc_names:
						if typeof(item) == TYPE_STRING:
							arc_names.append(item)

			# Charger les milestones
			if loaded_data.has("milestones"):
				var loaded_milestones = loaded_data["milestones"]
				if loaded_milestones is Array:
					milestones_data.clear()
					for m in loaded_milestones:
						if m is Dictionary:
							milestones_data.append(m)

			# Charger les données du joueur
			if loaded_data.has("player"):
				var loaded_player = loaded_data["player"]
				if loaded_player is Dictionary:
					player_data = loaded_player
