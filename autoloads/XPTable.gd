extends Node
class_name XPTable

# Dictionnaire global des quêtes
var quest_table := {
	"Journalière": {
		1: { "xp": [25, 31, 38], "malus": 0.20 },
		2: { "xp": [20, 25, 30], "malus": 0.20 },
		3: { "xp": [17.5, 22, 26], "malus": 0.20 },
		4: { "xp": [15.625, 20, 23], "malus": 0.20 },
		5: { "xp": [14, 18, 21], "malus": 0.20 },
		6: { "xp": [12.5, 16, 19], "malus": 0.20 },
		7: { "xp": [11.25, 14, 17], "malus": 0.20 },
		8: { "xp": [10, 13, 15], "malus": 0.20 },
		9: { "xp": [8.75, 11, 13], "malus": 0.20 },
		10: { "xp": [8.125, 10, 12], "malus": 0.20 }
	},
	"Hebdomadaire": {
		1: { "xp": [100, 125, 150], "malus": 0.20 },
		2: { "xp": [80, 100, 120], "malus": 0.20 },
		3: { "xp": [70, 88, 105], "malus": 0.20 },
		4: { "xp": [62.5, 78, 94], "malus": 0.20 },
		5: { "xp": [56, 70, 84], "malus": 0.20 },
		6: { "xp": [50, 63, 75], "malus": 0.20 },
		7: { "xp": [45, 56, 68], "malus": 0.20 },
		8: { "xp": [40, 50, 60], "malus": 0.20 },
		9: { "xp": [35, 44, 53], "malus": 0.20 },
		10: { "xp": [32.5, 41, 49], "malus": 0.20 }
	},
	"Mensuelle": {
		1: { "xp": [400, 500, 600], "malus": 0.25 },
		2: { "xp": [350, 438, 525], "malus": 0.25 },
		3: { "xp": [300, 375, 450], "malus": 0.25 },
		4: { "xp": [250, 313, 375], "malus": 0.25 },
		5: { "xp": [220, 275, 330], "malus": 0.25 },
		6: { "xp": [200, 250, 300], "malus": 0.25 },
		7: { "xp": [185, 231, 278], "malus": 0.25 },
		8: { "xp": [172, 215, 258], "malus": 0.25 },
		9: { "xp": [160, 200, 240], "malus": 0.25 },
		10: { "xp": [150, 188, 225], "malus": 0.25 }
	},
	"Annuelle": {
		1: { "xp": [3000, 3750, 4500], "malus": 0.30 },
		2: { "xp": [1750, 2188, 2625], "malus": 0.30 },
		3: { "xp": [1333, 1666, 2000], "malus": 0.30 },
		4: { "xp": [1125, 1406, 1688], "malus": 0.30 },
		5: { "xp": [1000, 1250, 1500], "malus": 0.30 },
		6: { "xp": [900, 1125, 1350], "malus": 0.30 },
		7: { "xp": [814, 1018, 1221], "malus": 0.30 },
		8: { "xp": [750, 938, 1125], "malus": 0.30 },
		9: { "xp": [700, 875, 1050], "malus": 0.30 },
		10: { "xp": [650, 813, 975], "malus": 0.30 }
	},
	"Unique": {
		1: { "xp": [900, 1400, 2100], "malus": 0.30 }
	}
}

func get_xp_theorique(freq:String, reps:int, intensity:int) -> int:
	if quest_table.has(freq) and quest_table[freq].has(reps):
		var values = quest_table[freq][reps]["xp"]
		return int(values[intensity - 1])
	return 0

func get_malus(freq:String, reps:int) -> float:
	if quest_table.has(freq) and quest_table[freq].has(reps):
		return float(quest_table[freq][reps]["malus"])
	return 0.0

func get_xp_net(freq:String, reps:int, intensity:int, fails:int) -> int:
	var base_xp = get_xp_theorique(freq, reps, intensity)
	var malus_pct = get_malus(freq, reps)
	var penalty = base_xp * malus_pct * fails
	return max(0, int(base_xp - penalty))
