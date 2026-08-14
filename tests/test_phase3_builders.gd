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
	_test_grid_locations()
	_test_polar_locations()
	_test_hex_locations()
	_test_builder_grid_holes()
	_test_builder_polar_bolt_circle()
	print("--- Phase 3 Test Results ---")
	print("Checks: %d, Failures: %d" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _test_grid_locations() -> void:
	var grid := BdgGridLocations.new(10.0, 20.0, 3, 2)
	check(grid.locations.size() == 6, "GridLocations 3x2 has 6 locations")
	var loc0 := grid.locations[0]
	check(loc0 is BdgLocation, "Grid location is BdgLocation")

func _test_polar_locations() -> void:
	var polar := BdgPolarLocations.new(10.0, 4)
	check(polar.locations.size() == 4, "PolarLocations count 4 has 4 locations")
	var p0 := polar.locations[0].position
	var p1 := polar.locations[1].position
	check(p0.distance_to(Vector3(10, 0, 0)) < 1e-4, "Polar first point at (10,0,0)")
	check(p1.distance_to(Vector3(0, 10, 0)) < 1e-4, "Polar second point at (0,10,0)")

func _test_hex_locations() -> void:
	var hex := BdgHexLocations.new(5.0, 2, 2)
	check(hex.locations.size() == 4, "HexLocations 2x2 has 4 locations")

func _test_builder_grid_holes() -> void:
	# Build a plate with a 2x2 grid of holes
	var plate := Bdg.build_part(func():
		Bdg.box(50.0, 50.0, 10.0)
		Bdg.grid_locations(20.0, 20.0, 2, 2, func():
			Bdg.cylinder(2.0, 15.0, 360.0, Vector3.ZERO, BdgEnums.Align.CENTER, BdgEnums.Mode.SUBTRACT)
		)
	)
	check(plate != null, "Plate with grid holes created")
	if plate != null:
		var solid_vol := 50.0 * 50.0 * 10.0
		var hole_vol := 4.0 * (PI * 4.0 * 10.0)
		var expected_vol := solid_vol - hole_vol
		check(absf(plate.volume() - expected_vol) < 2.0, "Volume reflects 4 holes cut: %f vs %f" % [plate.volume(), expected_vol])

func _test_builder_polar_bolt_circle() -> void:
	# Flange with 6 bolt holes around radius 15
	var flange := Bdg.build_part(func():
		Bdg.cylinder(25.0, 6.0) # base flange
		Bdg.cylinder(10.0, 12.0) # central boss
		Bdg.cylinder(5.0, 20.0, 360.0, Vector3.ZERO, BdgEnums.Align.CENTER, BdgEnums.Mode.SUBTRACT) # central bore
		Bdg.polar_locations(18.0, 6, 0.0, 360.0, true, func():
			Bdg.cylinder(1.5, 10.0, 360.0, Vector3.ZERO, BdgEnums.Align.CENTER, BdgEnums.Mode.SUBTRACT)
		)
	)
	check(flange != null, "Flange with bolt circle created")
	if flange != null:
		var base_vol := PI * 25.0 * 25.0 * 6.0
		var boss_vol := PI * 10.0 * 10.0 * 6.0
		var bore_vol := PI * 5.0 * 5.0 * 12.0
		var bolt_vol := 6.0 * (PI * 1.5 * 1.5 * 6.0)
		var expected_vol := base_vol + boss_vol - bore_vol - bolt_vol
		check(absf(flange.volume() - expected_vol) < 5.0, "Flange volume matches exact CAD model: %f vs %f" % [flange.volume(), expected_vol])
