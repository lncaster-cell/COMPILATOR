#include "dl_core_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oExit = GetExitingObject();

    DL_OnAreaExitBootstrap(oArea, oExit);

    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "[DL] area exit: area=" + GetName(oArea) + " actor=" + GetName(oExit) + " tier=" + IntToString(DL_GetAreaTier(oArea)));
    }
}
