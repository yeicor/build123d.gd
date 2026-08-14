extends BdgLineObject
## BdgAirfoil - 1D Curve: NACA 4-Digit Airfoil Profile.
## Generates aerodynamic NACA 4-digit airfoil curves (e.g., NACA 0012, NACA 2412, NACA 4415).
## Mirrors build123d/objects_curve.py Airfoil.
class_name BdgAirfoil

var naca: String
var chord: float
var count: int

## Args:
##   naca_code: String (e.g. "2412" or "0012")
##   chord_length: float (chord length along X axis)
##   sample_count: int (number of points per surface, default 100)
##   mode: BdgEnums.Mode = ADD
func _init(naca_code: String = "2412", chord_length: float = 100.0, sample_count: int = 100, md: int = BdgEnums.Mode.ADD) -> void:
	super()
	naca = naca_code
	chord = chord_length
	count = max(10, sample_count)

	var pts := _generate_naca_points(naca, chord, count)
	var wire := BdgWire.make_polygon(pts, true)
	if wire != null and not wire.is_null():
		_wrapped = wire._wrapped
	_register(md)

static func _generate_naca_points(code: String, c: float, n: int) -> Array[Vector3]:
	var clean := code.strip_edges()
	if clean.length() < 4:
		clean = "0012"

	var m := float(clean[0].to_int()) / 100.0       # Max camber
	var p := float(clean[1].to_int()) / 10.0        # Camber location
	var t := float(clean.substr(2, 2).to_int()) / 100.0 # Thickness

	var upper_pts: Array[Vector3] = []
	var lower_pts: Array[Vector3] = []

	# Cosine spacing for high resolution near leading edge
	for i in range(n + 1):
		var beta := float(i) * PI / float(n)
		var x := 0.5 * (1.0 - cos(beta)) # x from 0.0 to 1.0

		var yt := 5.0 * t * (
			0.2969 * sqrt(maxf(0.0, x))
			- 0.1260 * x
			- 0.3516 * (x * x)
			+ 0.2843 * (x * x * x)
			- 0.1036 * (x * x * x * x) # Closed trailing edge
		)

		var yc := 0.0
		var dyc_dx := 0.0
		if p > 0.0:
			if x < p:
				yc = (m / (p * p)) * (2.0 * p * x - x * x)
				dyc_dx = (2.0 * m / (p * p)) * (p - x)
			else:
				yc = (m / ((1.0 - p) * (1.0 - p))) * ((1.0 - 2.0 * p) + 2.0 * p * x - x * x)
				dyc_dx = (2.0 * m / ((1.0 - p) * (1.0 - p))) * (p - x)

		var theta := atan(dyc_dx)
		var xu := (x - yt * sin(theta)) * c
		var yu := (yc + yt * cos(theta)) * c
		var xl := (x + yt * sin(theta)) * c
		var yl := (yc - yt * cos(theta)) * c

		upper_pts.append(Vector3(xu, yu, 0.0))
		if i > 0 and i < n:
			lower_pts.append(Vector3(xl, yl, 0.0))

	# Combine points starting from trailing edge upper -> leading edge -> trailing edge lower
	var combined: Array[Vector3] = []
	for i in range(upper_pts.size() - 1, -1, -1):
		combined.append(upper_pts[i])
	for pt in lower_pts:
		combined.append(pt)

	return combined
