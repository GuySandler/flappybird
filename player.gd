extends CharacterBody2D

var gamestarted = false

var speed: float = 200.0
var jump_force: float = -400.0
var gravity: float = 900.0

var pipe_texture: Texture2D
var pipe_gap: float = 265.0
var pipe_spawn_x: float = 1250
var pipe_min_y: float = -60
var pipe_max_y: float = 690
var pipe_timer: float = 0.0
var pipe_interval: float = 2.0
var pipe_speed: float = 200
var pipes: Array = []
var pipe_reference: StaticBody2D

var score: int = 0
var night = false;

func _ready() -> void:
	gamestarted = false
	night = Highscore.get_mode()
	if night:
		var nighttxt = load("res://asprite/newbackgroundsunset.svg")
		$"../background".texture = nighttxt
	else:
		var day = load("res://asprite/newbackground.svg")
		$"../background".texture = day
	$"../score".text = str(Highscore.get_score())
	pipe_reference = $"../pipe"
	pipe_reference.visible = false
	$sprite.animation_finished.connect(_on_anim_done)

func startGame() -> void:
	$"../title".visible = false
	$"../byme".visible = false
	$"../presstoplay".visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		if not gamestarted:
			gamestarted = true
			startGame()
		playPlayerAnimation()
	if Input.is_action_just_pressed("ui_select") and !gamestarted:
		if night:
			night = false
			Highscore.set_mode(false)
			var day = load("res://asprite/newbackground.svg")
			$"../background".texture = day
		else:
			night = true
			Highscore.set_mode(true)
			var nighttxt = load("res://asprite/newbackgroundsunset.svg")
			$"../background".texture = nighttxt
	
	if gamestarted:
		pipe_timer += delta
		if pipe_timer >= pipe_interval:
			pipe_timer = 0.0
			var randint = randi_range(1, 100)
			var pipetexture
			var pipetexturetop
			if randint <= 15:
				pipetexture = "/pipetop2.svg"
				pipetexturetop = "/pipetop7.svg"
			elif randint <= 30:
				pipetexture = "/pipetop3.svg"
				pipetexturetop = "/pipetop8.svg"
			elif randint <= 40:
				pipetexture = "/pipetop4.svg"
				pipetexturetop = "/pipetop9.svg"
			else:
				pipetexturetop = "/pipetop5.svg"
				pipetexture = "/pipetop1.svg"
			spawn_pipe_pair(pipetexturetop, pipetexture)
		
	for pipe in pipes:
		pipe.position.x -= pipe_speed * delta
		
		if not pipe.get_meta("passed"):
			if pipe.position.x + pipe.get_node("pipesprite").texture.get_width() < global_position.x:
				pipe.set_meta("passed", true)
				score += 1
				print("Score: ", score)
				$"../score".text = str(score)
				
				if score > Highscore.get_score():
					Highscore.set_score(score)
	
	for pipe in pipes.duplicate():
		if pipe.position.x < -100:
			pipes.erase(pipe)
			pipe.queue_free()

func playPlayerAnimation() -> void:
	$sprite.stop()
	$sprite.play("jump")
	playerJump()

func playerJump() -> void:
	if night:
		velocity.y = jump_force
		return
	velocity.y = jump_force

func _physics_process(delta: float) -> void:
	if gamestarted:
		if night:
			velocity.y += (gravity/1.65) * delta
		else:
			velocity.y += gravity * delta
		
	move_and_slide()
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "killzone1" or collision.get_collider().name == "killzone2" or collision.get_collider().name.begins_with("@StaticBody2D"):
			print("Collided")
			gameover()

func _on_anim_done() -> void:
	$sprite.frame = 0

func spawn_pipe_pair(pipetexture, pipetoptexture) -> void:
	var gap_y = randf_range(pipe_min_y + pipe_gap, pipe_max_y - pipe_gap)
	var pipe_sprite = pipe_reference.get_node("pipesprite") as Sprite2D
	var segment_height = pipe_sprite.texture.get_height()
	var end_pipe_path = "res://asprite" + pipetoptexture
	var end_pipe_texture: Texture2D = load(end_pipe_path)
	var pipe_path = "res://asprite" + pipetexture
	var pipe_texture: Texture2D = load(pipe_path)
	pipe_reference.get_node("pipesprite").texture = pipe_texture

	var top_y = gap_y - pipe_gap / 2
	var first_top = true
	while top_y > -segment_height:
		var top_pipe = pipe_reference.duplicate() as StaticBody2D
		top_pipe.visible = true
		top_pipe.position = Vector2(pipe_spawn_x, top_y)
		var top_sprite = top_pipe.get_node("pipesprite") as Sprite2D
		top_sprite.scale.y = -1
		
		if first_top:
			top_pipe.get_node("pipesprite").texture = end_pipe_texture
			top_pipe.set_meta("passed", false)
			first_top = false
		else:
			top_pipe.set_meta("passed", true)
		
		get_tree().current_scene.add_child(top_pipe)
		pipes.append(top_pipe)
		
		top_y -= segment_height

	var bottom_y = gap_y + pipe_gap / 2
	var first_bottom = true
	while bottom_y < get_viewport_rect().size.y + segment_height:
		var bottom_pipe = pipe_reference.duplicate() as StaticBody2D
		bottom_pipe.visible = true
		bottom_pipe.position = Vector2(pipe_spawn_x, bottom_y)
		var bottom_sprite = bottom_pipe.get_node("pipesprite") as Sprite2D
		
		if first_bottom:
			bottom_pipe.get_node("pipesprite").texture = end_pipe_texture
			first_bottom = false
		
		bottom_pipe.set_meta("passed", true)
		
		get_tree().current_scene.add_child(bottom_pipe)
		pipes.append(bottom_pipe)
		
		bottom_y += segment_height

func gameover() -> void:
	get_tree().reload_current_scene()
