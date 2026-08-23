    // CANDIDATE B: binary min-heap extract-min (sift-down), O(log n) - replaces the old
    // deleteAt 0 (O(n) shift of the whole queue). Remove the root, move the tail
    // into the root hole, then walk it down past the smaller of its two children until
    // the heap order is restored. Return the complete heap node so internal
    // callers can inspect its queued cost snapshot.
    private _queue = _this;
    private "_result";
    private _n = count _queue;
    if (_n > 0) then {
        _result = _queue select 0;                    // the minimum node
        private _last = _queue deleteAt (_n - 1);     // pop the tail
        private _m = _n - 1;                           // heap size after the pop
        if (_m > 0) then {
            private _i = 0;
            private _pri = _last select 0;
            while {true} do {
                private _l = 2*_i + 1;
                private _r = 2*_i + 2;
                private _smallest = _i;
                private _smPri = _pri;
                if (_l < _m && {((_queue select _l) select 0) < _smPri}) then { _smallest = _l; _smPri = ((_queue select _l) select 0); };
                if (_r < _m && {((_queue select _r) select 0) < _smPri}) then { _smallest = _r; };
                if (_smallest == _i) exitWith {};
                _queue set [_i, _queue select _smallest];   // pull the smaller child up
                _i = _smallest;
            };
            _queue set [_i, _last];                  // drop the tail in its slot
        };
    };
    _result
