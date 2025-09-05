# scenes/QuestDirectory.gd
extends Control

const QuestManager = preload("res://scenes/QuestManager.gd")

@onready var add_quest_button: Button = $VBoxContainer/AddQuestButton
@onready var quest_table: GridContainer = $VBoxContainer/QuestTable
# NOUVEAU : On récupère le conteneur pour l'éditeur de noms
@onready var arc_name_editor: GridContainer = $VBoxContainer/ArcNameEditor

var quest_manager: QuestManager

func _ready() -> void:
	quest_manager = QuestManager.new(quest_table)
	add_quest_button.pressed.connect(quest_manager.add_quest_row)
	quest_manager.load_quests()
	
	# NOUVEAU : On appelle la fonction pour créer le tableau d'édition
	populate_arc_name_editor()

# NOUVELLE FONCTION : Crée les champs pour éditer les noms
func populate_arc_name_editor():
	for i in range(Gamedata.arc_names.size()):
		var label = Label.new()
		label.text = "Arc " + str(i + 1)
		
		var line_edit = LineEdit.new()
		line_edit.text = Gamedata.arc_names[i]
		# On se connecte au signal "text_changed" pour le temps réel
		line_edit.text_changed.connect(_on_arc_name_changed.bind(i))
		
		arc_name_editor.add_child(label)
		arc_name_editor.add_child(line_edit)

# NOUVELLE FONCTION : Appelée à chaque lettre tapée
func _on_arc_name_changed(new_text: String, index: int):
	# On demande à GameData de faire la mise à jour
	Gamedata.update_arc_name(index, new_text)
