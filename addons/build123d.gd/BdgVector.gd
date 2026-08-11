extends RefCounted
## BdgVector - static vector math helpers on Godot Vector3
## Mirrors build123d's Vector class methods as pure functions.
class_name BdgVector

const TOL := 1e-6

## unsigned angle in degrees between two vectors
static func get_angle(a: Vector3, b: Vector3) -> float:
	return rad_to_deg(a.angle_to(b))

## signed angle in degrees between two vectors with given normal
## angle = atan2((a x b) . n, a . b)
static func get_signed_angle(a: Vector3, b: Vector3, normal: Vector3 = Vector3(0, 0, -1)) -> float:
	var cross := a.cross(b)
	var dot := a.dot(b)
	return rad_to_deg(atan2(cross.dot(normal), dot))

## project vector a onto the line represented by Vector3 line
static func project_to_line(a: Vector3, line: Vector3) -> Vector3:
	var ll := line.length_squared()
	if ll == 0.0:
		return Vector3.ZERO
	return line * (a.dot(line) / ll)

## minimum unsigned distance between point and plane (BdgPlane or gp_Pln style)
static func distance_to_plane(p: Vector3, plane_origin: Vector3, plane_normal: Vector3) -> float:
	var v := p - plane_origin
	return abs(v.dot(plane_normal.normalized()))

## signed distance from plane to point
static func signed_distance_from_plane(p: Vector3, plane_origin: Vector3, plane_z: Vector3) -> float:
	return (p - plane_origin).dot(plane_z.normalized())

## project point onto plane defined by origin + normal
static func project_to_plane(p: Vector3, plane_origin: Vector3, plane_normal: Vector3) -> Vector3:
	var n := plane_normal.normalized()
	return p - n * (p - plane_origin).dot(n)

## rotate vector about an axis (position + direction) by angle in degrees
static func rotate(v: Vector3, axis_pos: Vector3, axis_dir: Vector3, angle_deg: float) -> Vector3:
	var d := axis_dir.normalized()
	return v.rotated(d, deg_to_rad(angle_deg))

## signed distance between two vectors (points)
static func distance(a: Vector3, b: Vector3) -> float:
	return a.distance_to(b)

## multiply component-wise
static func multiply(a: Vector3, s: float) -> Vector3:
	return a * s

## copy
static func copy(v: Vector3) -> Vector3:
	return Vector3(v.x, v.y, v.z)

## wrap zeros below tolerance (build123d format-style trimming)
static func trim_float(x: float, precision: int, tol: float = TOL) -> float:
	var r := roundf(x * pow(10.0, precision)) / pow(10.0, precision)
	return 0.0 if abs(x) < tol else r
