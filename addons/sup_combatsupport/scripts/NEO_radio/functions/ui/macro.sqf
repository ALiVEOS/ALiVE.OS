//VR Main Display idc's
#define SR_Main_Display 655555
#define SR_Map 655565
#define SR_ABORT_BTN 655561
#define SR_Support_List 655565
#define SR_Transport_List 655568
#define SR_Arty_List 655594


//Control Macros
#define SR_getControl(disp,ctrl) ((findDisplay ##disp) displayCtrl ##ctrl)
#define SR_getSelData(ctrl) (lbData[##ctrl,(lbCurSel ##ctrl)])
