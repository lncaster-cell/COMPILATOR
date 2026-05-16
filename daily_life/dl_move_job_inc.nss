// Canonical Daily Life local movement job controller.
// Movement directives own presentation state; this job owns generic movement
// lifecycle: target resolution, reach checks, action reissue, and failure state.

const int DL_MOVE_TARGET_SEARCH_CAP = 64;
const float DL_MOVE_DEFAULT_RADIUS = 1.60;
const string DL_L_NPC_MOVE_REACHED_FINALIZED_DBG = "move_reached_finalized";
const string DL_L_NPC_REACHED_MOVE_OWNER_DBG = "reached_move_owner";
const string DL_L_NPC_REACHED_MOVE_TARGET_DBG = "reached_move_target";
const string DL_L_NPC_REACHED_FINALIZE_ATTEMPTED_DBG = "reached_finalize_attempted";
const string DL_L_NPC_REACHED_FINALIZE_SUCCESS_DBG = "reached_finalize_success";
const string DL_L_NPC_REACHED_FINALIZE_REASON_DBG = "reached_finalize_reason";
const string DL_L_NPC_REACHED_FINALIZE_DIRECTIVE_DBG = "reached_finalize_directive";
const string DL_L_NPC_REACHED_FINALIZE_OWNER_DBG = "reached_finalize_owner";
const string DL_L_NPC_REACHED_FINALIZE_TARGET_DBG = "reached_finalize_target";
const string DL_L_NPC_FOCUS_AFTER_REACHED_FINALIZE_DBG = "focus_status_after_reached_finalize";
const string DL_L_NPC_MOVE_RESULT_AFTER_REACHED_FINALIZE_DBG = "move_result_after_reached_finalize";
const string DL_L_NPC_MOVE_TARGET_OBJ_TAG_DBG = "move_target_obj_tag";
const string DL_L_NPC_MOVE_TARGET_OBJ_AREA_DBG = "move_target_obj_area";
const string DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG = "move_target_obj_dist";
const string DL_L_NPC_FOCUS_TARGET_OBJ_TAG_DBG = "focus_target_obj_tag";
const string DL_L_NPC_FOCUS_TARGET_OBJ_AREA_DBG = "focus_target_obj_area";
const string DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG = "focus_target_obj_dist";
const string DL_L_NPC_MOVE_FOCUS_TARGET_SAME_OBJ_DBG = "move_focus_target_same_object";
const string DL_L_NPC_REACHED_FINALIZE_USED_FOCUS_DBG = "reached_finalize_used_focus_target";
const string DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_DBG = "duplicate_move_target_tag";
const string DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_VALUE_DBG = "duplicate_move_target_tag_value";
const string DL_L_NPC_DUPLICATE_MOVE_TARGET_AREA_DBG = "duplicate_move_target_area";
const string DL_L_NPC_MOVE_LAST_DIST = "dl_move_last_dist";
const string DL_L_NPC_MOVE_LAST_PROGRESS_TICK = "dl_move_last_progress_tick";
const string DL_L_NPC_MOVE_LAST_X = "dl_move_last_x";
const string DL_L_NPC_MOVE_LAST_Y = "dl_move_last_y";
const string DL_L_NPC_MOVE_NO_PROGRESS_COUNT = "dl_move_no_progress_count";
const string DL_L_NPC_MOVE_REISSUE_COUNT = "dl_move_reissue_count";
const string DL_L_NPC_MOVE_LAST_REISSUE_TICK = "dl_move_last_reissue_tick";
const string DL_L_NPC_MOVE_STALL_REASON = "dl_move_stall_reason";
const string DL_L_NPC_MOVE_DIST_DELTA_DBG = "move_dist_delta";
const string DL_L_NPC_MOVE_ACTION_REISSUED_DBG = "move_action_reissued";
const string DL_L_NPC_MOVE_CURRENT_ACTION_DBG = "current_action";
const float DL_MOVE_PROGRESS_EPSILON = 0.15;
const int DL_MOVE_NO_PROGRESS_SECONDS = 8;
const int DL_MOVE_PERSISTENT_REISSUE_COUNT = 3;

