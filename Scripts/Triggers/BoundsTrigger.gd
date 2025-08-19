tool
class_name BoundsTrigger
extends Trigger

export var environment: Environment
export var ship_spawner: NodePath
onready var _ShipSpawner: ShipSpawner = get_node_or_null(ship_spawner)

var tween: SceneTreeTween

func trigger_entered(ship: Ship)->void:
	if tween:
		tween.kill()
	tween = create_tween()
	if environment:
		tween.tween_property(environment, "fog_depth_begin", 10.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(environment, "fog_depth_end", 500.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func trigger_exited(ship: Ship)->void:
	if tween:
		tween.kill()
	tween = create_tween()
	if environment:
		tween.tween_property(environment, "fog_depth_begin", 0.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(environment, "fog_depth_end", 1.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if _ShipSpawner:
		tween.tween_callback(PlayerManager, "respawn")
