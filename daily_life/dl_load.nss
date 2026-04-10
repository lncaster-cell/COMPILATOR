#include "dl_core_inc"

void main()
{
    DL_InitModuleContract();

    object oModule = GetModule();
    object oPC = GetFirstPC();
    if (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "[DL] load: runtime=" + IntToString(DL_IsRuntimeEnabled()) + " contract=" + GetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION));
    }
}
