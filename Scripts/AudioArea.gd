extends Area

export(String) var target_group: String = "Player"
export(NodePath) var associated_player: NodePath
export(float, 0, 60) var margin_time: float = 30

var exited_time: float = 0.0

onready var _AssociatedPlayer: AudioStreamPlayer = get_node_or_null(associated_player)

func _ready() -> void:
	connect("body_entered",self,"_on_InteriorArea_body_entered")
	connect("body_exited",self,"_on_InteriorArea_body_exited")

func _process(delta: float) -> void:
	exited_time = max(exited_time - delta, 0)

func _on_InteriorArea_body_entered(body: Node) -> void:
	if body.is_in_group(target_group):
		AudioManager.fade_to(_AssociatedPlayer, 6.0)
		AudioManager.fade_area_reverb(self, 0.5)
		
		if exited_time <= 0:
			_AssociatedPlayer.play()

func _on_InteriorArea_body_exited(body: Node) -> void:
	if body.is_in_group(target_group):
		if _AssociatedPlayer == AudioManager._CurrentPlayer:
			AudioManager.fade_to(AudioManager._DefaultPlayer, 3.0)
			AudioManager.fade_area_reverb(self, 0, 0)
		
		exited_time = margin_time
