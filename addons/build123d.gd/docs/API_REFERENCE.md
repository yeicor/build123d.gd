# build123d.gd - Complete API Reference

Automated reference generated programmatically by `@tool` script `build_docs.gd`.


## Topology

### `BdgVertex.center() -> Vector3`
Position of the vertex

### `BdgVertex.position() -> Vector3`
Vector3 position aliases

### `BdgVertex.to_vector3() -> Vector3`
Method to_vector3 in class BdgVertex.

### `static BdgVertex.make_vertex(p: Vector3) -> BdgVertex`
Create a vertex at a point

### `BdgVertex.to_tuple() -> Array`
Convert vertex position to array tuple [x, y, z]

### `BdgVertex.split(other: Variant) -> Array`
Split vertex by vector/plane

### `BdgEdge.radius() -> float`
radius of an underlying circle or ellipse

### `BdgEdge.arc_center() -> Vector3`
center of an underlying circle or ellipse geometry

### `static BdgEdge.make_line(point1: Vector3, point2: Vector3) -> BdgEdge`
linear edge between two points

### `static BdgEdge.make_three_point_arc(p1: Vector3, p2: Vector3, p3: Vector3) -> BdgEdge`
three point arc

### `static BdgEdge.make_arc_radius(p1: Vector3, p2: Vector3, radius: float, short_sagitta: bool = true) -> BdgEdge`
Method make_arc_radius in class BdgEdge.

### `static BdgEdge.make_tangent_arc(p1: Vector3, tangent_dir: Vector3, p2: Vector3) -> BdgEdge`
tangent arc tangent arc

### `static BdgEdge.make_bezier(control_points: Array, weights: Array = []) -> BdgEdge`
bezier curve through control points (optionally rational with weights)

### `static BdgEdge.make_spline(points: Array, tangents: Array = [], scale: bool = true) -> BdgEdge`
spline interpolating through points

### `static BdgEdge.make_mid_way(first: BdgEdge, second: BdgEdge, middle: float = 0.5) -> BdgEdge`
line between two reference edges at a fractional distance (default center)

### `static BdgEdge.make_double_tangent_arc(p1: Vector3, tangent1: Vector3, p2: Vector3, tangent2: Vector3) -> BdgEdge`
double tangent arc: smooth curve from p1 (along tangent1) to p2 (along tangent2)

### `BdgEdge.trim(start_param: float, end_param: float) -> BdgEdge`
Trim this edge to parameter range (0..1)

### `BdgEdge.find_intersection(other: BdgEdge, tolerance: float = 1e-5) -> Array`
Find geometric intersections between this edge and another edge. Returns Array of Dictionaries: [{"point": Vector3, "param_self": float, "param_other": float, "distance": float}]

### `BdgEdge.project_to_shape(target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array`
Project this edge onto a target shape surface along a direction. Returns Array of BdgEdge projected onto the shape.

### `BdgEdge.find_intersection_points(other: BdgEdge, tolerance: float = 1e-5) -> Array[Vector3]`
Return list of 3D intersection points with another edge

### `BdgEdge.find_tangent(param: float = 0.0) -> Vector3`
Tangent vector at parameter u (0..1)

### `BdgEdge.param_at(distance_along: float) -> float`
Curve parameter u (0..1) corresponding to distance along curve

### `BdgEdge.param_at_point(point: Vector3) -> float`
Curve parameter u (0..1) closest to 3D point

### `BdgEdge.trim_to_length(target_length: float) -> BdgEdge`
Trim edge to fixed length starting from u=0

### `BdgEdge.trim_to_other(other: BdgEdge) -> BdgEdge`
Trim edge up to intersection with other edge

### `BdgEdge.trim_infinite() -> BdgEdge`
Trim infinite line/curve to bounded region

### `BdgEdge.is_infinite() -> bool`
Check if edge is mathematically infinite

### `BdgEdge.distribute_locations(count: int, start: float = 0.0, stop: float = 1.0) -> Array[BdgLocation]`
Distribute locations uniformly along edge

### `BdgEdge.close() -> BdgEdge`
Close edge into wire/loop

### `static BdgShell.make_shell(faces: Array) -> BdgShell`
create a shell from faces

### `BdgShell.area() -> float`
Method area in class BdgShell.

### `BdgShell.center() -> Vector3`
Method center in class BdgShell.

### `static BdgShell.make_loft(objs: Array, ruled: bool = false, as_solid: bool = false) -> BdgShape`
Loft a shell (open surface) through the given section wires.

### `BdgShell.location_at(u: float = 0.5, v: float = 0.5) -> BdgLocation`
Location at UV coordinates of first face

### `BdgShell.extrude_amount(amount: float, dir: Vector3 = Vector3.ZERO) -> BdgShape`
Extrude shell into solid

### `BdgShell.extrude(direction: Vector3) -> BdgShape`
Method extrude in class BdgShell.

### `BdgShell.revolve(angle_deg: float = 360.0, axis: BdgAxis = null) -> BdgShape`
Revolve shell around axis into solid

### `BdgShell.sweep(spine: BdgWire, aux_spines: Array = [], is_frenet: bool = false) -> BdgShape`
Sweep shell along wire path into solid

### `static BdgSolid.make_solid_from_shells(shells: Array) -> BdgSolid`
create a solid from shells (e.g. via TopoDS_Builder make_solid + add)

### `BdgSolid.center() -> Vector3`
center of mass

### `static BdgSolid.make_box(length: float, width: float, height: float, plane: BdgPlane = null) -> BdgSolid`
Box with corner at plane origin, extending positive dx, dy, dz

### `static BdgSolid.make_cylinder(radius: float, height: float, plane: BdgPlane = null, angle: float = 360.0) -> BdgSolid`
Cylinder with base center at plane origin

### `BdgSolid.fillet(radius: float, edge_list: Array = []) -> BdgSolid`
Fillet edges of this solid

### `BdgSolid.chamfer(length: float, length2: float, edge_list: Array, reference_face: BdgFace = null) -> BdgSolid`
Chamfer the given edges. length2 (optional) makes an asymmetric chamfer; reference_face identifies the side where length is measured.

### `static BdgSolid.make_revolve(section: BdgFace, angle: float, axis: BdgAxis) -> BdgSolid`
Revolve a face/wire section about axis by angle degrees into a solid.

### `BdgSolid.hollow(faces_to_remove: Array, thickness: float, tolerance: float = 1e-4) -> BdgSolid`
Hollow out this solid (creating a shell with open face openings). faces_to_remove: Array of BdgFace openings. thickness: shell wall thickness (negative = inward).

### `BdgSolid.draft(faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO) -> BdgSolid`
Apply a draft taper angle (degrees) to selected faces of this solid.

### `BdgSolid.offset_solid(amount: float, openings: Array = []) -> BdgShape`
Offset / shell solid with optional face openings

### `BdgSolid.offset_shape(amount: float, openings: Array = []) -> BdgShape`
Method offset_shape in class BdgSolid.

### `static BdgSolid.make_loft(objs: Array, ruled: bool = false, as_solid: bool = true) -> BdgShape`
Loft a solid through the given sections (wires) and optional apex vertices. objs: Array of BdgWire and/or BdgVertex (vertices only at start/end). ruled: smooth (false) or stepped/linear (true).

### `static BdgSolid.from_bounding_box(bbox: BdgBoundBox) -> BdgSolid`
Construct a solid from a bounding box

### `BdgSolid.extrude_amount(amount: float, dir: Vector3 = Vector3.ZERO) -> BdgShape`
Extrude solid / face into 3D solid by distance or direction

### `BdgSolid.extrude(direction: Vector3) -> BdgShape`
Method extrude in class BdgSolid.

### `BdgSolid.extrude_taper(amount: float, taper_deg: float) -> BdgShape`
Extrude with draft taper angle

### `BdgSolid.revolve(angle_deg: float = 360.0, axis: BdgAxis = null) -> BdgShape`
Revolve solid around an axis

### `BdgSolid.sweep(spine: BdgWire, aux_spines: Array = [], is_frenet: bool = false) -> BdgShape`
Sweep solid along a path wire

### `BdgSolid.thicken(amount: float) -> BdgSolid`
Thicken solid walls by amount

### `static BdgCompound.make_compound(shapes: Array) -> BdgCompound`
create a compound from shapes

### `BdgCompound.center() -> Vector3`
Method center in class BdgCompound.

### `BdgCompound.do_children_intersect() -> bool`
Check if children in compound intersect each other

### `static BdgCompound.make_triad(axis_length: float = 10.0) -> BdgCompound`
Construct 3D RGB XYZ axis triad compound

### `BdgCompound.unwrap() -> Array`
Extract flat array of child shapes

### `BdgCompound.project_to_viewport(plane: BdgPlane = null) -> BdgCompound`
Project compound onto 2D viewport plane

### `BdgShape.wrapped() -> OcgTopoDSShape`
Method wrapped in class BdgShape.

### `BdgShape.set_wrapped(shape: OcgTopoDSShape) -> void`
Method set_wrapped in class BdgShape.

### `BdgShape.is_null() -> bool`
Method is_null in class BdgShape.

### `BdgShape.shape_type() -> int`
OCGTT TopAbs shape enum (BdgEnums.ShapeType values)

### `BdgShape.is_valid() -> bool`
Method is_valid in class BdgShape.

### `BdgShape.clean() -> BdgShape`
Remove extraneous internal structure (unifies coplanar faces & collinear edges)

### `BdgShape.clone() -> BdgShape`
Return a clone / copy of this shape

### `BdgShape.is_same(other: BdgShape) -> bool`
Method is_same in class BdgShape.

### `BdgShape.is_equal(other: BdgShape) -> bool`
Method is_equal in class BdgShape.

### `BdgShape.reversed() -> BdgShape`
Reverse the orientation of the shape (returns a new BdgShape)

### `BdgShape.area() -> float`
Method area in class BdgShape.

### `BdgShape.volume() -> float`
Method volume in class BdgShape.

### `BdgShape.compute_volume() -> float`
Method compute_volume in class BdgShape.

### `BdgShape.center_of_mass() -> Vector3`
Method center_of_mass in class BdgShape.

### `BdgShape.center() -> Vector3`
center of the shape (bounding box center by default; subclasses override)

### `BdgShape.geom_type() -> int`
geometry type: BdgEnums.GeomType

### `BdgShape.location() -> BdgLocation`
Method location in class BdgShape.

### `BdgShape.set_location(loc: BdgLocation) -> void`
Method set_location in class BdgShape.

### `BdgShape.position() -> Vector3`
Method position in class BdgShape.

### `BdgShape.orientation() -> Quaternion`
Method orientation in class BdgShape.

### `BdgShape.located(loc: BdgLocation) -> BdgShape`
Copy of self at the given absolute location

