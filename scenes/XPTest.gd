extends Control

# On précharge le script du manager pour pouvoir l'utiliser
const QuestManager = preload("res://scenes/QuestManager.gd")

# Les noeuds gérés directement par cette scène
@onready var freq_cell : OptionButton = $VBoxContainer/QuestTable/FreqCell
@onready var reps_cell : SpinBox = $VBoxContainer/QuestTable/RepsCell
@onready var intensity_cell : SpinBox = $VBoxContainer/QuestTable/IntensityCell
@onready var xp_cell : Label = $VBoxContainer/QuestTable/XpCell
@onready var fails_cell : SpinBox = $VBoxContainer/QuestTable/FailsCell
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
	
	# --- Logique de la calculatrice (qui reste ici) ---
	for f in ["Journalière", "Hebdomadaire", "Mensuelle", "Annuelle", "Unique"]:
		freq_cell.add_item(f)

	reps_cell.value_changed.connect(_update_xp)
	intensity_cell.value_changed.connect(_update_xp)
	fails_cell.value_changed.connect(_update_xp)
	freq_cell.item_selected.connect(_update_xp)
	_update_xp()

# Cette fonction ne concerne que la ligne de calcul, elle reste donc ici.
func _update_xp(arg = null) -> void:
	var freq = freq_cell.get_item_text(freq_cell.selected)
	var reps = int(reps_cell.value)
	var intensity = int(intensity_cell.value)
	var fails = int(fails_cell.value)
	
	# On utilise l'Autoload !
	var xp_net = XpTable.get_xp_net(freq, reps, intensity, fails)
	xp_cell.text = str(xp_net)
