#include "dl_activity_archive_anim_inc"
#include "dl_move_job_decl_inc"
#include "dl_transition_inc"


// Compile-compatibility shims/wrappers preserved for include-order stability.
void DL_LogChatDebugEvent(object oNpc, string sKind, string sPayload)
{
    // Intentionally no-op: legacy diagnostic hook retained for compile compatibility.
}

int DL_HasTransitionExecutionState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return DL_IsTransitionExecutionStateActive(oNpc);
}

void DL_ClearTransitionExecutionStateWithReason(object oNpc, string sReason, string sOwner)
{
    DL_ClearTransitionExecutionState(oNpc);

    if (GetIsObjectValid(oNpc) && sReason != "")
    {
        if (sOwner == "")
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sReason);
        }
        else
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "owner=" + sOwner + " reason=" + sReason);
        }
    }
}

// Step 05+: resolver/materialization skeleton.
#include "dl_res_contract_inc"

#include "dl_sched_inc"

int DL_DirectiveUsesFocusState(int nDirective)
{
    return nDirective == DL_DIR_MEAL ||
        nDirective == DL_DIR_SOCIAL ||
        nDirective == DL_DIR_PUBLIC ||
        nDirective == DL_DIR_CHILL;
}

string DL_GetDirectiveDebugLabel(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP)
    {
        return "SLEEP";
    }
    if (nDirective == DL_DIR_WORK)
    {
        return "WORK";
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return "MEAL";
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return "SOCIAL";
    }
    if (nDirective == DL_DIR_PUBLIC)
    {
        return "PUBLIC";
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return "CHILL";
    }
    return "NONE";
}
void DL_LogMarkupIssueOnce(object oNpc, string sKey, string sMessage)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    string sLastKey = GetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY);
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE);
    if (sLastKey == sKey && (nNowAbsMin - nLastMin) < DL_CHAT_MARKUP_COOLDOWN_MIN)
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY, sKey);
    SetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE, nNowAbsMin);
}

void DL_ApplyMaterializationSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirective == DL_DIR_SLEEP)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SLEEP);
        return;
    }

    if (nDirective == DL_DIR_WORK)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_WORK);
        return;
    }

    if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SOCIAL);
        return;
    }

    if (nDirective == DL_DIR_MEAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_MEAL);
        return;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_PUBLIC);
        return;
    }

    if (nDirective == DL_DIR_CHILL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_CHILL);
        return;
    }

    DeleteLocalInt(oNpc, DL_L_NPC_MAT_REQ);
    DeleteLocalString(oNpc, DL_L_NPC_MAT_TAG);
}

#include "dl_anchor_cache_inc"
#include "dl_presentation_inc"
#include "dl_anchor_move_inc"
#include "dl_sleep_inc"
#include "dl_move_job_inc"
#include "dl_work_inc"
#include "dl_focus_inc"

#include "dl_res_cache_inc"

#include "dl_res_directive_state_inc"

object DL_ResolveFocusTargetInCurrentArea(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    if (sTarget == "")
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nIndex = 0;
    object oCandidate = GetObjectByTag(sTarget, nIndex);
    while (GetIsObjectValid(oCandidate) && nIndex < DL_WAYPOINT_TAG_SEARCH_CAP)
    {
        if (GetArea(oCandidate) == oArea)
        {
            return oCandidate;
        }

        nIndex = nIndex + 1;
        oCandidate = GetObjectByTag(sTarget, nIndex);
    }

    return OBJECT_INVALID;
}

int DL_IsFocusRecoverySocialTarget(object oNpc, object oTarget)
{
    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL)
    {
        return TRUE;
    }

    object oSocial = DL_ResolveSocialWaypoint(oNpc);
    if (GetIsObjectValid(oSocial) && oSocial == oTarget)
    {
        return TRUE;
    }

    return FALSE;
}

