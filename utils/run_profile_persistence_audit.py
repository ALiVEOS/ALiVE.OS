#!/usr/bin/env python3
"""Run the profile audit on an isolated Windows dedicated server; retain RPT evidence."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import subprocess
import sys
import tempfile
import time
import uuid


def pack_pbo(source, destination, prefix=None):
    """Write an uncompressed PBO, with virtual prefix and SHA-1 trailer."""
    files = [(p.relative_to(source).as_posix().replace("/", "\\"), p.read_bytes())
             for p in sorted(source.rglob("*")) if p.is_file()]
    archive = bytearray()
    if prefix:
        archive.extend(b"\0" + struct.pack("<5I", 0x56657273, 0, 0, 0, 0))
        archive.extend(b"prefix\0" + prefix.encode("utf-8") + b"\0\0")
    for name, content in files:
        archive.extend(name.encode("utf-8") + b"\0")
        archive.extend(struct.pack("<5I", 0, len(content), 0, 0, len(content)))
    archive.extend(b"\0" + struct.pack("<5I", 0, 0, 0, 0, 0))
    for _, content in files:
        archive.extend(content)
    destination.write_bytes(archive + b"\0" + hashlib.sha1(archive).digest())


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="backslashreplace")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game-dir", type=Path, default=Path(
        r"C:\Program Files (x86)\Steam\steamapps\common\Arma 3"))
    parser.add_argument("--alive-mod", type=Path)
    parser.add_argument("--cba-mod", type=Path)
    parser.add_argument("--port", type=int, default=24402)
    parser.add_argument("--timeout", type=int, default=240)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[1]
    game = args.game_dir.resolve()
    server = game / "arma3server_x64.exe"
    alive = args.alive_mod or game / "@alive"
    cba = args.cba_mod or game / "!Workshop/@CBA_A3"
    for required in [server, alive / "addons", cba / "addons"]:
        if not required.exists():
            parser.error(f"Required installation missing: {required}")
    if not 1024 <= args.port <= 65531 or args.timeout < 1:
        parser.error("Use a non-privileged port below 65532 and a positive timeout")
    run = Path(tempfile.gettempdir()) / "ALiVE_Profile_Persistence_Audit" / (
        time.strftime("%Y%m%d-%H%M%S-") + uuid.uuid4().hex[:8])
    addons = run / "@audit/addons"
    missions = run / "mpmissions"
    profiles = run / "profiles"
    for directory in [addons, missions, profiles]:
        directory.mkdir(parents=True, exist_ok=True)
    # Link installed dependencies, replacing the addons under test in this run.
    rebuilt = ["sys_profile", "sys_data_couchdb", "x_lib"]
    for pbo in sorted((alive / "addons").glob("*.pbo")):
        if pbo.stem.lower() in rebuilt:
            continue
        destination = addons / pbo.name
        try:
            os.link(pbo, destination)
        except OSError:
            import shutil
            shutil.copy2(pbo, destination)
    for addon in rebuilt:
        pack_pbo(repo / "addons" / addon, addons / (addon + ".pbo"),
                 "x\\alive\\addons\\" + addon)
    mission_source = repo / "demo/MP/ALiVE_Profile_Persistence_Audit.Stratis"
    mission_name = "ALIVE_PA_" + uuid.uuid4().hex + ".Stratis"
    packaged_mission = missions / (mission_name + ".pbo")
    pack_pbo(mission_source, packaged_mission)
    # Older server binaries ignore -mpmissions. Stage a unique file in the
    # standard mission directory and remove only this generated file afterward.
    game_mission = game / "MPMissions" / packaged_mission.name
    game_mission.parent.mkdir(exist_ok=True)
    with game_mission.open("xb") as target:
        target.write(packaged_mission.read_bytes())
    config = run / "server.cfg"
    config.write_text('hostname = "ALiVE persistence regression";\npassword = "' + uuid.uuid4().hex + '\n'.join(['";',
        'maxPlayers = 1;', 'persistent = 1;', 'BattlEye = 0;', 'verifySignatures = 0;',
        'allowedFilePatching = 0;', 'upnp = 0;', 'steamProtocolMaxDataSize = 1024;',
        'class Missions { class Audit {',
        f'template = "{mission_name}";', 'difficulty = "Regular";',
        'class Params { PA_Automated = 1; };', '}; };', '']), encoding="utf-8")
    command = [str(server), "-autoInit", "-noSound", "-world=empty", "-ip=127.0.0.1",
               f"-port={args.port}", f"-config={config}", f"-profiles={profiles}",
               "-name=PA_Audit", f"-mod={cba};{run / '@audit'}"]
    manifest = {"command": command, "head": subprocess.check_output(
        ["git", "rev-parse", "HEAD"], cwd=repo, text=True).strip(),
        "profile_sources": {p.name: hashlib.sha256(p.read_bytes()).hexdigest()
                            for p in (repo / "addons/sys_profile").glob("*.sqf")}}
    manifest["rebuilt_sources"] = {p.relative_to(repo).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
        for addon in rebuilt for p in (repo / "addons" / addon).rglob("*") if p.is_file()}
    (run / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(f"Evidence directory: {run}", flush=True)
    process = subprocess.Popen(command, cwd=game, creationflags=subprocess.CREATE_NO_WINDOW)
    print(f"Dedicated server PID: {process.pid}", flush=True)
    text = ""
    complete = False
    deadline = time.monotonic() + args.timeout
    try:
        while time.monotonic() < deadline:
            rpts = sorted(profiles.rglob("*.rpt"), key=lambda p: p.stat().st_mtime)
            if rpts:
                text = rpts[-1].read_text(encoding="utf-8", errors="replace")
                if "[PA] AUTOMATED COMPLETE" in text:
                    complete = True
                    break
            if process.poll() is not None:
                break
            time.sleep(1)
    finally:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait(timeout=10)
        if game_mission.resolve().parent == (game / "MPMissions").resolve():
            game_mission.unlink(missing_ok=True)
    audit_lines = [line for line in text.splitlines() if "[PA]" in line]
    for line in audit_lines:
        print(line)
    result = {"complete": complete, "audit_lines": audit_lines,
              "failures": sum("[PA] FAIL |" in line for line in audit_lines)}
    # Missing or interrupted suites are failures, even if no FAIL assertion appeared.
    result["suites_complete"] = all(f"AUTOMATED SUITE END | {suite} | assertions=" in text
                                      for suite in ["roundtrip", "spawnHooks", "damage", "transport", "orders", "json", "cloudDownloads", "empty"])
    result["script_errors"] = [line for line in text.splitlines()
                                if re.search(r"Error (in expression|position|Undefined|Generic|Type)|Script .* not found", line)]
    required = {"Empty save is accepted as persistent", "Empty save leaves no non-player profiles",
                "Unresolved vehicle references return a complete walking-speed array",
                "Speed resolver leaves its caller's result unchanged"}
    required.update({"JSON / quotes escaped", "JSON / backslashes escaped", "JSON / controls escaped",
                     "JSON / empty object", "JSON / bulk / 0", "JSON / bulk / 1"})
    required.update("JSON / roundtrip / " + field for field in [
        "PA_JSON_text", "PA_JSON_controls", "PA_JSON_unicode", "PA_JSON_nested", "PA_JSON_array",
        "PA_JSON_emptyHash", "onEachSpawn", "onEachSpawnOnce"])
    required.update("JSON / standard / " + field for field in ["escaped key", "unicode", "items", "number", "bool"])
    required.update("JSON / invalid escape / " + str(i) for i in range(3))
    for index in range(3):
        required.update("JSON / nested error / " + container + " / " + str(index)
                        for container in ["object", "array", "rows"])
    required.update("JSON / nested boundary / " + str(index) for index in range(7))
    required.add("JSON / ERROR literal is valid data")
    for round_number in [1, 2]:
        for alias in ["repeat", "once", "ranOnce", "ranRepeat"]:
            required.update(f"JSON / Boolean fallback / {round_number} / {alias}: " + observation
                            for observation in ["source strings", "restored", "once Boolean",
                                                "execution Boolean", "physical execution"])
    required.update("JSON / invalid grammar / " + str(index) for index in range(29))
    required.update({"JSON / valid number grammar", "JSON / whitespace and empty values"})
    for case in ["start error", "stream error", "partial stream error", "missing document",
                 "partial missing document", "duplicate missing document", "malformed document",
                 "missing ID", "unexpected ID", "malformed first", "malformed last", "missing ID first",
                 "unexpected ID first", "empty stream error", "empty unexpected document",
                 "empty", "populated", "populated reverse"]:
        required.update("Cloud download / " + case + ": " + observation
                        for observation in ["bulk result", "seed state", "persistence state", "profile IDs"])
    required.add("Cloud download / other module remains strict")
    required.update("Cloud download / missing vehicle: " + observation for observation in [
        "crew retained", "vehicle excluded", "assignments cleared", "links cleared", "walking speed",
        "walking path", "order applied"])
    required.update("Cloud download / missing crew: " + observation for observation in [
        "vehicle retained", "links cleared"])
    for alias in ["carrier", "load"]:
        required.update("Cloud download / missing sling partner / " + alias + ": " + observation
                        for observation in ["restored", "link cleared"])
    for once in ["false", "true"]:
        required.update("JSON / profile / " + once + ": " + observation
                        for observation in ["restored", "code exact", "boolean exact", "execution 1", "execution 2"])
    wire_chunks = {}
    for line in text.splitlines():
        if match := re.search(r"\[PA_JSON_CODES\] (\w+) (\d+) (\[[0-9, ]*\])", line):
            wire_chunks.setdefault(match.group(1), {})[int(match.group(2))] = json.loads(match.group(3))
    wire_checks = []
    for name in ["fixture", "bulk0", "bulk1"]:
        try:
            codes = []
            for offset, chunk in sorted(wire_chunks.get(name, {}).items()):
                if offset != len(codes):
                    raise ValueError(f"Missing JSON wire chunk at {len(codes)}")
                codes.extend(chunk)
            wire = b"".join(struct.pack("<H", code) for code in codes).decode("utf-16-le")
            wire_checks.append({"name": name, "parsed": json.loads(wire)})
        except (ValueError, UnicodeError, struct.error) as error:
            wire_checks.append({"name": name, "error": str(error)})
    result["json_wire_checks"] = wire_checks
    punctuation = 'quote " slash \\ path C:\\ALiVE\\test literal \\n [, {, ,]} : [ ] { } / apostrophe \''
    controls = "".join(chr(code) for code in [1, 8, 9, 10, 12, 13, 31])
    unicode_text = "\u0152\u03a9\u4e2d\U0001f600"
    expected_wire = [
        {"PA_JSON_text": punctuation, "PA_JSON_controls": controls,
         "PA_JSON_unicode": unicode_text, "PA_JSON_nested": {'key":[,]\\\t': punctuation},
         "PA_JSON_array": ["", punctuation, [controls, unicode_text], [], "false", "true", 12.5],
         "PA_JSON_emptyHash": {}, "onEachSpawn": '_this params ["_unit"];', "onEachSpawnOnce": "false"},
        {"docs": [{"PA_JSON_bulk": punctuation, "_id": "audit-one"},
                  {"PA_JSON_bulk": controls, "_id": "audit-two"}]},
        {"docs": []}]
    result["json_wire_valid"] = len(wire_checks) == len(expected_wire) and all(
        item.get("parsed") == expected for item, expected in zip(wire_checks, expected_wire))
    required.update({"hook: onEachSpawn survives save/load", "hook: onEachSpawnOnce survives save/load",
                     "injured: damages survives save/load", "Damage / active: fixture spawned",
                     "Damage / active: live damage differs from cached damage", "Damage / PNS document readable",
                     "Damage / all fixture IDs saved"})
    required.update({"cargo: cargo survives save/load", "cargo: slung survives save/load",
                     "carrier: slingload survives save/load", "Transport / PNS document readable",
                     "Transport / all fixture IDs saved"})
    for case in ["Normal / carrier first", "Normal / load first", "Legacy PNS / carrier first"]:
        required.add(f"Transport / {case}: record order saved")
        for alias in ["truck", "carrier", "load", "classCarrier", "legacy", "empty"]:
            for observation in ["profile restored", "cargo restored", "slingload restored", "slung restored"]:
                required.add(f"Transport / {case} / {alias}: {observation}")
        for observation in ["cargo truck spawned", "duplicate cargo recreated", "first sling vehicle spawned",
                            "second sling vehicle spawned", "profiled sling attachment recreated", "profiled load cargo recreated",
                            "class sling carrier spawned", "class sling attachment recreated", "class load cargo recreated",
                            "spawned cargo cleaned up"]:
            required.add(f"Transport / {case}: {observation}")
    required.add("Queued order destination survives, applied or awaiting a new path")
    for alias in ["foot", "mounted"]:
        for observation in ["real requests pending at save time", "durable methods and destinations saved",
                            "runtime queue omitted", "callbacks removed and live orders unchanged"]:
            required.add(f"Orders / {alias}: {observation}")
    for case in ["normal entities first", "normal vehicles first", "legacy loader", "legacy raw queue", "numeric strings", "pathfinding disabled"]:
        for alias in ["foot", "mounted", "legacy"]:
            for observation in ["profile restored", "fresh queue size", "fresh job count", "queue drained",
                                "applied order sequence", "cycle state preserved", "filtered orders absent", "obsolete callbacks absent"]:
                required.add(f"Orders / {case} / {alias}: {observation}")
            if case != "pathfinding disabled" and alias != "legacy":
                for observation in ["methods and destinations restored", "correct movement procedure",
                                    "readiness and waypoint settings restored"]:
                    required.add(f"Orders / {case} / {alias}: {observation}")
    for alias in ["virtual", "active", "filtered"]:
        for observation in ["saved damage matches source units", "saved class alignment"]:
            required.add(f"Damage / {alias}: {observation}")
    for loader in ["Normal", "Legacy PNS"]:
        for alias in ["virtual", "active", "legacy", "short", "strings", "filtered"]:
            for observation in ["profile restored", "cached damage restored", "physical spawn completed",
                                "physical damage restored", "despawn completed"]:
                required.add(f"Damage / {loader} / {alias}: {observation}")
    for round_number in [1, 2]:
        required.add(f"Spawn hooks / round {round_number}: PNS document readable")
        required.add(f"Spawn hooks / round {round_number}: all fixture IDs saved")
        for alias in ["repeat", "once", "legacy"]:
            for observation in ["profile restored", "code restored or defaults retained", "once flag restored or defaults retained",
                                "prior execution state restored", "physical spawn completed", "execution count",
                                "unit customization and arguments", "despawn completed"]:
                required.add(f"Spawn hooks / round {round_number} / {alias}: {observation}")
    for alias in ["mounted", "partlyMounted", "multipleVehicles"]:
        required.add(f"{alias}: vehicleAssignments survives save/load")
        required.add(f"{alias}: vehiclesInCommandOf survives save/load")
    for order in ["entities first", "vehicles first"]:
        required.add(f"Mounted-speed fixture saved with {order}")
        for alias in ["mounted", "partlyMounted", "multipleVehicles", "onFoot"]:
            required.add(f"{order} / {alias}: profile exists")
            for field in ["unitCount", "speedPerSecond"]:
                required.add(f"{order} / {alias}: {field} restored")
    for loader in ["Normal", "Legacy PNS"]:
        for case in ["missing", "short array", "wrong marker", "non-array values", "misaligned keys", "empty", "populated"]:
            for observation in ["persistence decision", "seed retained or cleared"]:
                required.add(f"{loader} loader / {case}: {observation}")
            if case != "empty":
                required.add(f"{loader} loader / {case}: saved/live class selection")
    passed_labels = {match.group(1) for line in audit_lines
                     if (match := re.search(r"\[PA\] PASS \| (.*?) \| expected=", line))}
    failed_labels = {match.group(1) for line in audit_lines
                     if (match := re.search(r"\[PA\] FAIL \| (.*?) \| expected=", line))}
    result["missing_or_failed_regressions"] = sorted((required - passed_labels) | (required & failed_labels))
    result["focused_assertions_required"] = len(required)
    result["focused_passed"] = complete and result["suites_complete"] and not result["missing_or_failed_regressions"] and not result["script_errors"] and result["json_wire_valid"]
    result["passed"] = result["focused_passed"] and not result["failures"]
    (run / "result.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(f"Focused regressions: {'PASS' if result['focused_passed'] else 'FAIL/BLOCKED'} ({len(required)} required assertions)")
    print(f"Full audit {'PASS' if result['passed'] else 'FAIL/BLOCKED'}; full RPT and result.json retained at {run}")
    if not complete:
        print("No completion marker. Last RPT lines:")
        print("\n".join(text.splitlines()[-35:]))
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
