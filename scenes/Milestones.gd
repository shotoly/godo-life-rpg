# scenes/Milestones.gd
extends Control

const MilestoneRow = preload("res://scenes/MilestoneRow.tscn")

@onready var milestones_list: HBoxContainer = $ScrollContainer/MilestonesList

func _ready():
	display_all_milestones()

func display_all_milestones():
	# 1. On vide l'affichage actuel
	for child in milestones_list.get_children():
		child.queue_free()

	# 2. On boucle sur chaque Arc
	for i in range(Gamedata.arc_names.size()):
		var arc_name = Gamedata.arc_names[i]
		
		# NOUVELLE LOGIQUE : On crée un conteneur vertical pour ce tableau d'Arc
		var arc_table_container = VBoxContainer.new()
		milestones_list.add_child(arc_table_container) # On l'ajoute à notre HBoxContainer principal
		
		# --- On construit le contenu de ce tableau spécifique ---
		
		var title_label = Label.new()
		title_label.text = arc_name
		title_label.add_theme_constant_override("margin_top", 20)
		# On ajoute le titre au conteneur de CE tableau
		arc_table_container.add_child(title_label)

		var header = HBoxContainer.new()
		var h_desc = Label.new(); h_desc.text = "Paliers"; h_desc.size_flags_horizontal = Control.SIZE_EXPAND
		var h_diff = Label.new(); h_diff.text = "Intensité"
		var h_check = Label.new(); h_check.text = "Atteint"
		var h_xp = Label.new(); h_xp.text = "XP"
		header.add_child(h_desc); header.add_child(h_diff); header.add_child(h_check); header.add_child(h_xp)
		# On ajoute les en-têtes au conteneur de CE tableau
		arc_table_container.add_child(header)

		# 3. On affiche les paliers de cet Arc
		for milestone in Gamedata.milestones_data:
			if milestone["arc_index"] == i:
				var row = MilestoneRow.instantiate()
				# On ajoute la ligne au conteneur de CE tableau
				arc_table_container.add_child(row)
				row.setup(milestone)
		
		# 4. On ajoute le bouton "Ajouter"
		var add_button = Button.new()
		add_button.text = "Ajouter un Palier"
		add_button.pressed.connect(_on_add_milestone_pressed.bind(i))
		# On ajoute le bouton au conteneur de CE tableau
		arc_table_container.add_child(add_button)

func _on_add_milestone_pressed(arc_index: int):
	Gamedata.add_milestone(arc_index)
	display_all_milestones()
