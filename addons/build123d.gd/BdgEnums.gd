extends RefCounted
## BdgEnums - enums mirroring build123d/build_enums.py
## Used as static constants: BdgEnums.GeomType.LINE etc.

class_name BdgEnums

enum GeomType { LINE, CIRCLE, ELLIPSE, HYPERBOLA, PARABOLA, BEZIER, BSPLINE, OFFSET, PLANE, CYLINDER, CONE, SPHERE, TORUS, REVOLUTION, EXTRUSION, OTHER }

enum CenterOf { MASS, GEOMETRY, BOUNDING_BOX }

enum Keep { TOP, BOTTOM, BOTH }

enum Kind { ARC, INTERSECTION, TANGENT }

enum SortBy { LENGTH, AREA, VOLUME, DISTANCE, DISTANCE_TO, X, Y, Z, CENTER_X, CENTER_Y, CENTER_Z, MIN_X, MIN_Y, MIN_Z, MAX_X, MAX_Y, MAX_Z, IS_A }

enum Transition { TRANSFORMED, ROUND, RIGHT }

enum Unit { DEFAULT, MM, CM, M, IN, FT }

enum Align { MIN, CENTER, MAX, NONE }

enum Side { LEFT, RIGHT, BOTH }

enum Mode { ADD, SUBTRACT, INTERSECT, REPLACE, PRIVATE }

enum Until { NEXT, LAST }

enum LengthMode { NORMAL, RETRIEVED, CAD_OBJECT, BRIDGE }

enum PositionMode { X, Y, Z, RADIAL }

enum PrecisionMode { LOW, MEDIUM, HIGH }

enum NumberDisplay { LEFT, RIGHT, DECIMAL, FLOATING }

enum Tangency { EQUAL, STRAIGHT, MIRROR, PERPENDICULAR }

enum AngularDirection { CLOCKWISE, COUNTER_CLOCKWISE }

enum HeadType { OPEN, CLOSED }

enum Extrinsic { XY, YZ, ZX, YX, ZY, XZ }

enum Intrinsic { XY, YZ, ZX, YX, ZY, XZ }

enum Sagitta { IN, OUT }

enum TextAlign { LEFT, CENTER, RIGHT, JUSTIFY }

enum FontStyle { REGULAR, BOLD, ITALIC, BOLD_ITALIC }

enum ApproxOption { TANGENT, NONE }

enum ContinuityLevel { C0, C1, C2, C3, G1, G2 }

enum FrameMethod { ORIGIN, OPEN, CLOSED }

enum MeshType { SIMPLE, FRENET, TRIHEDRON, CONSTANT, BIFURCATED }

enum PageSize { A0, A1, A2, A3, A4, A5, LETTER, LEGAL, TABLOID }

## TopAbs shape enum mirror (OCCT integer values)
enum ShapeType { COMPOUND=0, COMPSOLID=1, SOLID=2, SHELL=3, FACE=4, WIRE=5, EDGE=6, VERTEX=7, SHAPE=8 }
