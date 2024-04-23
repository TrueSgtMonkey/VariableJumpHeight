extends CharacterBody2D

enum Ani {
	IDLE = 0,
	JUMP_HOLDING = 2,
	JUMP_RELEASE = 7,
	MAX_ANI = 14
}
var ani_state: int = Ani.IDLE
var ani_time: float = 0.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const ANI_PERIOD: float = 1.0 / 24.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var original_col_position: Vector2 = Vector2.ZERO

var collision_shape: CollisionShape2D = null
var sprite: Sprite2D = null

func _ready():
	sprite = $Sprite2D
	collision_shape = $CollisionShape2D
	
	original_col_position = collision_shape.transform.origin

func _process(delta):
	ani_time += delta
	if ani_time >= ANI_PERIOD:
		ani_time = 0.0
		change_frame()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		# velocity.y = JUMP_VELOCITY
		ani_state = Ani.JUMP_HOLDING

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _input(event):
	if event.is_action_released("jump"):
		ani_state = Ani.JUMP_RELEASE

func change_frame():
	var frame = sprite.frame
	match ani_state:
		Ani.IDLE:
			frame = 0
		Ani.JUMP_HOLDING:
			# play jump holding animation -- loop
			frame += 1
			if frame > Ani.JUMP_RELEASE:
				frame = Ani.JUMP_HOLDING
		Ani.JUMP_RELEASE:
			# Play jump release animation
			frame += 1
			if frame >= Ani.MAX_ANI:
				ani_state = Ani.IDLE
		_:
			ani_state = Ani.IDLE
	
	change_collision_shape_per_frame(frame)
	sprite.frame = frame

func change_collision_shape_per_frame(frame: int):
	if frame < Ani.JUMP_HOLDING or frame > (Ani.MAX_ANI-1):
		collision_shape.transform.origin.y = original_col_position.y + 9.0
		collision_shape.shape.radius = 22.0
		collision_shape.shape.height = 104.0
	elif frame >= Ani.JUMP_HOLDING && frame <= Ani.JUMP_RELEASE:
		collision_shape.transform.origin.y = original_col_position.y + 30.0
		collision_shape.shape.radius = 31.0
		collision_shape.shape.height = 66.0
	elif frame > Ani.JUMP_RELEASE && frame <= (Ani.MAX_ANI-1):
		collision_shape.transform.origin.y = original_col_position.y
		collision_shape.shape.radius = 19.0
		collision_shape.shape.height = 122.0
