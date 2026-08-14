extends "res://demo/BdgExample.gd"
class_name ExKeyCap

func _init() -> void:
	super(
		"key_cap",
		"Cherry MX Key Cap",
		"Mechanical",
		"Parametric mechanical keyboard keycap with 15-degree tapered draft angle, spherical dished concave top surface, hollowed internal cavity, and stem ribs.",
		"https://raw.githubusercontent.com/gumyr/build123d/dev/examples/key_cap.py"
	)
	gdscript_code = """# 1. Base rectangle plan & tapered loft (extrude amount=10, taper=15)
var base_wire: BdgWire = Bdg.make_rect_wire(18.0, 18.0)
var top_dim: float = 18.0 - 2.0 * 10.0 * tan(deg_to_rad(15.0))
var top_wire: BdgWire = Bdg.translate(Bdg.make_rect_wire(top_dim, top_dim), Vector3(0, 0, 10.0)) as BdgWire

var key_cap: BdgShape = Bdg.make_loft([base_wire, top_wire], true)

# 2. Dished spherical top surface cut (build123d Sphere SUBTRACT)
var dish_sphere: BdgShape = Bdg.translate(Bdg.make_sphere(40.0), Vector3(0, -3.0, 47.0))
key_cap = Bdg.cut(key_cap, dish_sphere)

# 3. Fillet all edges above the bottom (Axis.Z position in (0, 30])
var top_edges: Array = []
for e in Bdg.edges(key_cap):
	var edge: BdgEdge = e as BdgEdge
	if Bdg.center(edge).z > 1.0:
		top_edges.append(edge)
if not top_edges.is_empty():
	key_cap = Bdg.fillet_edges(key_cap, 1.0, top_edges)

# 4. Hollow out by subtracting a scaled copy (build123d scale by=(0.925,0.925,0.85))
var cavity: BdgShape = Bdg.scaled(key_cap, Vector3(0.925, 0.925, 0.85))
key_cap = Bdg.cut(key_cap, cavity)

# 5. Internal cavity size at z = 4 * MM
#    The cavity section at z=4 is the key_cap section at z = 4/0.85 (pre-scale).
var internal_size: float = (18.0 - 2.0 * (4.0 / 0.85) * tan(deg_to_rad(15.0))) * 0.925

# 6. Mount ribs + stem, filling the cavity up to the key cap underside.
#    build123d's `extrude(until=Until.NEXT)` trims the mount to the cavity,
#    so intersect the mount prisms with the cavity solid to reproduce it.
var mount_h: float = 3.0
var rib1: BdgShape = Bdg.translate(Bdg.extrude_vec(Bdg.make_rect(internal_size, 0.5), Vector3(0, 0, mount_h)), Vector3(0, 0, 4.0))
var rib2: BdgShape = Bdg.translate(Bdg.extrude_vec(Bdg.make_rect(0.5, internal_size), Vector3(0, 0, mount_h)), Vector3(0, 0, 4.0))
var stem: BdgShape = Bdg.translate(Bdg.make_cylinder(5.5 * 0.5, mount_h), Vector3(0, 0, 4.0))
var mount: BdgShape = Bdg.intersect(Bdg.fuse(Bdg.fuse(rib1, rib2), stem), cavity)
key_cap = Bdg.fuse(key_cap, mount)

# 7. Cruciform switch socket on the bottom of the ribs (build123d extrude ADD)
var socket_cyl: BdgShape = Bdg.translate(Bdg.make_cylinder(5.5 * 0.5, 3.5), Vector3(0, 0, 0.5))
var cross_h: BdgShape = Bdg.translate(Bdg.extrude_vec(Bdg.make_rect(4.1, 1.17), Vector3(0, 0, 3.5)), Vector3(0, 0, 0.5))
var cross_v: BdgShape = Bdg.translate(Bdg.extrude_vec(Bdg.make_rect(1.17, 4.1), Vector3(0, 0, 3.5)), Vector3(0, 0, 0.5))
var socket: BdgShape = Bdg.cut(Bdg.cut(socket_cyl, cross_h), cross_v)
key_cap = Bdg.fuse(key_cap, socket)

return Bdg.clean(key_cap)"""
