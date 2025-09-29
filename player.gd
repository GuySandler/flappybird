extends CharacterBody2D

var gamestarted = false

var speed: float = 200.0
var jump_force: float = -400.0
var gravity: float = 900.0

var pipe_texture: Texture2D
var pipe_gap: float = 150.0
var pipe_spawn_x: float = 1250
var pipe_min_y: float = -20
var pipe_max_y: float = 650
var pipe_timer: float = 0.0
var pipe_interval: float = 2.0

func _ready() -> void:
	gamestarted = false
	$sprite.animation_finished.connect(_on_anim_done)

func startGame() -> void:
	$"../title".visible = false
	$"../byme".visible = false
	$"../presstoplay".visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		if !gamestarted:
			gamestarted = true
			startGame()
		playPlayerAnimation()
	
	if gamestarted:
		pipe_timer += delta
		if pipe_timer >= pipe_interval:
			pipe_timer = 0.0
			spawn_pipe_pair() 

func playPlayerAnimation() -> void:
	$sprite.stop()
	$sprite.play("jump")
	playerJump()

func playerJump() -> void:
	velocity.y = jump_force

func _physics_process(delta: float) -> void:
	if gamestarted:
		velocity.y += gravity * delta
		
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "killzone1" || collision.get_collider().name == "killzone2":
			print("Collided")
			gameover()



func _on_anim_done() -> void:
	$sprite.frame = 0
	
func create_pipe_tile(texture: Texture2D, position: Vector2) -> Area2D:
	var pipe_tile = Area2D.new()
	
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2.ZERO
	pipe_tile.add_child(sprite)
	
	pipe_tile.position = position
	
	return pipe_tile

func spawn_pipe_pair() -> void:
	var gap_y = randf_range(pipe_min_y, pipe_max_y)
	
	var top_pipe = create_pipe_tile(pipe_texture, Vector2(pipe_spawn_x, gap_y - pipe_gap / 2))
	top_pipe.scale.y = -1
	add_child(top_pipe)
	
	var bottom_pipe = create_pipe_tile(pipe_texture, Vector2(pipe_spawn_x, gap_y + pipe_gap / 2))
	add_child(bottom_pipe)

func gameover() -> void:
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()
