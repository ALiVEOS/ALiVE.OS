class CfgVehicles
{
 // The tablet on the ground, so Zeus and Eden can place it (it was only an inventory item)
 class Item_Base_F;
 class Item_ALIVE_Tablet: Item_Base_F
 {
  scope = 2; scopeCurator = 2;
  displayName = "$STR_ALIVE_Tablet";
  author = "ALiVE Mod"; vehicleClass = "Items";
  class TransportItems { class ALIVE_Tablet { name = "ALIVE_Tablet"; count = 1; }; };
 };
 class NATO_Box_Base;
 class East_Box_Base;
 class IND_Box_Base;
 class Box_NATO_Support_F : NATO_Box_Base
 {
  class TransportItems
  {
   class _xx_ALIVE_Tablet
   {
    name = "ALIVE_Tablet";
    count = 4;
   };
  };
 };
 class Box_East_Support_F : East_Box_Base
 {
  class TransportItems
  {
   class _xx_ALIVE_Tablet
   {
    name = "ALIVE_Tablet";
    count = 4;
   };
  };
 };
 class Box_IND_Support_F : IND_Box_Base
 {
  class TransportItems
  {
   class _xx_ALIVE_Tablet
   {
    name = "ALIVE_Tablet";
    count = 4;
   };
  };
 };
};