### `BdgShape.locate(loc: BdgLocation) -> BdgShape`
Apply location in-place

### `BdgShape.move(loc: BdgLocation) -> BdgShape`
Move (relative) in place

### `BdgShape.moved(loc: BdgLocation) -> BdgShape`
Move (relative) returning copy

### `BdgShape.translate(v: Vector3) -> BdgShape`
Method translate in class BdgShape.

### `BdgShape.rotated_about(axis: BdgAxis, angle_deg: float) -> BdgShape`
Method rotated_about in class BdgShape.

### `BdgShape.rotate(axis: BdgAxis, angle_deg: float) -> BdgShape`
Alias for rotated_about

### `BdgShape.scale(factor: float, center: Vector3 = Vector3.ZERO) -> BdgShape`
Method scale in class BdgShape.

### `BdgShape.scaled(factor: Vector3, center: Vector3 = Vector3.ZERO) -> BdgShape`
Non-uniform scale about a center, returning a new copy of the shape. build123d's `scale(by=(sx, sy, sz), mode=...)` uses a general (non-uniform) transform, which a gp_Trsf cannot represent, so this uses BRepBuilderAPI_GTransform.

### `BdgShape.transform_geometry(m: BdgMatrix) -> BdgShape`
transform geometry (in place)

### `BdgShape.transform_shape(m: BdgMatrix) -> BdgShape`
transform shape returning a copy

### `BdgShape.mirrored(plane: BdgPlane) -> BdgShape`
Method mirrored in class BdgShape.

### `BdgShape.bounding_box(tolerance: float = -1.0) -> BdgBoundBox`
Method bounding_box in class BdgShape.

### `BdgShape.extrude(direction: Vector3) -> BdgShape`
Extrude this shape along direction. Vertices->Edges, Edges->Faces, Wires->Shells, Faces->Solids, Shells->Compounds.

### `BdgShape.tessellate(tolerance: float = 0.1, angular_tolerance: float = 11.459) -> Array`
Tessellate this shape into Godot-native vertex/triangle arrays. Returns [vertices: PackedVector3Array, triangles: PackedInt32Array]. tolerance (linear) and angular_tolerance (degrees) control mesh density. Build123d interactive display defaults: linear=0.1, angular=0.2 rad (≈11.46°)

### `BdgShape.tessellate_with_uvs(tolerance: float = 0.1, angular_tolerance: float = 11.459, texture_scale: float = 0.05) -> Array`
Tessellate this shape into Godot-native vertices, triangles, and OpenCASCADE UVs. Returns [vertices: PackedVector3Array, triangles: PackedInt32Array, uvs: PackedVector2Array]. Build123d interactive display defaults: linear=0.1, angular=0.2 rad (≈11.46°)

### `BdgShape.fuse(other: BdgShape) -> BdgShape`
fuse all shapes into one

### `BdgShape.cut(other: BdgShape) -> BdgShape`
Method cut in class BdgShape.

### `BdgShape.intersect(other: BdgShape) -> BdgShape`
Method intersect in class BdgShape.

### `BdgShape.fillet(radius: float, edge_list: Array = []) -> BdgShape`
Fillet edges of this shape with given radius

### `static BdgShape.make_pipe_shell(path_wire: BdgWire, sections: Array, as_solid: bool = true) -> BdgShape`
Multisection sweep (pipe shell) along a path wire through section faces or wires.

### `BdgShape.fuse_all(tools: Array) -> BdgShape`
fuse with multiple tools at once

### `BdgShape.cut_all(tools: Array) -> BdgShape`
cut with multiple tools at once

### `BdgShape.intersect_all(tools: Array) -> BdgShape`
intersect with multiple tools at once

### `BdgShape.revolve(angle_deg: float, axis: BdgAxis = BdgAxis.Z) -> BdgShape`
Revolve this shape around an axis by angle_deg (360 = full). Returns a BdgShape.

### `BdgShape.sweep(spine: BdgWire, aux_spines: Array = [], is_frenet: bool = false) -> BdgShape`
Sweep this profile shape along a spine wire. Returns the swept shape.

### `BdgShape.thicken(amount: float) -> BdgShape`
Thicken a face (or shell) outward by amount (negative = inward). Returns a BdgShape.

### `BdgShape.section(plane: BdgPlane = null) -> Array`
World coord section of this shape with a plane. Returns edges (array of BdgEdge).

### `BdgShape.split_by_perimeter(perimeter: Variant, keep: int = BdgEnums.Keep.INSIDE) -> Variant`
Split this shape's faces by a closed perimeter wire or edge. keep: BdgEnums.Keep.INSIDE/OUTSIDE/BOTH. Returns the inside/outside part as a BdgShape (or Array of BdgShape), or for BOTH an array [inside, outside].

### `static BdgShape.make_loft(objs: Array, ruled: bool = false, as_solid: bool = true) -> BdgShape`
Loft a shape (Solid if as_solid, else Shell) through wires/vertices sections. objs: Array of BdgWire and/or BdgVertex (vertices only at the ends).

### `BdgShape.entities(topo_type: int) -> Array[OcgTopoDSShape]`
Method entities in class BdgShape.

### `BdgShape.vertices() -> Array`
Method vertices in class BdgShape.

### `BdgShape.edges() -> Array`
Method edges in class BdgShape.

### `BdgShape.wires() -> Array`
Method wires in class BdgShape.

### `BdgShape.faces() -> Array`
Method faces in class BdgShape.

### `BdgShape.shells() -> Array`
Method shells in class BdgShape.

### `BdgShape.solids() -> Array`
Method solids in class BdgShape.

### `BdgShape.compounds() -> Array`
Method compounds in class BdgShape.

### `BdgShape.vertex() -> BdgVertex`
Method vertex in class BdgShape.

### `BdgShape.edge() -> BdgEdge`
Method edge in class BdgShape.

### `BdgShape.wire() -> BdgWire`
Method wire in class BdgShape.

### `BdgShape.face() -> BdgFace`
Method face in class BdgShape.

### `BdgShape.shell() -> BdgShell`
Method shell in class BdgShape.

### `BdgShape.solid() -> BdgSolid`
Method solid in class BdgShape.

### `BdgShape.compound() -> BdgCompound`
Method compound in class BdgShape.

### `BdgShape.get_top_level_shapes() -> Array`
get_top_level_shapes - first level non-compound children

### `static BdgShape.cast(obj: OcgTopoDSShape) -> BdgShape`
Return the right Bdg* wrapper class given an OCCT shape

### `static BdgShape.make_compound_of(shapes: Array) -> BdgShape`
Build a compound from an array of BdgShape

### `BdgShape.distance_to(other: BdgShape) -> float`
Minimum distance between this shape and another shape

### `BdgShape.distance_to_with_closest_points(other: BdgShape) -> Array`
Minimum distance along with the closest points on both shapes [dist, p1, p2]

### `BdgShape.closest_points(other: BdgShape) -> Array`
Closest points between this shape and another shape [p1, p2]

### `BdgShape.compute_mass() -> float`
Alias for mass computation (length, area, or volume based on shape dimension)

### `BdgShape.matrix_of_inertia() -> Array`
3x3 inertia matrix of shape

### `BdgShape.principal_properties() -> Dictionary`
Principal moments of inertia and principal axes

### `BdgShape.radius_of_gyration() -> Vector3`
Radius of gyration

### `BdgShape.static_moments() -> Vector3`
Static moments

### `BdgShape.is_manifold() -> bool`
Check if shape is a closed, water-tight 2-manifold

### `BdgShape.faces_intersected_by_axis(axis: BdgAxis) -> Array`
Find faces intersected by a 3D ray/axis

### `BdgShape.copy_attributes_to(target: BdgShape, exceptions: Array = []) -> void`
Copy attributes (label, color, for_construction) to target shape

### `BdgShape.global_location() -> BdgLocation`
Return global location of shape

### `BdgShape.relocate(loc: BdgLocation) -> BdgShape`
Relocate shape to target location returning a new BdgShape

### `BdgShape.oriented_bounding_box() -> BdgBoundBox`
Oriented bounding box (OBB)

### `BdgShape.show_topology() -> String`
Topology tree representation as string

### `BdgShape.to_splines() -> BdgShape`
Convert curves/surfaces to B-splines

### `BdgShape.make_composite() -> BdgCompound`
Wrap shape into a BdgCompound

### `BdgShape.get_shape_list() -> BdgShapeList`
Return a BdgShapeList of sub-shapes

### `BdgShape.get_single_shape() -> BdgShape`
Return single shape

### `BdgShape.to_array_mesh(deflection: float = 0.1) -> ArrayMesh`
Convert OCCT tessellated shape into a Godot native ArrayMesh

### `BdgShape.to_node3d(deflection: float = 0.1) -> MeshInstance3D`
Convert shape into a Godot MeshInstance3D node

### `static BdgShape.BdgLocation_to_matrix(loc: BdgLocation) -> BdgMatrix`
Method BdgLocation_to_matrix in class BdgShape.

### `static BdgShape.duplicate_shape(s: BdgShape) -> BdgShape`
Duplicate a BdgShape (deep copy of wrapped OCCT shape)

### `static BdgWire.make_wire(edges: Array) -> BdgWire`
Create a wire from a list of edges/wires (must share endpoints)

### `static BdgWire.make_polygon(points: Array, close: bool = true) -> BdgWire`
Create a wire from a sequence of points as straight segments

### `static BdgWire.make_circle(radius: float, plane: BdgPlane = null) -> BdgWire`
Create a circle wire in a plane

### `static BdgWire.make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgWire`
Create a rectangular wire

### `static BdgWire.make_ellipse(x_radius: float, y_radius: float, plane: BdgPlane = null) -> BdgWire`
Create an elliptical wire in a plane

### `static BdgWire.make_spline(points: Array, periodic: bool = false) -> BdgWire`
Create a spline wire through points

### `static BdgWire.make_bezier(control_points: Array) -> BdgWire`
Create a bezier wire through control points

### `static BdgWire.make_bspline(control_points: Array, knots: Array, degree: int = 3, periodic: bool = false) -> BdgWire`
Create a bspline wire from control points and knot data (see BdgEdge.make_bspline)

### `static BdgWire.combine(edges: Array) -> Array`
Combine a list of edges into wires (connected chains). Returns an array of BdgWire.

### `BdgWire.fillet_2d(radius: float, vertices: Array = [], plane: BdgPlane = null) -> BdgWire`
2D fillet of planar wire corners (straight-line edges only). vertices: Array of Vector3 (or BdgVertex) corners to fillet; empty = all corners. Returns a new BdgWire (or self if nothing to do / on error).

