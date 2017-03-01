#include <script_component.hpp>

#include <CfgPatches.hpp>
//#include <CfgVehicles.hpp>
#include <CfgFunctions.hpp>
#include <data\ui\main.hpp>
#include <CfgMarkers.hpp>
#include <eventhandlers.hpp>

class ALiVE_civilian_interaction {
    class Questions {

        class HowAreYou {
            texts[] = { "Hi, How are you today?" };
            isDefault = 1;
            threatLevel = 0;
            followQuestions[] = { };
            condition = "";

            class Respones {

                class HasAnswered {
                    condition = "_question in _answersGiven";

                    class NonHostile {
                        condition = "_civHostility <= 30";
                        texts[] = { "You already asked me that." };
                        onDisplayed = "";
                    };

                    class SemiHostile {
                        condition = "_civHostility > 30 && _civHostility < 60";
                        texts[] = { "You are beginning to annoy me with that question."};
                        onDisplayed = "";
                    };

                    class Hostile {
                        condition = "_civHostility >= 60";
                        texts[] = { "You already asked me that you filthy pig." };
                        onDisplayed = "";
                    };
                };

                class HasNotAnswered {
                    condition = "!(_question in _answersGiven)";

                    class IAmWell {
                        condition = "_civHostility < 30";
                        text = "I am well, thank you.";
                    };

                    class PleaseLeave {
                        condition = "_civHostility > 30 && _civHostility < 60";
                        text = "Please leave..";
                    };

                    class LeaveNow {
                        condition = "_civHostility > 60";
                        text = "Leave now!";
                    };
                };

            };

        };

    };
};