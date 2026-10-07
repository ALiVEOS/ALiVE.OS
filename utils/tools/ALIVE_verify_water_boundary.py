"""Verify and summarize focused Altis water-query diagnostics."""
import argparse
import collections
import hashlib
import json
import re
from pathlib import Path


def markers(text, name):
    tag = "CLUSTER_BENCHMARK " + name + " "
    return [json.JSONDecoder().raw_decode(line.split(tag, 1)[1].replace('""', '"'))[0]
            for line in text.splitlines() if tag in line]


def verify(run):
    text = next(run.glob("*.rpt")).read_text(errors="replace")
    assert "PASS: focused water boundary diagnostic complete" in text
    assert "CLUSTER_BENCHMARK RUNNER_DONE" in text
    assert not re.search(r"Error in expression|Error position|RUNNER ERROR|Exception code:", text)
    result = markers(text, "WATER_RESULT")
    assert len(result) == 1
    mode, pairs, observations, changes, sectors = result[0]
    rows = markers(text, "WATER_OBSERVATION")
    assert len(rows) == pairs == observations
    assert sectors == 200 and changes == 0
    assert not markers(text, "WATER_SAMPLER_CHANGE")
    baseline = rows[0][12]
    estimated_levels = []
    shoreline = []
    for row in rows:
        assert len(row[12]) == 2
        sample = []
        for cell, probes in enumerate(row[12]):
            assert len(probes) == 5
            for i, point in enumerate(probes):
                assert point[0][:2] == baseline[cell][i][0][:2]
                assert point[3] == baseline[cell][i][3]
                assert point[1] == point[2]  # 3D and 2D native queries agree.
            count_water = sum(p[1] for p in probes)
            expected = "SEA" if count_water == 5 else "LAND" if count_water == 0 else "SHORE"
            assert row[11][cell] == expected
            # Underwater getPos Z is relative to water. Subtract it from the
            # fixed terrain ASL reading to infer that query's water reference.
            wet = probes[1]
            assert wet[1] and wet[3] < 0 and len(wet[0]) == 3
            level = wet[3] - float(wet[0][2])
            estimated_levels.append(level)
            edge = next(p for p in probes if p[3] > 0)
            assert edge[1] == (edge[3] < level)
            sample.append({"center_xy": baseline[cell][0][0][:2],
                           "edge_xy": edge[0][:2], "edge_terrain_asl_m": edge[3],
                           "edge_is_water": edge[1], "estimated_water_reference_m": level,
                           "classification": row[11][cell]})
        shoreline.append({"phase": row[1], "step": row[2], "simulation_seconds": row[6],
                          "date": row[4], "waves": row[8], "samples": sample})
    groups = {}
    for phase in dict.fromkeys(r[1] for r in rows):
        rr = [r for r in rows if r[1] == phase]
        groups[phase] = {"checks": len(rr), "classification_pairs": dict(collections.Counter(
            "/".join(r[11]) for r in rr)), "waves_values": sorted(set(r[8] for r in rr))}
    if mode == "controlled":
        assert all(r[8] == 0 for r in rows if r[1] == "simulation_time")
        assert {r[8] for r in rows if r[1] == "wave_sweep"} == {0, 1}
    session = json.loads((run / "session.json").read_text(encoding="utf-8-sig"))
    root = Path(session["mission"]) / "cluster/tests"
    old = (root / "reference_boundaryTerrain.sqf").read_text().rstrip()
    new = (root / "source_boundaryTerrain.sqf").read_text().rstrip()
    assert old == new
    report = {"mode": mode, "paired_checks": pairs, "sectors_per_check": sectors,
              "classifier_comparisons": pairs * sectors, "sampler_water_changes": changes,
              "probe_xy_and_terrain_heights_constant": True, "native_2d_3d_water_queries_equal": True,
              "classifier_sources_equal_ignoring_eof_newline": True, "phases": groups,
              "estimated_water_reference_range_m": [min(estimated_levels), max(estimated_levels)],
              "threshold_prediction_matches_all_observations": True,
              "water_reference_note": "Inferred from an always-submerged probe's getPos Z and terrain ASL; rounding of RPT scalar output limits precision. No claim about the internal wave/tide implementation.",
              "shoreline_observations": shoreline,
              "source_hashes": {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in root.glob("*boundary*.sqf")}}
    (run / "water-boundary-results.json").write_text(json.dumps(report, indent=2))
    return {k: report[k] for k in ["mode", "paired_checks", "classifier_comparisons", "sampler_water_changes", "phases", "estimated_water_reference_range_m"]}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("runs", nargs="+", type=Path)
    args = parser.parse_args()
    print(json.dumps([verify(run) for run in args.runs], indent=2))


if __name__ == "__main__":
    main()
