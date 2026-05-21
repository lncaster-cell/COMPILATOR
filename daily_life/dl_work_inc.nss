const string DL_L_NPC_WORK_ACTION_STAMP = "dl_work_anchor_action_stamp";
const string DL_L_NPC_WORK_ACTION_TARGET = "dl_work_anchor_action_target";
// NOTE: keep literal aligned with sleep status; contexts are isolated by different local fields
// (DL_L_NPC_WORK_STATUS vs DL_L_NPC_SLEEP_STATUS), so downstream diagnostics do not mix channels.
const string DL_WORK_STATUS_MISSING_WAYPOINTS = "missing_waypoints";
// Contract note: intentionally shares literal with focus status moving marker.
// Domain must be inferred from owner key DL_L_NPC_WORK_STATUS (work domain).
const string DL_WORK_STATUS_MOVING_TO_ANCHOR = "moving_to_anchor";
const string DL_WORK_STATUS_ON_ANCHOR = "on_anchor";
const string DL_L_NPC_WORK_RESOLVED_KIND = "dl_work_resolved_kind";
const string DL_L_NPC_WORK_RESOLVED_TARGET = "dl_work_resolved_target";
const string DL_L_NPC_WORK_RESOLVE_MISSING_DIAG = "dl_work_resolve_missing_diag";

void DL_ExecuteWorkDirective(object oNpc);
object DL_ResolveWorkWaypointByRoleParams(object oNpc, object oArea, string sAnchorKey, string sAnchorCacheKey, string sFallbackCacheKey, string sFallbackPrefix, string sFallbackSuffix, string sFallbackDefaultTag);

object DL_ResolveWorkWaypointByRoleParams(
    object oNpc,
    object oArea,
    string sAnchorKey,
    string sAnchorCacheKey,
    string sFallbackCacheKey,
    string sFallbackPrefix,
    string sFallbackSuffix,
    string sFallbackDefaultTag
)
{
    if (GetIsObjectValid(oArea))
    {
        object oWp = DL_GetAreaAnchorWaypoint(oNpc, oArea, sAnchorKey, sAnchorCacheKey, FALSE);
        if (GetIsObjectValid(oWp))
        {
            return oWp;
        }
    }

    if (sFallbackCacheKey == "" || sFallbackPrefix == "" || sFallbackSuffix == "" || sFallbackDefaultTag == "")
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

string DL_ResolveBlacksmithWorkKindAtHour(object oNpc);
string DL_ResolveDomesticWorkerWorkKind(object oNpc, int bHasFetch);
int DL_ProgressWorkAtTarget(object oNpc, object oTarget);

object DL_ResolveWorkAnchorWithFallback(
    object oNpc,
    object oArea,
    string sAnchorKey,
    string sCacheKey,
    string sFallbackCacheKey,
    string sFallbackSuffix,
    string sFallbackDefaultTag
)
{
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oArea, sAnchorKey, sCacheKey, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    if (sFallbackSuffix == "" || sFallbackDefaultTag == "" || sFallbackCacheKey == "")
    {
        return OBJECT_INVALID;
    }

    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        sFallbackCacheKey,
        "dl_work_",
        sFallbackSuffix,
        sFallbackDefaultTag
    );
}



// Single source of truth for work kind classification in CRAFT/FETCH/else branches.
int DL_IsWorkKindCraft(string sKind)
{
    return sKind == DL_WORK_KIND_CRAFT;
}

int DL_IsWorkKindFetch(string sKind)
{
    return sKind == DL_WORK_KIND_FETCH;
}

object DL_SelectWorkTargetByKind(
    string sKind,
    object oPrimaryTarget,
    object oCraftTarget,
    object oFetchTarget,
    int bAllowFetch
)
{
    object oTarget = oPrimaryTarget;

    if (DL_IsWorkKindCraft(sKind))
    {
        oTarget = oCraftTarget;
    }
    else if (DL_IsWorkKindFetch(sKind))
    {
        if (bAllowFetch)
        {
            oTarget = oFetchTarget;
        }
        else
        {
            oTarget = oCraftTarget;
        }
    }

    return oTarget;
}
object DL_ResolveWorkAnchorByKind(
    object oNpc,
    object oArea,
    string sKind,
    string sFallbackCacheKey,
    string sFallbackSuffix,
    string sFallbackDefaultTag
)
{
    string sAnchorKey = "";
    string sAnchorCacheKey = "";

    if (sKind == DL_WORK_KIND_FETCH)
    {
        sAnchorKey = "dl_anchor_work_fetch";
        sAnchorCacheKey = DL_L_NPC_CACHE_WORK_FETCH;
    }
    else if (sKind == DL_WORK_KIND_CRAFT)
    {
        sAnchorKey = "dl_anchor_work_secondary";
        sAnchorCacheKey = DL_L_NPC_CACHE_WORK_SECONDARY;
    }
    else
    {
        sAnchorKey = "dl_anchor_work_primary";
        sAnchorCacheKey = DL_L_NPC_CACHE_WORK_PRIMARY;
    }

    return DL_ResolveWorkWaypointByRoleParams(
        oNpc,
        oArea,
        sAnchorKey,
        sAnchorCacheKey,
        sFallbackCacheKey,
        "dl_work_",
        sFallbackSuffix,
        sFallbackDefaultTag
    );
}

