extends Node2D

export (float) var length = 30
export (float) var constrain = 1
export (Vector2) var gravity = Vector2(0,9.8)
export (float) var friction = 0.9
export (bool) var start_pin = true
export (bool) var end_pin = true

var pos: PoolVector2Array
var pos_ex: PoolVector2Array
var count: int

var force_applied = Vector2.ZERO

func _ready():
	count = get_count(length)
	resize_arrays()
	init_position()
	pos[count-1] = Vector2.ZERO
	pos_ex[count-1] = Vector2.ZERO
	pos[0] = $handset/chainEnd.global_position - global_position
	pos_ex[0] = $handset/chainEnd.global_position - global_position

func get_count(distance: float):
	var new_count = ceil(distance / constrain)
	return new_count

func resize_arrays():
	pos.resize(count)
	pos_ex.resize(count)

func init_position():
	for i in range(count):
		pos[i] = position + Vector2(constrain *i, 0)
		pos_ex[i] = position + Vector2(constrain *i, 0)
	position = Vector2.ZERO

func _process(delta):
	var cable_end = $handset/chainEnd.global_position - global_position
#	print($handset.linear_velocity)
#	print($handset.applied_force)
#	print(length/pos[count-1].distance_to(cable_end))
	
	pos[0] = cable_end
	pos_ex[0] = cable_end
	
	if force_applied != Vector2.ZERO: 
		$handset.add_central_force(-force_applied)
	
	if length/pos[count-1].distance_to(cable_end) > 1: #within radius
		force_applied = Vector2.ZERO
	else: 
#		force_applied = (($handset.mass*pow($handset.linear_velocity.length(),2))/pow(cable_end.length(),2) )  * (cable_end) *(-1.0)
		force_applied = ($handset.weight*cable_end) / cable_end.length()
		$handset.add_central_force(force_applied)
			
#	if length/pos[count-1].distance_to($handset/chainEnd.global_position) >= 1: #within radius
#		pos[0] = $handset.global_position + cable_offset
#		pos_ex[0] = $handset.global_position + cable_offset
#	else: 
#		print("too long!")
	
#	if Input.is_action_pressed("click"):	#Move start point
#		pos[0] = get_global_mouse_position()
#		pos_ex[0] = get_global_mouse_position()
#		#find the best feel length ratio
#		print("length ratio to distance ",length/pos[count-1].distance_to(pos[0]))

#	if Input.is_action_pressed("right_click"):	#Move start point
#		pos[count-1] = get_global_mouse_position()
#		pos_ex[count-1] = get_global_mouse_position()
		
	update_points(delta)
	for i in range(5):
		update_distance()
#	update_distance()	#Repeat to get tighter rope
#	update_distance()
	$Line2D.points = pos

func update_points(delta):
	for i in range (count):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=count-1) || (i==0 && !start_pin) || (i==count-1 && !end_pin):
			var vec2 = (pos[i] - pos_ex[i]) * friction
			pos_ex[i] = pos[i]
			pos[i] += vec2 + (gravity * delta)

func update_distance():
	for i in range(count):
		if i == count-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		if i == 0:
			if start_pin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		elif i == count-1:
			pass
		else:
			if i+1 == count-1 && end_pin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
