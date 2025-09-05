# scenes/Milestones.gd
extends Control

# On précharge notre scène "modèle" pour une ligne de palier
const MilestoneRow = preload("res://scenes/MilestoneRow.tscn")

# On récupère le conteneur principal
@onready var milestones_list: VBoxContainer = $ScrollContainer/MilestonesList

func _ready():
	# Au démarrage de l'écran, on affiche les paliers
	display_all_milestones()

# La fonction principale qui construit toute l'interface
func display_all_milestones():
	# 1. On vide l'affichage actuel pour éviter les doublons
	for child in milestones_list.get_children():
		child.queue_free()

	# 2. On boucle sur chaque Arc défini dans GameData
	for i in range(Gamedata.arc_names.size()):
		var arc_name = Gamedata.arc_names[i]
		
		# --- Création de la section pour cet Arc ---
		
		# On ajoute un titre pour l'Arc
		var title_label = Label.new()
		title_label.text = arc_name
		# Pour le style, on peut le mettre en gras (nécessite une police ou un thème)
		# Pour l'instant, on ajoute juste une marge en haut
		title_label.add_theme_constant_override("margin_top", 20)
		milestones_list.add_child(title_label)

		# On ajoute les en-têtes du tableau ("Paliers", "Intensité", etc.)
		var header = HBoxContainer.new()
		var h_desc = Label.new(); h_desc.text = "Paliers"; h_desc.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
		var h_diff = Label.new(); h_diff.text = "Intensité"
		var h_check = Label.new(); h_check.text = "Atteint"
		var h_xp = Label.new(); h_xp.text = "XP"
		header.add_child(h_desc); header.add_child(h_diff); header.add_child(h_check); header.add_child(h_xp)
		milestones_list.add_child(header)

		# 3. On filtre et on affiche les paliers de cet Arc
		for milestone in Gamedata.milestones_data:
			if milestone["arc_index"] == i:
				var row = MilestoneRow.instantiate()
				milestones_list.add_child(row)
				# On initialise la ligne avec ses données
				row.setup(milestone)
		
		# 4. On ajoute un bouton pour créer un nouveau palier pour cet Arc
		var add_button = Button.new()
		add_button.text = "Ajouter un Palier pour " + arc_name
		add_button.pressed.connect(_on_add_milestone_pressed.bind(i))
		milestones_list.add_child(add_button)

# Fonction appelée quand un bouton "Ajouter un Palier" est cliqué
func _on_add_milestone_pressed(arc_index: int):
	# On demande à GameData de créer un nouveau palier
	Gamedata.add_milestone(arc_index)
	# On rafraîchit tout l'affichage pour montrer le nouveau palier
	display_all_milestones()
