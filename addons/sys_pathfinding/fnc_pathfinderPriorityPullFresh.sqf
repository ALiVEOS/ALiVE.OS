    params ["_queue", "_costSoFarMap"];
    private "_result";

    // Better paths append new heap entries rather than searching and updating an
    // existing entry in place. Discard those older entries lazily when they reach
    // the root; this keeps heap insertion O(log n) and avoids duplicate expansion.
    while {isNil "_result" && {count _queue > 0}} do {
        private _node = _queue call ALiVE_fnc_pathfinderPriorityPullNode;
        private _item = _node select 1;
        private _queuedCost = _node param [2, objNull];

        if !(_queuedCost isEqualType 0) then {
            _result = _item;
        } else {
            private _bestCost = _costSoFarMap get (_item select 0);
            if (!isNil "_bestCost" && {_queuedCost <= _bestCost}) then {
                _result = _item;
            };
        };
    };

    _result
