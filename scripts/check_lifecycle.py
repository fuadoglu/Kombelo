"""Check the Classic terminal/refill/alternate fixture against the rules data."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
rules = json.loads((ROOT / "contracts/game-v1.json").read_text())
vector = json.loads((ROOT / "contracts/classic-lifecycle-v1.json").read_text())
catalog = {shape["id"]: shape for shape in rules["catalog"]}


def rotations(mask):
    unique = []
    for _ in range(4):
        if mask not in unique:
            unique.append(mask)
        mask = tuple("".join(row) for row in zip(*mask[::-1]))
    return unique


def refill(rng):
    limit = rules["rng"]["modulus"] - 1
    left, right, final = rules["rng"]["shifts"]

    def next_value():
        nonlocal rng
        rng ^= (rng << left) & limit
        rng ^= rng >> right
        rng ^= (rng << final) & limit
        return rng

    tray = []
    for _ in range(rules["traySize"]):
        sample = next_value() % sum(shape["weight"] for shape in catalog.values())
        for shape in catalog.values():
            if sample < shape["weight"]:
                break
            sample -= shape["weight"]
        count = len(rotations(tuple(shape["mask"])))
        tray.append(dict(shape=shape["id"], rotation=next_value() % count,
                         color=next_value() % len(rules["palette"])))
    return tray, rng


def fits(board, piece, row, col):
    mask = rotations(tuple(catalog[piece["shape"]]["mask"]))[piece["rotation"]]
    return (row + len(mask) <= 8 and col + len(mask[0]) <= 8
            and all(board[row + y][col + x] == "."
                    for y, line in enumerate(mask) for x, value in enumerate(line)
                    if value == "#"))


def play_last_dot(state, move):
    board = state["board"].copy()
    row, col = move["row"], move["col"]
    piece = state["tray"][move["slot"]]
    assert piece["shape"] == "dot" and fits(board, piece, row, col)
    assert sum(piece is not None for piece in state["tray"]) == 1
    board[row] = board[row][:col] + "#" + board[row][col + 1:]
    assert all("." in line for line in board)
    assert all("." in column for column in zip(*board))
    tray, rng = refill(state["rng"])
    terminal = not any(fits(board, piece, r, c)
                       for piece in tray for r in range(8) for c in range(8))
    after = dict(board=board, tray=tray, rng=rng, score=state["score"] + 1,
                 chain=0, personalBest=state["personalBest"])
    return after, terminal


original, terminal = play_last_dot(vector["before"], vector["original"])
assert terminal and original == vector["terminal"]
alternate, terminal = play_last_dot(vector["before"], vector["alternate"])
assert dict(terminal=terminal, score=alternate["score"], rng=alternate["rng"]) == vector["alternateOutcome"]
print("Verified terminal refill and viable alternate placement. Runtime reward callbacks require integration tests.")
