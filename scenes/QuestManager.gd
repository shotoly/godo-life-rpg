# QuestManager.gd - Version 2.2, syntaxe garantie correcte
class_name QuestManager

var quests: Array[Dictionary] = []
var quest_container: GridContainer

func _init(container: GridContainer):
	self.quest_container = container

func add_quest_row():
	var new_quest_data = {
		"id": Time.get_unix_time_from_system(), 
		"arc": "Arc I", "freq": "Journalière", "reps": 1, "intensity": 1,
		"desc": "", "xp": 0, "fails": 0
	}
	quests.append(new_quest_data)
	_create_quest_row_ui(new_quest_data)
	save_quests()

func _create_quest_row_ui(quest_data: Dictionary):
	var arc_select = OptionButton.new()
	for arc_name in ["Arc I", "Arc II", "Arc III", "Arc IV", "Arc V", "Arc VI", "Arc VII", "Arc VIII", "Arc IX", "Arc X", "Arc XI", "Arc XII"]:
		arc_select.add_item(arc_name)
	select_item_by_text(arc_select, quest_data.get("arc", "Arc I"))

	var freq_select = OptionButton.new()
	for f in ["Journalière", "Hebdomadaire", "Mensuelle", "Annuelle", "Unique"]:
		freq_select.add_item(f)
	select_item_by_text(freq_select, quest_data.get("freq", "Journalière"))

	var reps_input = SpinBox.new(); reps_input.min_value = 1; reps_input.max_value = 10; reps_input.value = quest_data.get("reps", 1)
	var intensity_input = SpinBox.new(); intensity_input.min_value = 1; intensity_input.max_value = 3; intensity_input.value = quest_data.get("intensity", 1)
	var desc_input = LineEdit.new(); desc_input.text = quest_data.get("desc", "")
	var xp_label = Label.new()
	var fails_input = SpinBox.new(); fails_input.min_value = 0; fails_input.max_value = 10; fails_input.value = quest_data.get("fails", 0)

	quest_container.add_child(arc_select)
	quest_container.add_child(freq_select)
	quest_container.add_child(reps_input)
	quest_container.add_child(intensity_input)
	quest_container.add_child(desc_input)
	quest_container.add_child(xp_label)
	quest_container.add_child(fails_input)

	var quest_id = quest_data["id"]
	arc_select.item_selected.connect(_on_quest_data_changed.bind(quest_id, "arc", arc_select, xp_label))
	freq_select.item_selected.connect(_on_quest_data_changed.bind(quest_id, "freq", freq_select, xp_label))
	reps_input.value_changed.connect(_on_quest_data_changed.bind(quest_id, "reps", null, xp_label))
	intensity_input.value_changed.connect(_on_quest_data_changed.bind(quest_id, "intensity", null, xp_label))
	desc_input.text_changed.connect(_on_quest_data_changed.bind(quest_id, "desc", null, xp_label))
	fails_input.value_changed.connect(_on_quest_data_changed.bind(quest_id, "fails", null, xp_label))

	_update_row_xp(quest_data, xp_label)

func _on_quest_data_changed(new_value, quest_id: int, field_to_change: String, control_node, xp_label: Label):
	var quest_index = -1
	for i in range(quests.size()):
		if quests[i]["id"] == quest_id:
			quest_index = i
			break
	
	if quest_index == -1:
		return

	var final_value
	match field_to_change:
		"arc", "freq":
			if control_node:
				final_value = control_node.get_item_text(new_value)
			else:
				final_value = str(new_value)
		"desc":
			final_value = new_value
		"reps", "intensity", "fails":
			final_value = int(new_value)

	quests[quest_index][field_to_change] = final_value
	
	# recalcul de l’XP à chaque modif
	_update_row_xp(quests[quest_index], xp_label)
	save_quests()



func _update_row_xp(quest_data: Dictionary, xp_label: Label):
	var xp_net = XpTable.get_xp_net(
		quest_data["freq"],
		int(quest_data["reps"]),
		int(quest_data["intensity"]),
		int(quest_data["fails"])
	)
	quest_data["xp"] = xp_net
	xp_label.text = str(xp_net)

func save_quests():
	var file = FileAccess.open("user://quests.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(quests, "\t"))

func load_quests():
	if not FileAccess.file_exists("user://quests.json"): 
		return

	quests.clear()
	for child in quest_container.get_children():
		if child.get_index() >= 7: # éviter les en-têtes
			child.queue_free()
	
	var file = FileAccess.open("user://quests.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var loaded_array = JSON.parse_string(content)
		if loaded_array is Array:
			for quest_data in loaded_array:
				quests.append(quest_data)
				_create_quest_row_ui(quest_data)  # <--- recrée ET recalcule l’XP


func select_item_by_text(option_button: OptionButton, text: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text:
			option_button.select(i)
			return
	option_button.select(0)
