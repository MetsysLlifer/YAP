class_name BASE
extends Resource

@export_range(0, 100) var max_speed: float = 100
@export_range(0, 100) var speed: float = 50
@export_range(0, 1000) var attack: int = 100
@export_range(0, 1000) var dexterity: int

@export_range(0, 1000) var health : int = 100


@export var ground_fiction_factor := 10.0
@export var accelerate := 1200.0
@export var decelerate := 1000.0

#instensity of the force to bounce back when colliding with any objects
@export_range(1, 100000) var avoidance_strength := 21000.0


enum STATES {IDLE, WALK, WORK}
