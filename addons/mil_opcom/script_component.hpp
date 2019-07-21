#define COMPONENT mil_OPCOM
#include "\x\alive\addons\main\script_mod.hpp"

#ifdef DEBUG_ENABLED_MIL_OPCOM
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_mil_OPCOM
    #define DEBUG_SETTINGS DEBUG_ENABLED_MIL_OPCOM
#endif

#define GET_PROPERTY(object,property)                   (object getvariable property)
#define GET_PROPERTY_DEFAULT(object,property,default)   (object getvariable [property,default])
#define SET_PROPERTY(object,property,value)             object setvariable [property,value]

#define ADD_SIMPLE_ACCESSOR(property,type) case property: { if (_args isEqualType type) then { SET_PROPERTY(_logic,_operation, _args) } else { _result = GET_PROPERTY(_logic,_operation) } };

#include "\x\cba\addons\main\script_macros.hpp"
