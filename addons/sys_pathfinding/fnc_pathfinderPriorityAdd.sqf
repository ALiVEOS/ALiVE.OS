    // Binary min-heap insertion: append at the tail and sift toward the root.
    private _args = _this;
    _args params ["_queue","_priority","_item", ["_costSnapshot", objNull]];
    // The cost snapshot lets internal searches recognize an older entry after a
    // better cost for the same sector has been queued. External three-argument
    // callers receive a non-number sentinel and skip stale-cost validation.
    private _node = [_priority, _item, _costSnapshot];
    _queue pushBack _node;
    private _i = (count _queue) - 1;
    while {_i > 0} do {
        private _parent = floor ((_i - 1) / 2);
        if (((_queue select _parent) select 0) <= _priority) exitWith {};
        _queue set [_i, _queue select _parent];   // pull the parent down into the hole
        _i = _parent;
    };
    _queue set [_i, _node];                        // drop the new node in its slot
