void DL_ApplyMealAnimationFallback(object oNpc, object oMeal, string sMealKind, string sAnim, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal))
    {
        return;
    }

    string sStableStatus = DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX + "_" + sMealKind;
    string sMealTag = GetTag(oMeal);
    int bAlreadyStable = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == sStableStatus &&
                         GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sMealTag;
    if (DL_ApplyFocusWaypointAnimation(oNpc, oMeal, sStableStatus, sAnim, DL_MEAL_LOOP_ANIM_DURATION) &&
        !bAlreadyStable && sDiagnostic != "")
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, sDiagnostic);
    }
}

int DL_ShouldUseMealLegacyActionSit(object oNpc, object oMeal)
{
    if (GetIsObjectValid(oNpc) && GetLocalInt(oNpc, DL_L_NPC_MEAL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    if (GetIsObjectValid(oMeal) && GetLocalInt(oMeal, DL_L_NPC_MEAL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    return FALSE;
}

string DL_GetMealWaypointAnimation(object oNpc, string sMealKind)
{
    if (sMealKind == DL_MEAL_KIND_BREAKFAST)
    {
        return "sitdrink";
    }
    if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 6, 0) % 6) == 0)
    {
        return "sitdrink";
    }
    return "siteat";
}

int DL_ExecuteMealWaypointAnimation(object oNpc, object oMeal, string sMealKind, string sAnim)
{
    DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
    return DL_ApplyFocusWaypointAnimation(oNpc, oMeal, DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX + "_" + sMealKind, sAnim, DL_MEAL_LOOP_ANIM_DURATION);
}

void DL_VerifyMealSitOrFallback(object oNpc, object oChair, object oMeal, string sMealKind, string sAnim)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oChair) || !GetIsObjectValid(oMeal))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_MEAL)
    {
        return;
    }

    if (GetSittingCreature(oChair) == oNpc)
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_MEAL_ANCHOR_SITTING);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oMeal));
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    SetLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL, DL_GetAbsoluteMinute() + DL_MEAL_SIT_RETRY_MINUTES);
    DL_ApplyMealAnimationFallback(oNpc, oMeal, sMealKind, sAnim, "");
}

int DL_TryProgressMealLegacyChair(object oNpc, object oMeal, string sMealKind, string sAnim)
{
    object oChair = DL_ResolveMealChairObject(oNpc, oMeal);
    if (!GetIsObjectValid(oChair))
    {
        return FALSE;
    }

    object oSitter = GetSittingCreature(oChair);
    if (oSitter == oNpc)
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_MEAL_ANCHOR_SITTING);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oMeal));
        return TRUE;
    }

    if (GetIsObjectValid(oSitter) && oSitter != oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "meal_chair_occupied");
        return FALSE;
    }

    if (!DL_ShouldAttemptMealActionSit(oNpc, oMeal, oChair))
    {
        return FALSE;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nRetryUntil = GetLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    if (nRetryUntil > nNowAbs)
    {
        if (sStatus == DL_FOCUS_STATUS_SITTING_MEAL_ATTEMPT)
        {
            return TRUE;
        }
        return FALSE;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DL_ClearMoveJob(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_SITTING_MEAL_ATTEMPT);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oMeal));
    SetLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL, nNowAbs + DL_MEAL_SIT_RETRY_MINUTES);
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionSit(oChair));
    DelayCommand(DL_MEAL_SIT_VERIFY_DELAY, DL_VerifyMealSitOrFallback(oNpc, oChair, oMeal, sMealKind, sAnim));
    return TRUE;
}
void DL_ExecuteMealDirective(object oNpc)
{
    string sMealKind = DL_ResolveMealKind(oNpc);
    object oMeal = DL_ResolveMealWaypoint(oNpc, sMealKind);
    if (!GetIsObjectValid(oMeal))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_meal_anchor");
        return;
    }

    string sAnim = DL_GetMealWaypointAnimation(oNpc, sMealKind);

    if (DL_NavTryAdvanceFromAnchorForOwner(oNpc, oMeal, DL_GetFocusMoveOwner(oNpc)))
    {
        return;
    }

    if (GetDistanceBetween(oNpc, oMeal) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldIssueFocusMoveAction(oNpc, oMeal))
        {
            DL_IssueFocusMoveAction(oNpc, oMeal);
        }
        return;
    }

    if (DL_ShouldUseMealLegacyActionSit(oNpc, oMeal))
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        if (DL_TryProgressMealLegacyChair(oNpc, oMeal, sMealKind, sAnim))
        {
            return;
        }

        DL_ExecuteMealWaypointAnimation(oNpc, oMeal, sMealKind, sAnim);
        return;
    }

    DL_ExecuteMealWaypointAnimation(oNpc, oMeal, sMealKind, sAnim);
}
