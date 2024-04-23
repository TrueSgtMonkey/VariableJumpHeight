extends CharacterBody3D

const MOUSE_SPEED: float = 0.007
const SPEED = 5.0
const JUMP_VELOCITY = 6.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var cut_jump_height: float = 0.5

var pivot: Node3D = null
var camera: Camera3D = null

func _ready():
	pivot = $Pivot
	camera = $Pivot/Camera3D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_front", "move_back")
	var direction = (pivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _input(event):
	if event.is_action_released("jump"):
		if velocity.y > 0.0:
			velocity.y *= cut_jump_height
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		pivot.rotate_y(event.relative.x * -MOUSE_SPEED)
		camera.rotate_x(event.relative.y * -MOUSE_SPEED)
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90.0, 90.0)
