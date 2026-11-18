"""Verify documentation assets, local references and deterministic engine fixtures."""
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
game = json.loads((ROOT / "contracts/game-v1.json").read_text())
vectors = json.loads((ROOT / "contracts/game-v1-vectors.json").read_text())
api = json.loads((ROOT / "contracts/openapi.json").read_text())


def step(value):
    limit = game["rng"]["modulus"] - 1
    left, right, final = game["rng"]["shifts"]
    value ^= (value << left) & limit
    value ^= value >> right
    return value ^ ((value << final) & limit)


def evaluate(case):
    board = [list(row) for row in case["board"]]
    cells = [
        (case["row"] + row, case["col"] + col)
        for row, line in enumerate(case["piece"])
        for col, value in enumerate(line)
        if value == "#"
    ]
    if any(not (0 <= row < 8 and 0 <= col < 8) for row, col in cells):
        return {"error": "bounds"}
    if any(board[row][col] == "#" for row, col in cells):
        return {"error": "overlap"}
    for row, col in cells:
        board[row][col] = "#"
    rows = [row for row in range(8) if all(cell == "#" for cell in board[row])]
    cols = [col for col in range(8) if all(row[col] == "#" for row in board)]
    cleared = {(row, col) for row in range(8) for col in range(8)
               if row in rows or col in cols}
    lines = len(rows) + len(cols)
    chain = case["chain"] + 1 if lines else 0
    score = game["score"]
    delta = (len(cells) * score["cell"] + score["line"] * lines
             + score["multiCoefficient"] * lines * (lines - 1)
             + score["comboStep"] * max(0, min(score["comboBonusCapSteps"], chain - 1)))
    return dict(rows=rows, cols=cols, distinctCleared=len(cleared), chain=chain, delta=delta)


def check_refs(value):
    if isinstance(value, dict):
        if "$ref" in value:
            target = api
            assert value["$ref"].startswith("#/"), value
            for part in value["$ref"][2:].split("/"):
                target = target[part]
        for child in value.values():
            check_refs(child)
    elif isinstance(value, list):
        for child in value:
            check_refs(child)


ids = set()
for shape in game["catalog"]:
    assert shape["id"] not in ids and shape["weight"] > 0, shape
    ids.add(shape["id"])
    mask = shape["mask"]
    assert 1 <= len(mask) <= 8 and 1 <= len(mask[0]) <= 8, shape
    assert all(len(row) == len(mask[0]) and re.fullmatch(r"[.#]+", row) for row in mask), shape
    assert all("#" in row for row in mask), shape
value = 1
for expected in vectors["rngSeed1"]:
    value = step(value)
    assert value == expected, (value, expected)
for case in vectors["cases"]:
    expected = case.get("expected", {"error": case.get("error")})
    assert evaluate(case) == expected, case["id"]
for page in [ROOT / "README.md", *sorted((ROOT / "docs").glob("*.md"))]:
    body = page.read_text()
    for link in re.findall(r'\]\(([^)]+)\)|src="([^"]+)"', body):
        dest = next(part for part in link if part)
        if "://" not in dest and not dest.startswith("#"):
            assert (page.parent / dest.split("#")[0]).is_file(), (page, dest)
for svg in (ROOT / "docs/media").glob("*.svg"):
    assert ET.parse(svg).getroot().tag.endswith("}svg"), svg
check_refs(api)
print("Verified Markdown links, SVG syntax, rule catalog, replay fixtures and OpenAPI references.")
