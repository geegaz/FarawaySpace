extends Spatial

export var merge: bool
var splerger: Splerger

func _ready():
	if merge:
		splerger = Splerger.new()
		splerger.merge_suitable_meshes_across_branches(self)
	
