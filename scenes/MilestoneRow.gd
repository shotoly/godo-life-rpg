# scenes/MilestoneRow.gd
extends HBoxContainer

@onready var description_input: LineEdit = $DescriptionInput
@onready var difficulty_input: SpinBox = $DifficultyInput
@onready var completed_check: CheckBox = $CompletedCheck
@onready var xp_label: Label = $XpLabel

var milestone_data: Dictionary

func setup(data: Dictionary):
	self.milestone_data = data
	description_input.text = milestone_data["description"]
	difficulty_input.value = milestone_data["difficulty"]
	completed_check.button_pressed = milestone_data["completed"]
	_update_xp_label()
	description_input.text_submitted.connect(_on_description_changed)
	difficulty_input.value_changed.connect(_on_difficulty_changed)
	completed_check.toggled.connect(_on_completed_toggled)

func _update_xp_label():
	var xp = XpTable.get_milestone_xp(difficulty_input.value)
	xp_label.text = str(xp) + " XP"

func _on_description_changed(new_text: String):
	Gamedata.update_milestone_data(milestone_data["id"], "description", new_text)

func _on_difficulty_changed(new_value: float):
	Gamedata.update_milestone_data(milestone_data["id"], "difficulty", int(new_value))
	_update_xp_label()

func _on_completed_toggled(is_pressed: bool):
	var xp_amount = XpTable.get_milestone_xp(milestone_data["difficulty"])
	print("--- Clic sur la CheckBox ---")
	print("Palier '", milestone_data["description"], "' | Statut précédent : ", milestone_data["completed"], " | Nouvelle action : ", is_pressed)
	
	if is_pressed:
		if not milestone_data["completed"]:
			print("Action: Ajout de ", xp_amount, " XP")
			Gamedata.add_player_xp(xp_amount)
	else:
		if milestone_data["completed"]:
			print("Action: Retrait de ", xp_amount, " XP")
			Gamedata.remove_player_xp(xp_amount)
	
	# On met à jour le statut dans la base de données...
	Gamedata.update_milestone_data(milestone_data["id"], "completed", is_pressed)
	# ...ET ON MET À JOUR LA COPIE LOCALE ! C'est la ligne qui manquait.
	milestone_data["completed"] = is_pressed
