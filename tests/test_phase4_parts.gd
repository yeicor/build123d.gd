extends SceneTree

var checks := 0
var failures := 0

func check(cond: bool, name: String) -> void:
	checks += 1
	if not cond:
		failures += 1
		printerr("FAIL: " + name)
	else:
		print("ok: " + name)

func _init():
	_test_hole()
	_test_counter_bore_hole()
	_test_counter_sink_hole()
	_test_hex_bolt()
	_test_hex_nut()
	_test_socket_head_screw()
	_test_parametric_mechanical_assembly()
	print("--- Phase 4 Test Results ---")
	print("Checks: %d, Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_hole() -> void:
	var plate := Bdg.build_part(func():
		Bdg.box(30.0, 30.0, 10.0)
		Bdg.hole(3.0, 15.0)
	)
	check(plate != null, "Bdg.hole created through plate")
	if plate != null:
		var expected := 30.0 * 30.0 * 10.0 - PI * 9.0 * 10.0
		check(absf(plate.volume() - expected) < 1.0, "plate volume with hole: %f vs %f" % [plate.volume(), expected])

func _test_counter_bore_hole() -> void:
	var block := Bdg.build_part(func():
		Bdg.box(30.0, 30.0, 20.0)
		Bdg.counter_bore_hole(3.0, 20.0, 6.0, 5.0)
	)
	check(block != null, "CounterBoreHole created")
	if block != null:
		check(block.volume() < 18000.0, "counterbore block volume: %f < 18000.0" % block.volume())



func _test_counter_sink_hole() -> void:
	var block := Bdg.build_part(func():
		Bdg.box(30.0, 30.0, 20.0)
		Bdg.counter_sink_hole(3.0, 20.0, 6.0, 90.0)
	)
	check(block != null, "CounterSinkHole created")
	if block != null:
		check(block.volume() < 30.0 * 30.0 * 20.0, "countersink cuts into block")

func _test_hex_bolt() -> void:
	var bolt := BdgHexBolt.new(3.0, 20.0)
	check(bolt != null, "HexBolt created")
	var solids := bolt.solids()
	check(solids.size() == 1, "HexBolt is single fused solid")
	if not solids.is_empty():
		check(solids[0].volume() > 0.0, "HexBolt has positive volume: %f" % solids[0].volume())

func _test_hex_nut() -> void:
	var nut := BdgHexNut.new(3.0)
	check(nut != null, "HexNut created")
	var solids := nut.solids()
	check(solids.size() == 1, "HexNut is single solid")
	if not solids.is_empty():
		check(solids[0].volume() > 0.0, "HexNut has positive volume: %f" % solids[0].volume())

func _test_socket_head_screw() -> void:
	var shcs := BdgSocketHeadCapScrew.new(3.0, 25.0)
	check(shcs != null, "SocketHeadCapScrew created")
	var solids := shcs.solids()
	check(solids.size() == 1, "SocketHeadCapScrew is single solid")
	if not solids.is_empty():
		check(solids[0].volume() > 0.0, "SocketHeadCapScrew volume > 0: %f" % solids[0].volume())

func _test_parametric_mechanical_assembly() -> void:
	# Full parametric assembly: bracket with 4 counterbore mounting holes and central bore
	var bracket := Bdg.build_part(func():
		Bdg.box(60.0, 40.0, 12.0)
		Bdg.hole(8.0, 20.0) # center bore
		Bdg.grid_locations(44.0, 24.0, 2, 2, func():
			Bdg.counter_bore_hole(2.5, 15.0, 4.5, 3.0)
		)
	)
	check(bracket != null, "Mechanical bracket created")
	if bracket != null:
		check(bracket.solids().size() == 1, "Bracket is a single solid part")
		check(bracket.volume() < 60.0 * 40.0 * 12.0, "Bracket volume has cuts")