### `BdgWire.chamfer_2d(length: float, length2: float = 0.0, vertices: Array = [], plane: BdgPlane = null) -> BdgWire`
2D chamfer of planar wire corners (straight-line edges only). length: distance cut back from the corner. length2: optional asymmetric distance.

### `BdgWire.close() -> BdgWire`
Close this wire by adding an edge from its end point to its start point if open.

### `BdgWire.order_edges() -> Array`
Return edges ordered end-to-end sequentially.

### `BdgWire.is_manifold() -> bool`
Is this wire closed (a loop)?

### `BdgWire.stitch() -> BdgWire`
Stitch degenerate wire edges into a clean wire

### `BdgWire.fix_degenerate_edges() -> BdgWire`
Remove degenerate 0-length edges from wire

### `static BdgWire.make_convex_hull(points: Array, plane: BdgPlane = null) -> BdgWire`
Compute 2D convex hull wire of planar vertices

### `BdgWire.order_chamfer_edges() -> Array`
Order edges for chamfering

### `BdgWire.trim(start_param: float, end_param: float) -> BdgWire`
Trim wire to parameter sub-range (0..1)

### `BdgShapeList.size() -> int`
Method size in class BdgShapeList.

### `BdgShapeList.is_empty() -> bool`
Method is_empty in class BdgShapeList.

### `BdgShapeList.at(i: int) -> BdgShape`
Method at in class BdgShapeList.

### `BdgShapeList.get_all() -> Array`
Method get_all in class BdgShapeList.

### `BdgShapeList.append(shape: BdgShape) -> BdgShapeList`
Method append in class BdgShapeList.

### `BdgShapeList.extend(other: BdgShapeList) -> BdgShapeList`
Method extend in class BdgShapeList.

### `BdgShapeList.slice(begin: int, end: int) -> BdgShapeList`
Method slice in class BdgShapeList.

### `BdgShapeList.first() -> BdgShape`
Method first in class BdgShapeList.

### `BdgShapeList.last() -> BdgShape`
Method last in class BdgShapeList.

### `BdgShapeList.center() -> Vector3`
average of the centers of all objects

### `BdgShapeList.vertices() -> BdgShapeList`
Method vertices in class BdgShapeList.

### `BdgShapeList.edges() -> BdgShapeList`
Method edges in class BdgShapeList.

### `BdgShapeList.wires() -> BdgShapeList`
Method wires in class BdgShapeList.

### `BdgShapeList.faces() -> BdgShapeList`
Method faces in class BdgShapeList.

### `BdgShapeList.shells() -> BdgShapeList`
Method shells in class BdgShapeList.

### `BdgShapeList.solids() -> BdgShapeList`
Method solids in class BdgShapeList.

### `BdgShapeList.compounds() -> BdgShapeList`
Method compounds in class BdgShapeList.

### `BdgShapeList.vertex() -> BdgShape`
return the single vertex/edge/... or raise an error if not exactly one

### `BdgShapeList.edge() -> BdgShape`
Method edge in class BdgShapeList.

### `BdgShapeList.wire() -> BdgShape`
Method wire in class BdgShapeList.

### `BdgShapeList.face() -> BdgShape`
Method face in class BdgShapeList.

### `BdgShapeList.shell() -> BdgShape`
Method shell in class BdgShapeList.

### `BdgShapeList.solid() -> BdgShape`
Method solid in class BdgShapeList.

### `BdgShapeList.compound() -> BdgShape`
Method compound in class BdgShapeList.

### `BdgShapeList.expand() -> BdgShapeList`
dissolve compounds to children, wires to edges, shells to faces; drop nulls

### `BdgShapeList.build_compound() -> BdgShape`
build a compound of every shape in this list

### `BdgShapeList.filter_by(filter_by, reverse: bool = false, tolerance: float = 1e-5) -> BdgShapeList`
filter by Callable(shape)->bool, BdgAxis, BdgPlane, or BdgEnums.GeomType. reverse=true inverts the predicate.

### `BdgShapeList.filter_by_position(axis: BdgAxis, minimum: float, maximum: float, include_min: bool = true, include_max: bool = true) -> BdgShapeList`
filter and sort by the position of centers along an axis

### `BdgShapeList.sort_by(sort_by, reverse: bool = false) -> BdgShapeList`
sort by Callable(shape)->float, BdgAxis, or BdgEnums.SortBy

### `BdgShapeList.group_by(group_by, reverse: bool = false, tol_digits: int = 6) -> Array`
group by Callable, BdgAxis, or BdgEnums.SortBy; returns Array of BdgShapeList

### `BdgShapeList.sort_by_distance(target: Variant, reverse: bool = false) -> BdgShapeList`
Sort shapes by distance to a target point/shape

### `BdgShapeList.distance_to(other: BdgShapeList) -> float`
minimum distance between the shapes of this list and another list

### `BdgShapeList.distance_to_with_closest_points(other: BdgShapeList) -> Dictionary`
minimum distance and the closest point pairs (via BRepExtrema_DistShapeShape)

### `static BdgFace.make_from_wires(outer_wire: BdgWire, inner_wires: Array = []) -> BdgFace`
create a face from an outer wire with optional hole wires

### `static BdgFace.make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgFace`
create a rectangle face centered on origin of plane

### `static BdgFace.make_circle(radius: float, plane: BdgPlane = null) -> BdgFace`
create a circle face in a plane

### `static BdgFace.make_ellipse(x_radius: float, y_radius: float, plane: BdgPlane = null) -> BdgFace`
create an elliptical face in a plane

### `static BdgFace.make_polygon(points: Array, plane: BdgPlane = null) -> BdgFace`
create a polygon face from a list of points in a plane

### `static BdgFace.make_regular_polygon(radius: float, side_count: int, plane: BdgPlane = null) -> BdgFace`
create a regular polygon face (radius is the circumradius)

### `static BdgFace.make_slot(length: float, width: float, rotation_deg: float = 0.0) -> BdgFace`
create a 2D slot face with semicircular ends

### `static BdgFace.make_triangle(base: float, height: float, plane: BdgPlane = null) -> BdgFace`
create an isosceles triangle face (apex centered, base horizontal)

### `static BdgFace.make_trapezoid(width: float, height: float, left_inset: float, right_inset: float, plane: BdgPlane = null) -> BdgFace`
create a trapezoid face

### `static BdgFace.make_rounded_rect(width: float, height: float, radius: float, plane: BdgPlane = null) -> BdgFace`
create a rounded rectangle face

### `static BdgFace.make_slot_center_to_center(center_to_center: float, height: float, plane: BdgPlane = null) -> BdgFace`
create a slot face (rounded ends) from an overall length and width

### `static BdgFace.make_slot_center_point(center: Vector3, point: Vector3, height: float, plane: BdgPlane = null) -> BdgFace`
create a slot centered at `center`, symmetric, with an end arc centered at `point`

### `static BdgFace.make_slot_arc(center: Vector3, radius: float, start_angle: float, arc_size: float, height: float, plane: BdgPlane = null) -> BdgFace`
create a slot along a circular center-line arc (band around the arc)

### `BdgFace.area() -> float`
area of the face (excluding holes)

### `BdgFace.center() -> Vector3`
center of the face

### `BdgFace.normal() -> Vector3`
normal of the face at its center

### `BdgFace.outer_wire() -> BdgWire`
outer wire of the face

### `BdgFace.inner_wires() -> Array`
inner wires (hole boundaries) of the face

### `BdgFace.is_planar() -> bool`
Whether the underlying surface is a plane

### `BdgFace.to_plane() -> BdgPlane`
Convert this planar face to a BdgPlane (origin at center, z_dir along normal)

### `BdgFace.surface_point(u: float, v: float) -> Vector3`
Evaluate 3D surface point at normalized parameter (u: 0..1, v: 0..1)

### `BdgFace.geometry() -> String`
The underlying surface geometry type name (e.g. "PLANE")

### `BdgFace.chamfer_2d(dist: float, dist2: float = 0.0, vertices: Array = [], edge: BdgEdge = null) -> BdgFace`
Apply 2D chamfer to face outer boundary corners

### `BdgFace.fillet_2d(radius_val: float, vertices: Array = []) -> BdgFace`
Apply 2D fillet to face outer boundary corners

### `BdgFace.area_without_holes() -> float`
Area of outer wire face excluding inner holes

### `BdgFace.without_holes() -> BdgFace`
Face with inner hole wires removed

### `BdgFace.make_holes(inner_wire_list: Array) -> BdgFace`
Add inner hole wires to face

### `BdgFace.position_at(u: float = 0.5, v: float = 0.5) -> Vector3`
Position at normalized UV coordinates (0..1, 0..1)

### `BdgFace.normal_at(u: float = 0.5, v: float = 0.5) -> Vector3`
Surface normal vector at normalized UV coordinates (0..1, 0..1)

### `BdgFace.location_at(u: float = 0.5, v: float = 0.5) -> BdgLocation`
Location at normalized UV coordinates (0..1, 0..1)

### `BdgFace.center_location() -> BdgLocation`
Location at center of face

### `BdgFace.is_coplanar(other: BdgFace, tol: float = 1e-5) -> bool`
Check if face is coplanar with another face

### `BdgFace.is_inside(point: Vector3, tol: float = 1e-5) -> bool`
Check if 3D point lies inside planar face

### `BdgFace.radius() -> float`
Radius of underlying cylinder/sphere/torus

### `BdgFace.width() -> float`
Width of bounding box in face plane

### `BdgFace.length() -> float`
Length of bounding box in face plane

### `static BdgFace.sew_faces(face_list: Array) -> BdgShell`
Sew an array of faces into a shell


## Objects

### `static BdgJoint.make_rigid(p_loc: BdgLocation, c_loc: BdgLocation, lbl: String = "") -> BdgJoint`
Create a rigid fixed joint

### `static BdgJoint.make_revolute(p_loc: BdgLocation, c_loc: BdgLocation, ax: BdgAxis, min_ang: float = -180.0, max_ang: float = 180.0, lbl: String = "") -> BdgJoint`
Create a revolute (rotational) joint

### `static BdgJoint.make_linear(p_loc: BdgLocation, c_loc: BdgLocation, ax: BdgAxis, min_dist: float = 0.0, max_dist: float = 100.0, lbl: String = "") -> BdgJoint`
Create a linear (prismatic sliding) joint

### `BdgJoint.compute_child_location(val: float = 0.0) -> BdgLocation`
Compute relative transform for child shape at current position

### `BdgAssembly.add(child: Variant, child_label: String = "", child_loc: BdgLocation = null, child_color: Color = Color.WHITE) -> BdgAssembly`
Add a child shape or sub-assembly to this assembly.

### `BdgAssembly.add_child(child: Variant, child_label: String = "", child_loc: BdgLocation = null, child_color: Color = Color.WHITE) -> BdgAssembly`
Alias for add(child, child_label, child_loc, child_color)

