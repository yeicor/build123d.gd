extends RefCounted
## BdgAssembly - Hierarchical CAD Assembly.
## Supports named components, relative transforms, joints/kinematics, and color hierarchy.
## Mirrors build123d/build_common.py Compound / Assembly.
class_name BdgAssembly

var label: String = ""
var shape: BdgShape = null
var location: BdgLocation = null
var color: Color = Color.WHITE
var children: Array[BdgAssembly] = []
var joints: Array[BdgJoint] = []
var parent: BdgAssembly = null

func _init(comp_shape: BdgShape = null, lbl: String = "", loc: BdgLocation = null, col: Color = Color.WHITE) -> void:
	shape = comp_shape
	label = lbl
	location = loc if loc != null else BdgLocation.new()
	color = col
	children = []
	joints = []

## Add a child shape or sub-assembly to this assembly.
func add(child: Variant, child_label: String = "", child_loc: BdgLocation = null, child_color: Color = Color.WHITE) -> BdgAssembly:
	var sub: BdgAssembly = null
	if child is BdgAssembly:
		sub = child
		if child_label != "":
			sub.label = child_label
		if child_loc != null:
			sub.location = child_loc
		if child_color != Color.WHITE:
			sub.color = child_color
	elif child is BdgShape:
		sub = BdgAssembly.new(child, child_label, child_loc, child_color)

	if sub != null:
		sub.parent = self
		children.append(sub)
	return sub

## Alias for add(child, child_label, child_loc, child_color)
func add_child(child: Variant, child_label: String = "", child_loc: BdgLocation = null, child_color: Color = Color.WHITE) -> BdgAssembly:
	return add(child, child_label, child_loc, child_color)

## Add a joint constraint between components
func add_joint(joint: BdgJoint) -> void:
	joints.append(joint)

## Find child assembly by name
func find(child_name: String) -> BdgAssembly:
	if label == child_name:
		return self
	for c in children:
		var found := c.find(child_name)
		if found != null:
			return found
	return null

## Compute total world/global transform location
func world_location() -> BdgLocation:
	if parent == null:
		return location
	return parent.world_location().multiplied(location)

## Flatten assembly into a single BdgCompound containing all positioned shapes.
func to_compound() -> BdgCompound:
	var all_shapes: Array = []
	_collect_shapes(BdgLocation.new(), all_shapes)
	return BdgCompound.make_compound(all_shapes)

func _collect_shapes(parent_loc: BdgLocation, out: Array) -> void:
	var cur_loc := parent_loc.multiplied(location)
	if shape != null and not shape.is_null():
		var positioned := shape.located(cur_loc)
		positioned.label = label
		positioned._color = BdgColor.new(color) if color != null else null
		out.append(positioned)
	for c in children:
		c._collect_shapes(cur_loc, out)

## Export entire assembly as STEP file
func export_step(path: String) -> bool:
	return BdgIO.export_step(to_compound(), path)

## Export entire assembly as STL mesh
func export_stl(path: String) -> bool:
	return BdgIO.export_stl(to_compound(), path)
