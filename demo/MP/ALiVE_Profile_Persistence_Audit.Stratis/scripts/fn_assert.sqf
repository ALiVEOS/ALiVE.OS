params ["_label", "_passed", ["_expected", ""], ["_actual", ""]];
private _verdict = ["FAIL", "PASS"] select _passed;
private _entry = [_label, _verdict, _expected, _actual];
PA_results pushBack _entry;
diag_log format ["[PA] %1 | %2 | expected=%3 | actual=%4", _verdict, _label, _expected, _actual];
format ["[PA] %1: %2", _verdict, _label] remoteExec ["systemChat", 0];
_passed
