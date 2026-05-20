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

    return DL_ShouldReissueSleepMoveAction(oNpc, sStampKey);
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
