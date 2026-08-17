extends BdgShape
## BdgShell - a set of connected faces, wrapping OcgTopoDSShell.
## Mirrors build123d/topology/two_d.py Shell.
class_name BdgShell

func _init(...args) -> void:
	super(args[0] if args.size() == 1 else null)

## create a shell from faces
static func make_shell(faces: Array) -> BdgShell:
	var builder := OcgTopoDSBuilder.new()
	var shell := OcgTopoDSShell.new()
	builder.make_shell(shell)
	for f in faces:
		builder.add(shell, f._wrapped)
	return BdgShell.new(shell)

func area() -> float:
	if is_null():
		return 0.0
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return props.mass()

func center() -> Vector3:
	var props := OcgGPropGProps.new()
	OcgBRepGProp.surface_properties_q(_wrapped, props, true, false)
	return BdgShape._gp_pnt_to_v3(props.centre_of_mass())

## Loft a shell (open surface) through the given section wires.
static func make_loft(objs: Array, ruled: bool = false, as_solid: bool = false) -> BdgShape:
	return BdgShape.make_loft(objs, ruled, as_solid)

## Location at UV coordinates of first face
func location_at(u: float = 0.5, v: float = 0.5) -> BdgLocation:
	var fs := faces()
	if not fs.is_empty():
		return fs[0].location_at(u, v)
	return BdgLocation.new()

## Extrude shell into solid
func extrude_amount(amount: float, dir: Vector3 = Vector3.ZERO) -> BdgShape:
	return BdgOperations.extrude(self, amount, dir)

func extrude(direction: Vector3) -> BdgShape:
	return BdgOperations.extrude(self, direction.length(), direction.normalized())

## Revolve shell around axis into solid
func revolve(angle_deg: float = 360.0, axis: BdgAxis = null) -> BdgShape:
	return BdgOperations.revolve(self, angle_deg, axis)

## Sweep shell along wire path into solid
func sweep(spine: BdgWire, aux_spines: Array = [], is_frenet: bool = false) -> BdgShape:
	return BdgOperations.sweep(self, spine)


