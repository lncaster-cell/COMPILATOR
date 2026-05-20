const string DL_L_NPC_WORK_ACTION_STAMP = "dl_work_anchor_action_stamp";
const string DL_L_NPC_WORK_ACTION_TARGET = "dl_work_anchor_action_target";
const string DL_WORK_STATUS_MISSING_WAYPOINTS = "missing_waypoints";
const string DL_WORK_STATUS_MOVING_TO_ANCHOR = "moving_to_anchor";
const string DL_WORK_STATUS_ON_ANCHOR = "on_anchor";


void DL_ExecuteWorkDirective(object oNpc);

object DL_ResolveWorkAnchorByArea(
    object oNpc,
    object oArea,
    string sAnchorRole,
    string sCacheKey,
    string sFallbackCacheKey,
    string sFallbackPrefix,
    string sFallbackSuffix,
    string sFallbackDefaultTag
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oArea, sAnchorRole, sCacheKey, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    if (sFallbackCacheKey == "")
    {
        return OBJECT_INVALID;
    }

    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        sFallbackCacheKey,
        sFallbackPrefix,
        sFallbackSuffix,
        sFallbackDefaultTag
    );
}
object DL_ResolveWorkAnchorByProfile(object oNpc, string sProfile, string sAnchorRole)
{
    object oArea = OBJECT_INVALID;
    string sCacheKey = "";
    string sFallbackCacheKey = "";
    string sFallbackSuffix = "";
    string sFallbackDefaultTag = "";

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        oArea = DL_GetWorkArea(oNpc);
        if (sAnchorRole == "primary")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_PRIMARY;
            sFallbackCacheKey = DL_L_NPC_CACHE_WORK_FORGE;
            sFallbackSuffix = "_forge";
            sFallbackDefaultTag = "dl_work_forge";
        }
        else if (sAnchorRole == "secondary")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_SECONDARY;
            sFallbackCacheKey = DL_L_NPC_CACHE_WORK_CRAFT;
            sFallbackSuffix = "_craft";
            sFallbackDefaultTag = "dl_work_craft";
        }
        else if (sAnchorRole == "fetch")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_FETCH;
        }
    }
    else if (sProfile == DL_PROFILE_GATE_POST)
    {
        oArea = DL_GetWorkArea(oNpc);
        if (sAnchorRole == "primary")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_PRIMARY;
            sFallbackCacheKey = DL_L_NPC_CACHE_WORK_POST;
            sFallbackSuffix = "_post";
            sFallbackDefaultTag = "dl_work_post";
        }
    }
    else if (sProfile == DL_PROFILE_TRADER)
    {
        oArea = DL_GetWorkArea(oNpc);
        if (sAnchorRole == "primary")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_PRIMARY;
            sFallbackCacheKey = DL_L_NPC_CACHE_WORK_TRADE;
            sFallbackSuffix = "_trade";
            sFallbackDefaultTag = "dl_work_trade";
        }
    }
    else if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        oArea = DL_GetHomeArea(oNpc);
        if (sAnchorRole == "primary")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_PRIMARY;
        }
        else if (sAnchorRole == "secondary")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_SECONDARY;
        }
        else if (sAnchorRole == "fetch")
        {
            sCacheKey = DL_L_NPC_CACHE_WORK_FETCH;
        }
    }

    return DL_ResolveWorkAnchorByArea(
        oNpc,
        oArea,
        "dl_anchor_work_" + sAnchorRole,
        sCacheKey,
        sFallbackCacheKey,
        "dl_work_",
        sFallbackSuffix,
        sFallbackDefaultTag
    );
}
object DL_ResolveBlacksmithForgeWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_BLACKSMITH, "primary");
}
object DL_ResolveBlacksmithCraftWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_BLACKSMITH, "secondary");
}

object DL_ResolveBlacksmithFetchWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_BLACKSMITH, "fetch");
}
object DL_ResolveGatePostWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_GATE_POST, "primary");
}
object DL_ResolveTraderWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_TRADER, "primary");
}
object DL_ResolveDomesticWorkerWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_DOMESTIC_WORKER, "primary");
}

object DL_ResolveDomesticWorkerSecondaryWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_DOMESTIC_WORKER, "secondary");
}

object DL_ResolveDomesticWorkerFetchWaypoint(object oNpc)
{
    return DL_ResolveWorkAnchorByProfile(oNpc, DL_PROFILE_DOMESTIC_WORKER, "fetch");
}

