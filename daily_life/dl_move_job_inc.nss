// Canonical Daily Life local movement job controller.
// Movement directives own presentation state; this job owns generic movement
// lifecycle: target resolution, reach checks, action reissue, and failure state.

const int DL_MOVE_TARGET_SEARCH_CAP = 64;
const float DL_MOVE_DEFAULT_RADIUS = 1.60;
const string DL_L_NPC_MOVE_REACHED_FINALIZED_DBG = "move_reached_finalized";
const string DL_L_NPC_REACHED_MOVE_OWNER_DBG = "reached_move_owner";
const string DL_L_NPC_REACHED_MOVE_TARGET_DBG = "reached_move_target";

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
    object oCached = GetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ);
    if (GetIsObjectValid(oCached) && GetTag(oCached) == sTargetTag)
    {
        object oCachedArea = GetArea(oCached);
        if (sTargetArea == "" || (GetIsObjectValid(oCachedArea) && GetTag(oCachedArea) == sTargetArea))
        {
            return oCached;
        }
    }
    DeleteLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ);

    object oNpcArea = GetArea(oNpc);
    object oFallback = OBJECT_INVALID;
    int nIndex = 0;
    while (nIndex < DL_MOVE_TARGET_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTargetTag, nIndex);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        object oCandidateArea = GetArea(oCandidate);
        if (sTargetArea != "")
        {
            if (GetIsObjectValid(oCandidateArea) && GetTag(oCandidateArea) == sTargetArea)
            {
                SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oCandidate);
                return oCandidate;
            }
        }
        else if (GetIsObjectValid(oNpcArea) && oCandidateArea == oNpcArea)
        {
            SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oCandidate);
            return oCandidate;
        }
        else if (!GetIsObjectValid(oFallback))
        {
            oFallback = oCandidate;
        }

        nIndex = nIndex + 1;
    }

    if (GetIsObjectValid(oFallback))
    {
        SetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ, oFallback);
    }
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

    if (GetDistanceBetween(oNpc, oTarget) <= fRadius)
    {
        SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_OWNER_DBG, GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER));
        SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_TARGET_DBG, GetTag(oTarget));
        SetLocalInt(oNpc, DL_L_NPC_MOVE_REACHED_FINALIZED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_REACHED);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        DL_ClearTransitionExecutionState(oNpc);
        return TRUE;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);

    if (GetCurrentAction(oNpc) != ACTION_MOVETOPOINT || DL_ShouldReissueSleepAction(oNpc, DL_L_NPC_MOVE_TICKET))
    {
        DL_IssueMoveJobAction(oNpc, oTarget);
    }

    return TRUE;
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

    int bSameJob = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == sOwner &&
                   GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == sPhase &&
                   GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sTargetTag;

    if (!bSameJob)
    {
        DL_ClearMoveJob(oNpc);
        SetLocalString(oNpc, DL_L_NPC_MOVE_OWNER, sOwner);
        SetLocalString(oNpc, DL_L_NPC_MOVE_PHASE, sPhase);
        SetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG, sTargetTag);
        SetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS, fRadius);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);
    }
    else if (DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_FAILED)
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_RUNNING);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    }

    object oTarget = DL_ResolveMoveJobTarget(oNpc);
    if (GetIsObjectValid(oTarget))
    {
        DL_SetMoveJobAreaFromTarget(oNpc, oTarget);
    }

    DL_TickMoveJob(oNpc);
}
