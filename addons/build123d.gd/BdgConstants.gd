extends RefCounted
## BdgConstants - units and tolerances, mirroring build123d/build_constants.py
class_name BdgConstants

const TOLERANCE := 1e-6
const DEG2RAD := PI / 180.0
const RAD2DEG := 180.0 / PI

const UNITS_PER_METER := 1000.0
const UNITS_PER_KILOGRAM := 1.0

const MC := 0.000001
const MM := 0.001
const CM := 0.01
const M := 1.0
const IN := 0.0254
const FT := 0.3048
const THOU := 0.0000254

const G := 0.001
const KG := 1.0
const G_PER_LB := 453.59237
const LB := 0.45359237

static func convert(value: float, from_unit: int, to_unit: int = BdgEnums.Unit.MM) -> float:
	return value * from_unit / to_unit
