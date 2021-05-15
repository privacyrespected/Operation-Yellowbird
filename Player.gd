extends KinematicBody

# stats
var curHp : int = 10
var maxHp : int = 10
var ammo : int = 15
var score: int = 0

# physics
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0

# cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

# vectors
var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()

# components
#what the fuck is going on here? lmao kekw

onready var camera : Camera = get_node("Camera")
onready var muzzle : Spatial = get_node("Camera/Muzzle")
onready var bulletScene = load("res://Bullet.tscn")

func _ready ():
	
	# hide and lock the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

# called 60 times a second
func _physics_process(delta):

	# reset the x and z velocity
	vel.x = 0
	vel.z = 0
	
	var input = Vector2()
	
	# movement inputs
	if Input.is_action_pressed("move_forward"):
		input.y -= 1
	if Input.is_action_pressed("move_backward"):
		input.y += 1
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
		
	input = input.normalized()
	
	# get the forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	var relativeDir = (forward * input.y + right * input.x)
	
	# set the velocity
	vel.x = relativeDir.x * moveSpeed
	vel.z = relativeDir.z * moveSpeed	
	
	# apply gravity
	vel.y -= gravity * delta
	
	# move the player
	vel = move_and_slide(vel, Vector3.UP)
	
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y = jumpForce

# called every frame	
func _process(delta):
	
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
	# rotate the player along their y axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	# reset the mouse delta vector
	mouseDelta = Vector2()
	
	# check to see if we have shot
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		shoot()
		
# called when an input is detected
func _input(event):
	
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

# called when we press the shoot button - spawn a new bullet	
func shoot ():
	
	var bullet = bulletScene.instance()
	get_node("/root/MainScene").add_child(bullet)
	
	bullet.global_transform = muzzle.global_transform
	
	ammo -= 1
	
# called when an enemy damages us
func take_damage (damage):
	
	curHp -= damage

	
	if curHp <= 0:
		die()

# called when our health reaches 0	
func die ():
	
	print("You died!")
	
func add_score (amount):
	
	score += amount

	
func add_health (amount):
	
	curHp += amount
	
	if curHp > maxHp:
		curHp = maxHp
		

	
func add_ammo (amount):
	
	ammo += amount
