# OpenCASCADE.gd compatibility assessment (build123d.gd port)

Status: BLOCKED — see "Critical blocker" below.

This port of build123d depends on the preinstalled
[OpenCASCADE.gd](https://github.com/yeicor-gd/OpenCASCADE.gd) GDExtension addon
(auto-generated `Ocg*` wrapper classes around OCCT, 5755 classes). Before
writing the port, the wrapper surface was audited against build123d's required
OCCT functionality. This document records what works, what is missing, and
what must be fixed in the addon for the port to reach feature parity.

## Summary

- Wrapper naming: `Ocg` + OCCT class name with `_` stripped
  (`BRepPrimAPI_MakeBox` → `OcgBRepPrimAPIMakeBox`).
- Static factory methods `from_*` return a *new* wrapper instance; the
  autowrapper binds **only methods declared in each class's own header** —
  inherited methods are NOT flattened onto derived wrappers.
- This inheritance limitation is the root cause of every gap below.

## Critical blocker: boolean operations cannot return their result

build123d's core `Part`/`Sketch` boolean operations
(`fuse`, `subtract`, `intersect` / `Part.add`, `Part.subtract`, `Part.intersect`)
map to OCCT `BRepAlgoAPI_Fuse`, `BRepAlgoAPI_Cut`, `BRepAlgoAPI_Common`.

The result shape is exposed by OCCT via `BRepBuilderAPI_MakeShape::Shape()`,
which these classes **inherit**. Because the autowrapper only binds
own-header methods and explicitly skips `BRepBuilderAPI_MakeShape`
(`OpenCASCADE.gd-autowrapper/autogen/policy.py:662`), the generated wrappers
expose only the constructors:

- `OcgBRepAlgoAPIFuse`: `from_U`, `from_b`, `from_o` — no `shape()`
- `OcgBRepAlgoAPICut`: `from_U`, `from_b`, `from_o` — no `shape()`
- `OcgBRepAlgoAPICommon`: `from_U`, `from_b`, `from_o` — no `shape()`

Verified live with Godot 4.7.1: `fuse.has_method("shape") == false`.
`OcgBOPAlgoBuilder` (`build_bop_P`, `build_bop_f`) similarly cannot extract a
result. The official addon demo test
(`demo/tests/autowrapper/test_new_occt_api.gd`) only *constructs* the boolean
ops and never extracts a shape.

**Impact:** `Part.add/subtract/intersect`, and any Sketch boolean, are
impossible. This alone blocks feature parity.

## Also missing (same root cause — inherited `Shape()`)

The following operations also produce results only through the inherited
`BRepBuilderAPI_MakeShape::Shape()` and therefore cannot extract their output:

| build123d feature | OCCT class | wrapper accessors bound |
|---|---|---|
| `Part.fillet` | `BRepFilletAPI_MakeFillet` | `add_*`, `build`, diagnostics (`nb_contours`, `radius_2`, …) — no `shape()` |
| `Part.chamfer` | `BRepFilletAPI_MakeChamfer` | `add_*`, `build`, diagnostics — no `shape()` |
| `Part.thicken` | `BRepOffsetAPI_MakeThickSolid` | `build`, `modified` — no `shape()` |
| `Part.offset` | `BRepOffsetAPI_MakeOffsetShape` | `build`, `generated`, `is_deleted`, `modified` — no `shape()` |
| `Part.remove_faces` / defeaturing | `BRepAlgoAPI_Defeaturing` | `build`, `generated`, `modified`, `is_deleted` — no `shape()` |
| `Shape.section` / slicing | `BRepAlgoAPI_Section` | `build`, `init1_*`, `init2_*`, `compute_p_curve_on*` — no `shape()` |
| `Shape.split` / splitting | `BRepAlgoAPI_Splitter` | `build`, `set_tools`, `add_*` — no `shape()` |
| `Edge.offset_2d` / `Wire.offset_2d` | `BRepOffsetAPI_MakeOffset` | `init_*`, `add_wire`, `perform`, `build` — no `shape()` |

## Missing wrapper classes (no `Ocg*` binding at all)

| build123d feature | OCCT class | workaround / alternative |
|---|---|---|
| `Compound` / `Part` assembly from shape lists | `BRepBuilderAPI_MakeCompound` | **NOT wrapped.** `OcgTopoDSBuilder` (=`TopoDS_Builder`) is wrapped and provides `make_compound`, `make_comp_solid`, `make_wire`, `make_shell`, `make_solid`, `add`, `remove` — low-level compound building works. Also `OcgShapeExtendExplorer.compound_from_seq` / `sorted_compound`. |
| `BRep_Builder` low-level editing (mostly redundant) | `BRep_Builder` | NOT wrapped, but its parent `OcgTopoDSBuilder` covers `make_*`/`add`/`remove`. |
| shape-list containers | `TopTools_ListOfShape`, `MapOfShape`, `IndexedMapOfShape`, `IndexedDataMapOfShapeListOfShape`, `HSequenceOfShape` | NOT wrapped. Use `OcgNCollection*TopoDSShape` instantiations (`OcgNCollectionHSequenceTopoDSShape.append_4`, `OcgNCollectionSequenceTopoDSShape`, `OcgNCollectionIndexedMapTopoDSShape`). |
| length/area/volume one-shots | `GProp_CurveProps`, `GProp_SurfaceProps`, `GProp_VolumeProps` | NOT wrapped. Use `OcgBRepGProp.linear/surface/volume_properties_*` + `OcgGPropGProps.mass()` / `centre_of_mass()`. |
| curvature/detail props | `GeomLProp_CLProps`, `GeomLProp_SLProps`, `BRepLProp_CLProps`, `BRepLProp_SLProps` | NOT wrapped; only namespace classes `OcgGeomLProp`/`OcgBRepLProp` exist. |
| extrema result object | `BRepExtrema_DistShapeShapeResult` | NOT wrapped, but `OcgBRepExtremaDistShapeShape` itself exposes `value()`, `point_on_shape1/2`, `par_on_edge/face_*` — sufficient. |

## Partial workarounds available (no `shape()` but alternative accessor works)

| build123d feature | OCCT class | working workaround |
|---|---|---|
| `Shape.moved/rotated/scaled/translated` (rigid+affine transform) | `BRepBuilderAPI_Transform` / `GTransform` | `modified_shape(S)` returns the transformed copy of input `S` (verified bound). |
| 3D offset (`Part.offset` deep variant) | `BRepOffset_MakeOffset` | **Wrapped and usable:** own-header `shape()`, `make_offset_shape()`, `make_thick_solid()`, `generated()` — a viable replacement for the broken `BRepOffsetAPI_MakeOffsetShape`. |

## Geometry queries — verify NOT relying on `BRepAdaptor_*` inherited methods

`OcgBRepAdaptorCurve` / `OcgBRepAdaptorSurface` / `OcgBRepAdaptorCompCurve` are
wrapped but lack `Value`/`D1`/`FirstParameter`/`LastParameter` (inherited from
`Adaptor3d_Curve`/`Adaptor3d_Surface`, not flattened). Use instead:

- `OcgGeomCurve.value(U)`, `.d0/d1/d2/d3/dn(U)`, `.first_parameter()`,
  `.last_parameter()`, `.is_closed()`, `.continuity()` — obtained via
  `OcgBRepTool.curve_F(edge, first, last)`.
- `OcgGeomAdaptorCurve` / `OcgGeomAdaptorSurface` (own-header `eval_d0`,
  `eval_dn`, `first/last_parameter`, `circle()`, `line()`, `degree()`, …).
- `OcgBRepGPropFace.normal(U, V, P, VNor)` for face normals.
- Surface geometry via `OcgBRepTool.surface_a(face)` / `surface_W(face, loc)`
  → `OcgGeomSurface` hierarchy (`plane()`, `cylindrical_surface()`, `sphere()`,
  …).

`OcgBRepAdaptorCurve.edge()` and `.trim()` ARE bound (own header).

## Operations that DO expose results (usable)

| build123d feature | OCCT class | working accessor |
|---|---|---|
| `Box` | `BRepPrimAPI_MakeBox` | `solid()`, `shell()`, `top_face()`, `bottom_face()`, … |
| `Cylinder`, `Cone`, `Sphere`, `Torus`, `Wedge` | `BRepPrimAPI_Make*` | `solid()`, `shell()` |
| `Extrude` / `Part.extrude` | `BRepPrimAPI_MakePrism` | `first_shape_g()`, `last_shape_g()` |
| `Revolve` / `Part.revolve` | `BRepPrimAPI_MakeRevol` | `first_shape_g()`, `last_shape_g()` |
| `Loft` / `Part.loft` | `BRepOffsetAPI_ThruSections` | `first_shape()`, `last_shape()` |
| `Sweep` / `Part.sweep` | `BRepOffsetAPI_MakePipeShell` | `first_shape()`, `last_shape()` |
| `Edge`, `Wire` | `BRepBuilderAPI_MakeEdge` / `MakeWire` | `edge()`, `wire()` |
| `Face` | `BRepBuilderAPI_MakeFace` | `face()` |
| `Vertex` | `BRepBuilderAPI_MakeVertex` | `vertex()` |

Supporting APIs verified present: `OcgTopoDSShape` (`.is_null()`, `.shape_type()`,
`.nb_children()`), `OcgTopoDSBuilder` (`make_compound/make_wire/make_shell/make_solid/add`),
`OcgTopExpExplorer`, `OcgTopExp` (`common_vertex`, `first/last_vertex`,
`map_shapes_H`, `map_shapes_and_ancestors`), `OcgBRepTools` (`outer_wire`, `clean`,
`compare_*`), `OcgBRepToolsWireExplorer`, `OcgBRepGProp`/`OcgGPropGProps`,
`OcgBRepMeshIncrementalMesh`, `OcgBRepTool` (=`BRep_Tool`: `curve_F`, `surface_a`,
`triangulation`, `parameter*`), `OcgPolyTriangulation` (`nb_nodes`, `node`,
`internal_triangles`, …), `OcgSTEPControlWriter/Reader`, `OcgStlAPIWriter/Reader`,
`OcgBRepExtremaDistShapeShape`, `OcgBRepClass3dSClassifier` (point-in-solid),
`OcgGCMakeLine/Segment/Circle/ArcOfCircle/Ellipse/Plane`, `OcgGCE2dMake*`
(`value()` accessor), `OcgGeom2dAPIInterpolate`, `OcgGeom2dAPIPointsToBSpline`,
`OcgGeomAPIInterpolate`, `OcgGeomAPIProjectPointOnCurve`,
`OcgGeomAPIProjectPointOnSurf`, `OcgGeomConvert`, `OcgGeomLProp`,
`OcgShapeFixShape/Wire`, `OcgShapeAnalysisWire`, `OcgBRepCheckAnalyzer`,
`OcgBRepPrimAPIMakeBox/Sphere/Cone/Revol/Cylinder/Prism` (own-header
`solid()/shell()/first_shape_*/last_shape_*`), `OcgBRepBuilderAPIMakePolygon`
(`wire()`, `edge()`), `OcgBRepProjProjection` (`shape()`, iteration),
`OcgBRepLibFindSurface` (`found()`, `surface()`), `OcgBRepSweepBuilder`.

## Required addon future work (to unblock the port)

1. **Flatten inherited result accessors onto result-producing builders.** At
   minimum bind `shape()` (and `is_done()`, `modified()`, `generated()`,
   `is_deleted()`) on the classes listed above, i.e. any class whose OCCT
   base `BRepBuilderAPI_MakeShape` is otherwise skipped. This is a codegen
   change in `OpenCASCADE.gd-autowrapper` (generalize the existing
   `inherited_native`/`sync_bases` mechanism beyond `TopoDS_Shape` tags, or add
   a targeted policy for `BRepBuilderAPI_MakeShape`-derived builders).
   Affected beyond the boolean family (all verified absent from the dump):
   `BRepAlgoAPI_Section`, `BRepAlgoAPI_Splitter`, `BRepFilletAPI_MakeFillet`,
   `BRepFilletAPI_MakeChamfer`, `BRepOffsetAPI_MakeThickSolid`,
   `BRepOffsetAPI_MakeOffsetShape`, `BRepOffsetAPI_MakeOffset`,
   `BRepAlgoAPI_Defeaturing`, `BRepBuilderAPI_Transform`/`GTransform`
   (`modified_shape` is a partial workaround).
2. **Wrap `BRepBuilderAPI_MakeCompound`** (or confirm `TopoDS_Builder` is
   sufficient) and the `TopTools_*` containers / `GProp_*Props` classes so the
   port does not depend on NCollection-typed workarounds.
3. Rebuild the addon (OCCT + godot-cpp + wrappers are all buildable locally at
   `/home/yeicor/Projects/OpenCASCADE.gd`, `build-gcc` CMake dir already
   configured for Debug) and replace the preinstalled
   `addons/OpenCASCADE.gd/libgdext.linux.debug.template_debug.x86_64.so`.
4. Re-run this audit to confirm no other inherited-only accessors are required.

## Note on tooling discovered during the audit

- OCCT installed from vcpkg at
  `/home/yeicor/Projects/OpenCASCADE.gd/vcpkg/installed/x64-linux`
  (OCCT V8_0_1, headers under `include/opencascade`).
- Autowrapper: `OpenCASCADE.gd-autowrapper/autogen/{codegen,extract,policy,synthesize}.py`.
- Full wrapped-API dump used for this audit: `/tmp/opencode/occt_api/classes.txt`
  (92965 lines; regenerable via `dump_api.gd` SceneTree script).
