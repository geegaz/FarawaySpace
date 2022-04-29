extends Area

export(String) var target_group: String = "Player"
export(NodePath) var associated_player: NodePath

onready var _AssociatedPlayer: AudioStreamPlayer = get_node_or_null(associated_player)

func _ready() -> void:
	connect("body_entered",self,"_on_InteriorArea_body_entered")
	connect("body_exited",self,"_on_InteriorArea_body_exited")

func _on_InteriorArea_body_entered(body: Node) -> void:
	if body.is_in_group(target_group):
		AudioManager.fade_to(_AssociatedPlayer)

func _on_InteriorArea_body_exited(body: Node) -> void:
	if body.is_in_group(target_group):
		AudioManager.fade_to(AudioManager._DefaultPlayer)
