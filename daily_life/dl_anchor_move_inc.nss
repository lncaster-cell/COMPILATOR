// Shared bounded local anchor movement helper.
// Scope: final local movement to an already-resolved anchor waypoint/object.
// This intentionally does not replace NWN2's action queue or pathfinding.

void DL_ClearAnchorMoveIssueState(object oNpc, string sStampKey, string sActionTargetKey)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (sStampKey != "")
    {
        DeleteLocalInt(oNpc, sStampKey);
    }
    if (sActionTargetKey != "")
    {
        DeleteLocalString(oNpc, sActionTargetKey);
    }
}

int DL_GetAnchorMoveActionStamp()
{
    return (GetTimeHour() * 3600) + (GetTimeMinute() * 60) + GetTimeSecond();
}

int DL_ShouldReissueAnchorMoveAction(object oNpc, string sKey, int nReissueSeconds)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) != ACTION_MOVETOPOINT)
    {
        return TRUE;
    }

    int nNow = DL_GetAnchorMoveActionStamp();
    int nLast = GetLocalInt(oNpc, sKey);

    if (nLast <= 0 || nNow < nLast || (nNow - nLast) >= nReissueSeconds)
    {
        return TRUE;
    }

    return FALSE;
}

int DL_ShouldIssueAnchorMoveAction(
    object oNpc,
    object oTarget,
    string sStatusKey,
    string sMovingStatus,
    string sActionTargetKey,
    string sStampKey
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (sStatusKey == "" || GetLocalString(oNpc, sStatusKey) != sMovingStatus)
    {
        return TRUE;
    }

    if (sActionTargetKey != "" && GetLocalString(oNpc, sActionTargetKey) != GetTag(oTarget))
    {
        return TRUE;
    }

    return DL_ShouldReissueAnchorMoveAction(oNpc, sStampKey, 6);
}

void DL_ResetCustomAnimationBeforeAnchorMove(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    // NWN2 custom animations can survive ClearAllActions(TRUE). The stock
    // ga_play_custom_animation script documents "%" as the reset-to-idle token.
    // Clear it before issuing movement so old work/chill/meal loops cannot
    // visually or behaviorally pin the NPC in place.
    PlayCustomAnimation(oNpc, "%", FALSE);
}



void DL_SetAnchorTerminalStatus(
    object oNpc,
    string sStatusKey,
    string sStatusValue,
    string sTargetKey,
    object oAnchor,
    string sIssueStampKey,
    string sIssueTargetKey,
    int bClearMoveJob,
    int bClearMoveIssueState,
    int bFaceAnchor
)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (bClearMoveIssueState)
    {
        DL_ClearAnchorMoveIssueState(oNpc, sIssueStampKey, sIssueTargetKey);
    }

    if (bClearMoveJob)
    {
        DL_ClearMoveJob(oNpc);
    }

    SetLocalString(oNpc, sStatusKey, sStatusValue);

    if (sTargetKey != "" && GetIsObjectValid(oAnchor))
    {
        SetLocalString(oNpc, sTargetKey, GetTag(oAnchor));
    }

    if (bFaceAnchor && GetIsObjectValid(oAnchor))
    {
        AssignCommand(oNpc, SetFacing(GetFacing(oAnchor)));
    }
}
void DL_BeginAnchorMoveJob(
    object oNpc,
    object oTarget,
    string sStatusKey,
    string sStatusValue,
    string sTargetKey,
    string sActionTargetKey,
    string sOwner,
    string sPhase,
    float fRadius
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    string sTargetTag = GetTag(oTarget);
    SetLocalString(oNpc, sStatusKey, sStatusValue);
    SetLocalString(oNpc, sTargetKey, sTargetTag);
    SetLocalString(oNpc, sActionTargetKey, sTargetTag);
    DL_BeginMoveJobToObject(oNpc, sOwner, sPhase, oTarget, fRadius);
}
