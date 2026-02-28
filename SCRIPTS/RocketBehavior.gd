extends BulletBehavior
class_name RocketBehavior

@export var e_explosionCaster : ShapeCast2D
@export var e_lockoutDuration : float = 1
@export var e_explosionVFX : PackedScene

var exploded : bool = false



func _on_area_2d_body_entered(_body: Node2D):
	Explode()
	queue_free()

func Explode():
	# Just to ensure no weird explosion duplication with simultanious on_area_2d_body_entered
	if !exploded:
		exploded = true
		e_explosionCaster.force_shapecast_update()
		if e_explosionCaster.is_colliding():
			var bodies = e_explosionCaster.collision_result
			for keypair in bodies:
				if keypair.collider is PlayerController:
					var player = keypair.collider as PlayerController
					player.RocketJump(global_position, e_lockoutDuration)


		var fx = e_explosionVFX.instantiate()
		fx.global_position = global_position
		get_tree().root.add_child(fx)
	pass
