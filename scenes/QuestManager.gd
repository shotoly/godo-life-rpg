# scenes/QuestManager.gd
class_name QuestManager

var quests: Array = []
var quest_container: GridContainer

func _init(container: GridContainer):
	self.quest_container = container
	# NOUVEAU : On se connecte au signal de GameData
	Gamedata.arc_name_updated.connect(_on_global_arc_name_updated)

# NOUVEAU : Réagit au changement de nom d'un Arc
func _on_global_arc_name_updated(arc_index: int, new_name: String):
	var children = quest_container.get_children()
	# On parcourt les lignes de quêtes (chaque ligne a 7 éléments)
	for i in range(0, children.size(), 7):
		var arc_select = children[i] as OptionButton
		if arc_select:
			# On met à jour le texte de l'item concerné dans la liste déroulante
			arc_select.set_item_text(arc_index, new_name)

func add_quest_row():
	# On utilise le premier nom d'Arc de GameData par défaut
	var quest = {
		"arc": Gamedata.arc_names[0], "freq": "Journalière", "reps": 1, "intensity": 1,
		"desc": "", "xp": 0, "fails": 0
	}
	add_quest_row_from_data(quest)
	save_all_rows()

func add_quest_row_from_data(quest: Dictionary):
	var arc_select = OptionButton.new()
	# MODIFIÉ : On utilise la liste de noms de GameData
	for arc_name in Gamedata.arc_names:
		arc_select.add_item(arc_name)
	select_item_by_text(arc_select, quest.get("arc", Gamedata.arc_names[0]))

	var freq_select = OptionButton.new()
	for f in ["Journalière", "Hebdomadaire", "Mensuelle", "Annuelle", "Unique"]:
		freq_select.add_item(f)
	select_item_by_text(freq_select, quest.get("freq", "Journalière"))

	var reps_input = SpinBox.new(); reps_input.min_value = 1; reps_input.max_value = 10; reps_input.value = quest.get("reps", 1)
	var intensity_input = SpinBox.new(); intensity_input.min_value = 1; intensity_input.max_value = 3; intensity_input.value = quest.get("intensity", 1)
	var desc_input = LineEdit.new(); desc_input.text = quest.get("desc", "")
	var xp_label = Label.new(); xp_label.text = str(quest.get("xp", 0))
	var fails_input = SpinBox.new(); fails_input.min_value = 0; fails_input.max_value = 10; fails_input.value = quest.get("fails", 0)

	quest_container.add_child(arc_select)
	quest_container.add_child(freq_select)
	quest_container.add_child(reps_input)
	quest_container.add_child(intensity_input)
	quest_container.add_child(desc_input)
	quest_container.add_child(xp_label)
	quest_container.add_child(fails_input)

	arc_select.item_selected.connect(save_all_rows)
	reps_input.value_changed.connect(func(_val): _update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label); save_all_rows())
	intensity_input.value_changed.connect(func(_val): _update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label); save_all_rows())
	fails_input.value_changed.connect(func(_val): _update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label); save_all_rows())
	freq_select.item_selected.connect(func(_id): _update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label); save_all_rows())
	desc_input.text_changed.connect(save_all_rows)

	_update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label)

func _update_row_xp(freq_select: OptionButton, reps_input: SpinBox, intensity_input: SpinBox, fails_input: SpinBox, xp_label: Label):
	var freq = freq_select.get_item_text(freq_select.selected)
	var reps = int(reps_input.value)
	var intensity = int(intensity_input.value)
	var fails = int(fails_input.value)
	var xp_net = XpTable.get_xp_net(freq, reps, intensity, fails)
	xp_label.text = str(xp_net)

func save_quests():
	var file = FileAccess.open("user://quests.json", FileAccess.WRITE)
	if file:
		var data = { "quests": quests }
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_quests():
	if not FileAccess.file_exists("user://quests.json"): return
	
	# Vide l'UI en ignorant les en-têtes (7 labels)
	for i in range(quest_container.get_child_count() - 1, 6, -1):
		quest_container.get_child(i).queue_free()

	var file = FileAccess.open("user://quests.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var result = JSON.parse_string(content)
		if result and result.has("quests"):
			quests = result["quests"]
			for quest in quests:
				add_quest_row_from_data(quest)

func save_all_rows():
	quests.clear()
	var children = quest_container.get_children()
	# On ignore les 7 premiers enfants (les labels d'en-tête)
	for i in range(7, children.size(), 7):
		var arc_select : OptionButton = children[i]
		var freq_select : OptionButton = children[i+1]
		var reps_input : SpinBox = children[i+2]
		var intensity_input : SpinBox = children[i+3]
		var desc_input : LineEdit = children[i+4]
		var xp_label : Label = children[i+5]
		var fails_input : SpinBox = children[i+6]

		quests.append({
			"arc": arc_select.get_item_text(arc_select.selected),
			"freq": freq_select.get_item_text(freq_select.selected),
			"reps": int(reps_input.value), "intensity": int(intensity_input.value),
			"desc": desc_input.text, "xp": int(xp_label.text), "fails": int(fails_input.value)
		})
	save_quests()

func select_item_by_text(option_button: OptionButton, text: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text:
			option_button.select(i)
			return
	option_button.select(0)