string DL_ResolveDomesticWorkerWorkKind(object oNpc, int bHasFetch)
{
    int nTick = (GetTimeHour() * 60 + GetTimeMinute()) / 10;
    int nPhase = (nTick + DL_GetTagDeterministicOffset(GetTag(oNpc), 101, 0)) % 10;

    // Primary chores (cooking) are dominant.
    if (nPhase <= 5)
    {
        return DL_WORK_KIND_DOMESTIC;
    }

    // Secondary chores (crafting/maintenance) are regular.
    if (nPhase <= 8)
    {
        return DL_WORK_KIND_CRAFT;
    }

    if (bHasFetch)
    {
        return DL_WORK_KIND_FETCH;
    }

    return DL_WORK_KIND_CRAFT;
}
int DL_HasWorkPresentationState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_WORK_KIND) != "" ||
        GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "" ||
        GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) != "" ||
        GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC) != "")
    {
        return TRUE;
    }

    int nActivity = GetLocalInt(oNpc, DL_L_NPC_ACTIVITY_ID);
    return nActivity == DL_ARCH_ACT_NPC_FORGE ||
           nActivity == DL_ARCH_ACT_NPC_FORGE_MULTI ||
           nActivity == DL_ARCH_ACT_NPC_MERCHANT_MULTI ||
           nActivity == DL_ARCH_ACT_NPC_GUARD;
}
void DL_StopWorkPresentationIfActive(object oNpc)
{
    if (!DL_HasWorkPresentationState(oNpc))
    {
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    PlayCustomAnimation(oNpc, "%", FALSE);
    AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, 0.1));
}
void DL_ClearWorkExecutionState(object oNpc)
{
    DL_StopWorkPresentationIfActive(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_KIND);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_WORK_ACTION_STAMP, DL_L_NPC_WORK_ACTION_TARGET);
    DL_ClearActivityPresentation(oNpc);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "work");
}
string DL_ResolveBlacksmithWorkKindAtHour(object oNpc)
{
    int nHour = DL_NormalizeHour(GetTimeHour());
    int nMinute = GetTimeMinute();
    int nSlot = (nHour * 6) + (nMinute / 10);
    int nOffset = DL_GetTagDeterministicOffset(GetTag(oNpc), 4, 0);
    int nPhase = (nSlot + nOffset) % 12;

    if (nPhase == 4 || nPhase == 9)
    {
        return DL_WORK_KIND_FETCH;
    }

    if ((nPhase % 2) == 0)
    {
        return DL_WORK_KIND_FORGE;
    }

    return DL_WORK_KIND_CRAFT;
}
void DL_SetWorkMissingState(object oNpc, string sKind, string sDiagnostic)
{
    SetLocalString(oNpc, DL_L_NPC_WORK_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, DL_WORK_STATUS_MISSING_WAYPOINTS);
    SetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC, sDiagnostic);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_WORK_ACTION_STAMP, DL_L_NPC_WORK_ACTION_TARGET);
    DL_ClearActivityPresentation(oNpc);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "work");
}
void DL_SetWorkTargetState(object oNpc, string sKind, object oTarget)
{
    string sTargetTag = GetTag(oTarget);
    if (GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != sTargetTag)
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_WORK_ACTION_STAMP, DL_L_NPC_WORK_ACTION_TARGET);
    }

    SetLocalString(oNpc, DL_L_NPC_WORK_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_TARGET, sTargetTag);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
}
void DL_FaceWorkTargetOrientation(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
}
int DL_ShouldIssueWorkMoveAction(object oNpc, object oTarget)
{
    return DL_ShouldIssueAnchorMoveAction(
        oNpc,
        oTarget,
        DL_L_NPC_WORK_STATUS,
        DL_WORK_STATUS_MOVING_TO_ANCHOR,
        DL_L_NPC_WORK_ACTION_TARGET,
        DL_L_NPC_WORK_ACTION_STAMP
    );
}
void DL_IssueWorkMoveAction(object oNpc, object oTarget)
{
    DL_BeginAnchorMoveJob(
        oNpc,
        oTarget,
        DL_L_NPC_WORK_STATUS,
        "moving_to_anchor",
        DL_L_NPC_WORK_TARGET,
        DL_L_NPC_WORK_ACTION_TARGET,
        DL_MOVE_OWNER_WORK,
        GetLocalString(oNpc, DL_L_NPC_WORK_KIND),
        DL_WORK_ANCHOR_RADIUS
    );
}
int DL_ProgressWorkAtTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    DL_NavPrepareTargetZoneFromAnchor(oNpc, oTarget);
    if (DL_NavTryAdvanceToZoneForOwner(oNpc, GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET), DL_MOVE_OWNER_WORK))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        if (DL_ShouldIssueWorkMoveAction(oNpc, oTarget))
        {
            DL_IssueWorkMoveAction(oNpc, oTarget);
        }
        return TRUE;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_WORK_ACTION_STAMP, DL_L_NPC_WORK_ACTION_TARGET);
    DL_ClearMoveJob(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
    SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, DL_WORK_STATUS_ON_ANCHOR);
    DL_FaceWorkTargetOrientation(oNpc, oTarget);
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
    return TRUE;
}
void DL_ExecuteWorkDirective(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);

    if (sProfile != DL_PROFILE_BLACKSMITH &&
        sProfile != DL_PROFILE_GATE_POST &&
        sProfile != DL_PROFILE_TRADER &&
        sProfile != DL_PROFILE_DOMESTIC_WORKER)
    {
        DL_ClearWorkExecutionState(oNpc);
        return;
    }

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        string sKind = DL_ResolveBlacksmithWorkKindAtHour(oNpc);
        object oForge = DL_ResolveBlacksmithForgeWaypoint(oNpc);
        object oCraft = DL_ResolveBlacksmithCraftWaypoint(oNpc);
        object oFetch = DL_ResolveBlacksmithFetchWaypoint(oNpc);

        if (!GetIsObjectValid(oForge) || !GetIsObjectValid(oCraft))
        {
            DL_SetWorkMissingState(oNpc, sKind, "need_forge_and_craft_waypoints");
            return;
        }

        object oTarget = oForge;
        if (sKind == DL_WORK_KIND_CRAFT)
        {
            oTarget = oCraft;
        }
        else if (sKind == DL_WORK_KIND_FETCH)
        {
            if (GetIsObjectValid(oFetch))
            {
                oTarget = oFetch;
            }
            else
            {
                sKind = DL_WORK_KIND_CRAFT;
                oTarget = oCraft;
            }
        }

        DL_SetWorkTargetState(oNpc, sKind, oTarget);
        DL_ProgressWorkAtTarget(oNpc, oTarget);
        return;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        object oPost = DL_ResolveGatePostWaypoint(oNpc);

        if (!GetIsObjectValid(oPost))
        {
            DL_SetWorkMissingState(oNpc, DL_WORK_KIND_POST, "need_post_waypoint");
            return;
        }

        DL_SetWorkTargetState(oNpc, DL_WORK_KIND_POST, oPost);
        DL_ProgressWorkAtTarget(oNpc, oPost);
        return;
    }

    if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        object oPrimary = DL_ResolveDomesticWorkerWaypoint(oNpc);
        object oSecondary = DL_ResolveDomesticWorkerSecondaryWaypoint(oNpc);
        object oFetch = DL_ResolveDomesticWorkerFetchWaypoint(oNpc);
        int bHasFetch = GetIsObjectValid(oFetch);

        if (!GetIsObjectValid(oPrimary) || !GetIsObjectValid(oSecondary))
        {
            DL_SetWorkMissingState(oNpc, DL_WORK_KIND_DOMESTIC, "need_home_domestic_anchors");
            return;
        }

        string sKind = DL_ResolveDomesticWorkerWorkKind(oNpc, bHasFetch);
        object oHomeWork = oPrimary;
        if (sKind == DL_WORK_KIND_CRAFT)
        {
            oHomeWork = oSecondary;
        }
        else if (sKind == DL_WORK_KIND_FETCH)
        {
            oHomeWork = oFetch;
        }

        DL_SetWorkTargetState(oNpc, sKind, oHomeWork);
        DL_ProgressWorkAtTarget(oNpc, oHomeWork);
        return;
    }

    object oTrade = DL_ResolveTraderWaypoint(oNpc);

    if (!GetIsObjectValid(oTrade))
    {
        DL_SetWorkMissingState(oNpc, DL_WORK_KIND_TRADE, "need_trade_waypoint");
        return;
    }

    DL_SetWorkTargetState(oNpc, DL_WORK_KIND_TRADE, oTrade);
    DL_ProgressWorkAtTarget(oNpc, oTrade);
}
