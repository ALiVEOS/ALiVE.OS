"""Verify map correctness coverage and original/batched native file bytes."""
import argparse,hashlib,json,re
from pathlib import Path

def markers(text,name):
    out=[]
    for line in text.splitlines():
        tag="CLUSTER_BENCHMARK "+name+" "
        if tag in line:
            out.append(json.JSONDecoder().raw_decode(line.split(tag,1)[1].replace('""','"'))[0])
    return out

def main():
    ap=argparse.ArgumentParser();ap.add_argument("run",type=Path);args=ap.parse_args()
    r=args.run;session=json.loads((r/"session.json").read_text(encoding="utf-8-sig"));text=next(r.glob("*.rpt")).read_text(errors="replace")
    assert "CLUSTER_BENCHMARK PASS: map correctness suite complete" in text
    assert not re.search(r"CLUSTER_BENCHMARK (?:MISMATCH|ERROR|RUNNER ERROR)|Error in expression|Error position|Exception code:",text)
    stages=markers(text,"CORRECT_STAGE_PASS")
    assert [x[1] for x in stages]==["lookup","initial","consolidation_and_cluster_exports","aggregation_fixtures","all_map_elevation_cells"]
    fixture_counts=[int(x) for x in re.findall(r"EDGE_CASES PASS \((\d+) cases\)",text)]
    assert fixture_counts==[21,13,20]
    assert "AGGREGATION PASS: 3 terrain fixtures" in text
    initial=markers(text,"CORRECT_INITIAL");assert len(initial)==14
    consolidation=markers(text,"CORRECT_CONSOLIDATION");assert len(consolidation)==2
    exports=markers(text,"CORRECT_CLUSTER_EXPORT");assert len(exports)==2
    heights=markers(text,"FULL_HEIGHT_VERIFY_PASS");assert len(heights)==1
    assert heights[0][0]==heights[0][2]*100 and heights[0][1]<=1e-4
    assignments=markers(text,"CORRECT_ASSIGNMENT_EXPORT");assert len(assignments)==2
    terrain=markers(text,"CORRECT_TERRAIN_EXPORT");assert len(terrain)==1
    assert terrain[0][1]==heights[0][2]
    prefix=session["exportPrefix"]
    def files(suffix):
        world=prefix+"_"+suffix;root=r/"native-output"/world
        return {str(p.relative_to(root)).replace(world,"WORLD"):p for p in root.rglob("*.sqf")}
    aa,bb=files("original"),files("optimized");assert set(aa)==set(bb) and len(aa)==3
    checks={}
    for key,p in aa.items():
        a,b=p.read_bytes(),bb[key].read_bytes();assert a==b,key
        checks[key]={"byte_identical":True,"bytes":len(a),"sha256":hashlib.sha256(a).hexdigest()}
    mission=Path(session["mission"])
    hashes={str(p.relative_to(mission)):hashlib.sha256(p.read_bytes()).hexdigest() for p in mission.rglob("*.sqf")}
    report={"world":session["world"],"fixture_counts":{"lookup":21,"initial":13,"consolidation":20,"aggregation":3},"live_node_drift":markers(text,"EXPORT_NODE_DRIFT"),"shared_export_node_snapshots":True,"initial_categories":initial,"consolidation":consolidation,"cluster_exports":exports,"heights":heights[0],"assignments":assignments,"terrain_records":terrain[0][1],"native_files":checks,"source_hashes":hashes,"expression_errors":0,"scope":"Real-map ordered lookup/initial/consolidation/subtype geometry, synthetic cache/identity/boundary fixtures, every cell paired elevation, aggregation replay fixtures, identical-record native cluster/terrain/assignment export with shared real node position snapshots. Randomized best-place/flat-empty search is replayed via checked-in terrain data for the export check."}
    (r/"correctness-results.json").write_text(json.dumps(report,indent=2));print(json.dumps({k:report[k] for k in ["world","heights","assignments","terrain_records","native_files","expression_errors"]},indent=2))
if __name__=="__main__":main()