object DL_ResolveBlacksmithWorkAnchorByKind(object oNpc, string sKind)
{
    if (sKind == DL_WORK_KIND_FETCH || sKind == DL_WORK_KIND_CRAFT)
    {
        return DL_ResolveWorkAnchorByKind(
            oNpc,
            DL_GetWorkArea(oNpc),
            sKind,
            DL_L_NPC_CACHE_WORK_CRAFT,
            "_craft",
            "dl_work_craft"
        );
    }

    return DL_ResolveWorkAnchorByKind(
        oNpc,
        DL_GetWorkArea(oNpc),
        DL_WORK_KIND_FORGE,
        DL_L_NPC_CACHE_WORK_FORGE,
        "_forge",
        "dl_work_forge"
    );
}

object DL_ResolveBlacksmithForgeWaypoint(object oNpc)
{
    return DL_ResolveBlacksmithWorkAnchorByKind(oNpc, DL_WORK_KIND_FORGE);
}

object DL_ResolveBlacksmithCraftWaypoint(object oNpc)
{
    return DL_ResolveBlacksmithWorkAnchorByKind(oNpc, DL_WORK_KIND_CRAFT);
}

object DL_ResolveBlacksmithFetchWaypoint(object oNpc)
{
    return DL_ResolveBlacksmithWorkAnchorByKind(oNpc, DL_WORK_KIND_FETCH);
}

object DL_ResolveGatePostWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    return DL_ResolveWorkAnchorWithFallback(
        oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, DL_L_NPC_CACHE_WORK_POST, "_post", "dl_work_post"
    );
}

object DL_ResolveTraderWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    return DL_ResolveWorkAnchorWithFallback(
        oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, DL_L_NPC_CACHE_WORK_TRADE, "_trade", "dl_work_trade"
    );
}

object DL_ResolveDomesticWorkAnchorByKind(object oNpc, string sKind)
{
    return DL_ResolveWorkAnchorByKind(
        oNpc,
        DL_GetHomeArea(oNpc),
        sKind,
        "",
        "",
        ""
    );
}

object DL_ResolveDomesticWorkerWaypoint(object oNpc)
{
    return DL_ResolveDomesticWorkAnchorByKind(oNpc, DL_WORK_KIND_FORGE);
}

object DL_ResolveDomesticWorkerSecondaryWaypoint(object oNpc)
{
    return DL_ResolveDomesticWorkAnchorByKind(oNpc, DL_WORK_KIND_CRAFT);
}

object DL_ResolveDomesticWorkerFetchWaypoint(object oNpc)
{
    return DL_ResolveDomesticWorkAnchorByKind(oNpc, DL_WORK_KIND_FETCH);
}