void DL_RecoverReachedFocusAnchorMoveState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != DL_FOCUS_STATUS_MOVING_TO_ANCHOR)
    {
        return;
    }

    object oTarget = DL_ResolveFocusTargetInCurrentArea(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        return;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        return;
    }

    if (DL_IsFocusRecoverySocialTarget(oNpc, oTarget))
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
        AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
        return;
    }

    if (GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
    {
        return;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
}

object DL_ResolveDirectiveAnchorForMoveBridge(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        return DL_ResolvePublicWaypoint(oNpc);
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return DL_ResolveSocialWaypoint(oNpc);
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return DL_ResolveMealWaypoint(oNpc, DL_ResolveMealKind(oNpc));
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return DL_ResolveChillWaypoint(oNpc);
    }

    return OBJECT_INVALID;
}

string DL_GetDirectiveMoveOwnerForBridge(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP) return DL_MOVE_OWNER_SLEEP;
    if (nDirective == DL_DIR_WORK) return DL_MOVE_OWNER_WORK;
    if (nDirective == DL_DIR_PUBLIC) return DL_MOVE_OWNER_PUBLIC;
    if (nDirective == DL_DIR_SOCIAL) return DL_MOVE_OWNER_SOCIAL;
    if (nDirective == DL_DIR_MEAL) return DL_MOVE_OWNER_MEAL;
    if (nDirective == DL_DIR_CHILL) return DL_MOVE_OWNER_CHILL;
    return "";
}

string DL_GetDirectiveDestinationZone(object oNpc, int nDirective)
{
    if (GetIsObjectValid(oNpc) &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == DL_GetDirectiveMoveOwnerForBridge(nDirective) &&
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "")
    {
        return GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oAnchor))
    {
        return "";
    }

    string sZone = DL_NavGetAnchorZoneId(oAnchor);
    if (sZone != "")
    {
        return sZone;
    }

    return DL_NavGetAreaZoneId(GetArea(oAnchor));
}

int DL_IsTransitionMoveJobCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sPhase = GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    if (sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        // Legacy transition-owned jobs are accepted only through the explicit
        // transition compatibility checks below.
    }
    else
    {
        if (sPhase != DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA)
        {
            return FALSE;
        }

        if (sOwner != DL_GetDirectiveMoveOwnerForBridge(nDirective))
        {
            return FALSE;
        }
    }

    string sDirectiveZone = DL_GetDirectiveDestinationZone(oNpc, nDirective);
    if (sDirectiveZone == "")
    {
        return FALSE;
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (GetIsObjectValid(oAnchor))
    {
        if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea == oAnchorArea)
        {
            return FALSE;
        }
    }

    string sMoveTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sMoveTargetZone == "" && sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        sMoveTargetZone = GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    }
    if (sMoveTargetZone != sDirectiveZone)
    {
        return FALSE;
    }

    string sMoveTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    string sNextZone = DL_NavGetNextZone(oNpc, sDirectiveZone);
    if (sCurrentZone == "" || sNextZone == "")
    {
        return FALSE;
    }

    return sMoveTargetTag == DL_NavMakeTransitionTag(sCurrentZone, sNextZone);
}

int DL_ProcessTransitionMoveInApply(object oNpc, int nEffectiveDirective)
{
    if (!DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nEffectiveDirective))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_TICKED_DBG, TRUE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MISMATCH_SUPPRESSED_DBG, TRUE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REACHED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, FALSE);

    if (!DL_IsTransitionStatusActive(GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS)))
    {
        DL_NavSetState(oNpc, "moving_to_entry", GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE), "");
    }

    DL_TickMoveJob(oNpc);
    if (GetLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG) == TRUE)
    {
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG, TRUE);
    }

    if (DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED || DL_IsMoveJobAtTargetNow(oNpc))
    {
        object oTargetWp = DL_ResolveMoveJobTarget(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REACHED_DBG, TRUE);
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG, TRUE);
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oTargetWp))
        {
            SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, TRUE);
        }
        else
        {
            SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, FALSE);
        }
        return TRUE;
    }

    return TRUE;
}

int DL_IsMoveJobOwnerCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    if (sOwner == "")
    {
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA)
    {
        return DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nDirective);
    }

    if (sOwner == DL_MOVE_OWNER_PUBLIC) return nDirective == DL_DIR_PUBLIC;
    if (sOwner == DL_MOVE_OWNER_SOCIAL) return nDirective == DL_DIR_SOCIAL;
    if (sOwner == DL_MOVE_OWNER_MEAL) return nDirective == DL_DIR_MEAL;
    if (sOwner == DL_MOVE_OWNER_CHILL) return nDirective == DL_DIR_CHILL;
    if (sOwner == DL_MOVE_OWNER_WORK) return nDirective == DL_DIR_WORK;
    if (sOwner == DL_MOVE_OWNER_SLEEP) return nDirective == DL_DIR_SLEEP;
    if (sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        return DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nDirective);
    }

    return FALSE;
}