object DL_ResolveFocusTargetInCurrentArea(object oNpc);

int DL_HasMoveJob(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) != "" &&
           GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) != "";
}

string DL_GetMoveJobResult(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return "";
    }

    return GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
}

int DL_IsMoveJobReached(object oNpc)
{
    return DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED;
}

void DL_ClearMoveJob(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_TARGET_AREA);
    DeleteLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    DeleteLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ);
    DeleteLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_DIST);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_LAST_PROGRESS_TICK);
    DeleteLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_X);
    DeleteLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_Y);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_NO_PROGRESS_COUNT);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_REISSUE_COUNT);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_LAST_REISSUE_TICK);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_STALL_REASON);
    DeleteLocalFloat(oNpc, DL_L_NPC_MOVE_DIST_DELTA_DBG);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG);
    DeleteLocalInt(oNpc, DL_L_NPC_MOVE_CURRENT_ACTION_DBG);
}

int DL_GetMoveJobTickStamp()
{
    return DL_GetSleepActionStamp();
}

int DL_GetMoveJobElapsedSeconds(int nNow, int nThen)
{
    if (nThen <= 0)
    {
        return 0;
    }

    if (nNow < nThen)
    {
        return (86400 - nThen) + nNow;
    }

    return nNow - nThen;
}

void DL_RecordMoveJobProgressSample(object oNpc, float fDistance, int nNowTick)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    vector vPos = GetPosition(oNpc);
    SetLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_DIST, fDistance);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_LAST_PROGRESS_TICK, nNowTick);
    SetLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_X, vPos.x);
    SetLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_Y, vPos.y);
}

void DL_ResetMoveJobProgressAfterAdvance(object oNpc, float fDistance, int nNowTick)
{
    DL_RecordMoveJobProgressSample(oNpc, fDistance, nNowTick);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_NO_PROGRESS_COUNT, 0);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_STALL_REASON);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
}

void DL_ReissueMoveJobAfterNoProgress(object oNpc, object oTarget, float fRadius, float fDistance, int nNowTick)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    int nNoProgressCount = GetLocalInt(oNpc, DL_L_NPC_MOVE_NO_PROGRESS_COUNT) + 1;
    int nReissueCount = GetLocalInt(oNpc, DL_L_NPC_MOVE_REISSUE_COUNT) + 1;
    string sReason = "move_no_progress_reissued";
    if (nReissueCount >= DL_MOVE_PERSISTENT_REISSUE_COUNT)
    {
        sReason = "move_no_progress_persistent";
    }

    SetLocalInt(oNpc, DL_L_NPC_MOVE_NO_PROGRESS_COUNT, nNoProgressCount);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_REISSUE_COUNT, nReissueCount);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_LAST_REISSUE_TICK, nNowTick);
    SetLocalString(oNpc, DL_L_NPC_MOVE_STALL_REASON, sReason);
    SetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC, sReason);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG, TRUE);

    AssignCommand(oNpc, ClearAllActions(TRUE));
    DL_ClearTransitionExecutionState(oNpc);
    DL_ResetCustomAnimationBeforeAnchorMove(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET, nNowTick);
    DL_QueueMoveToObjectAction(oNpc, oTarget, TRUE, fRadius);
    DL_RecordMoveJobProgressSample(oNpc, fDistance, nNowTick);
}

