extends Node2D

@export var player_controller : PlayerController
@export var animation_player  : AnimationPlayer
@export var sprite            : Sprite2D
#@export var hitbox            : Area2D    # an Area2D child with a CollisionShape2D

# how much damage your sword does
@export var attack_damage : int = 10

func _ready():
	# start with hitbox off
	#hitbox.monitoring = false
	# connect to detect enemies
	#hitbox.body_entered.connect(_on_Hitbox_body_entered)
	# listen for when an animation finishes
	animation_player.animation_finished.connect(_on_AnimationPlayer_animation_finished)

func _physics_process(delta):
	# 1) check for attack input
	if Input.is_action_just_pressed("attack") and animation_player.current_animation != "attack":
		_start_attack()
		return   # skip all other anim logic while attacking

	# 2) if we’re mid‑attack, let the attack animation run
	if animation_player.current_animation == "attack":
		return

	# 3) otherwise do your normal flip & move anims
	# — flip sprite
	sprite.flip_h = player_controller.direction < 0

	# — choose a movement anim (jump/fall has priority)
	if      player_controller.velocity.y < 0:
		animation_player.play("jump")
	elif    player_controller.velocity.y > 0:
		animation_player.play("fall")
	elif    abs(player_controller.velocity.x) > 0:
		animation_player.play("move")
	else:
		animation_player.play("Idle")

func _start_attack():
	# play the swing
	animation_player.play("attack")
	# turn on hit detection
	#hitbox.monitoring = true

func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "attack":
		# done swinging, turn hitbox off and snap back to Idle
		#hitbox.monitoring = false
		animation_player.play("Idle")

func _on_Hitbox_body_entered(body):
	# only damage enemy‑grouped nodes
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
		# optional: knockback, particles, sound, etc.