int DL_IsFocusStateCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    if (sFocusStatus == "")
    {
        return TRUE;
    }

    if (sFocusStatus == DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR) return nDirective == DL_DIR_PUBLIC;
    if (sFocusStatus == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR) return nDirective == DL_DIR_SOCIAL;
    if (GetSubString(sFocusStatus, 0, 15) == "on_meal_anchor") return nDirective == DL_DIR_MEAL;
    if (sFocusStatus == "on_chill_anchor") return nDirective == DL_DIR_CHILL;

    if (sFocusStatus == DL_FOCUS_STATUS_MOVING_TO_ANCHOR)
    {
        return DL_DirectiveUsesFocusState(nDirective) &&
               DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nDirective);
    }

    return DL_DirectiveUsesFocusState(nDirective);
}

void DL_ClearDirectiveChangeDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP);
}

void DL_PreemptOldDirectiveState(object oNpc, int nPrevDirective, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sOldMoveOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sOldMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    int bHadMoveJob = DL_HasMoveJob(oNpc);
    int bClearedFocus = FALSE;
    int bTriggeredFocusCleanup = FALSE;
    int bClearedTransition = FALSE;
    int bHadTransitionExecutionState = FALSE;

    SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, bHadMoveJob);
    SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER, sOldMoveOwner);
    SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET, sOldMoveTarget);
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV, DL_GetDirectiveDebugLabel(nPrevDirective));
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT, DL_GetDirectiveDebugLabel(nEffectiveDirective));

    DL_ClearMoveJob(oNpc);

    if (DL_DirectiveUsesFocusState(nPrevDirective) ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "" ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "")
    {
        DL_ClearFocusExecutionState(oNpc);
        bClearedFocus = TRUE;
        bTriggeredFocusCleanup = TRUE;
    }

    bHadTransitionExecutionState = DL_HasTransitionExecutionState(oNpc);
    if (bHadTransitionExecutionState)
    {
        DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "res");
        bClearedTransition = TRUE;
    }

    if (DL_DirectiveUsesFocusState(nPrevDirective) ||
        nPrevDirective == DL_DIR_WORK ||
        nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearActivityPresentation(oNpc);
    }

    SetLocalString(
        oNpc,
        DL_L_NPC_LAST_DIRECTIVE_CLEANUP,
        "prev=" + DL_GetDirectiveDebugLabel(nPrevDirective) +
            " next=" + DL_GetDirectiveDebugLabel(nEffectiveDirective) +
            " old_move_owner=" + sOldMoveOwner +
            " old_move_target=" + sOldMoveTarget +
            " cleared_move=" + IntToString(bHadMoveJob) +
            " cleared_focus=" + IntToString(bClearedFocus) +
            " focus_cleanup_triggered=" + IntToString(bTriggeredFocusCleanup) +
            " had_transition_state=" + IntToString(bHadTransitionExecutionState) +
            " cleared_transition=" + IntToString(bClearedTransition)
    );
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP, GetLocalString(oNpc, DL_L_NPC_LAST_DIRECTIVE_CLEANUP));
}

int DL_HasDistantSameAreaDirectiveAnchor(object oNpc, int nDirective)
{
    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea != oAnchorArea)
    {
        return FALSE;
    }

    return GetDistanceBetween(oNpc, oAnchor) > DL_WORK_ANCHOR_RADIUS;
}

