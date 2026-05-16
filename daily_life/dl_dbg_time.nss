#include "dl_runtime_contract_inc"
#include "dl_diag_inc"

// Manual Daily Life debug entry point.
// Assign this script to a debug placeable OnUsed event.
// It enables the narrow blacksmith01 trace and prints a direct, human-readable
// "what do you think you are doing right now?" snapshot for the NPC.
// Read only BSMITH_STATUS / BSMITH_TARGET / BSMITH_TRACE /
// BSMITH_CONTRADICTION / BSMITH_CLASSIFY lines.

void DL_DebugTimeSendToAll(string sMessage)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);
        oPC = GetNextPC();
    }
}

string DL_DebugTimeAreaTag(object oObj)
{
    if (!GetIsObjectValid(oObj))
    {
        return "invalid";
    }

    object oArea = GetArea(oObj);
    if (!GetIsObjectValid(oArea))
    {
        return "no_area";
    }

    return GetTag(oArea);
}

string DL_DebugTimeBool(int bValue)
{
    if (bValue)
    {
        return "1";
    }
    return "0";
}

string DL_DebugTimeNpcClaim(object oNpc, object oTarget, float fDistance)
{
    string sMoveResult = GetLocalString(oNpc, "dl_move_result");
    string sFocusStatus = GetLocalString(oNpc, "dl_npc_focus_status");
    string sFinalizeReason = GetLocalString(oNpc, "reached_finalize_reason");
    int nAction = GetCurrentAction(oNpc);
    float fRadius = GetLocalFloat(oNpc, "dl_move_radius");
    if (fRadius <= 0.0)
    {
        fRadius = 1.60;
    }

    if (sMoveResult == "running" && fDistance >= 0.0 && fDistance <= fRadius && nAction != ACTION_MOVETOPOINT)
    {
        return "I_THINK_I_AM_MOVING_BUT_I_AM_ALREADY_AT_TARGET_AND_NO_MOVE_ACTION";
    }

    if (sMoveResult == "running" && fDistance >= 0.0 && fDistance <= fRadius)
    {
        return "I_THINK_I_AM_MOVING_BUT_I_AM_ALREADY_AT_TARGET";
    }

    if (sFinalizeReason == "target_not_reached" && fDistance >= 0.0 && fDistance <= fRadius)
    {
        return "FINALIZE_SAYS_NOT_REACHED_BUT_DISTANCE_IS_REACHED";
    }

    if (sFocusStatus == "moving_to_anchor" && fDistance >= 0.0 && fDistance <= fRadius)
    {
        return "FOCUS_THINKS_MOVING_TO_ANCHOR_BUT_TARGET_IS_REACHED";
    }

    if (sMoveResult == "running" && nAction != ACTION_MOVETOPOINT)
    {
        return "I_THINK_I_AM_MOVING_BUT_ENGINE_ACTION_IS_NOT_MOVETOPOINT";
    }

    if (sMoveResult == "running")
    {
        return "I_THINK_I_AM_MOVING_TO_TARGET";
    }

    if (sMoveResult == "reached")
    {
        return "I_THINK_I_REACHED_TARGET";
    }

    if (sFocusStatus != "")
    {
        return "I_AM_IN_FOCUS_STATE_" + sFocusStatus;
    }

    return "I_HAVE_NO_CLEAR_ACTIVE_MOVE";
}