### `BdgAssembly.add_joint(joint: BdgJoint) -> void`
Add a joint constraint between components

### `BdgAssembly.find(child_name: String) -> BdgAssembly`
Find child assembly by name

### `BdgAssembly.world_location() -> BdgLocation`
Compute total world/global transform location

### `BdgAssembly.to_compound() -> BdgCompound`
Flatten assembly into a single BdgCompound containing all positioned shapes.

### `BdgAssembly.export_step(path: String) -> bool`
Export entire assembly as STEP file

### `BdgAssembly.export_stl(path: String) -> bool`
Export entire assembly as STL mesh

### `BdgMixin1D.length() -> float`
Total length of the shape

### `BdgMixin1D.is_closed() -> bool`
Method is_closed in class BdgMixin1D.

### `BdgMixin1D.position_at(position: float) -> Vector3`
Position at given parameter (0..1) along the curve. Uses the edge's Geom_Curve.

### `BdgMixin1D.param_at_distance(dist: float) -> float`
Find normalized parameter (0..1) at given arclength distance along the curve.

### `BdgMixin1D.start_point() -> Vector3`
Method start_point in class BdgMixin1D.

### `BdgMixin1D.end_point() -> Vector3`
Method end_point in class BdgMixin1D.

### `BdgMixin1D.tangent_at(position: float) -> Vector3`
Tangent unit vector at parameter (0..1) along the curve.

### `BdgMixin1D.normal_at(position: float) -> Vector3`
Principal normal unit vector at parameter (0..1) along the curve.

### `BdgMixin1D.curvature_at(position: float) -> float`
Curvature (1 / radius) at parameter (0..1) along the curve.

### `BdgMixin1D.radius_at(position: float) -> float`
Radius of curvature at parameter (0..1). INF if straight.

### `BdgMixin1D.positions(count_or_params: Variant) -> Array[Vector3]`
Sample positions at given count or array of parameters (0..1).

### `BdgMixin1D.locations(count_or_params: Variant) -> Array[BdgLocation]`
Sample Locations along the curve (position + tangent orientation).

### `BdgMixin1D.center() -> Vector3`
center of the edge/wire

### `BdgMixin1D.tessellate_edge(tolerance: float = 0.02) -> PackedVector3Array`
Tessellate this 1D edge/wire into a polyline point array.

### `static BdgConstants.convert(value: float, from_unit: int, to_unit: int = BdgEnums.Unit.MM) -> float`
Method convert in class BdgConstants.

### `BdgDimensionLine.to_wires() -> Array[BdgWire]`
Generate 2D CAD wires for the dimension line annotation (witness lines + dim line)

### `BdgTechnicalDrawing.add_dimension(dim: BdgDimensionLine) -> void`
Add a dimension annotation

### `BdgTechnicalDrawing.to_compound() -> BdgCompound`
Generate drawing as a single BdgCompound containing sheet borders, title block, views, and dimensions.

### `BdgTechnicalDrawing.export_svg(path: String) -> bool`
Export technical drawing as 2D SVG

### `BdgTechnicalDrawing.export_dxf(path: String) -> bool`
Export technical drawing as 2D DXF


## Math & Geometry

### `static BdgVector.get_angle(a: Vector3, b: Vector3) -> float`
unsigned angle in degrees between two vectors

### `static BdgVector.get_signed_angle(a: Vector3, b: Vector3, normal: Vector3 = Vector3(0, 0, -1) -> Variant`
signed angle in degrees between two vectors with given normal angle = atan2((a x b) . n, a . b)

### `static BdgVector.project_to_line(a: Vector3, line: Vector3) -> Vector3`
project vector a onto the line represented by Vector3 line

### `static BdgVector.distance_to_plane(p: Vector3, plane_origin: Vector3, plane_normal: Vector3) -> float`
minimum unsigned distance between point and plane (BdgPlane or gp_Pln style)

### `static BdgVector.signed_distance_from_plane(p: Vector3, plane_origin: Vector3, plane_z: Vector3) -> float`
signed distance from plane to point

### `static BdgVector.project_to_plane(p: Vector3, plane_origin: Vector3, plane_normal: Vector3) -> Vector3`
project point onto plane defined by origin + normal

### `static BdgVector.rotate(v: Vector3, axis_pos: Vector3, axis_dir: Vector3, angle_deg: float) -> Vector3`
rotate vector about an axis (position + direction) by angle in degrees

### `static BdgVector.distance(a: Vector3, b: Vector3) -> float`
signed distance between two vectors (points)

### `static BdgVector.multiply(a: Vector3, s: float) -> Vector3`
multiply component-wise

### `static BdgVector.copy(v: Vector3) -> Vector3`
copy

### `static BdgVector.add(a: Vector3, b: Vector3) -> Vector3`
Add two vectors

### `static BdgVector.sub(a: Vector3, b: Vector3) -> Vector3`
Subtract two vectors

### `static BdgVector.to_dir(v: Vector3) -> Vector3`
Return unit direction vector

### `static BdgVector.to_pnt(v: Vector3) -> Vector3`
Return point vector (alias for self)

### `static BdgVector.to_tuple(v: Vector3) -> Array`
Convert vector to array tuple [x, y, z]

### `static BdgVector.transform(v: Vector3, matrix_or_loc: Variant) -> Vector3`
Transform vector by a matrix or location

### `static BdgVector.reverse(v: Vector3) -> Vector3`
Reverse vector direction

### `static BdgVector.to_vector3(val: Variant) -> Vector3`
Seamless conversion helper to Godot Vector3

### `static BdgVector.trim_float(x: float, precision: int, tol: float = TOL) -> float`
wrap zeros below tolerance (build123d format-style trimming)

### `static BdgColor.categorical_set(idx: int) -> BdgColor`
Generate a distinct color from categorical palette index

### `BdgPlane.set_location(value: Vector3) -> void`
Set location (origin)

### `BdgPlane.wrapped() -> OcgGpPln`
The plane's wrapped OCCT gp_Pln

### `BdgPlane.reverse() -> void`
Flip the plane normal

### `BdgPlane.distance(p: Vector3) -> float`
Distance from a point to the plane (unsigned)

### `BdgPlane.project(p: Vector3) -> Vector3`
Project a point onto the plane

### `BdgPlane.signed_distance(p: Vector3) -> float`
Signed distance from the plane to point p

### `BdgPlane.to_axis() -> BdgAxis`
Method to_axis in class BdgPlane.

### `BdgPlane.to_ax2() -> OcgGpAx2`
Convert to an OCCT gp_Ax2 with x_dir as X and z_dir as Z

### `BdgPlane.offset(dist: float) -> BdgPlane`
Create a new plane shifted along its normal z_dir by distance.

### `BdgPlane.location() -> BdgLocation`
Return location corresponding to this plane (origin + orientation)

### `BdgPlane.shift_origin(new_origin: Vector3) -> BdgPlane`
Return new plane with origin shifted to new_origin

### `BdgPlane.to_local_coords(world_p: Vector3) -> Vector3`
Transform world 3D point/vector into local plane 2D/3D coordinates

### `BdgPlane.from_local_coords(local_p: Vector3) -> Vector3`
Transform local plane 2D/3D coordinates into world 3D coordinates

### `BdgPlane.forward_transform() -> BdgMatrix`
Forward 4x4 matrix mapping local plane space to world space

### `BdgPlane.reverse_transform() -> BdgMatrix`
Reverse 4x4 matrix mapping world space to local plane space

### `BdgPlane.rotated(angle_deg: float, axis_vector: Vector3 = Vector3.ZERO) -> BdgPlane`
Create a new plane rotated by angle_deg around an axis vector or local axis

### `BdgPlane.move(offset_vec: Vector3) -> BdgPlane`
Move plane origin in-place by offset_vec

### `BdgPlane.moved(offset_vec: Vector3) -> BdgPlane`
Move plane origin returning a new BdgPlane

### `BdgPlane.contains(p: Vector3, tolerance: float = 1e-5) -> bool`
Check if point lies within plane tolerance

### `BdgPlane.intersect(other: Variant) -> Variant`
Compute line of intersection with another plane, or point of intersection with line/axis

### `BdgBoundBox.wrapped() -> OcgBndBox`
Method wrapped in class BdgBoundBox.

### `BdgBoundBox.is_void() -> bool`
Method is_void in class BdgBoundBox.

### `BdgBoundBox.size() -> Vector3`
Method size in class BdgBoundBox.

### `BdgBoundBox.center() -> Vector3`
Method center in class BdgBoundBox.

### `BdgBoundBox.diagonal() -> float`
Method diagonal in class BdgBoundBox.

### `BdgBoundBox.diagonal_length() -> float`
Method diagonal_length in class BdgBoundBox.

### `BdgBoundBox.contains(p: Vector3, tolerance: float = 1e-6) -> bool`
Method contains in class BdgBoundBox.

### `BdgBoundBox.add_box(other: BdgBoundBox) -> void`
Method add_box in class BdgBoundBox.

### `BdgBoundBox.add(other: Variant) -> void`
Generic add method (box or vector/point)

### `BdgBoundBox.is_inside(other: Variant, tolerance: float = 1e-6) -> bool`
Check if point or box is inside this bounding box

### `BdgBoundBox.measure() -> Vector3`
Measure box dimensions (returns size)

### `BdgBoundBox.overlaps(other: BdgBoundBox, tolerance: float = 1e-6) -> bool`
Check if two bounding boxes overlap

### `BdgBoundBox.to_align_offset(align: Variant) -> Vector3`
Compute alignment offset vector for aligning shapes

### `BdgBoundBox.find_outside_box_2d() -> Array`
Find outside box bounds in 2D plane

### `BdgBoundBox.to_aabb() -> AABB`
Convert to Godot native AABB

### `BdgBoundBox.enlarge(delta: float) -> void`
expand by a scalar on all sides

### `BdgAxis.wrapped() -> OcgGpAx1`
The wrapped OCCT gp_Ax1

### `BdgAxis.flipped() -> BdgAxis`
Flip axis direction

### `BdgAxis.reverse() -> BdgAxis`
Alias for flipped (Python parity)

### `BdgAxis.location() -> BdgLocation`
Return location corresponding to this axis (position and direction as Z)

### `BdgAxis.to_plane() -> BdgPlane`
Convert axis to plane perpendicular to direction or containing axis

### `BdgAxis.angle_between(other: BdgAxis) -> float`
Angle in degrees between this axis direction and another axis direction

### `BdgAxis.is_coaxial(other: BdgAxis, tol_angle_deg: float = 1e-3, tol_dist: float = 1e-4) -> bool`
Returns true if axes are coaxial (collinear) within tolerance