void DL_SetMoveTargetIdentityDebug(object oNpc, object oMoveTarget, object oFocusTarget)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oNpcArea = GetArea(oNpc);
    if (GetIsObjectValid(oMoveTarget))
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_TAG_DBG, GetTag(oMoveTarget));
        object oMoveArea = GetArea(oMoveTarget);
        if (GetIsObjectValid(oMoveArea))
        {
            SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_AREA_DBG, GetTag(oMoveArea));
        }
        if (GetIsObjectValid(oNpcArea) && oMoveArea == oNpcArea)
        {
            SetLocalFloat(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG, GetDistanceBetween(oNpc, oMoveTarget));
        }
        else
        {
            SetLocalFloat(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG, -1.0);
        }
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_TAG_DBG);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_AREA_DBG);
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG, -1.0);
    }

    if (GetIsObjectValid(oFocusTarget))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_TAG_DBG, GetTag(oFocusTarget));
        object oFocusArea = GetArea(oFocusTarget);
        if (GetIsObjectValid(oFocusArea))
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_AREA_DBG, GetTag(oFocusArea));
        }
        if (GetIsObjectValid(oNpcArea) && oFocusArea == oNpcArea)
        {
            SetLocalFloat(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG, GetDistanceBetween(oNpc, oFocusTarget));
        }
        else
        {
            SetLocalFloat(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG, -1.0);
        }
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_TAG_DBG);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_AREA_DBG);
        SetLocalFloat(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG, -1.0);
    }

    SetLocalInt(oNpc, DL_L_NPC_MOVE_FOCUS_TARGET_SAME_OBJ_DBG,
        GetIsObjectValid(oMoveTarget) && oMoveTarget == oFocusTarget);
}

void DL_SetDuplicateMoveTargetDebug(object oNpc, string sTargetTag, string sTargetArea, int bDuplicate)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_DBG, bDuplicate);
    if (bDuplicate)
    {
        SetLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_VALUE_DBG, sTargetTag);
        SetLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_AREA_DBG, sTargetArea);
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_VALUE_DBG);
        DeleteLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_AREA_DBG);
    }
}

void DL_UpdateDuplicateMoveTargetDebug(object oNpc, string sTargetTag, string sTargetArea)
{
    if (!GetIsObjectValid(oNpc) || sTargetTag == "")
    {
        return;
    }

    object oNpcArea = GetArea(oNpc);
    string sMatchArea = sTargetArea;
    if (sMatchArea == "" && GetIsObjectValid(oNpcArea))
    {
        sMatchArea = GetTag(oNpcArea);
    }

    int nMatches = 0;
    int nIndex = 0;
    while (nIndex < DL_MOVE_TARGET_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTargetTag, nIndex);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        object oCandidateArea = GetArea(oCandidate);
        if (sMatchArea != "")
        {
            if (GetIsObjectValid(oCandidateArea) && GetTag(oCandidateArea) == sMatchArea)
            {
                nMatches = nMatches + 1;
            }
        }
        else
        {
            nMatches = nMatches + 1;
        }
        nIndex = nIndex + 1;
    }

    DL_SetDuplicateMoveTargetDebug(oNpc, sTargetTag, sMatchArea, nMatches > 1);
}

void DL_SetMoveTargetIdentityDebug(object oNpc, object oMoveTarget, object oFocusTarget)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oNpcArea = GetArea(oNpc);
    if (GetIsObjectValid(oMoveTarget))
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_TAG_DBG, GetTag(oMoveTarget));
        object oMoveArea = GetArea(oMoveTarget);
        if (GetIsObjectValid(oMoveArea))
        {
            SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_AREA_DBG, GetTag(oMoveArea));
        }
        if (GetIsObjectValid(oNpcArea) && oMoveArea == oNpcArea)
        {
            SetLocalFloat(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG, GetDistanceBetween(oNpc, oMoveTarget));
        }
        else
        {
            SetLocalFloat(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG, -1.0);
        }
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_TAG_DBG);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_AREA_DBG);
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_TARGET_OBJ_DIST_DBG, -1.0);
    }

    if (GetIsObjectValid(oFocusTarget))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_TAG_DBG, GetTag(oFocusTarget));
        object oFocusArea = GetArea(oFocusTarget);
        if (GetIsObjectValid(oFocusArea))
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_AREA_DBG, GetTag(oFocusArea));
        }
        if (GetIsObjectValid(oNpcArea) && oFocusArea == oNpcArea)
        {
            SetLocalFloat(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG, GetDistanceBetween(oNpc, oFocusTarget));
        }
        else
        {
            SetLocalFloat(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG, -1.0);
        }
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_TAG_DBG);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_AREA_DBG);
        SetLocalFloat(oNpc, DL_L_NPC_FOCUS_TARGET_OBJ_DIST_DBG, -1.0);
    }

    SetLocalInt(oNpc, DL_L_NPC_MOVE_FOCUS_TARGET_SAME_OBJ_DBG,
        GetIsObjectValid(oMoveTarget) && oMoveTarget == oFocusTarget);
}

