# scenes/QuestScene.gd
extends Control

# On précharge le script du manager pour pouvoir l'utiliser
const QuestManager = preload("res://scenes/QuestManager.gd")

# Les noeuds gérés directement par cette scène
@onready var add_quest_button : Button = $VBoxContainer/AddQuestButton
@onready var quest_table : GridContainer = $VBoxContainer/QuestTable

# Une variable pour contenir notre manager de quêtes
var quest_manager : QuestManager

func _ready() -> void:
	# 1. On crée une instance du manager en lui donnant le conteneur de quêtes
	quest_manager = QuestManager.new(quest_table)

	# 2. On connecte le bouton "Ajouter" à la fonction du manager
	add_quest_button.pressed.connect(quest_manager.add_quest_row)

	# 3. On charge les quêtes via le manager
	quest_manager.load_quests()
