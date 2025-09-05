# autoloads/GameData.gd
extends Node

signal arc_name_updated(arc_index, new_name)
signal player_stats_updated
signal quest_list_updated

# --- Données ---
var arc_names: Array[String] = []
var milestones_data: Array[Dictionary] = []
var player_data: Dictionary = {
	"name": "Aventurier",
	"xp": 0,
	"level": 1,
	"start_date": ""
}
var quests_data: Array[Dictionary] = []

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
		if milestones_data[i].has("id") and milestones_data[i]["id"] == milestone_id:
			milestones_data[i][field] = value
			save_data()
			return

func add_player_xp(amount: int):
	player_data["xp"] += amount
	var xp_needed = XpTable.get_xp_for_level(int(player_data.get("level", 1)))
	while int(player_data["xp"]) >= xp_needed:
		player_data["xp"] = int(player_data["xp"]) - xp_needed
		player_data["level"] = int(player_data.get("level", 1)) + 1
		xp_needed = XpTable.get_xp_for_level(int(player_data["level"]))
	emit_signal("player_stats_updated")
	save_data()

func remove_player_xp(amount: int):
	player_data["xp"] = int(player_data.get("xp", 0)) - amount
	while int(player_data["xp"]) < 0:
		if int(player_data.get("level", 1)) <= 1:
			player_data["xp"] = 0
			break
		var prev_level := int(player_data["level"]) - 1
		var xp_for_previous_level = XpTable.get_xp_for_level(prev_level)
		player_data["level"] = prev_level
		player_data["xp"] = int(player_data["xp"]) + xp_for_previous_level
	emit_signal("player_stats_updated")
	save_data()

# --- Quêtes ---

func add_quest():
	var new_quest: Dictionary = {
		"id": Time.get_unix_time_from_system(),
		"arc_index": 0,
		"freq": "Journalière",
		"reps": 1,
		"intensity": 1,
		"desc": "Nouvelle quête...",
		"progress": 0,
		"total_xp": 0,
		"last_reset_day": Time.get_unix_time_from_system()
	}
	quests_data.append(new_quest)
	emit_signal("quest_list_updated")
	save_data()

func update_quest_data(quest_id: int, field: String, value):
	for i in range(quests_data.size()):
		if quests_data[i].has("id") and quests_data[i]["id"] == quest_id:
			quests_data[i][field] = value
			emit_signal("quest_list_updated")
			save_data()
			return

func delete_quest(quest_id: int):
	for i in range(quests_data.size()):
		if quests_data[i].has("id") and quests_data[i]["id"] == quest_id:
			quests_data.remove_at(i)
			emit_signal("quest_list_updated")
			save_data()
			return

# --- Sauvegarde et Chargement ---

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data_to_save = {
			"arc_names": arc_names,
			"milestones": milestones_data,
			"player": player_data,
			"quests": quests_data
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
		quests_data.clear()
		if not player_data.has("start_date") or String(player_data["start_date"]) == "":
			player_data["start_date"] = Time.get_datetime_string_from_system()
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var loaded_data = JSON.parse_string(file.get_as_text())
		file.close()

		if loaded_data is Dictionary:
			# Arc names → Array[String]
			if loaded_data.has("arc_names"):
				var loaded_arc_names = loaded_data["arc_names"]
				if loaded_arc_names is Array:
					arc_names.clear()
					for item in loaded_arc_names:
						if typeof(item) == TYPE_STRING:
							arc_names.append(item)

			# Milestones → Array[Dictionary]
			if loaded_data.has("milestones"):
				var loaded_milestones = loaded_data["milestones"]
				if loaded_milestones is Array:
					milestones_data.clear()
					for m in loaded_milestones:
						if m is Dictionary:
							milestones_data.append(m)

			# Quests → Array[Dictionary]
			if loaded_data.has("quests"):
				var loaded_quests = loaded_data["quests"]
				if loaded_quests is Array:
					quests_data.clear()
					for q in loaded_quests:
						if q is Dictionary:
							quests_data.append(q)

			# Player → Dictionary
			if loaded_data.has("player"):
				var loaded_player = loaded_data["player"]
				if loaded_player is Dictionary:
					player_data = loaded_player

			# Sécurité: s'assurer d'avoir une date de départ
			if not player_data.has("start_date") or String(player_data["start_date"]) == "":
				player_data["start_date"] = Time.get_datetime_string_from_system()