void DL_SetDuplicateMoveTargetDebug(object oNpc, string sTargetTag, string sTargetArea, int bDuplicate)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_DBG, bDuplicate);
    if (bDuplicate)
    {
        SetLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_VALUE_DBG, sTargetTag);
        SetLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_AREA_DBG, sTargetArea);
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_TAG_VALUE_DBG);
        DeleteLocalString(oNpc, DL_L_NPC_DUPLICATE_MOVE_TARGET_AREA_DBG);
    }
}

void DL_UpdateDuplicateMoveTargetDebug(object oNpc, string sTargetTag, string sTargetArea)
{
    if (!GetIsObjectValid(oNpc) || sTargetTag == "")
    {
        return;
    }

    object oNpcArea = GetArea(oNpc);
    string sMatchArea = sTargetArea;
    if (sMatchArea == "" && GetIsObjectValid(oNpcArea))
    {
        sMatchArea = GetTag(oNpcArea);
    }

    int nMatches = 0;
    int nIndex = 0;
    while (nIndex < DL_MOVE_TARGET_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTargetTag, nIndex);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        object oCandidateArea = GetArea(oCandidate);
        if (sMatchArea != "")
        {
            if (GetIsObjectValid(oCandidateArea) && GetTag(oCandidateArea) == sMatchArea)
            {
                nMatches = nMatches + 1;
            }
        }
        else
        {
            nMatches = nMatches + 1;
        }
        nIndex = nIndex + 1;
    }

    DL_SetDuplicateMoveTargetDebug(oNpc, sTargetTag, sMatchArea, nMatches > 1);
}