int DL_ResolveWorkForProfile(object oNpc, string sProfile)
{
    object oTarget = OBJECT_INVALID;
    string sKind = "";
    string sMissingDiagnostic = "";

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        string sBlacksmithKind = DL_ResolveBlacksmithWorkKindAtHour(oNpc);
        object oForge = DL_ResolveBlacksmithForgeWaypoint(oNpc);
        object oCraft = DL_ResolveBlacksmithCraftWaypoint(oNpc);
        object oFetch = DL_ResolveBlacksmithFetchWaypoint(oNpc);

        if (!GetIsObjectValid(oForge) || !GetIsObjectValid(oCraft))
        {
            SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVED_KIND, sBlacksmithKind);
            SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_MISSING_DIAG, "need_forge_and_craft_waypoints");
            DeleteLocalObject(oNpc, DL_L_NPC_WORK_RESOLVED_TARGET);
            return FALSE;
        }

        oTarget = DL_SelectWorkTargetByKind(
            sBlacksmithKind,
            oForge,
            oCraft,
            oFetch,
            GetIsObjectValid(oFetch)
        );

        if (DL_IsWorkKindFetch(sBlacksmithKind) && !GetIsObjectValid(oFetch))
        {
            sBlacksmithKind = DL_WORK_KIND_CRAFT;
        }

        SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVED_KIND, sBlacksmithKind);
        SetLocalObject(oNpc, DL_L_NPC_WORK_RESOLVED_TARGET, oTarget);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_MISSING_DIAG);
        return TRUE;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        oTarget = DL_ResolveGatePostWaypoint(oNpc);
        sKind = DL_WORK_KIND_POST;
        sMissingDiagnostic = "need_post_waypoint";
    }
    else if (sProfile == DL_PROFILE_TRADER)
    {
        oTarget = DL_ResolveTraderWaypoint(oNpc);
        sKind = DL_WORK_KIND_TRADE;
        sMissingDiagnostic = "need_trade_waypoint";
    }
    else if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        object oPrimary = DL_ResolveDomesticWorkerWaypoint(oNpc);
        object oSecondary = DL_ResolveDomesticWorkerSecondaryWaypoint(oNpc);
        object oFetch = DL_ResolveDomesticWorkerFetchWaypoint(oNpc);
        int bHasFetch = GetIsObjectValid(oFetch);

        if (!GetIsObjectValid(oPrimary) || !GetIsObjectValid(oSecondary))
        {
            SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVED_KIND, DL_WORK_KIND_DOMESTIC);
            SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_MISSING_DIAG, "need_home_domestic_anchors");
            DeleteLocalObject(oNpc, DL_L_NPC_WORK_RESOLVED_TARGET);
            return FALSE;
        }

        sKind = DL_ResolveDomesticWorkerWorkKind(oNpc, bHasFetch);
        oTarget = DL_SelectWorkTargetByKind(
            sKind,
            oPrimary,
            oSecondary,
            oFetch,
            bHasFetch
        );
    }

    if (!GetIsObjectValid(oTarget))
    {
        SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVED_KIND, sKind);
        SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_MISSING_DIAG, sMissingDiagnostic);
        DeleteLocalObject(oNpc, DL_L_NPC_WORK_RESOLVED_TARGET);
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVED_KIND, sKind);
    SetLocalObject(oNpc, DL_L_NPC_WORK_RESOLVED_TARGET, oTarget);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_MISSING_DIAG);
    return TRUE;
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
string DL_L_NPC_WORK_RESOLVE_KIND = "dl_work_resolve_kind";
string DL_L_NPC_WORK_RESOLVE_ERROR = "dl_work_resolve_error";

void DL_ClearWorkResolveState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_KIND);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_ERROR);
}
void DL_SetWorkResolveState(object oNpc, string sKind, string sError)
{
    SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_RESOLVE_ERROR, sError);
}
object DL_ResolveWorkTargetForProfile(object oNpc, string sProfile, string sKindOut, object oTargetOut, string sErrorOut)
{
    DL_ClearWorkResolveState(oNpc);

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        string sKind = DL_ResolveBlacksmithWorkKindAtHour(oNpc);
        object oForge = DL_ResolveBlacksmithForgeWaypoint(oNpc);
        object oCraft = DL_ResolveBlacksmithCraftWaypoint(oNpc);
        object oFetch = DL_ResolveBlacksmithFetchWaypoint(oNpc);

        if (!GetIsObjectValid(oForge) || !GetIsObjectValid(oCraft))
        {
            DL_SetWorkResolveState(oNpc, sKind, "need_forge_and_craft_waypoints");
            return OBJECT_INVALID;
        }

        object oTarget = DL_SelectWorkTargetByKind(
            sKind,
            oForge,
            oCraft,
            oFetch,
            GetIsObjectValid(oFetch)
        );

        if (DL_IsWorkKindFetch(sKind) && !GetIsObjectValid(oFetch))
        {
            sKind = DL_WORK_KIND_CRAFT;
        }

        DL_SetWorkResolveState(oNpc, sKind, "");
        return oTarget;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        object oPost = DL_ResolveGatePostWaypoint(oNpc);
        if (!GetIsObjectValid(oPost))
        {
            DL_SetWorkResolveState(oNpc, DL_WORK_KIND_POST, "need_post_waypoint");
            return OBJECT_INVALID;
        }

