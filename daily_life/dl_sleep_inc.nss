const string DL_L_NPC_SLEEP_APPROACH_ACTION_STAMP = "dl_sleep_approach_action_stamp";
const string DL_L_NPC_SLEEP_BED_ACTION_STAMP = "dl_sleep_bed_action_stamp";
const int DL_SLEEP_ACTION_REISSUE_SECONDS = 6;

// NOTE: keep literal aligned with work status; contexts are isolated by different local fields
// (DL_L_NPC_SLEEP_STATUS vs DL_L_NPC_WORK_STATUS), so downstream diagnostics do not mix channels.
const string DL_SLEEP_STATUS_MISSING_WAYPOINTS = "missing_waypoints";
const string DL_SLEEP_STATUS_MOVING_VIA_NAVIGATION = "moving_via_navigation";
const string DL_SLEEP_STATUS_MOVING_TO_APPROACH = "moving_to_approach";
const string DL_SLEEP_STATUS_APPROACH_REACHED = "approach_reached";
const string DL_SLEEP_STATUS_JUMPING_TO_BED = "jumping_to_bed";
const string DL_SLEEP_STATUS_ON_BED = "on_bed";

int DL_GetNpcHomeSlot(object oNpc)
{
    int nSlot = GetLocalInt(oNpc, DL_L_NPC_HOME_SLOT);
    if (nSlot <= 0)
    {
        string sSlot = GetLocalString(oNpc, DL_L_NPC_HOME_SLOT);
        if (sSlot != "")
        {
            nSlot = StringToInt(sSlot);
        }
    }

    if (nSlot <= 0)
    {
        nSlot = 1;
    }

    return nSlot;
}
object DL_ResolveSleepApproachWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
    string sAnchor = "dl_anchor_sleep_approach_" + IntToString(nSlot);
    object oWp = DL_GetAreaAnchorWaypoint(
        oNpc,
        oHome,
        sAnchor,
        DL_L_NPC_CACHE_SLEEP_APPROACH,
        FALSE
    );
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_APPROACH,
        oHome,
        "dl_sleep_",
        "_approach",
        "dl_sleep_approach_" + IntToString(nSlot)
    );
}
object DL_ResolveSleepBedWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
    string sAnchor = "dl_anchor_sleep_bed_" + IntToString(nSlot);
    object oWp = DL_GetAreaAnchorWaypoint(
        oNpc,
        oHome,
        sAnchor,
        DL_L_NPC_CACHE_SLEEP_BED,
        FALSE
    );
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_BED,
        oHome,
        "dl_sleep_",
        "_bed",
        "dl_sleep_bed_" + IntToString(nSlot)
    );
}
int DL_HasSleepExitBedPlacement(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);

    if (nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED)
    {
        return TRUE;
    }

    if (sStatus == DL_SLEEP_STATUS_APPROACH_REACHED || sStatus == DL_SLEEP_STATUS_JUMPING_TO_BED || sStatus == DL_SLEEP_STATUS_ON_BED)
    {
        return TRUE;
    }

    return FALSE;
}
int DL_GetSleepActionStamp()
{
    return (GetTimeHour() * 3600) + (GetTimeMinute() * 60) + GetTimeSecond();
}
int DL_ShouldReissueSleepAction(object oNpc, string sKey)
{
    int nNow = DL_GetSleepActionStamp();
    int nLast = GetLocalInt(oNpc, sKey);

    if (nLast <= 0 || nNow < nLast || (nNow - nLast) >= DL_SLEEP_ACTION_REISSUE_SECONDS)
    {
        return TRUE;
    }

    return FALSE;
}
int DL_ShouldReissueSleepMoveAction(object oNpc, string sKey)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) != ACTION_MOVETOPOINT)
    {
        return TRUE;
    }

    return DL_ShouldReissueSleepAction(oNpc, sKey);
}
void DL_MarkSleepActionIssued(object oNpc, string sKey)
{
    SetLocalInt(oNpc, sKey, DL_GetSleepActionStamp());
}
void DL_ClearSleepActionIssueState(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_APPROACH_ACTION_STAMP);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_BED_ACTION_STAMP);
}
void DL_DelayedSleepExitJumpToApproach(object oNpc, location lApproach)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (!GetIsObjectValid(GetAreaFromLocation(lApproach)))
    {
        SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_exit_approach_invalid_location");
        DL_LogChatDebugEvent(oNpc, "sleep_exit_failed", "approach_valid=0 reason=invalid_location");
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lApproach));
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "sleep");
    DL_LogChatDebugEvent(oNpc, "sleep_exit_return", "returned_to_approach=1");
}
int DL_TryExitSleepToApproach(object oNpc)
{
    if (!DL_HasSleepExitBedPlacement(oNpc))
    {
        return FALSE;
    }

    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    if (!GetIsObjectValid(oApproach))
    {
        AssignCommand(oNpc, ClearAllActions(TRUE));
        DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "sleep");
        SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_exit_approach_missing");
        DL_LogChatDebugEvent(oNpc, "sleep_exit_failed", "approach_valid=0 reason=missing_waypoint");
        return TRUE;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, 0.1));
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "sleep");
    DL_LogChatDebugEvent(
        oNpc,
        "sleep_exit_queue_return",
        "approach_anchor=" + GetTag(oApproach)
    );

    DelayCommand(0.2, DL_DelayedSleepExitJumpToApproach(oNpc, GetLocation(oApproach)));

    DL_ClearSleepActionIssueState(oNpc);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    return TRUE;
}
void DL_StopSleepPresentationIfActive(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE) <= 0 &&
        GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == "" &&
        GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) == "")
    {
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, 0.1));
}
void DL_ClearSleepExecutionState(object oNpc)
{
    if (DL_TryExitSleepToApproach(oNpc))
    {
        return;
    }

    DL_StopSleepPresentationIfActive(oNpc);
    DL_ClearSleepActionIssueState(oNpc);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "sleep");
}
void DL_SetSleepMissingState(object oNpc)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_NONE);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_SLEEP_STATUS_MISSING_WAYPOINTS);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_waypoints_missing");
    DL_ClearSleepActionIssueState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "sleep");
}
void DL_SetSleepTargetState(object oNpc, object oBed)
{
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, GetTag(oBed));
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
}
void DL_QueueMoveAction(object oNpc, location lTarget, int bRun)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionMoveToLocation(lTarget, bRun));
}
void DL_QueueMoveToObjectAction(object oNpc, object oTarget, int bRun, float fRange)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionMoveToObject(oTarget, bRun, fRange));
}
void DL_QueueJumpAction(object oNpc, location lTarget)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lTarget));
}
void DL_MarkSleepNavigationInProgress(object oNpc, string sTargetTag)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_SLEEP_STATUS_MOVING_VIA_NAVIGATION);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, sTargetTag);
}
int DL_ShouldAttemptSleepNavigation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}
void DL_ExecuteSleepDirective(object oNpc)
{
    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    object oBed = DL_ResolveSleepBedWaypoint(oNpc);

    if (!GetIsObjectValid(oApproach) || !GetIsObjectValid(oBed))
    {
        DL_SetSleepMissingState(oNpc);
        return;
    }

    DL_SetSleepTargetState(oNpc, oBed);
    DL_LogChatDebugEvent(
        oNpc,
        "target_sleep",
        "target dir=SLEEP area=" + GetTag(GetArea(oBed)) + " anchor=" + GetTag(oBed)
    );

    location lApproach = GetLocation(oApproach);
    location lBed = GetLocation(oBed);
    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    int bCommittedToBed = nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED;
    int bMayUseNavigation = DL_ShouldAttemptSleepNavigation(oNpc);

    if (!bCommittedToBed && bMayUseNavigation && DL_NavTryAdvanceFromAnchorForOwner(oNpc, oApproach, DL_MOVE_OWNER_SLEEP))
    {
        DL_MarkSleepNavigationInProgress(oNpc, GetTag(oApproach));
        return;
    }


    if (!bCommittedToBed && GetDistanceBetween(oNpc, oApproach) > DL_SLEEP_APPROACH_RADIUS)
    {
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
        DL_BeginAnchorMoveJob(
            oNpc,
            oApproach,
            DL_L_NPC_SLEEP_STATUS,
            "moving_to_approach",
            DL_L_NPC_SLEEP_TARGET,
            DL_L_NPC_SLEEP_TARGET,
            DL_MOVE_OWNER_SLEEP,
            "approach",
            DL_SLEEP_APPROACH_RADIUS
        );
        return;
    }

    if (!bCommittedToBed)
    {
        DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_APPROACH_ACTION_STAMP);
        DL_ClearMoveJob(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_SLEEP_STATUS_APPROACH_REACHED);
        nPhase = DL_SLEEP_PHASE_JUMPING;
        sStatus = DL_SLEEP_STATUS_APPROACH_REACHED;
    }

    if (bMayUseNavigation && DL_NavTryAdvanceFromAnchorForOwner(oNpc, oBed, DL_MOVE_OWNER_SLEEP))
    {
        DL_MarkSleepNavigationInProgress(oNpc, GetTag(oBed));
        return;
    }

    if (GetDistanceBetween(oNpc, oBed) > DL_SLEEP_BED_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_JUMPING ||
            sStatus != DL_SLEEP_STATUS_JUMPING_TO_BED ||
            DL_ShouldReissueSleepAction(oNpc, DL_L_NPC_SLEEP_BED_ACTION_STAMP))
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_SLEEP_STATUS_JUMPING_TO_BED);
            DL_ClearTransitionExecutionState(oNpc);
            DL_MarkSleepActionIssued(oNpc, DL_L_NPC_SLEEP_BED_ACTION_STAMP);
            DL_QueueJumpAction(oNpc, lBed);
        }
        return;
    }

    if (nPhase != DL_SLEEP_PHASE_ON_BED || sStatus != DL_SLEEP_STATUS_ON_BED)
    {
        DL_PlaySleepAnimation(oNpc);
    }

    DL_ClearSleepActionIssueState(oNpc);
    DL_SetAnchorTerminalStatus(
        oNpc,
        DL_L_NPC_SLEEP_STATUS,
        DL_SLEEP_STATUS_ON_BED,
        "",
        OBJECT_INVALID,
        "",
        "",
        TRUE,
        FALSE,
        FALSE
    );
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "sleep");
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
    DL_LogChatDebugEvent(oNpc, DL_SLEEP_STATUS_ON_BED, "on_bed anchor=" + GetTag(oBed));
}
