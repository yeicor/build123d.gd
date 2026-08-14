extends RefCounted
## BdgJoint - CAD Assembly Joint Connection.
## Represents kinematic relationships (Rigid, Revolute, Linear, Cylindrical, Ball)
## between components in a CAD assembly.
## Mirrors build123d/joints.py.
class_name BdgJoint

enum Type {
	RIGID,
	REVOLUTE,
	LINEAR,
	CYLINDRICAL,
	BALL,
}

var label: String = ""
var joint_type: int = Type.RIGID
var parent_shape: BdgShape = null
var parent_location: BdgLocation = null
var child_shape: BdgShape = null
var child_location: BdgLocation = null

## Axis of motion (rotation or translation)
var axis: BdgAxis = null

## Current joint position (angle in degrees or distance in mm)
var position: float = 0.0

## Lower and upper motion limits
var min_limit: float = -INF
var max_limit: float = INF

func _init(type: int = Type.RIGID, lbl: String = "", p_loc: BdgLocation = null, c_loc: BdgLocation = null, ax: BdgAxis = null) -> void:
	joint_type = type
	label = lbl
	parent_location = p_loc if p_loc != null else BdgLocation.new()
	child_location = c_loc if c_loc != null else BdgLocation.new()
	axis = ax if ax != null else BdgAxis.Z

## Create a rigid fixed joint
static func make_rigid(p_loc: BdgLocation, c_loc: BdgLocation, lbl: String = "") -> BdgJoint:
	return BdgJoint.new(Type.RIGID, lbl, p_loc, c_loc)

## Create a revolute (rotational) joint
static func make_revolute(p_loc: BdgLocation, c_loc: BdgLocation, ax: BdgAxis, min_ang: float = -180.0, max_ang: float = 180.0, lbl: String = "") -> BdgJoint:
	var j := BdgJoint.new(Type.REVOLUTE, lbl, p_loc, c_loc, ax)
	j.min_limit = min_ang
	j.max_limit = max_ang
	return j

## Create a linear (prismatic sliding) joint
static func make_linear(p_loc: BdgLocation, c_loc: BdgLocation, ax: BdgAxis, min_dist: float = 0.0, max_dist: float = 100.0, lbl: String = "") -> BdgJoint:
	var j := BdgJoint.new(Type.LINEAR, lbl, p_loc, c_loc, ax)
	j.min_limit = min_dist
	j.max_limit = max_dist
	return j

## Compute relative transform for child shape at current position
func compute_child_location(val: float = 0.0) -> BdgLocation:
	position = clampf(val, min_limit, max_limit)
	match joint_type:
		Type.RIGID:
			return parent_location.multiplied(child_location.inverted())
		Type.REVOLUTE:
			var rot := Quaternion(axis.direction.normalized(), deg_to_rad(position))
			var motion := BdgLocation.new(Vector3.ZERO, rot)
			return parent_location.multiplied(motion).multiplied(child_location.inverted())
		Type.LINEAR:
			var trans := axis.direction.normalized() * position
			var motion := BdgLocation.new(trans, Quaternion.IDENTITY)
			return parent_location.multiplied(motion).multiplied(child_location.inverted())
	return parent_location
