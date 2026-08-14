extends BdgLocations
## BdgHexLocations - Hexagonal packing pattern of locations.
## Mirrors build123d/build_common.py HexLocations.
class_name BdgHexLocations

var radius: float
var apothem: float
var diagonal: float
var x_count: int
var y_count: int
var major_radius: bool

## Args: radius: float, x_count: int, y_count: int, major_radius: bool = false
func _init(radius_in: float, x_cnt: int, y_cnt: int, major_radius_in: bool = false) -> void:
	super()
	major_radius = major_radius_in
	radius = radius_in
	x_count = max(1, x_cnt)
	y_count = max(1, y_cnt)

	if major_radius:
		diagonal = 2.0 * radius
		apothem = radius * cos(PI / 6.0)
	else:
		diagonal = 4.0 * radius / sqrt(3.0)
		apothem = radius

	var x_spacing := 3.0 * diagonal / 4.0
	var y_spacing := diagonal * sqrt(3.0) / 2.0

	var raw: Array[Vector3] = []
	for x_val in range(0, x_count, 2):
		for y_val in range(y_count):
			raw.append(Vector3(x_spacing * float(x_val), y_spacing * float(y_val) + y_spacing * 0.5, 0.0))
	for x_val in range(1, x_count, 2):
		for y_val in range(y_count):
			raw.append(Vector3(x_spacing * float(x_val), y_spacing * float(y_val) + y_spacing, 0.0))

	var min_x: float = INF
	var max_x: float = -INF
	var min_y: float = INF
	var max_y: float = -INF
	for p in raw:
		min_x = minf(min_x, p.x)
		max_x = maxf(max_x, p.x)
		min_y = minf(min_y, p.y)
		max_y = maxf(max_y, p.y)

	var size_x := max_x - min_x
	var size_y := max_y - min_y

	locations = []
	for p in raw:
		var aligned := p + Vector3(-size_x * 0.5, -size_y * 0.5, 0.0) - Vector3(min_x, min_y, 0.0)
		locations.append(BdgLocation.new(aligned))
