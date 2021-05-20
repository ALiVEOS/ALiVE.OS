#define BASE_SIZE_TEXT          (((((safezoneW / safezoneH) min 1.2) / 1.2) / 25) * 1)
#define BASE_SIZE_TEXT_LISTBOX  (safeZoneH / 100) + (safeZoneH / 100)



class ctrlStatic;
class ctrlEdit;

class ALiVE_modules_AttributeTitle: ctrlStatic {
	style = 0x01; // ST_RIGHT;
};

class ALiVE_modules_AttributeEdit: ctrlEdit {
	//sizeEx = BASE_SIZE_TEXT;
};