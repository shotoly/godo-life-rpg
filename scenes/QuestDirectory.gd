# scenes/QuestDirectory.gd
extends Control

const QuestEditorRow = preload("res://scenes/QuestEditorRow.tscn")

@onready var add_quest_button: Button = $VBoxContainer/AddQuestButton
@onready var quest_table: GridContainer = $VBoxContainer/QuestTable
@onready var arc_name_editor: GridContainer = $VBoxContainer/ArcNameEditor

func _ready():
	# On se connecte aux signaux de GameData pour se rafraîchir
	Gamedata.quest_list_updated.connect(display_quests)
	Gamedata.arc_name_updated.connect(populate_arc_name_editor)
	
	add_quest_button.pressed.connect(Gamedata.add_quest)
	
	display_quests()
	populate_arc_name_editor()

func display_quests():
	for child in quest_table.get_children():
		child.queue_free()
		
	# On ajoute les en-têtes
	var h_arc = Label.new(); h_arc.text = "Arc"
	var h_freq = Label.new(); h_freq.text = "Fréquence"
	var h_reps = Label.new(); h_reps.text = "Répétitions"
	var h_desc = Label.new(); h_desc.text = "Description"; h_desc.size_flags_horizontal = Control.SIZE_EXPAND
	var h_int = Label.new(); h_int.text = "Intensité"
	var h_xp = Label.new(); h_xp.text = "XP"
	var h_act = Label.new(); h_act.text = "Action"
	quest_table.add_child(h_arc); quest_table.add_child(h_freq); quest_table.add_child(h_reps)
	quest_table.add_child(h_desc); quest_table.add_child(h_int); quest_table.add_child(h_xp); quest_table.add_child(h_act)
	
	for quest in Gamedata.quests_data:
		var row = QuestEditorRow.instantiate()
		quest_table.add_child(row)
		row.setup(quest)

func populate_arc_name_editor():
	for child in arc_name_editor.get_children():
		child.queue_free()

	for i in range(Gamedata.arc_names.size()):
		var label = Label.new(); label.text = "Arc " + str(i + 1)
		var line_edit = LineEdit.new(); line_edit.text = Gamedata.arc_names[i]
		line_edit.text_changed.connect(Gamedata.update_arc_name.bind(i))
		arc_name_editor.add_child(label)
		arc_name_editor.add_child(line_edit)
