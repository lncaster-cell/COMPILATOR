#include "dl_core_inc"

void main()
{
    DL_RequestNpcLifecycleSignal(OBJECT_SELF, DL_NPC_EVENT_SPAWN);

    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "[DL] spawn signal: npc=" + GetName(OBJECT_SELF));
    }
}
