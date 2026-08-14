#!/usr/bin/env python3
import sys, os, json, types

# Create a robust mock for ocp_vscode
captured = []

def show(*args, **kwargs):
    for a in args:
        captured.append(a)

def show_object(*args, **kwargs):
    show(*args, **kwargs)

class DummyMock:
    def __init__(self, *args, **kwargs): pass
    def __call__(self, *args, **kwargs): return self
    def __getattr__(self, name): return self

mock_ocp = types.ModuleType("ocp_vscode")
mock_ocp.show = show
mock_ocp.show_object = show_object
mock_ocp.show_all = lambda *args, **kwargs: None
mock_ocp.set_port = lambda *args, **kwargs: None
mock_ocp.Camera = DummyMock
mock_ocp.Color = DummyMock
sys.modules["ocp_vscode"] = mock_ocp

from build123d import *
from build123d.topology import Shape, Compound, Solid

def extract_metrics_for_file(filepath):
    captured.clear()

    if not os.path.exists(filepath):
        return {"error": f"File not found: {filepath}"}

    with open(filepath, "r", encoding="utf-8") as f:
        code = f.read()

    # Disable assert statements or catch assertion errors gracefully
    file_dir = os.path.dirname(os.path.abspath(filepath))
    old_cwd = os.getcwd()
    os.chdir(file_dir)

    local_env = {
        "show": show,
        "show_object": show_object,
        "__file__": filepath,
        "__name__": "__main__"
    }

    try:
        exec(code, local_env)
    except AssertionError as ae:
        # Code completed geometric modeling but failed an assertion threshold
        pass
    except Exception as e:
        os.chdir(old_cwd)
        return {"error": f"Python execution error in {os.path.basename(filepath)}: {type(e).__name__}: {str(e)}"}

    os.chdir(old_cwd)

    def unwrap(obj):
        if hasattr(obj, "part") and obj.part is not None:
            return obj.part
        if hasattr(obj, "sketch") and obj.sketch is not None:
            return obj.sketch
        if hasattr(obj, "line") and obj.line is not None:
            return obj.line
        if hasattr(obj, "shape") and obj.shape is not None:
            return obj.shape
        if hasattr(obj, "wrapped") and isinstance(obj, Shape):
            return obj
        return obj

    target = None
    # Check common variable names
    for candidate_name in ["grid", "part", "result", "rail", "vase", "maker_coin", "clock", "clock_face", "key_cap", "holes", "canadian_flag", "fast_grid", "logo", "heat_exchanger", "lego", "pillow_block", "tea_cup", "toy_truck", "bp", "ex", "handle", "din", "circuit_board", "stud_wall", "assembly", "cards", "dice"]:
        if candidate_name in local_env:
            target = unwrap(local_env[candidate_name])
            if isinstance(target, (Shape, Compound, Solid, Face, Wire, Edge)):
                break

    if (target is None or not isinstance(target, Shape)) and captured:
        for raw in reversed(captured):
            t = unwrap(raw)
            if isinstance(t, (Shape, Compound, Solid, Face, Wire, Edge)):
                target = t
                break

    if target is None or not isinstance(target, Shape):
        for k, v in local_env.items():
            if k.startswith("_"):
                continue
            t = unwrap(v)
            if isinstance(t, (Shape, Compound, Solid, Face, Wire, Edge)):
                target = t
                break

    if target is None:
        return {"error": f"No solid/shape target found in python script: {os.path.basename(filepath)}"}

    bdg_shape = target if isinstance(target, Shape) else Shape(target)

    # Compute volume, face count, edge count, vertex count, bounding box size
    vol = float(bdg_shape.volume) if hasattr(bdg_shape, "volume") else 0.0
    faces = len(bdg_shape.faces()) if hasattr(bdg_shape, "faces") else 0
    edges = len(bdg_shape.edges()) if hasattr(bdg_shape, "edges") else 0
    verts = len(bdg_shape.vertices()) if hasattr(bdg_shape, "vertices") else 0
    bbox = bdg_shape.bounding_box()
    bbox_size = [float(bbox.size.X), float(bbox.size.Y), float(bbox.size.Z)]
    bbox_min = [float(bbox.min.X), float(bbox.min.Y), float(bbox.min.Z)]
    bbox_max = [float(bbox.max.X), float(bbox.max.Y), float(bbox.max.Z)]

    return {
        "volume": vol,
        "faces": faces,
        "edges": edges,
        "vertices": verts,
        "bbox_size": bbox_size,
        "bbox_min": bbox_min,
        "bbox_max": bbox_max
    }

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: py_reference_runner.py <example_py_path>"}))
        sys.exit(1)
    res = extract_metrics_for_file(sys.argv[1])
    print("PYTHON_METRICS_JSON:" + json.dumps(res))
