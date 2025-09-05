# scenes/QuestEditorRow.gd
extends HBoxContainer

@onready var arc_select: OptionButton = $ArcSelect
@onready var freq_select: OptionButton = $FreqSelect
@onready var reps_input: SpinBox = $RepsInput
@onready var desc_input: LineEdit = $DescInput
@onready var intensity_input: SpinBox = $IntensityInput
@onready var xp_label: Label = $XpLabel
@onready var delete_button: Button = $DeleteButton

var quest_data: Dictionary

func setup(data: Dictionary):
	self.quest_data = data
	
	# --- Peuplement de l'interface ---
	for i in range(Gamedata.arc_names.size()):
		arc_select.add_item(Gamedata.arc_names[i])
	arc_select.select(quest_data["arc_index"])
	
	for f in ["Journalière", "Hebdomadaire", "Mensuelle", "Annuelle", "Unique"]:
		freq_select.add_item(f)
		if f == quest_data["freq"]:
			freq_select.select(freq_select.get_item_count() - 1)

	reps_input.min_value = 1; reps_input.max_value = 10; reps_input.value = quest_data["reps"]
	intensity_input.min_value = 1; intensity_input.max_value = 3; intensity_input.value = quest_data["intensity"]
	desc_input.text = quest_data["desc"]
	
	_update_xp_label()
	
	# --- Connexion des signaux ---
	arc_select.item_selected.connect(func(i): Gamedata.update_quest_data(quest_data["id"], "arc_index", i))
	freq_select.item_selected.connect(func(i): Gamedata.update_quest_data(quest_data["id"], "freq", freq_select.get_item_text(i)))
	reps_input.value_changed.connect(func(v): Gamedata.update_quest_data(quest_data["id"], "reps", int(v)))
	desc_input.text_submitted.connect(func(t): Gamedata.update_quest_data(quest_data["id"], "desc", t))
	intensity_input.value_changed.connect(func(v): Gamedata.update_quest_data(quest_data["id"], "intensity", int(v)))
	delete_button.pressed.connect(func(): Gamedata.delete_quest(quest_data["id"]))
	
	# Mettre à jour l'XP quand les valeurs changent
	freq_select.item_selected.connect(_update_xp_label)
	reps_input.value_changed.connect(_update_xp_label)
	intensity_input.value_changed.connect(_update_xp_label)

func _update_xp_label():
	var xp = XpTable.get_xp_net(freq_select.get_item_text(freq_select.selected), reps_input.value, intensity_input.value, 0)
	xp_label.text = str(xp) + " XP"
