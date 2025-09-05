# scenes/MilestoneRow.gd
extends HBoxContainer

# On récupère les 4 nœuds de notre scène
@onready var description_input: LineEdit = $DescriptionInput
@onready var difficulty_input: SpinBox = $DifficultyInput
@onready var completed_check: CheckBox = $CompletedCheck
@onready var xp_label: Label = $XpLabel

# Une variable pour garder en mémoire les données du palier
var milestone_data: Dictionary

# C'est la fonction "d'initialisation". On l'appellera depuis l'extérieur
# pour dire à cette ligne quelles données elle doit afficher.
func setup(data: Dictionary):
	self.milestone_data = data
	
	# On remplit l'interface avec les bonnes informations
	description_input.text = milestone_data["description"]
	difficulty_input.value = milestone_data["difficulty"]
	completed_check.button_pressed = milestone_data["completed"]
	
	# On met à jour l'affichage de l'XP
	_update_xp_label()
	
	# On connecte les signaux : si l'utilisateur change quelque chose,
	# on appelle les fonctions correspondantes pour sauvegarder.
	description_input.text_submitted.connect(_on_description_changed)
	difficulty_input.value_changed.connect(_on_difficulty_changed)
	completed_check.toggled.connect(_on_completed_toggled)

# Calcule et affiche l'XP en fonction de la difficulté choisie
func _update_xp_label():
	var xp = XpTable.get_milestone_xp(difficulty_input.value)
	xp_label.text = str(xp) + " XP"

# --- Fonctions de sauvegarde (appelées par les signaux) ---

func _on_description_changed(new_text: String):
	Gamedata.update_milestone_data(milestone_data["id"], "description", new_text)

func _on_difficulty_changed(new_value: float):
	Gamedata.update_milestone_data(milestone_data["id"], "difficulty", int(new_value))
	_update_xp_label() # On met aussi à jour le label d'XP

func _on_completed_toggled(is_pressed: bool):
	Gamedata.update_milestone_data(milestone_data["id"], "completed", is_pressed)
