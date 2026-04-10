#include "dl_core_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oEnter = GetEnteringObject();

    DL_OnAreaEnterBootstrap(oArea, oEnter);

    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "[DL] area enter: area=" + GetName(oArea) + " actor=" + GetName(oEnter) + " tier=" + IntToString(DL_GetAreaTier(oArea)));
    }
}
