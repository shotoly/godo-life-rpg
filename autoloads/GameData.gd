# autoloads/GameData.gd
extends Node

# La liste des noms d'Arcs par défaut. C'est notre source de vérité.
var arc_names: Array[String] = [
	"Arc I", "Arc II", "Arc III", "Arc IV",
	"Arc V", "Arc VI", "Arc VII", "Arc VIII",
	"Arc IX", "Arc X", "Arc XI", "Arc XII"
]

# Le chemin du fichier de sauvegarde pour les données du jeu
const SAVE_PATH = "user://gamedata.json"

func _ready():
	# Au démarrage du jeu, on charge les données
	load_data()

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# On sauvegarde uniquement la liste des noms pour l'instant
		var data_to_save = {"arc_names": arc_names}
		file.store_string(JSON.stringify(data_to_save, "\t"))
		file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		return # Pas de fichier de sauvegarde, on garde les valeurs par défaut

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var loaded_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if loaded_data and loaded_data.has("arc_names"):
			var loaded_array = loaded_data["arc_names"]

			if loaded_array is Array:
				arc_names = []  # Réinitialise proprement

				for item in loaded_array:
					if typeof(item) == TYPE_STRING:
						arc_names.append(item)