### `BdgAxis.is_normal(other: BdgAxis, tol_deg: float = 1e-3) -> bool`
Returns true if axis directions are normal (perpendicular) within tolerance

### `BdgAxis.is_opposite(other: BdgAxis, tol_deg: float = 1e-3) -> bool`
Returns true if axis directions are opposite (anti-parallel) within tolerance

### `BdgAxis.is_parallel(other: BdgAxis, tol_deg: float = 1e-3) -> bool`
Returns true if axis directions are parallel within tolerance

### `BdgAxis.is_skew(other: BdgAxis, tol_deg: float = 1e-3, tol_dist: float = 1e-4) -> bool`
Returns true if axes are skew (non-parallel and non-intersecting)

### `static BdgMatrix.new_identity() -> BdgMatrix`
identity

### `BdgMatrix.wrapped() -> OcgGpTrsf`
Method wrapped in class BdgMatrix.

### `BdgMatrix.get_values() -> Array`
4x4 matrix values (OCCT convention: [a11..a34])

### `BdgMatrix.to_transform3d() -> Transform3D`
Extract as a Godot Transform3D

### `static BdgMatrix.rotation_about(axis_pos: Vector3, axis_dir: Vector3, angle_deg: float) -> BdgMatrix`
Build a rotation matrix about an axis by angle in degrees

### `static BdgMatrix.translation(v: Vector3) -> BdgMatrix`
Translation matrix

### `static BdgMatrix.scaling(center: Vector3, s: Vector3) -> BdgMatrix`
Scale matrix

### `BdgMatrix.multiplied(other: BdgMatrix) -> BdgMatrix`
Compose: self * other (apply self after other)

### `BdgMatrix.inverted() -> BdgMatrix`
Method inverted in class BdgMatrix.

### `BdgMatrix.inverse() -> BdgMatrix`
Alias for inverted (Python parity)

### `BdgMatrix.multiply(other: BdgMatrix) -> BdgMatrix`
Alias for multiplied (Python parity)

### `BdgMatrix.rotate(axis_pos_or_dir: Variant, angle_deg: float = 0.0) -> BdgMatrix`
Rotate matrix in-place or returning new BdgMatrix around axis

### `BdgMatrix.transposed_list() -> Array`
Return 4x4 matrix values formatted as a transposed 4x4 nested array

### `BdgMatrix.apply(p: Vector3) -> Vector3`
Apply this transform to a point

### `BdgMatrix.apply_dir(d: Vector3) -> Vector3`
Apply this transform to a direction (no translation)

### `static BdgLocation.new_identity() -> BdgLocation`
identity location

### `BdgLocation.wrapped() -> OcgTopLocLocation`
Method wrapped in class BdgLocation.

### `BdgLocation.inverted() -> BdgLocation`
Method inverted in class BdgLocation.

### `BdgLocation.inverse() -> BdgLocation`
Alias for inverted (Python parity)

### `BdgLocation.multiplied(other: BdgLocation) -> BdgLocation`
Combine two locations: self * other

### `BdgLocation.mirror(plane_or_axis: Variant) -> BdgLocation`
Mirror location across a plane or axis

### `BdgLocation.to_axis() -> BdgAxis`
Convert location orientation/position to BdgAxis along Z axis

### `BdgLocation.to_tuple() -> Array`
Convert location to array tuple [px, py, pz, qx, qy, qz, qw]

### `BdgLocation.x_axis() -> BdgAxis`
Local X axis

### `BdgLocation.y_axis() -> BdgAxis`
Local Y axis

### `BdgLocation.z_axis() -> BdgAxis`
Local Z axis

### `BdgLocation.center() -> Vector3`
Center position (alias for position)

### `BdgLocation.to_transform3d() -> Transform3D`
Convert to Godot Transform3D


## Operations

### `static BdgOperations.add(objects: Variant, mode: int = BdgEnums.Mode.ADD) -> Variant`
Method add in class BdgOperations.

### `static BdgOperations.mirror(objects: Variant, about: BdgPlane = null) -> Variant`
Method mirror in class BdgOperations.

### `static BdgOperations.scale(objects: Variant, factor: Variant, center: Vector3 = Vector3.ZERO) -> Variant`
Method scale in class BdgOperations.

### `static BdgOperations.offset(objects: Variant, amount: float, kind: int = 0) -> Variant`
Method offset in class BdgOperations.

### `static BdgOperations.project(objects: Variant, target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array`
Method project in class BdgOperations.

### `static BdgOperations.split(objects: Variant, bisect_by: Variant, keep: int = BdgEnums.Keep.TOP) -> Variant`
Method split in class BdgOperations.

### `static BdgOperations.bounding_box(objects: Variant) -> BdgBoundBox`
Method bounding_box in class BdgOperations.

### `static BdgOperations.make_face(wires_or_edges: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Method make_face in class BdgOperations.

### `static BdgOperations.make_hull(points_or_shapes: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Method make_hull in class BdgOperations.

### `static BdgOperations.trace(wire: BdgWire, distance: float, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Method trace in class BdgOperations.

### `static BdgOperations.loft(objs: Array, ruled: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Method loft in class BdgOperations.

### `static BdgOperations.fillet(objects: Variant, radius: float) -> BdgShape`
Method fillet in class BdgOperations.

### `static BdgOperations.chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape`
Method chamfer in class BdgOperations.

### `static BdgOperations.section(shape: BdgShape, plane: BdgPlane = null) -> Array`
Method section in class BdgOperations.

### `static BdgOperations.thicken(shape: BdgShape, amount: float, mode: int = BdgEnums.Mode.ADD) -> BdgShape`
Method thicken in class BdgOperations.

### `static BdgOperations.hollow(solid: BdgSolid, faces_to_remove: Array, thickness: float, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Method hollow in class BdgOperations.

### `static BdgOperations.draft(solid: BdgSolid, faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Method draft in class BdgOperations.

### `static BdgOperations.make_brake_formed(sheet_face: BdgFace, radius: float, angle_deg: float) -> BdgShape`
Method make_brake_formed in class BdgOperations.

### `static BdgOperations.detect_primitives(shape: BdgShape) -> Dictionary`
Method detect_primitives in class BdgOperations.

### `static BdgOperations.sort_wires_by_build_order(wires: Array) -> Array`
Method sort_wires_by_build_order in class BdgOperations.

### `static BdgOperations.all_location_like(objs: Array) -> bool`
Method all_location_like in class BdgOperations.

### `static BdgOperations.to_align_offset(bbox: BdgBoundBox, align: Variant) -> Vector3`
Method to_align_offset in class BdgOperations.

### `static BdgOperations.find_max_dimension(shape: BdgShape) -> float`
Method find_max_dimension in class BdgOperations.

### `static BdgOpsGeneric.add(objects: Variant, mode: int = BdgEnums.Mode.ADD) -> Variant`
Add shapes/objects to the active builder context.

### `static BdgOpsGeneric.mirror(objects: Variant, about: BdgPlane = null) -> Variant`
Mirror a shape across a given plane (defaults to XY).

### `static BdgOpsGeneric.scale(objects: Variant, factor: Variant, center: Vector3 = Vector3.ZERO) -> Variant`
Scale a shape uniformly (by float) or non-uniformly (by Vector3 / [sx, sy, sz]).

### `static BdgOpsGeneric.offset(objects: Variant, amount: float, kind: int = 0) -> Variant`
Offset a shape in 2D (face/wire) or 3D (solid).

### `static BdgOpsGeneric.project(objects: Variant, target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array`
Project a shape onto target shape surface.

### `static BdgOpsGeneric.split(objects: Variant, bisect_by: Variant, keep: int = BdgEnums.Keep.TOP) -> Variant`
Split a shape with a bisecting plane or face. keep: BdgEnums.Keep (TOP / BOTTOM / BOTH / ALL)

### `static BdgOpsGeneric.bounding_box(objects: Variant) -> BdgBoundBox`
Compute total bounding box for one or more shapes.

### `static BdgOpsSketch.make_face(wires_or_edges: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Create a Face from one or more closed wires.

### `static BdgOpsSketch.make_hull(points_or_shapes: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
2D Convex Hull of points or shapes in the XY plane.

### `static BdgOpsSketch.trace(wire: BdgWire, distance: float, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Trace a wire with a given line thickness to create a planar ribbon face.

### `static BdgOpsSketch.full_round(sketch_or_face: Variant, edge1: BdgEdge, edge2: BdgEdge, radius: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Full tangent rounding between two edges in a sketch.

### `static BdgOpsPart.loft(objs: Array, ruled: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Loft a solid through the given sections (wires / vertices).

### `static BdgOpsPart.fillet(objects: Variant, radius: float) -> BdgShape`
Fillet edges of a solid with given radius.

### `static BdgOpsPart.chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape`
Chamfer edges of a solid.

### `static BdgOpsPart.section(shape: BdgShape, plane: BdgPlane = null) -> Array`
Section a shape with a plane.

### `static BdgOpsPart.thicken(shape: BdgShape, amount: float, mode: int = BdgEnums.Mode.ADD) -> BdgShape`
Thicken a face into a solid with thickness.

### `static BdgOpsPart.hollow(solid: BdgSolid, faces_to_remove: Array, thickness: float, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Hollow out a solid leaving face openings.

### `static BdgOpsPart.draft(solid: BdgSolid, faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Apply draft angle to solid faces.

### `static BdgPack.pack(objects: Array, sheet_width: float, sheet_height: float, padding: float = 2.0) -> Array`
Pack objects into a 2D sheet (sheet_width x sheet_height) with padding. Returns Array of relocated BdgShape objects.


## Builders

### `BdgBuilder.begin() -> void`
Activate this builder as the innermost context.

### `BdgBuilder.end() -> bool`
Deactivate this builder (returns true if it was the current context).

### `static BdgBuilder.get_current() -> BdgBuilder`
Current innermost builder context (or null).

### `static BdgBuilder.add_to_current(obj: BdgShape, mode: int, builder_tag: String) -> bool`
Convenience: add an object (already built with its mode) to the current matching builder context. Returns true if handled.

### `static BdgBuilder.has_context(tag: String) -> bool`
Whether the current context is of the given tag.

### `BdgBuilder.obj() -> BdgShape`
The object built by this builder.

### `BdgBuilder.vertices(select: int = BdgEnums.Select.ALL) -> Array`
Method vertices in class BdgBuilder.

### `BdgBuilder.vertex(select: int = BdgEnums.Select.ALL) -> BdgVertex`
Method vertex in class BdgBuilder.

### `BdgBuilder.edges(select: int = BdgEnums.Select.ALL) -> Array`
Method edges in class BdgBuilder.

### `BdgBuilder.edge(select: int = BdgEnums.Select.ALL) -> BdgEdge`
Method edge in class BdgBuilder.

