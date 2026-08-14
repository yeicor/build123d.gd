extends BdgLocations
## BdgPolarLocations - Circular polar pattern of locations.
## Mirrors build123d/build_common.py PolarLocations.
class_name BdgPolarLocations

var radius: float
var count: int
var start_angle: float
var angular_range: float
var rotate: bool

## Args: radius: float, count: int, start_angle: float = 0.0, angular_range: float = 360.0, rotate: bool = true
func _init(r: float, cnt: int, start_deg: float = 0.0, range_deg: float = 360.0, rot: bool = true) -> void:
	super()
	radius = r
	count = max(1, cnt)
	start_angle = start_deg
	angular_range = range_deg
	rotate = rot

	locations = []
	var is_full_circle := is_equal_approx(absf(angular_range), 360.0)
	var step := angular_range / float(count if is_full_circle else max(1, count - 1))

	for i in count:
		var deg := start_angle + float(i) * step
		var rad := deg_to_rad(deg)
		var pos := Vector3(cos(rad) * radius, sin(rad) * radius, 0.0)
		var rot_q := Quaternion(Vector3.BACK, rad) if rotate else Quaternion.IDENTITY
		locations.append(BdgLocation.new(pos, rot_q))
