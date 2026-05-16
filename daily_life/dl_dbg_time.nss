#include "dl_runtime_contract_inc"
#include "dl_diag_inc"

// Manual Daily Life debug entry point.
// Assign this script to a debug placeable OnUsed event.
// On use it enables the narrow blacksmith01 trace and immediately emits one
// BSMITH_TRACE snapshot. After that the normal Daily Life worker/move pipeline
// continues emitting only BSMITH_TRACE / BSMITH_CONTRADICTION /
// BSMITH_CLASSIFY lines for blacksmith01 while dl_bsmith_trace remains enabled.

void DL_DebugTimeSendToAll(string sMessage)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);
        oPC = GetNextPC();
    }
}

void main()
{
    object oModule = GetModule();
    object oNpc = GetObjectByTag("blacksmith01", 0);

    SetLocalInt(oModule, "dl_bsmith_trace", TRUE);
    SetLocalInt(oModule, "dl_bsmith_trace_seq", 0);

    if (!GetIsObjectValid(oNpc))
    {
        DL_DebugTimeSendToAll("BSMITH_TRACE_SETUP status=failed reason=blacksmith01_not_found");
        return;
    }

    SetLocalInt(oNpc, "dl_bsmith_trace", TRUE);
    DeleteLocalString(oNpc, "dl_bsmith_last_classify");
    DeleteLocalInt(oNpc, "dl_bsmith_bad_action_samples");

    DL_DebugTimeSendToAll("BSMITH_TRACE_SETUP status=enabled npc=blacksmith01 note=collect_BSMITH_TRACE_CONTRADICTION_CLASSIFY_only");
    DL_BsmithTraceStage(oNpc, "PROBLEM_SUMMARY", "manual_debug_placeable_used");
}
