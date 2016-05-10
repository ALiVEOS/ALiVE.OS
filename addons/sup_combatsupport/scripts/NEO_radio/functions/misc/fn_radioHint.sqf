disableSerialization;

if (isnil {uinamespace getvariable "NEO_radioHint"}) then { uinamespace setvariable ["NEO_radioHint", displaynull] };
if (isnull (uinamespace getvariable "NEO_radioHint")) then { 2988 cutrsc ["NEO_radioHintInterface", "plain", 2] };

private ["_display", "_textRsc", "_text"];
_display = uinamespace getvariable "NEO_radioHint";
_textRsc = _display displayctrl 655001;
_text = _this;

_textRsc ctrlSetStructuredText parseText format ["<t color='#FFFFFF' size='1' font='PuristaMedium'>%1</t>", _text];

sleep 15;
2988 cutrsc ["Default", "Plain", 2];