object DL_ResolveMoveJobTarget(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    if (sTargetTag == "")
    {
        return OBJECT_INVALID;
    }

    string sTargetArea = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_AREA);
    object oNpcArea = GetArea(oNpc);
    string sNpcArea = "";
    if (GetIsObjectValid(oNpcArea))
    {
        sNpcArea = GetTag(oNpcArea);
    }

    object oFocusTarget = OBJECT_INVALID;
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sTargetTag)
    {
        oFocusTarget = DL_ResolveFocusTargetInCurrentArea(oNpc);
    }

    object oCached = GetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ);
    int bCachedValid = FALSE;
    if (GetIsObjectValid(oCached) && GetTag(oCached) == sTargetTag)
    {
        object oCachedArea = GetArea(oCached);
        if (sTargetArea == "" || (GetIsObjectValid(oCachedArea) && GetTag(oCachedArea) == sTargetArea))
        {
            bCachedValid = TRUE;
        }
        if (bCachedValid && sTargetArea == sNpcArea && oCachedArea != oNpcArea)
        {
            bCachedValid = FALSE;
        }
    }

    if (bCachedValid && GetIsObjectValid(oFocusTarget) && oFocusTarget != oCached)
    {
        float fRadius = GetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS);
        if (fRadius <= 0.0)
        {
            fRadius = DL_MOVE_DEFAULT_RADIUS;
        }
        float fFocusDist = GetDistanceBetween(oNpc, oFocusTarget);
        float fCachedDist = GetDistanceBetween(oNpc, oCached);
        if (fFocusDist <= fRadius || fFocusDist < fCachedDist)
        {
            oCached = oFocusTarget;
            SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oCached);
            bCachedValid = TRUE;
        }
    }

    if (bCachedValid)
    {
        DL_UpdateDuplicateMoveTargetDebug(oNpc, sTargetTag, sTargetArea);
        DL_SetMoveTargetIdentityDebug(oNpc, oCached, oFocusTarget);
        return oCached;
    }
    DeleteLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ);

    object oFallback = OBJECT_INVALID;
    object oFirstInTargetArea = OBJECT_INVALID;
    int nMatchesInTargetArea = 0;
    int nIndex = 0;
    while (nIndex < DL_MOVE_TARGET_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTargetTag, nIndex);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        object oCandidateArea = GetArea(oCandidate);
        int bAreaMatches = FALSE;
        if (sTargetArea != "")
        {
            bAreaMatches = GetIsObjectValid(oCandidateArea) && GetTag(oCandidateArea) == sTargetArea;
        }
        else if (GetIsObjectValid(oNpcArea) && oCandidateArea == oNpcArea)
        {
            bAreaMatches = TRUE;
        }

        if (bAreaMatches)
        {
            nMatchesInTargetArea = nMatchesInTargetArea + 1;
            if (!GetIsObjectValid(oFirstInTargetArea))
            {
                oFirstInTargetArea = oCandidate;
            }
        }
        else if (!GetIsObjectValid(oFallback))
        {
            oFallback = oCandidate;
        }

        nIndex = nIndex + 1;
    }

    DL_SetDuplicateMoveTargetDebug(oNpc, sTargetTag, sTargetArea, nMatchesInTargetArea > 1);

    if (GetIsObjectValid(oFocusTarget))
    {
        SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oFocusTarget);
        DL_SetMoveTargetIdentityDebug(oNpc, oFocusTarget, oFocusTarget);
        return oFocusTarget;
    }

    if (GetIsObjectValid(oFirstInTargetArea))
    {
        SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oFirstInTargetArea);
        DL_SetMoveTargetIdentityDebug(oNpc, oFirstInTargetArea, oFocusTarget);
        return oFirstInTargetArea;
    }

    if (GetIsObjectValid(oFallback))
    {
        SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oFallback);
    }
    DL_SetMoveTargetIdentityDebug(oNpc, oFallback, oFocusTarget);
    return oFallback;
}

void DL_SetMoveJobAreaFromTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    object oTargetArea = GetArea(oTarget);
    if (GetIsObjectValid(oTargetArea))
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_AREA, GetTag(oTargetArea));
    }
}

void DL_SetMoveJobFailed(object oNpc, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_FAILED);
    SetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC, sDiagnostic);
}

void DL_IssueMoveJobAction(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    DL_ClearTransitionExecutionState(oNpc);
    DL_ResetCustomAnimationBeforeAnchorMove(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET, DL_GetSleepActionStamp());
    DL_QueueMoveAction(oNpc, GetLocation(oTarget), TRUE);
}