### `BdgBuilder.wires(select: int = BdgEnums.Select.ALL) -> Array`
Method wires in class BdgBuilder.

### `BdgBuilder.wire(select: int = BdgEnums.Select.ALL) -> BdgWire`
Method wire in class BdgBuilder.

### `BdgBuilder.faces(select: int = BdgEnums.Select.ALL) -> Array`
Method faces in class BdgBuilder.

### `BdgBuilder.face(select: int = BdgEnums.Select.ALL) -> BdgFace`
Method face in class BdgBuilder.

### `BdgBuilder.shells(select: int = BdgEnums.Select.ALL) -> Array`
Method shells in class BdgBuilder.

### `BdgBuilder.shell(select: int = BdgEnums.Select.ALL) -> BdgShell`
Method shell in class BdgBuilder.

### `BdgBuilder.solids(select: int = BdgEnums.Select.ALL) -> Array`
Method solids in class BdgBuilder.

### `BdgBuilder.solid(select: int = BdgEnums.Select.ALL) -> BdgSolid`
Method solid in class BdgBuilder.

### `BdgBuildPart.part() -> BdgPart`
The built 3D part.

### `BdgBuildSketch.sketch() -> BdgSketch`
The built sketch.

### `BdgBuildLine.line() -> BdgShape`
The built line (a Curve/Wire of the collected edges).

### `BdgBuildLine.curve() -> BdgShape`
The built wire/curve.

### `static Bdg.build_part(block: Callable) -> BdgPart`
Build a 3D Part using a callback closure. Automatically accumulates 3D primitives and boolean operations. Returns the built BdgPart.

### `static Bdg.build_sketch(block: Callable) -> BdgSketch`
Build a 2D Sketch using a callback closure. Automatically combines 2D planar sketch shapes. Returns the built BdgSketch.

### `static Bdg.build_line(block: Callable) -> BdgShape`
Build a 1D Line/Curve using a callback closure. Automatically connects lines, arcs, and splines into a continuous curve/wire.

### `static Bdg.last_shape() -> BdgShape`
Return the current shape / object of the active builder context (or null).

### `static Bdg.last_solid() -> BdgSolid`
Return the last solid created in the active builder context.

### `static Bdg.last_face() -> BdgFace`
Return the last face created in the active builder context.

### `static Bdg.last_edge() -> BdgEdge`
Return the last edge created in the active builder context.

### `static Bdg.last_wire() -> BdgWire`
Return the last wire created in the active builder context.

### `static Bdg.eval(code: String) -> Variant`
Dynamically compile and execute a GDScript CAD code string, returning the built BdgShape or Variant.

### `Bdg.run_cad_builder() -> Variant`
Method run_cad_builder in class Bdg.

### `static Bdg.locations(loc_generator: Variant, block: Callable) -> void`
Run a block with an active BdgLocations context (Array of locations, planes, or points).

### `static Bdg.grid_locations(x_spacing: float, y_spacing: float, x_count: int, y_count: int, block: Callable) -> void`
Run a block with a 2D rectangular GridLocations context centered at origin.

### `static Bdg.hex_locations(apothem: float, x_count: int, y_count: int, block: Callable) -> void`
Run a block with a 2D Hexagonal packing HexLocations context.

### `static Bdg.polar_locations(radius: float, count: int, start_angle: float = 0.0, angular_range: float = 360.0, rotate: bool = true, block: Callable = Callable() -> Variant`
Run a block with a circular PolarLocations pattern context.

### `static Bdg.pos(x: float, y: float, z: float = 0.0) -> Vector3`
Create a position vector (Vector3 shorthand).

### `static Bdg.rot(x_deg: float, y_deg: float, z_deg: float) -> Quaternion`
Create an orientation quaternion from Euler degrees (X, Y, Z).

### `static Bdg.location(position: Vector3 = Vector3.ZERO, orientation: Quaternion = Quaternion.IDENTITY) -> BdgLocation`
Create a 3D Location from position and optional rotation.

### `static Bdg.fuse(a: BdgShape, b: Variant) -> BdgShape`
Fuse (union) shapes: a + b

### `static Bdg.cut(a: BdgShape, b: Variant) -> BdgShape`
Cut (difference) shapes: a - b

### `static Bdg.intersect(a: BdgShape, b: Variant) -> BdgShape`
Intersect (common) shapes: a & b

### `static Bdg.line(p1: Vector3, p2: Vector3, mode: int = BdgEnums.Mode.ADD) -> BdgLine`
Straight line segment between two 3D points.

### `static Bdg.polar_line(p0: Vector3, length: float, angle_deg: float, mode: int = BdgEnums.Mode.ADD) -> BdgPolarLine`
Line defined by start point, length, and polar angle in degrees.

### `static Bdg.polyline(points: Array, close: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgPolyline`
Multi-segment polyline connecting an ordered list of points.

### `static Bdg.fillet_polyline(points: Array, radius: float, close: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgFilletPolyline`
Polyline with automatic corner filleting by a given radius.

### `static Bdg.arc_3pt(p1: Vector3, p2: Vector3, p3: Vector3, mode: int = BdgEnums.Mode.ADD) -> BdgThreePointArc`
Circular arc passing through three points (start, mid, end).

### `static Bdg.center_arc(center: Vector3, radius: float, start_angle: float, arc_size: float, mode: int = BdgEnums.Mode.ADD) -> BdgCenterArc`
Circular arc defined by center, radius, start angle, and arc size.

### `static Bdg.radius_arc(start: Vector3, end: Vector3, radius: float, short_sagitta: bool = true, mode: int = BdgEnums.Mode.ADD) -> BdgRadiusArc`
Circular arc defined by start, end point, and radius.

### `static Bdg.sagitta_arc(start: Vector3, end: Vector3, sagitta: float, mode: int = BdgEnums.Mode.ADD) -> BdgSagittaArc`
Circular arc defined by start, end point, and sagitta (bulge height).

### `static Bdg.tangential_arc(start: Vector3, tangent: Vector3, radius: float, angle_deg: float, mode: int = BdgEnums.Mode.ADD) -> BdgJernArc`
Tangential arc continuing smoothly from an initial tangent direction.

### `static Bdg.double_tangent_arc(edge1: BdgEdge, edge2: BdgEdge, mode: int = BdgEnums.Mode.ADD) -> BdgDoubleTangentArc`
Smooth arc connecting two curves with tangency constraints at both ends.

### `static Bdg.jern_arc(start: Vector3, tangent: Vector3, radius: float, arc_size: float, mode: int = BdgEnums.Mode.ADD) -> BdgJernArc`
Jern arc tangent to an existing edge or direction vector.

### `static Bdg.elliptical_center_arc(center: Vector3, x_radius: float, y_radius: float, start_angle: float = 0.0, end_angle: float = 360.0, rotation: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgEllipticalCenterArc`
Elliptical arc around a center point with major and minor radii.

### `static Bdg.parabolic_center_arc(focal_length: float = 10.0, u_min: float = -10.0, u_max: float = 10.0, plane: BdgPlane = null, mode: int = BdgEnums.Mode.ADD) -> BdgParabolicCenterArc`
Analytical parabolic arc defined by focal length and parameter limits.

### `static Bdg.hyperbolic_center_arc(major_radius: float = 10.0, minor_radius: float = 5.0, u_min: float = -1.0, u_max: float = 1.0, plane: BdgPlane = null, mode: int = BdgEnums.Mode.ADD) -> BdgHyperbolicCenterArc`
Analytical hyperbolic arc defined by major/minor radii and parameter limits.

### `static Bdg.spline(points: Array, mode: int = BdgEnums.Mode.ADD) -> BdgSpline`
Smooth B-Spline curve passing through an array of points.

### `static Bdg.bspline(points: Array, mode: int = BdgEnums.Mode.ADD) -> BdgSpline`
Smooth B-Spline curve.

### `static Bdg.bezier(control_points: Array, weights: Array = [], mode: int = BdgEnums.Mode.ADD) -> BdgBezier`
Rational/polynomial Bezier curve with control points and optional weights.

### `static Bdg.helix(pitch: float, height: float, radius: float, center: Vector3 = Vector3.ZERO, dir: Vector3 = Vector3.UP, angle: float = 0.0, righthanded: bool = true, mode: int = BdgEnums.Mode.ADD) -> BdgHelix`
3D Helix curve defined by pitch, height, and radius.

### `static Bdg.airfoil(naca_code: String = "2412", chord_length: float = 100.0, sample_count: int = 100, mode: int = BdgEnums.Mode.ADD) -> BdgAirfoil`
NACA 4-Digit Airfoil curve profile (e.g. "2412", "0012").

### `static Bdg.blend_curve(edge1: BdgEdge, edge2: BdgEdge, tangent_scale: float = 1.0, mode: int = BdgEnums.Mode.ADD) -> BdgBlendCurve`
G1/G2 Curvature-continuous blend curve bridging two edges.

### `static Bdg.intersecting_line(start: Vector3, direction: Vector3, target_shape: BdgShape, mode: int = BdgEnums.Mode.ADD) -> BdgIntersectingLine`
Ray line intersecting another shape or surface.

### `static Bdg.rect(width: float, height: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgRectangle`
Planar rectangle sketch face.

### `static Bdg.rounded_rect(width: float, height: float, radius: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgRectangleRounded`
Planar rectangle with filleted corners.

### `static Bdg.circle(radius: float, arc_size: float = 360.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgCircle`
Planar circle sketch face.

### `static Bdg.ellipse(x_radius: float, y_radius: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgEllipse`
Planar ellipse sketch face.

### `static Bdg.regular_polygon(radius: float, side_count: int, major_radius: bool = true, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgRegularPolygon`
Regular N-gon polygon sketch face.

### `static Bdg.polygon(points: Array, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgPolygon`
Arbitrary planar polygon face from vertex points.

### `static Bdg.triangle(a: float, b: float, c: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgTriangle`
Planar triangle sketch face.

### `static Bdg.trapezoid(width: float, height: float, top_width: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgTrapezoid`
Planar trapezoid sketch face.

### `static Bdg.slot_c2c(distance: float, radius: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotCenterToCenter`
Stadium slot defined by center-to-center distance and radius.

### `static Bdg.slot_cp(center: Vector3, point: Vector3, radius: float, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotCenterPoint`
Stadium slot defined by center point, outer point, and radius.

### `static Bdg.slot_overall(width: float, height: float, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotOverall`
Stadium slot defined by overall bounding width and height.

### `static Bdg.slot_arc(arc_edge: BdgEdge, radius: float, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSlotArc`
Curved slot along an arc path.

### `static Bdg.text(txt: String, font_size: float = 12.0, font_name: String = "sans-serif", font_style: int = BdgEnums.FontStyle.REGULAR, align: Variant = BdgEnums.Align.CENTER, rotation: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgText`
2D Text faces generated via OpenCASCADE native BRep font builder.

