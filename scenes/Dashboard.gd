# scenes/Dashboard.gd
extends Control

@onready var player_name_label: Label = $VBoxContainer/PlayerNameLabel
@onready var level_label: Label = $VBoxContainer/LevelLabel
@onready var xp_progress_bar: ProgressBar = $VBoxContainer/XpProgressBar
@onready var xp_label: Label = $VBoxContainer/XpLabel

func _ready():
	# On se connecte au signal de GameData pour se mettre à jour automatiquement
	Gamedata.player_stats_updated.connect(update_display)
	# On fait un premier affichage au chargement de l'écran
	update_display()

# La fonction qui met à jour toute l'interface
func update_display():
	var player_level = Gamedata.player_data["level"]
	var player_xp = Gamedata.player_data["xp"]
	var xp_for_next_level = XpTable.get_xp_for_level(player_level)
	
	player_name_label.text = Gamedata.player_data["name"]
	level_label.text = "Niveau : " + str(player_level)
	xp_label.text = str(player_xp) + " / " + str(xp_for_next_level) + " XP"
	
	# On met à jour la barre de progression
	xp_progress_bar.max_value = xp_for_next_level
	xp_progress_bar.value = player_xp
