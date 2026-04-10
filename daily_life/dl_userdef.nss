#include "dl_core_inc"

void main()
{
    int nEvent = GetUserDefinedEventNumber();

    DL_HandleNpcUserDefined(OBJECT_SELF, nEvent);

    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        object oModule = GetModule();
        SendMessageToPC(oPC, "[DL] userdef: npc=" + GetName(OBJECT_SELF) + " event=" + IntToString(nEvent) + " spawn_count=" + IntToString(GetLocalInt(oModule, DL_L_MODULE_SPAWN_COUNT)) + " death_count=" + IntToString(GetLocalInt(oModule, DL_L_MODULE_DEATH_COUNT)));
    }
}