### `static Bdg.superellipse(x_radius: float, y_radius: float, exponent: float, count: int = 120, rotation: float = 0.0, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSuperellipse`
Lamé curve / squircle superellipse sketch face.

### `static Bdg.box(length: float, width: float, height: float, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgBox`
3D Solid Box primitive.

### `static Bdg.cylinder(radius: float, height: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgCylinder`
3D Solid Cylinder primitive.

### `static Bdg.sphere(radius: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgSphere`
3D Solid Sphere primitive.

### `static Bdg.cone(radius1: float, radius2: float, height: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgCone`
3D Solid Cone/Frustum primitive.

### `static Bdg.torus(major_radius: float, minor_radius: float, arc_size: float = 360.0, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgTorus`
3D Solid Torus primitive.

### `static Bdg.wedge(dx: float, dy: float, dz: float, xmin: float, zmin: float, xmax: float, zmax: float, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgWedge`
3D Right Angular Wedge primitive.

### `static Bdg.convex_polyhedron(points: Array, rotation: Vector3 = Vector3.ZERO, align: Variant = BdgEnums.Align.CENTER, mode: int = BdgEnums.Mode.ADD) -> BdgConvexPolyhedron`
3D Convex Polyhedron solid generated from a 3D point cloud.

### `static Bdg.hole(radius: float, depth: float = 100.0, mode: int = BdgEnums.Mode.SUBTRACT) -> BdgHole`
Simple drilled cylindrical hole subtractor.

### `static Bdg.counter_bore_hole(radius: float, depth: float, cb_radius: float, cb_depth: float, mode: int = BdgEnums.Mode.SUBTRACT) -> BdgCounterBoreHole`
Counterbored stepped hole subtractor for socket screws.

### `static Bdg.counter_sink_hole(radius: float, depth: float, cs_radius: float, cs_angle: float = 90.0, mode: int = BdgEnums.Mode.SUBTRACT) -> BdgCounterSinkHole`
Countersunk conical hole subtractor for flathead screws.

### `static Bdg.hex_bolt(thread_radius: float, length: float, head_width: float = 0.0, head_height: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgHexBolt`
ISO standard Hexagonal Head Bolt solid.

### `static Bdg.hex_nut(thread_radius: float, width: float = 0.0, height: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgHexNut`
ISO standard Hexagonal Nut solid with central threaded bore hole.

### `static Bdg.socket_head_screw(thread_radius: float, length: float, head_radius: float = 0.0, head_height: float = 0.0, socket_size: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgSocketHeadCapScrew`
Socket Head Cap Screw (SHCS) solid with hex socket head.

### `static Bdg.add(objects: Variant, mode: int = BdgEnums.Mode.ADD) -> Variant`
Add objects to the current builder context.

### `static Bdg.mirror(objects: Variant, about: BdgPlane = null) -> Variant`
Mirror shapes across a plane (default XY).

### `static Bdg.scale(objects: Variant, factor: Variant, center: Vector3 = Vector3.ZERO) -> Variant`
Scale shapes uniformly (by float) or non-uniformly (by Vector3 [sx, sy, sz]).

### `static Bdg.offset(objects: Variant, amount: float, kind: int = 0) -> Variant`
2D/3D Offset operation.

### `static Bdg.project(objects: Variant, target: BdgShape, direction: Vector3 = Vector3.ZERO) -> Array`
Project curves/wires onto a target shape or surface.

### `static Bdg.split(objects: Variant, bisect_by: Variant, keep: int = BdgEnums.Keep.TOP) -> Variant`
Split / bisect shapes with a plane or surface (Keep.TOP, Keep.BOTTOM, Keep.BOTH).

### `static Bdg.bounding_box(objects: Variant) -> BdgBoundBox`
Compute oriented bounding box of objects.

### `static Bdg.pack(objects: Array, sheet_width: float, sheet_height: float, padding: float = 2.0) -> Array`
2D Sheet metal nesting and bin-packing algorithm.

### `static Bdg.make_face(wires_or_edges: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Make a planar face from closed wires or edges.

### `static Bdg.make_hull(points_or_shapes: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
2D Convex Hull face from a set of points or shapes.

### `static Bdg.trace(wire: BdgWire, distance: float, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Trace a wire with line thickness to generate a planar ribbon face.

### `static Bdg.full_round(sketch_or_face: Variant, edge1: BdgEdge, edge2: BdgEdge, radius: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgFace`
Full tangent rounding between two edges in a sketch.

### `static Bdg.extrude(to_extrude: Variant, amount: float, dir: Vector3 = Vector3.ZERO, both: bool = false, taper: float = 0.0, mode: int = BdgEnums.Mode.ADD) -> BdgPart`
Extrude a face along its normal or direction vector, with optional draft taper and both-directions.

### `static Bdg.revolve(to_revolve: Variant, angle: float, axis: BdgAxis = null, mode: int = BdgEnums.Mode.ADD) -> BdgPart`
Revolve a planar face around an axis (default Z).

### `static Bdg.sweep(profile: Variant, path: Variant, mode: int = BdgEnums.Mode.ADD) -> BdgShape`
Sweep a profile face along a 3D wire or curve path.

### `static Bdg.loft(objs: Array, ruled: bool = false, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Loft solid through a sequence of planar sections.

### `static Bdg.fillet(objects: Variant, radius: float) -> BdgShape`
Fillet 3D edges or vertices of a shape with a given radius.

### `static Bdg.chamfer(objects: Variant, length: float, length2: float = 0.0) -> BdgShape`
Chamfer 3D edges of a shape with a given bevel length.

### `static Bdg.section(shape: BdgShape, plane: BdgPlane = null) -> Array`
Section a 3D shape with a cutting plane, returning intersection edges/wires.

### `static Bdg.thicken(shape: BdgShape, amount: float, mode: int = BdgEnums.Mode.ADD) -> BdgShape`
Thicken a 2D face/wire into a 3D shell or solid.

### `static Bdg.hollow(solid: BdgSolid, faces_to_remove: Array, thickness: float, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Hollow a solid to create a thin-walled shell/cavity.

### `static Bdg.draft(solid: BdgSolid, faces: Array, angle_deg: float, neutral_plane: BdgPlane, pull_dir: Vector3 = Vector3.ZERO, mode: int = BdgEnums.Mode.ADD) -> BdgSolid`
Apply draft angle taper to mold/casting faces.

### `static Bdg.assembly(comp_shape: BdgShape = null, label: String = "", loc: BdgLocation = null, color: Color = Color.WHITE) -> BdgAssembly`
Create a hierarchical CAD Assembly component.

### `static Bdg.rigid_joint(parent_loc: BdgLocation, child_loc: BdgLocation, label: String = "") -> BdgJoint`
Create a Rigid (fixed) kinematic assembly joint.

### `static Bdg.revolute_joint(parent_loc: BdgLocation, child_loc: BdgLocation, axis: BdgAxis, min_ang: float = -180.0, max_ang: float = 180.0, label: String = "") -> BdgJoint`
Create a Revolute (rotational) kinematic assembly joint.

### `static Bdg.linear_joint(parent_loc: BdgLocation, child_loc: BdgLocation, axis: BdgAxis, min_dist: float = 0.0, max_dist: float = 100.0, label: String = "") -> BdgJoint`
Create a Linear (prismatic sliding) kinematic assembly joint.

### `static Bdg.technical_drawing(shape: BdgShape = null, width: float = 297.0, height: float = 210.0, scale: float = 1.0, title: String = "Part Drawing", author: String = "Antigravity") -> BdgTechnicalDrawing`
Create a multi-view orthographic technical drawing sheet.

### `static Bdg.dimension_line(start_point: Vector3, end_point: Vector3, offset: float = 10.0, text: String = "", arrow_size: float = 2.5) -> BdgDimensionLine`
Create a 2D dimension line annotation with witness lines and arrowheads.

### `static Bdg.export_step(shape: BdgShape, path: String) -> bool`
Export shape or assembly to STEP AP214 format.

### `static Bdg.export_stl(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export shape or assembly to ASCII STL format.

### `static Bdg.export_stl_binary(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export shape or assembly to binary STL format.

### `static Bdg.export_brep(shape: BdgShape, path: String) -> bool`
Export shape to native OpenCASCADE BREP format.

### `static Bdg.export_svg(shape: BdgShape, path: String, plane: BdgPlane = null, scale: float = 1.0) -> bool`
Export 2D contours of a shape to vector SVG format.

### `static Bdg.export_dxf(shape: BdgShape, path: String, plane: BdgPlane = null) -> bool`
Export 2D contours of a shape to AutoCAD DXF format.

### `static Bdg.export_obj(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export shape mesh to Wavefront OBJ format.

### `static Bdg.export_ply(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export shape mesh to Stanford PLY format.

### `static Bdg.export_gltf(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export shape mesh to standard GLTF 2.0 format.

### `static Bdg.import_step(path: String) -> BdgShape`
Import STEP AP214 file into BRep CAD shape with assembly hierarchy.

### `static Bdg.import_stl(path: String) -> BdgShape`
Import STL mesh file into reference face.

### `static Bdg.import_brep(path: String) -> BdgShape`
Import native OpenCASCADE BREP file.

### `static Bdg.import_svg(path: String) -> Array[BdgWire]`
Import 2D curves/wires from an SVG vector drawing.

### `static Bdg.import_dxf(path: String) -> Array[BdgWire]`
Import 2D curves/wires from an AutoCAD DXF drafting file.

### `static Bdg.polar(radius: float, angle_deg: float) -> Vector3`
Create 2D polar vector from radius and angle in degrees.

### `static Bdg.delta(dx: float, dy: float, dz: float = 0.0) -> Vector3`
Delta displacement vector shorthand.

### `static Bdg.vertices(shape: BdgShape) -> Array[BdgVertex]`
Return all vertices of a shape.

### `static Bdg.edges(shape: BdgShape) -> Array[BdgEdge]`
Return all edges of a shape.

### `static Bdg.wires(shape: BdgShape) -> Array[BdgWire]`
Return all wires of a shape.

### `static Bdg.faces(shape: BdgShape) -> Array[BdgFace]`
Return all faces of a shape.

### `static Bdg.solids(shape: BdgShape) -> Array[BdgSolid]`
Return all solids of a shape.

### `static Bdg.edges_to_wires(edge_list: Array) -> Array[BdgWire]`
Combine an array of edges into closed or continuous wires.

### `static Bdg.make_box(length: float, width: float, height: float, plane: BdgPlane = null) -> BdgSolid`
Box solid with its base corner at the plane origin (raw solid, not a PartObject).

