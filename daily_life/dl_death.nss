#include "dl_core_inc"

void main()
{
    DL_RequestNpcLifecycleSignal(OBJECT_SELF, DL_NPC_EVENT_DEATH);

    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "[DL] death signal: npc=" + GetName(OBJECT_SELF));
    }
}
