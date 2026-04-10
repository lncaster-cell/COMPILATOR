#include "dl_core_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();

    DL_RunAreaWorkerTick(oArea);

    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "[DL] area heartbeat: area=" + GetName(oArea) + " tier=" + IntToString(DL_GetAreaTier(oArea)) + " tick=" + IntToString(GetLocalInt(oArea, DL_L_AREA_WORKER_TICK)) + " worker_ticks=" + IntToString(GetLocalInt(oModule, DL_L_MODULE_WORKER_TICKS)));
    }
}