### `static Bdg.make_cylinder(radius: float, height: float, plane: BdgPlane = null, angle: float = 360.0) -> BdgSolid`
Cylinder solid with base center at the plane origin.

### `static Bdg.make_sphere(radius: float, plane: BdgPlane = null) -> BdgSolid`
Sphere solid centered at the plane origin.

### `static Bdg.make_loft(objs: Array, ruled: bool = false, as_solid: bool = true) -> BdgShape`
Loft solid through an ordered array of wire sections (or apex vertices).

### `static Bdg.make_rect(width: float, height: float, plane: BdgPlane = null) -> BdgFace`
Planar rectangle face centered on the given plane (default XY).

### `static Bdg.make_rounded_rect(width: float, height: float, radius: float, plane: BdgPlane = null) -> BdgFace`
Planar rounded-corner rectangle face centered on the given plane.

### `static Bdg.make_circle(radius: float, plane: BdgPlane = null) -> BdgFace`
Planar circle face centered on the given plane.

### `static Bdg.make_slot(length: float, width: float, rotation_deg: float = 0.0) -> BdgFace`
Stadium-slot face with overall length and width, optionally rotated in degrees.

### `static Bdg.make_from_wires(outer_wire: BdgWire, inner_wires: Array = []) -> BdgFace`
Face built from an outer boundary wire and optional inner hole wires.

### `static Bdg.make_wire(edges: Array) -> BdgWire`
Wire built from an array of edges, wires, or 1D shapes.

### `static Bdg.make_polygon(points: Array, close: bool = true) -> BdgWire`
Polygon wire from an ordered list of points (closed by default).

### `static Bdg.make_rect_wire(width: float, height: float, plane: BdgPlane = null) -> BdgWire`
Rectangle wire centered on the given plane (1D boundary, not a face).

### `static Bdg.make_line(point1: Vector3, point2: Vector3) -> BdgEdge`
Straight line edge between two points.

### `static Bdg.make_radius_arc(start_point: Vector3, end_point: Vector3, radius: float, short_sagitta: bool = true) -> BdgEdge`
Circular arc edge between two points with a given radius.

### `static Bdg.make_spline(points: Array, tangents: Array = [], scale: bool = true) -> BdgEdge`
B-Spline edge through points with optional start/end tangents.

### `static Bdg.make_compound(shapes: Array) -> BdgCompound`
Compound of the given shapes.

### `static Bdg.make_pipe_shell(path_wire: BdgWire, sections: Array, as_solid: bool = true) -> BdgShape`
Swept shell/solid along a path wire with cross-section faces.

### `static Bdg.axis(origin: Vector3, direction: Vector3) -> BdgAxis`
Axis through an origin point in the given direction.

### `static Bdg.axis_x() -> BdgAxis`
World X axis.

### `static Bdg.axis_y() -> BdgAxis`
World Y axis.

### `static Bdg.axis_z() -> BdgAxis`
World Z axis.

### `static Bdg.grid_locations_list(x_spacing: float, y_spacing: float, x_count: int, y_count: int) -> Array`
Rectangular grid pattern locations (Array of BdgLocation), centered at origin.

### `static Bdg.hex_locations_list(apothem: float, x_count: int, y_count: int) -> Array`
Hexagonal packing pattern locations (Array of BdgLocation), centered at origin.

### `static Bdg.shape_list(shapes: Array) -> BdgShapeList`
Shape list wrapper around an array of shapes.

### `static Bdg.sort_by(shape_list: BdgShapeList, sort_by: Variant, reverse: bool = false) -> BdgShapeList`
Sort a shape list by a callable key, BdgAxis, or BdgEnums.SortBy criterion.

### `static Bdg.at(shape_list: BdgShapeList, index: int) -> BdgShape`
Index into a shape list (negative indexes from the end).

### `static Bdg.translate(shape: BdgShape, v: Vector3) -> BdgShape`
Translate a shape by a displacement vector.

### `static Bdg.scaled(shape: BdgShape, factor: Variant, center: Vector3 = Vector3.ZERO) -> BdgShape`
Scale a shape about a center (uniform float factor or per-axis Vector3 factor), returning a copy.

### `static Bdg.rotate(shape: BdgShape, axis: BdgAxis, angle_deg: float) -> BdgShape`
Rotate a shape about an axis by an angle in degrees.

### `static Bdg.move(shape: BdgShape, loc: BdgLocation) -> BdgShape`
Move a shape to a location (position + orientation).

### `static Bdg.clean(shape: BdgShape) -> BdgShape`
Clean / heal a shape (remove nulls, fix tolerances, reorder).

### `static Bdg.center(shape: BdgShape) -> Vector3`
Centroid of a shape.

### `static Bdg.geom_type(shape: BdgShape) -> int`
Geometric type enum value of a shape (Bdg.GeomType.LINE, CIRCLE, PLANE, ...).

### `static Bdg.to_plane(face: BdgFace) -> BdgPlane`
Base plane of a planar face.

### `static Bdg.length(edge: BdgMixin1D) -> float`
Length of a 1D edge or wire.

### `static Bdg.param_at_distance(edge: BdgMixin1D, dist: float) -> float`
Parameter value (u) at a given distance along a 1D edge/wire.

### `static Bdg.position_at(edge: BdgMixin1D, position: float) -> Vector3`
Point position at parameter value u along a 1D edge/wire.

### `static Bdg.tangent_at(edge: BdgMixin1D, position: float) -> Vector3`
Tangent direction vector at parameter value u along a 1D edge/wire.

### `static Bdg.normal_at(edge: BdgMixin1D, position: float) -> Vector3`
Normal direction vector at parameter value u along a 1D edge/wire.

### `static Bdg.offset_shape(shape: BdgShape, amount: float, openings: Array = []) -> BdgShape`
Solid offset / shell operation (negative amount shells inward).

### `static Bdg.fillet_edges(shape: BdgShape, radius: float, edge_list: Array = []) -> BdgShape`
Fillet specific edges of a shape with a given radius.

### `static Bdg.extrude_vec(shape: BdgShape, direction: Vector3) -> BdgShape`
Extrude a face by a full 3D direction vector (magnitude = distance).

### `static Bdg.revolve_axis(shape: BdgShape, angle_deg: float, axis: BdgAxis = BdgAxis.Z) -> BdgShape`
Revolve a face about an axis by an angle in degrees (raw result, not wrapped).

### `static Bdg.ball_joint(parent_loc: BdgLocation, child_loc: BdgLocation, label: String = "") -> BdgJoint`
Create a Ball (spherical 3-DOF rotation) kinematic joint.

### `static Bdg.cylindrical_joint(parent_loc: BdgLocation, child_loc: BdgLocation, axis: BdgAxis, label: String = "") -> BdgJoint`
Create a Cylindrical (1 rotation + 1 translation) kinematic joint.

### `static Bdg.vector(val: Variant) -> Vector3`
Helper vector constructor / converter

### `static Bdg.compounds(shape: Variant) -> BdgShapeList`
Return compounds of shape or shape list

### `static Bdg.export_to_pcbway(shape: BdgShape, path: String) -> bool`
Export model as ZIP package for PCBWay quote

### `static Bdg.import_svg_document(path: String) -> Dictionary`
Import full SVG document metadata along with wires

### `static Bdg.import_svg_as_buildline_code(path: String) -> String`
Import SVG path and convert to executable Bdg.build_line GDScript code


## Patterns

### `BdgLocations.begin() -> void`
Push this location context onto the active stack.

### `BdgLocations.end() -> bool`
Pop this location context from the active stack.

### `static BdgLocations.get_current_locations() -> Array[BdgLocation]`
Get currently active locations (or empty array if none active).

### `static BdgLocations.has_active_locations() -> bool`
Whether a location context is currently active.


## I/O & Meshing

### `static BdgIO.export_stl(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> bool`
Export a shape as an ASCII STL file. Returns true on success.

### `static BdgIO.export_step(shape: BdgShape, path: String) -> bool`
Export a shape as a STEP file (AP214 / ManifoldSolidBrep). Returns true on success.

### `static BdgIO.import_stl(path: String) -> BdgShape`
Import an STL file (ASCII or binary) as a reference Face. The result is a mesh-based face, suitable for viewing or meshing, not for CAD boolean editing. Returns null on failure.

### `static BdgIO.import_step(path: String) -> BdgShape`
Import a STEP file using the XCAF reader, preserving assemblies, names, locations and colors. Returns a BdgShape (a BdgCompound for multi-root files, the single root shape for single-root files). Null on failure.

### `static BdgIO.export_stl_binary(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> bool`
Export a shape as a binary STL file. Returns true on success.

### `static BdgIO.export_brep(shape: BdgShape, path: String) -> bool`
Export a shape in native OpenCASCADE BREP format.

### `static BdgIO.import_brep(path: String) -> BdgShape`
Import an OpenCASCADE BREP file.

### `static BdgIO.export_svg(shape: BdgShape, path: String, plane: BdgPlane = null, scale_val: float = 1.0) -> bool`
Export 2D contours / edges of a shape to a vector SVG file.

### `static BdgIO.export_dxf(shape: BdgShape, path: String, plane: BdgPlane = null) -> bool`
Export 2D edges of a shape to a minimal AutoCAD DXF file.

### `static BdgIO.import_svg(path: String) -> Array[BdgWire]`
Import 2D curves/wires from an SVG file.

### `static BdgIO.import_dxf(path: String) -> Array[BdgWire]`
Import 2D curves/wires from a DXF file.

### `static BdgIO.export_obj(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export a shape as Wavefront OBJ format.

### `static BdgIO.export_ply(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export a shape as Stanford PLY format.

### `static BdgIO.export_gltf(shape: BdgShape, path: String, tolerance: float = 0.1, angular_tolerance: float = 12.0) -> bool`
Export a shape as GLTF JSON format.

### `static BdgIO.export_to_pcbway(shape: BdgShape, path: String) -> bool`
Export model as ZIP archive package for PCBWay fabrication quote

### `static BdgIO.import_svg_document(path: String) -> Dictionary`
Import full SVG document metadata along with wires

### `static BdgIO.import_svg_as_buildline_code(path: String) -> String`
Import SVG path and convert to executable Bdg.build_line GDScript code

### `static BdgMesh.to_array_mesh(shape: BdgShape, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> ArrayMesh`
Build a Godot ArrayMesh from a shape's tessellation. tolerance (linear) and angular_tolerance (degrees) control mesh density. Per-vertex normals are area-weighted smoothed from the triangle faces.

### `static BdgMesh.to_mesh_instance3d(shape: BdgShape, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> MeshInstance3D`
Build a MeshInstance3D node displaying the shape.

### `static BdgMesh.triangle_count(shape: BdgShape, tolerance: float = 0.1, angular_tolerance: float = 10.0) -> int`
Count of triangles in a shape's tessellation.