int DL_BridgeLegacyDirectiveAnchorMoveJob(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc) || DL_HasMoveJob(oNpc) || !DL_DirectiveUsesFocusState(nDirective))
    {
        return FALSE;
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea != oAnchorArea)
    {
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oAnchor) <= DL_WORK_ANCHOR_RADIUS)
    {
        return FALSE;
    }

    string sOwner = DL_GetDirectiveMoveOwnerForBridge(nDirective);
    if (sOwner == "")
    {
        return FALSE;
    }

    string sReason = "bridge_" + sOwner + "_anchor";
    if (nDirective == DL_DIR_PUBLIC &&
        (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) == "transitioning" ||
            GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == ""))
    {
        sReason = "bridge_public_anchor_after_transition";
    }

    DL_ClearTransitionExecutionState(oNpc);
    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    // Canonical focus/anchor move command path:
    // keep all move-job issue state through DL_IssueFocusMoveAction.
    DL_IssueFocusMoveAction(oNpc, oAnchor);
    string sAnchorZone = DL_NavGetAnchorZoneId(oAnchor);
    DL_NavSetDebug(oNpc, DL_NavGetNpcCurrentZone(oNpc), sAnchorZone, sAnchorZone, sReason);
    return TRUE;
}

void DL_SetReachedFinalizeDebug(object oNpc, int bAttempted, int bSuccess, string sReason, int nDirective, string sOwner, string sTargetTag)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_ATTEMPTED_DBG, bAttempted);
    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_SUCCESS_DBG, bSuccess);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_REASON_DBG, sReason);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_DIRECTIVE_DBG, DL_GetDirectiveDebugLabel(nDirective));
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_OWNER_DBG, sOwner);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_TARGET_DBG, sTargetTag);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_AFTER_REACHED_FINALIZE_DBG, GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS));
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_AFTER_REACHED_FINALIZE_DBG, GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT));
}

int DL_FinalizeReachedDirectiveMoveJob(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_USED_FOCUS_DBG, FALSE);


    if (!DL_HasMoveJob(oNpc))
    {
        DL_SetReachedFinalizeDebug(oNpc, FALSE, FALSE, "no_move_job", nEffectiveDirective, "", "");
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "checking", nEffectiveDirective, sOwner, sTargetTag);

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        object oUnreachedTarget = DL_ResolveMoveJobTarget(oNpc);
        if (!GetIsObjectValid(oUnreachedTarget))
        {
            DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "missing_target", nEffectiveDirective, sOwner, sTargetTag);
            return FALSE;
        }

        object oNpcAreaCheck = GetArea(oNpc);
        object oTargetAreaCheck = GetArea(oUnreachedTarget);
        if (!GetIsObjectValid(oNpcAreaCheck) || !GetIsObjectValid(oTargetAreaCheck) || oNpcAreaCheck != oTargetAreaCheck)
        {
            DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "target_area_mismatch", nEffectiveDirective, sOwner, sTargetTag);
            return FALSE;
        }

        DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "target_not_reached", nEffectiveDirective, sOwner, sTargetTag);
        return FALSE;
    }

    DL_MarkMoveJobReachedNow(oNpc, "finalize_at_target");
    object oTarget = DL_ResolveMoveJobTarget(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "missing_target_after_reach", nEffectiveDirective, sOwner, sTargetTag);
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_REACHED);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_REACHED_FINALIZED_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_OWNER_DBG, sOwner);
    SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_TARGET_DBG, sTargetTag);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "res");

    if (sOwner == DL_MOVE_OWNER_PUBLIC && nEffectiveDirective == DL_DIR_PUBLIC)
    {
        string sAnim = "pause";
        if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
        {
            sAnim = "talk01";
        }
        DL_ClearMoveJob(oNpc);
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
        PlayCustomAnimation(oNpc, sAnim, TRUE);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "public_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SOCIAL && nEffectiveDirective == DL_DIR_SOCIAL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteSocialDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "social_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_MEAL && nEffectiveDirective == DL_DIR_MEAL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteMealDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "meal_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_CHILL && nEffectiveDirective == DL_DIR_CHILL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteChillDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "chill_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_WORK && nEffectiveDirective == DL_DIR_WORK)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteWorkDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "work_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SLEEP && nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteSleepDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "sleep_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "owner_directive_mismatch", nEffectiveDirective, sOwner, sTargetTag);
    return FALSE;
}

