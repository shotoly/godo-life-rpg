extends Control
@onready var gestion_des_quêtes = $TabContainer/"Répertoire des Quêtes"/TextureRect/Panel/gestion_des_quêtes
@onready var arck_tab = $TabContainer/"Répertoire des Quêtes"/TextureRect/arck_tab
@onready var Tabcontainer = $TabContainer

func _on_arc_name_changed(new_text: String, arc_index: int):

	var colonnes = gestion_des_quêtes.columns
	var enfants = gestion_des_quêtes.get_child_count()
	
	if enfants == 0 or colonnes == 0:
		return

	var lignes = ceil(float(enfants) / colonnes)

	for i in range(lignes):
		var option_button_index = i * colonnes + 0
		
		var arckcell = gestion_des_quêtes.get_child(option_button_index)
		
		if arckcell is OptionButton:
			arckcell.set_item_text(arc_index, new_text)
	if arc_index < Tabcontainer.get_child_count():
		# 2. On récupère le nœud enfant correspondant à l'onglet (un PanelContainer).
		var tab_page = Tabcontainer.get_child(arc_index + 1)

		tab_page.name = new_text
			
func _ready() -> void:
	
	var roman_numerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"]

	for i in range(12): # i ira de 0 à 11
		var arc_name = "Arc " + roman_numerals[i]
		var new_line_edit = LineEdit.new()
		new_line_edit.add_theme_color_override("font_color", Color.WHITE)
		new_line_edit.text = arc_name
		new_line_edit.text_changed.connect(_on_arc_name_changed.bind(i))
		arck_tab.add_child(new_line_edit)
		var new_tab_page = PanelContainer.new()
		new_tab_page.name = arc_name
		Tabcontainer.add_child(new_tab_page)