void DL_DebugTimePrintBlacksmithSnapshot(object oNpc)
{
    int nHour = GetTimeHour();
    int nMinute = GetTimeMinute();
    int nMinuteOfDay = nHour * 60 + nMinute;
    int nStartMinute = GetLocalInt(oNpc, "dl_bsmith_manual_start_min");
    if (nStartMinute <= 0)
    {
        nStartMinute = nMinuteOfDay;
        SetLocalInt(oNpc, "dl_bsmith_manual_start_min", nStartMinute);
    }

    int nElapsed = nMinuteOfDay - nStartMinute;
    if (nElapsed < 0)
    {
        nElapsed = nElapsed + 1440;
    }

    object oMoveObj = GetLocalObject(oNpc, "dl_move_target_obj");
    string sMoveTag = GetLocalString(oNpc, "dl_move_target_tag");
    if (!GetIsObjectValid(oMoveObj) && sMoveTag != "")
    {
        oMoveObj = GetObjectByTag(sMoveTag, 0);
    }

    float fDistance = -1.0;
    if (GetIsObjectValid(oMoveObj) && GetArea(oMoveObj) == GetArea(oNpc))
    {
        fDistance = GetDistanceBetween(oNpc, oMoveObj);
    }

    vector vNpc = GetPosition(oNpc);
    vector vTarget = Vector(0.0, 0.0, 0.0);
    if (GetIsObjectValid(oMoveObj))
    {
        vTarget = GetPosition(oMoveObj);
    }

    object oRegArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    int nRegSlot = GetLocalInt(oNpc, "dl_npc_reg_slot");
    int bSlotSelf = FALSE;
    if (GetIsObjectValid(oRegArea) && nRegSlot >= 0)
    {
        bSlotSelf = GetLocalObject(oRegArea, "dl_reg_slot_" + IntToString(nRegSlot)) == oNpc;
    }

    string sClaim = DL_DebugTimeNpcClaim(oNpc, oMoveObj, fDistance);

    DL_DebugTimeSendToAll(
        "BSMITH_STATUS t=" + IntToString(nHour) + ":" + IntToString(nMinute) +
        " elapsed_min=" + IntToString(nElapsed) +
        " npc=blacksmith01" +
        " area=" + DL_DebugTimeAreaTag(oNpc) +
        " pos=" + FloatToString(vNpc.x, 1, 1) + "," + FloatToString(vNpc.y, 1, 1) + "," + FloatToString(vNpc.z, 1, 1) +
        " says=" + sClaim +
        " move=" + GetLocalString(oNpc, "dl_move_owner") + "/" + GetLocalString(oNpc, "dl_move_phase") + "/" + sMoveTag + "/" + GetLocalString(oNpc, "dl_move_result") +
        " focus=" + GetLocalString(oNpc, "dl_npc_focus_status") + "/" + GetLocalString(oNpc, "dl_npc_focus_target") +
        " action=" + IntToString(GetCurrentAction(oNpc)) +
        " finalize=" + IntToString(GetLocalInt(oNpc, "reached_finalize_attempted")) + "/" + IntToString(GetLocalInt(oNpc, "reached_finalize_success")) + "/" + GetLocalString(oNpc, "reached_finalize_reason")
    );

    DL_DebugTimeSendToAll(
        "BSMITH_TARGET t=" + IntToString(nHour) + ":" + IntToString(nMinute) +
        " elapsed_min=" + IntToString(nElapsed) +
        " target=" + sMoveTag +
        " valid=" + DL_DebugTimeBool(GetIsObjectValid(oMoveObj)) +
        " target_area=" + DL_DebugTimeAreaTag(oMoveObj) +
        " dist=" + FloatToString(fDistance, 1, 2) +
        " target_pos=" + FloatToString(vTarget.x, 1, 1) + "," + FloatToString(vTarget.y, 1, 1) + "," + FloatToString(vTarget.z, 1, 1) +
        " reg=" + DL_DebugTimeAreaTag(oRegArea) + "/" + IntToString(nRegSlot) + "/" + IntToString(bSlotSelf) +
        " worker=" + IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq")) + "/" + GetLocalString(oNpc, "npc_touch_skipped_reason") +
        " transition=" + GetLocalString(oNpc, "dl_transition_status") + "/" + GetLocalString(oNpc, "dl_transition_target")
    );
}

void main()
{
    object oModule = GetModule();
    object oNpc = GetObjectByTag("blacksmith01", 0);

    SetLocalInt(oModule, "dl_bsmith_trace", TRUE);

    if (!GetIsObjectValid(oNpc))
    {
        DL_DebugTimeSendToAll("BSMITH_TRACE_SETUP status=failed reason=blacksmith01_not_found");
        return;
    }

    SetLocalInt(oNpc, "dl_bsmith_trace", TRUE);

    DL_DebugTimeSendToAll("BSMITH_TRACE_SETUP status=enabled npc=blacksmith01 note=manual_status_snapshot_active");
    DL_DebugTimePrintBlacksmithSnapshot(oNpc);
    DL_BsmithTraceStage(oNpc, "PROBLEM_SUMMARY", "manual_debug_placeable_used");
}