int DL_TickMoveJob(object oNpc)
{
    if (!DL_HasMoveJob(oNpc))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_MOVE_REACHED_FINALIZED_DBG, FALSE);

    object oTarget = DL_ResolveMoveJobTarget(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        DL_SetMoveJobFailed(oNpc, "missing_target");
        return TRUE;
    }

    DL_SetMoveJobAreaFromTarget(oNpc, oTarget);

    float fRadius = GetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS);
    if (fRadius <= 0.0)
    {
        fRadius = DL_MOVE_DEFAULT_RADIUS;
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS, fRadius);
    }

    object oNpcArea = GetArea(oNpc);
    object oTargetArea = GetArea(oTarget);
    if (GetIsObjectValid(oNpcArea) && GetIsObjectValid(oTargetArea) && oNpcArea != oTargetArea)
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);
        SetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC, "waiting_for_transition");
        return TRUE;
    }

    int nNowTick = DL_GetMoveJobTickStamp();
    int nCurrentAction = GetCurrentAction(oNpc);
    float fDistance = GetDistanceBetween(oNpc, oTarget);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_CURRENT_ACTION_DBG, nCurrentAction);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG, FALSE);

    if (fDistance <= fRadius)
    {
        SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_OWNER_DBG, GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER));
        SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_TARGET_DBG, GetTag(oTarget));
        SetLocalInt(oNpc, DL_L_NPC_MOVE_REACHED_FINALIZED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_REACHED);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_STALL_REASON);
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_DIST_DELTA_DBG, 0.0);
        DL_RecordMoveJobProgressSample(oNpc, fDistance, nNowTick);
        DL_ClearTransitionExecutionState(oNpc);
        return TRUE;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);

    int nLastProgressTick = GetLocalInt(oNpc, DL_L_NPC_MOVE_LAST_PROGRESS_TICK);
    if (nLastProgressTick <= 0)
    {
        DL_RecordMoveJobProgressSample(oNpc, fDistance, nNowTick);
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_DIST_DELTA_DBG, 0.0);
        SetLocalInt(oNpc, DL_L_NPC_MOVE_NO_PROGRESS_COUNT, 0);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_STALL_REASON);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    }
    else
    {
        float fLastDistance = GetLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_DIST);
        float fDelta = fLastDistance - fDistance;
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_DIST_DELTA_DBG, fDelta);

        if (fDelta >= DL_MOVE_PROGRESS_EPSILON)
        {
            DL_ResetMoveJobProgressAfterAdvance(oNpc, fDistance, nNowTick);
        }
        else if (DL_GetMoveJobElapsedSeconds(nNowTick, nLastProgressTick) >= DL_MOVE_NO_PROGRESS_SECONDS)
        {
            DL_ReissueMoveJobAfterNoProgress(oNpc, oTarget, fRadius, fDistance, nNowTick);
            return TRUE;
        }
    }

    if (nCurrentAction != ACTION_MOVETOPOINT || DL_ShouldReissueSleepAction(oNpc, DL_L_NPC_MOVE_TICKET))
    {
        DL_IssueMoveJobAction(oNpc, oTarget);
        SetLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG, TRUE);
    }

    return TRUE;
}

void DL_BeginMoveJobToObject(object oNpc, string sOwner, string sPhase, object oTarget, float fRadius)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget) || sOwner == "" || sPhase == "")
    {
        return;
    }

    if (fRadius <= 0.0)
    {
        fRadius = DL_MOVE_DEFAULT_RADIUS;
    }

    DL_ClearMoveJob(oNpc);
    SetLocalString(oNpc, DL_L_NPC_MOVE_OWNER, sOwner);
    SetLocalString(oNpc, DL_L_NPC_MOVE_PHASE, sPhase);
    SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG, GetTag(oTarget));
    DL_SetMoveJobAreaFromTarget(oNpc, oTarget);
    SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oTarget);
    SetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS, fRadius);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);

    DL_TickMoveJob(oNpc);
}

void DL_BeginMoveJob(object oNpc, string sOwner, string sPhase, string sTargetTag, float fRadius)
{
    if (!GetIsObjectValid(oNpc) || sOwner == "" || sPhase == "" || sTargetTag == "")
    {
        return;
    }

    if (fRadius <= 0.0)
    {
        fRadius = DL_MOVE_DEFAULT_RADIUS;
    }

    DL_ClearMoveJob(oNpc);
    SetLocalString(oNpc, DL_L_NPC_MOVE_OWNER, sOwner);
    SetLocalString(oNpc, DL_L_NPC_MOVE_PHASE, sPhase);
    SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG, sTargetTag);
    SetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS, fRadius);

    object oTarget = DL_ResolveMoveJobTarget(oNpc);
    if (GetIsObjectValid(oTarget))
    {
        DL_BeginMoveJobToObject(oNpc, sOwner, sPhase, oTarget, fRadius);
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    DL_TickMoveJob(oNpc);
}
