extends BdgLocations
## BdgGridLocations - 2D rectangular grid pattern of locations.
## Mirrors build123d/build_common.py GridLocations.
class_name BdgGridLocations

var x_spacing: float
var y_spacing: float
var x_count: int
var y_count: int

## Args: x_spacing: float, y_spacing: float, x_count: int, y_count: int
func _init(x_sp: float, y_sp: float, x_cnt: int, y_cnt: int) -> void:
	super()
	x_spacing = x_sp
	y_spacing = y_sp
	x_count = max(1, x_cnt)
	y_count = max(1, y_cnt)

	var x_offset := float(x_count - 1) * x_spacing * 0.5
	var y_offset := float(y_count - 1) * y_spacing * 0.5

	locations = []
	for iy in y_count:
		for ix in x_count:
			var p := Vector3(
				float(ix) * x_spacing - x_offset,
				float(iy) * y_spacing - y_offset,
				0.0
			)
			locations.append(BdgLocation.new(p))
