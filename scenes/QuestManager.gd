# Ce script n'est attaché à aucun noeud. C'est une classe logique.
class_name QuestManager

var quests: Array = []               # Liste des quêtes (Array simple pour éviter erreurs JSON)
var quest_container: GridContainer   # Le conteneur où ajouter les lignes de quête

# On passe le noeud GridContainer quand on crée le manager
func _init(container: GridContainer):
	self.quest_container = container

# 🔹 Ajoute une nouvelle quête par défaut
func add_quest_row():
	var quest = {
		"arc": "Arc I", "freq": "Journalière", "reps": 1, "intensity": 1,
		"desc": "", "xp": 0, "fails": 0
	}
	add_quest_row_from_data(quest)
	save_all_rows()

# 🔹 Ajoute une ligne UI depuis un dictionnaire de données
func add_quest_row_from_data(quest: Dictionary):
	var arc_select = OptionButton.new()
	for arc_name in [
		"Arc I","Arc II","Arc III","Arc IV","Arc V","Arc VI",
		"Arc VII","Arc VIII","Arc IX","Arc X","Arc XI","Arc XII"
	]:
		arc_select.add_item(arc_name)
	select_item_by_text(arc_select, quest.get("arc", "Arc I"))

	var freq_select = OptionButton.new()
	for f in ["Journalière", "Hebdomadaire", "Mensuelle", "Annuelle", "Unique"]:
		freq_select.add_item(f)
	select_item_by_text(freq_select, quest.get("freq", "Journalière"))

	var reps_input = SpinBox.new()
	reps_input.min_value = 1
	reps_input.max_value = 10
	reps_input.value = quest.get("reps", 1)

	var intensity_input = SpinBox.new()
	intensity_input.min_value = 1
	intensity_input.max_value = 3
	intensity_input.value = quest.get("intensity", 1)

	var desc_input = LineEdit.new()
	desc_input.text = quest.get("desc", "")

	var xp_label = Label.new()
	xp_label.text = str(quest.get("xp", 0))

	var fails_input = SpinBox.new()
	fails_input.min_value = 0
	fails_input.max_value = 10
	fails_input.value = quest.get("fails", 0)

	# Ajout à la grille
	quest_container.add_child(arc_select)
	quest_container.add_child(freq_select)
	quest_container.add_child(reps_input)
	quest_container.add_child(intensity_input)
	quest_container.add_child(desc_input)
	quest_container.add_child(xp_label)
	quest_container.add_child(fails_input)

	# Connexions → recalcul + sauvegarde
	arc_select.item_selected.connect(func(_id): save_all_rows())
	freq_select.item_selected.connect(func(_id):
		_update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label)
		save_all_rows()
	)
	reps_input.value_changed.connect(func(_val):
		_update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label)
		save_all_rows()
	)
	intensity_input.value_changed.connect(func(_val):
		_update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label)
		save_all_rows()
	)
	fails_input.value_changed.connect(func(_val):
		_update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label)
		save_all_rows()
	)
	desc_input.text_changed.connect(func(_new): save_all_rows())

	# Premier calcul d’XP
	_update_row_xp(freq_select, reps_input, intensity_input, fails_input, xp_label)

# 🔹 Recalcule l’XP pour une ligne
func _update_row_xp(freq_select: OptionButton, reps_input: SpinBox, intensity_input: SpinBox, fails_input: SpinBox, xp_label: Label):
	var freq = freq_select.get_item_text(freq_select.selected)
	var reps = int(reps_input.value)
	var intensity = int(intensity_input.value)
	var fails = int(fails_input.value)
	var xp_net = XpTable.get_xp_net(freq, reps, intensity, fails)
	xp_label.text = str(xp_net)

# 🔹 Sauvegarde des quêtes actuelles en JSON
func save_quests():
	var file = FileAccess.open("user://quests.json", FileAccess.WRITE)
	if file:
		var data = { "quests": quests }
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

# 🔹 Recharge les quêtes depuis JSON
func load_quests():
	if not FileAccess.file_exists("user://quests.json"):
		return

	# Supprimer les anciennes lignes UI avant de recharger
	for child in quest_container.get_children():
		child.queue_free()

	var file = FileAccess.open("user://quests.json", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var result = JSON.parse_string(content)
		if result and result.has("quests"):
			var loaded_array = result["quests"]
			if loaded_array is Array:
				quests.clear()
				for quest in loaded_array:
					if quest is Dictionary:
						quests.append(quest)
						add_quest_row_from_data(quest)

# 🔹 Reconstruit la liste des quêtes depuis l’UI
func save_all_rows():
	quests.clear()
	var children = quest_container.get_children()

	# Chaque ligne = 7 widgets (arc, freq, reps, intensity, desc, xp, fails)
	for i in range(0, children.size(), 7):
		if i + 6 >= children.size():
			break

		var arc_select = children[i] as OptionButton
		var freq_select = children[i+1] as OptionButton
		var reps_input = children[i+2] as SpinBox
		var intensity_input = children[i+3] as SpinBox
		var desc_input = children[i+4] as LineEdit
		var xp_label = children[i+5] as Label
		var fails_input = children[i+6] as SpinBox

		if arc_select and freq_select and reps_input and intensity_input and desc_input and xp_label and fails_input:
			quests.append({
				"arc": arc_select.get_item_text(arc_select.selected),
				"freq": freq_select.get_item_text(freq_select.selected),
				"reps": int(reps_input.value),
				"intensity": int(intensity_input.value),
				"desc": desc_input.text,
				"xp": int(xp_label.text),
				"fails": int(fails_input.value)
			})

	save_quests()

# 🔹 Sélectionne un item par texte
func select_item_by_text(option_button: OptionButton, text: String) -> void:
	for i in range(option_button.item_count):
		if option_button.get_item_text(i) == text:
			option_button.select(i)
			return
	option_button.select(0)
