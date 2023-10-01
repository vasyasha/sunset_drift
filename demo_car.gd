extends Node3D

#Node references
@onready var ball = $Ball
@onready var car_mesh = $van
@onready var ground_ray = $van/RayCast3D
@onready var camera = $van/camTarget/Camera3D

#where to place the car mesh relative to the sphere
@export var sphere_offset = Vector3(0, 0, 0)
#Engine power
@export var acceleration = 20
#turn amount, degrees
@export var steering = 21
#how quickly the car turns
@export var turn_speed = 5
#below this speed the car doesn't turn
@export var turn_stop_limit = .75

#variables for input values
var speed_input = 0
var rotate_input = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	ground_ray.add_exception(ball)

func _physics_process(_delta):
	#align the car mesh with the sphere
	car_mesh.transform.origin = ball.transform.origin + sphere_offset
	#accelerate based on the car's forward direction - forward is -z
	ball.apply_central_force(-car_mesh.global_transform.basis.z * speed_input)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#can't accelerate or steer in the air
	if not ground_ray.is_colliding():
		print("not on ground")
		#return
	#get inputs
	speed_input = 0
	speed_input += Input.get_action_strength("accelerate")
	speed_input -= Input.get_action_strength("brake")
	speed_input *= acceleration
	
	rotate_input = 0
	rotate_input += Input.get_action_strength("steer_left")
	rotate_input -= Input.get_action_strength("steer_right")
	rotate_input *= steering
	
	#rotate car mesh
	if ball.linear_velocity.length() > turn_stop_limit:
		var new_basis = car_mesh.global_transform.basis.rotated(car_mesh.global_transform.basis.y, rotate_input)
		car_mesh.global_transform.basis = car_mesh.global_transform.basis.slerp(new_basis, turn_speed * delta)
		car_mesh.global_transform = car_mesh.global_transform.orthonormalized()
	
	print(speed_input)
	print(rotate_input)
