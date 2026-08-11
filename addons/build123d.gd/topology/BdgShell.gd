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