int DL_IsDirectiveStableAfterReachedFinalize(object oNpc, int nEffectiveDirective)
{
    // Stable-stage mapping (general "arrived and settled" stage -> owner status):
    // PUBLIC  -> DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR
    // SOCIAL  -> DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR
    // MEAL    -> DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX*
    // CHILL   -> DL_FOCUS_STATUS_ON_CHILL_ANCHOR
    // WORK    -> DL_WORK_STATUS_ON_ANCHOR
    // SLEEP   -> DL_SLEEP_STATUS_ON_BED
    if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_MEAL)
    {
        return GetSubString(GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS), 0, 15) == "on_meal_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_WORK)
    {
        return GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == DL_WORK_STATUS_ON_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        return GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == DL_SLEEP_STATUS_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
    }
    return TRUE;
}

void DL_VerifyReachedFinalizeClosure(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if ((DL_HasMoveJob(oNpc) && GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING) ||
        !DL_IsDirectiveStableAfterReachedFinalize(oNpc, nEffectiveDirective))
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC, DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
    }
}

// AUDIT(#864): EMERGENCY CLOSURE for reached-but-not-closed contradictions.
// Preserve as narrow invariant repair until overlap debt is reduced with runtime evidence.
int DL_EmergencyCloseReachedMoveInvariant(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    if (sTargetTag == "")
    {
        sTargetTag = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    }

    if (sOwner == DL_MOVE_OWNER_PUBLIC && nEffectiveDirective == DL_DIR_PUBLIC && sTargetTag != "")
    {
        DL_ClearMoveJob(oNpc);
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        SetLocalInt(oNpc, DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_OWNER_DBG, sOwner);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_TARGET_DBG, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SOCIAL && nEffectiveDirective == DL_DIR_SOCIAL && sTargetTag != "")
    {
        DL_ClearMoveJob(oNpc);
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        SetLocalInt(oNpc, DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_OWNER_DBG, sOwner);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_TARGET_DBG, sTargetTag);
        return TRUE;
    }

    return FALSE;
}

void DL_DetectApplyMoveRegression(object oNpc, int bReachedOrClearedEarlier, int nMoveTicketBefore, string sMoveTargetBefore, string sStage, int nEffectiveDirective)
{
    if (!bReachedOrClearedEarlier)
    {
        return;
    }

    if (sMoveTargetBefore != "" &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING &&
        GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nMoveTicketBefore &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sMoveTargetBefore)
    {
        SetLocalInt(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG, sStage);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG, "same_tick_reopened_reached_move");
        if (DL_IsMoveJobAtTargetNow(oNpc))
        {
            int nGuardTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
            string sGuardOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
            string sGuardTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
            DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective);
            if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
            {
                if (GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nGuardTicket &&
                    GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == sGuardOwner &&
                    GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sGuardTarget)
                {
                    DL_EmergencyCloseReachedMoveInvariant(oNpc, nEffectiveDirective);
                }
                else
                {
                }
            }
        }
    }
}

