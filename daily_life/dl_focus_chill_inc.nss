void DL_ApplyChillAnimationFallback(object oNpc, object oSeat, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return;
    }

    string sSeatTag = GetTag(oSeat);
    int bAlreadyStable = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_CHILL_ANCHOR &&
                         GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sSeatTag;
    if (DL_ApplyFocusWaypointAnimation(oNpc, oSeat, DL_FOCUS_STATUS_ON_CHILL_ANCHOR, DL_CHILL_ANIM_SIT_IDLE, DL_CHILL_LOOP_ANIM_DURATION) &&
        !bAlreadyStable && sDiagnostic != "")
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, sDiagnostic);
    }
}

int DL_ShouldUseChillLegacyActionSit(object oNpc, object oSeat)
{
    if (GetIsObjectValid(oNpc) && GetLocalInt(oNpc, DL_L_NPC_CHILL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    if (GetIsObjectValid(oSeat) && GetLocalInt(oSeat, DL_L_NPC_CHILL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    return FALSE;
}

int DL_ExecuteChillWaypointAnimation(object oNpc, object oSeat)
{
    DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    return DL_ApplyFocusWaypointAnimation(oNpc, oSeat, DL_FOCUS_STATUS_ON_CHILL_ANCHOR, DL_CHILL_ANIM_SIT_IDLE, DL_CHILL_LOOP_ANIM_DURATION);
}

void DL_VerifyChillSitOrFallback(object oNpc, object oChair, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oChair) || !GetIsObjectValid(oSeat))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_CHILL)
    {
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != GetTag(oSeat))
    {
        return;
    }

    if (GetSittingCreature(oChair) == oNpc)
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_CHILL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        DL_LogChatDebugEvent(oNpc, DL_FOCUS_STATUS_ON_CHILL_ANCHOR, "on_chill_anchor chair=" + GetTag(oChair));
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL, DL_GetAbsoluteMinute() + DL_CHILL_SIT_RETRY_MINUTES);
    DL_ApplyChillAnimationFallback(oNpc, oSeat, "chill_action_sit_failed");
}

int DL_TryProgressChillLegacyChair(object oNpc, object oSeat)
{
    object oChair = DL_ResolveChillChairObject(oNpc, oSeat);
    if (!GetIsObjectValid(oChair))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_MISSING_CHILL_CHAIR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_FOCUS_STATUS_MISSING_CHILL_CHAIR);
        return FALSE;
    }

    object oSitter = GetSittingCreature(oChair);
    if (oSitter == oNpc)
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_CHILL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        DL_LogChatDebugEvent(oNpc, DL_FOCUS_STATUS_ON_CHILL_ANCHOR, "on_chill_anchor legacy_chair=" + GetTag(oChair));
        return TRUE;
    }

    if (GetIsObjectValid(oSitter) && oSitter != oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_CHILL_CHAIR_OCCUPIED);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_FOCUS_STATUS_CHILL_CHAIR_OCCUPIED);
        return FALSE;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nRetryUntil = GetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_SITTING_CHILL_ATTEMPT && nRetryUntil > nNowAbs)
    {
        return TRUE;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DL_ClearMoveJob(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_SITTING_CHILL_ATTEMPT);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
    SetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL, nNowAbs + DL_CHILL_SIT_RETRY_MINUTES);
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionSit(oChair));
    DelayCommand(DL_CHILL_SIT_VERIFY_DELAY, DL_VerifyChillSitOrFallback(oNpc, oChair, oSeat));
    DL_LogChatDebugEvent(oNpc, DL_FOCUS_STATUS_SITTING_CHILL_ATTEMPT, "sitting_chill_attempt legacy_chair=" + GetTag(oChair));
    return TRUE;
}

int DL_ProgressChillAtSeat(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return FALSE;
    }

    if (DL_NavTryAdvanceFromAnchorForOwner(oNpc, oSeat, DL_GetFocusMoveOwner(oNpc)))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oSeat) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldIssueFocusMoveAction(oNpc, oSeat))
        {
            DL_IssueFocusMoveAction(oNpc, oSeat);
        }
        return TRUE;
    }

    if (DL_ShouldUseChillLegacyActionSit(oNpc, oSeat))
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        if (DL_TryProgressChillLegacyChair(oNpc, oSeat))
        {
            return TRUE;
        }
    }

    return DL_ExecuteChillWaypointAnimation(oNpc, oSeat);
}
void DL_ExecuteChillDirective(object oNpc)
{
    object oSeat = DL_ResolveChillWaypoint(oNpc);
    if (!GetIsObjectValid(oSeat))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_chill_seat");
        return;
    }

    DL_LogChatDebugEvent(
        oNpc,
        "target_chill",
        "target dir=CHILL area=" + GetTag(GetArea(oSeat)) + " anchor=" + GetTag(oSeat)
    );
    DL_ProgressChillAtSeat(oNpc, oSeat);
}