        DL_SetWorkResolveState(oNpc, DL_WORK_KIND_POST, "");
        return oPost;
    }

    if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        object oPrimary = DL_ResolveDomesticWorkerWaypoint(oNpc);
        object oSecondary = DL_ResolveDomesticWorkerSecondaryWaypoint(oNpc);
        object oFetch = DL_ResolveDomesticWorkerFetchWaypoint(oNpc);
        int bHasFetch = GetIsObjectValid(oFetch);

        if (!GetIsObjectValid(oPrimary) || !GetIsObjectValid(oSecondary))
        {
            DL_SetWorkResolveState(oNpc, DL_WORK_KIND_DOMESTIC, "need_home_domestic_anchors");
            return OBJECT_INVALID;
        }

        string sKind = DL_ResolveDomesticWorkerWorkKind(oNpc, bHasFetch);
        object oTarget = DL_SelectWorkTargetByKind(
            sKind,
            oPrimary,
            oSecondary,
            oFetch,
            bHasFetch
        );

        DL_SetWorkResolveState(oNpc, sKind, "");
        return oTarget;
    }

    object oTrade = DL_ResolveTraderWaypoint(oNpc);
    if (!GetIsObjectValid(oTrade))
    {
        DL_SetWorkResolveState(oNpc, DL_WORK_KIND_TRADE, "need_trade_waypoint");
        return OBJECT_INVALID;
    }

    DL_SetWorkResolveState(oNpc, DL_WORK_KIND_TRADE, "");
    return oTrade;
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
int DL_HandleMissingWorkTarget(object oNpc, string sKind, int bOk, string sReason)
{
    if (bOk)
    {
        return TRUE;
    }

    DL_SetWorkMissingState(oNpc, sKind, sReason);
    return FALSE;
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
        DL_WORK_STATUS_MOVING_TO_ANCHOR,
        DL_L_NPC_WORK_TARGET,
        DL_L_NPC_WORK_ACTION_TARGET,
        DL_MOVE_OWNER_WORK,
        GetLocalString(oNpc, DL_L_NPC_WORK_KIND),
        DL_WORK_ANCHOR_RADIUS
    );
}

void DL_LogWorkTargetSelection(object oNpc, object oTarget, string sKind)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }
}

void DL_ApplyWorkTargetAndProgress(object oNpc, string sKind, object oTarget)
{
    DL_SetWorkTargetState(oNpc, sKind, oTarget);
    DL_LogWorkTargetSelection(oNpc, oTarget, sKind);
    DL_ProgressWorkAtTarget(oNpc, oTarget);
}
int DL_ProgressWorkAtTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (DL_NavTryAdvanceFromAnchorForOwner(oNpc, oTarget, DL_MOVE_OWNER_WORK))
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

    DL_SetAnchorTerminalStatus(
        oNpc,
        DL_L_NPC_WORK_STATUS,
        DL_WORK_STATUS_ON_ANCHOR,
        "",
        OBJECT_INVALID,
        DL_L_NPC_WORK_ACTION_STAMP,
        DL_L_NPC_WORK_ACTION_TARGET,
        TRUE,
        TRUE,
        FALSE
    );
    DL_ClearTransitionExecutionState(oNpc);
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

        if (!DL_HandleMissingWorkTarget(oNpc, sKind, GetIsObjectValid(oForge) && GetIsObjectValid(oCraft), "need_forge_and_craft_waypoints"))
        {
            return;
        }

        object oTarget = DL_SelectWorkTargetByKind(
            sKind,
            oForge,
            oCraft,
            oFetch,
            GetIsObjectValid(oFetch)
        );

        if (DL_IsWorkKindFetch(sKind) && !GetIsObjectValid(oFetch))
        {
            sKind = DL_WORK_KIND_CRAFT;
        }

        DL_ApplyWorkTargetAndProgress(oNpc, sKind, oTarget);
        return;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        object oPost = DL_ResolveGatePostWaypoint(oNpc);

        if (!DL_HandleMissingWorkTarget(oNpc, DL_WORK_KIND_POST, GetIsObjectValid(oPost), "need_post_waypoint"))
        {
            return;
        }

        DL_ApplyWorkTargetAndProgress(oNpc, DL_WORK_KIND_POST, oPost);
        return;
    }

    if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        object oPrimary = DL_ResolveDomesticWorkerWaypoint(oNpc);
        object oSecondary = DL_ResolveDomesticWorkerSecondaryWaypoint(oNpc);
        object oFetch = DL_ResolveDomesticWorkerFetchWaypoint(oNpc);
        int bHasFetch = GetIsObjectValid(oFetch);

        if (!DL_HandleMissingWorkTarget(oNpc, DL_WORK_KIND_DOMESTIC, GetIsObjectValid(oPrimary) && GetIsObjectValid(oSecondary), "need_home_domestic_anchors"))
        {
            return;
        }

        string sKind = DL_ResolveDomesticWorkerWorkKind(oNpc, bHasFetch);
        object oHomeWork = DL_SelectWorkTargetByKind(
            sKind,
            oPrimary,
            oSecondary,
            oFetch,
            bHasFetch
        );

        DL_ApplyWorkTargetAndProgress(oNpc, sKind, oHomeWork);
        return;
    }

    object oTrade = DL_ResolveTraderWaypoint(oNpc);

    if (!DL_HandleMissingWorkTarget(oNpc, DL_WORK_KIND_TRADE, GetIsObjectValid(oTrade), "need_trade_waypoint"))
    {
        return;
    }

    DL_ApplyWorkTargetAndProgress(oNpc, DL_WORK_KIND_TRADE, oTrade);
}