// AUDIT(#864): APPLY-EXIT INVARIANT ENFORCER (emergency/fallback boundary).
// Purpose is to prevent stale running/moving_to_anchor contradictions after apply.
void DL_EnforceReachedMoveApplyExitInvariant(object oNpc, int nEffectiveDirective)
{
    if (DL_IsMoveJobAtTargetNow(oNpc) &&
        (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING ||
            GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_MOVING_TO_ANCHOR))
    {
        int nGuardTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
        string sGuardOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
        string sGuardTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
        SetLocalInt(oNpc, DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG, TRUE);
        if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
        {
            DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
        }
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
        {
            if (GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nGuardTicket &&
                GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == sGuardOwner &&
                GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sGuardTarget)
            {
                DL_EmergencyCloseReachedMoveInvariant(oNpc, nEffectiveDirective);
            }
            else
            {
            }
        }
    }
}

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DL_MaybeRefreshNpcCachesForEpoch(oNpc);

    int nEffectiveDirective = DL_ResolveEffectiveDirective(oNpc, nDirective);
    int nPrevDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    int nApplyStartMoveTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    string sApplyStartMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);

    if (nPrevDirective != nEffectiveDirective)
    {
        DL_PreemptOldDirectiveState(oNpc, nPrevDirective, nEffectiveDirective);
    }
    else
    {
        DL_ClearDirectiveChangeDebug(oNpc);
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) != DL_MOVE_OWNER_TRANSITION &&
            GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) != DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA &&
            DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective) &&
            DL_IsMoveJobAtTargetNow(oNpc))
        {
            if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
            {
                DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            }
        }
        DL_RecoverReachedFocusAnchorMoveState(oNpc);
        if (DL_ProcessTransitionMoveInApply(oNpc, nEffectiveDirective))
        {
            return;
        }
        if (!DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective))
        {
            string sBadMoveOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
            string sBadMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
            DL_ClearMoveJob(oNpc);
            SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, TRUE);
            SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER, sBadMoveOwner);
            SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET, sBadMoveTarget);
            SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV, DL_GetDirectiveDebugLabel(nPrevDirective));
            SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT, DL_GetDirectiveDebugLabel(nEffectiveDirective));
            SetLocalString(
                oNpc,
                DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP,
                "move_owner_mismatch_cleared old_move_owner=" + sBadMoveOwner +
                    " old_move_target=" + sBadMoveTarget
            );
        }
        DL_BridgeLegacyDirectiveAnchorMoveJob(oNpc, nEffectiveDirective);
    }

    int nMoveTicketBefore = nApplyStartMoveTicket;
    string sMoveTargetBefore = sApplyStartMoveTarget;
    string sMoveResultBeforeTick = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    int bReachedOrClearedEarlier = sMoveResultBeforeTick == DL_MOVE_RESULT_REACHED || !DL_HasMoveJob(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET_BEFORE_DBG, nMoveTicketBefore);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_BEFORE_TICK_DBG, sMoveResultBeforeTick);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG);
    SetLocalInt(oNpc, DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG, FALSE);

    int bMoveJobTicked = FALSE;
    if (nPrevDirective == nEffectiveDirective && DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective))
    {
        bMoveJobTicked = DL_TickMoveJob(oNpc);
        if (bMoveJobTicked && DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED)
        {
            if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
            {
                DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            }
            bReachedOrClearedEarlier = TRUE;
        }
    }
    else
    {
    }

    if (!DL_HasMoveJob(oNpc) || GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_REACHED)
    {
        bReachedOrClearedEarlier = TRUE;
    }
    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_TICK_MOVE_JOB", nEffectiveDirective);

    if (bMoveJobTicked && DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_RUNNING)
    {
        if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
        {
            DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            bReachedOrClearedEarlier = TRUE;
        }
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
        {
            DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
        }
    }

    int nMoveTicketAfter = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    string sMoveResultAfterTick = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET_AFTER_DBG, nMoveTicketAfter);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_AFTER_TICK_DBG, sMoveResultAfterTick);
    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "BEFORE_DIRECTIVE_EXECUTOR", nEffectiveDirective);

    if (nPrevDirective == nEffectiveDirective && DL_ShouldUseDirectiveFastPath(oNpc, nEffectiveDirective))
    {
        if (nEffectiveDirective == DL_DIR_WORK)
        {
            DL_RefreshWorkPresentationOnFastPath(oNpc);
        }

        DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_DIRECTIVE_EXECUTOR", nEffectiveDirective);
        DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
        DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DIRECTIVE, nEffectiveDirective);

    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearWorkExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SLEEP);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SLEEP, DL_SERVICE_OFF);
        DL_ApplyArchiveActivityPresentation(oNpc, nEffectiveDirective);
        DL_ExecuteSleepDirective(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_WORK);
        string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
        DL_SetInteractionModes(
            oNpc,
            DL_DIALOGUE_WORK,
            DL_IsProfileServiceAvailable(sProfile) ? DL_SERVICE_AVAILABLE : DL_SERVICE_OFF
        );

        DL_ClearSleepExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        DeleteLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE);
        DL_ExecuteWorkDirective(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_MEAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_MEAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteMealDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SOCIAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SOCIAL, DL_SERVICE_OFF);
        DL_ExecuteSocialDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_PUBLIC);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecutePublicDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_CHILL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_CHILL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteChillDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else
    {
        DL_ApplyIdleLikeDirectiveState(oNpc, FALSE);
    }

    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_DIRECTIVE_EXECUTOR", nEffectiveDirective);
    DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
    DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
}
