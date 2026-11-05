#include "script_component.hpp"

LOG(MSG_INIT);

// uiNamespace outlives the mission, so the server's private copy of the build catalogue from the
// previous mission is dropped here; the build scan writes this mission's
if (isServer) then { uiNamespace setVariable ["ALiVE_FOB_catalogServer", nil] };
