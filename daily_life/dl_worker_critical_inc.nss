int DL_IsRegisteredCurrentAreaStaleReachedMoveCritical(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    if (!DL_HasMoveJob(oNpc))
    {
        return FALSE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) != DL_MOVE_RESULT_RUNNING)
    {
        return FALSE;
    }

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
    {
        return FALSE;
    }

    if (GetArea(oNpc) != oArea)
    {
        return FALSE;
    }

    if (GetLocalObject(oNpc, DL_L_NPC_REG_AREA) != oArea)
    {
        return FALSE;
    }

    return TRUE;
}

// AUDIT(#864): EMERGENCY RECOVERY PATH.
// Keep behavior stable; this path must route back into canonical worker touch flow,
// not replace it with parallel directive/move logic.
int DL_EmergencyTouchCriticalStaleReachedNpc(object oNpc, object oArea, int nPassMode, int nTickStamp, int nSlot, int nCount, string sReason)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return FALSE;
    }

    if (!DL_IsRegisteredCurrentAreaStaleReachedMoveCritical(oNpc, oArea))
    {
        return FALSE;
    }

    if (nSlot < 0 || nSlot >= nCount)
    {
        return FALSE;
    }

    if (DL_GetAreaRegistryNpcAtSlot(oArea, nSlot) != oNpc)
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG, TRUE);
    DL_SetCriticalProcessFailedDebug(oNpc, oArea, nSlot, nCount, nPassMode, sReason);
    DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, DL_WORKER_BUDGET_MIN, nSlot, nSlot, TRUE, FALSE, sReason);
    DL_WorkerTouchNpc(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
    return TRUE;
}


int DL_IsStaleReachedMoveJobCritical(object oNpc)
{
    if (!DL_HasMoveJob(oNpc))
    {
        return FALSE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) != DL_MOVE_RESULT_RUNNING)
    {
        return FALSE;
    }

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
    {
        return FALSE;
    }

    return TRUE;
}

// AUDIT(#864): FALLBACK/EMERGENCY CLASSIFIER.
// This predicate is safety-net logic for stale/contradictory states and should stay
// bounded and diagnosable; avoid broadening without focused evidence.
int DL_NpcNeedsCriticalWorkerTouch(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    DL_ClearCriticalWorkerDebug(oNpc);

    int nStoredDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    int nResolvedDirective = DL_ResolveEffectiveDirective(oNpc, DL_ResolveNpcDirective(oNpc));
    if (nStoredDirective != nResolvedDirective)
    {
        DL_SetCriticalWorkerDebug(oNpc, "directive_changed");
        return TRUE;
    }

    if (DL_HasMoveJob(oNpc))
    {
        if (!DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nResolvedDirective))
        {
            DL_SetCriticalWorkerDebug(oNpc, "move_owner_directive_mismatch");
            return TRUE;
        }

        if (DL_IsStaleReachedMoveJobCritical(oNpc))
        {
            DL_SetCriticalWorkerDebug(oNpc, "stale_reached_without_moveto");
            return TRUE;
        }
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_MOVING_TO_ANCHOR && DL_IsMoveJobAtTargetNow(oNpc))
    {
        DL_SetCriticalWorkerDebug(oNpc, "focus_anchor_reached");
        return TRUE;
    }

    if (GetLocalString(oNpc, "dl_post_jump_result") == DL_POST_JUMP_RESULT_COMPLETE &&
        (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "" ||
            GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "" ||
            GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC) != ""))
    {
        DL_SetCriticalWorkerDebug(oNpc, "stale_transition_after_post_jump");
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC) == DL_DIAG_REGULAR_WORKER_NOT_TOUCHING_REGISTERED_NPC)
    {
        DL_SetCriticalWorkerDebug(oNpc, DL_DIAG_REGULAR_WORKER_NOT_TOUCHING_REGISTERED_NPC);
        return TRUE;
    }

    if (DL_GetNpcProblemSummary(oNpc) == DL_DIAG_REGULAR_WORKER_NOT_TOUCHING_REGISTERED_NPC)
    {
        DL_SetCriticalWorkerDebug(oNpc, DL_DIAG_REGULAR_WORKER_NOT_TOUCHING_REGISTERED_NPC);
        return TRUE;
    }

    return FALSE;
}

object DL_GetAreaWorkerCursorNpc(object oArea)
{
    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        return OBJECT_INVALID;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    return DL_GetAreaRegistryNpcAtSlot(oArea, nCursor);
}


int DL_ProcessCriticalAreaCursorNpc(object oArea, int nPassMode, int nTickStamp, string sBypassKind)
{
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        return FALSE;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    int nAttempts = 0;
    int nSlot = 0;
    object oNpc = OBJECT_INVALID;
    while (nAttempts < nCount)
    {
        nSlot = (nCursor + nAttempts) % nCount;
        oNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);
        if (GetIsObjectValid(oNpc))
        {
            DL_TraceAreaWorkerTickForRegisteredNpc(oNpc, oArea, nTickStamp, nPassMode, DL_WORKER_BUDGET_MIN, nCursor);
            if (DL_IsActivePipelineNpc(oNpc) && GetArea(oNpc) == oArea && GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea)
            {
                if (DL_IsRegisteredCurrentAreaStaleReachedMoveCritical(oNpc, oArea))
                {
                    DL_ClearCriticalProcessFailedDebug(oNpc);
                    SetLocalInt(oNpc, DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG, FALSE);
                    DL_SetCriticalWorkerDebug(oNpc, "stale_reached_without_moveto");
                    if (DL_TouchNpcFromAreaWorker(oNpc, oArea, nPassMode, nTickStamp, DL_WORKER_BUDGET_MIN, nSlot, nSlot))
                    {
                        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
                        return TRUE;
                    }
                    DL_SetCriticalProcessFailedDebug(oNpc, oArea, nSlot, nCount, nPassMode, "critical_stale_area_worker_touch_failed");
                    if (DL_EmergencyTouchCriticalStaleReachedNpc(oNpc, oArea, nPassMode, nTickStamp, nSlot, nCount, "critical_stale_area_worker_touch_failed"))
                    {
                        return TRUE;
                    }
                }
            }
            else if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
            {
                DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nSlot);
                nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
                if (nCount <= 0)
                {
                    return FALSE;
                }
                if (nCursor >= nCount)
                {
                    nCursor = 0;
                }
            }
        }

        nAttempts = nAttempts + 1;
    }

    nAttempts = 0;
    while (nAttempts < nCount)
    {
        nSlot = (nCursor + nAttempts) % nCount;
        oNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);
        if (GetIsObjectValid(oNpc))
        {
            DL_TraceAreaWorkerTickForRegisteredNpc(oNpc, oArea, nTickStamp, nPassMode, DL_WORKER_BUDGET_MIN, nCursor);
            if (DL_IsActivePipelineNpc(oNpc) && GetArea(oNpc) == oArea && GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea)
            {
                if (DL_NpcNeedsCriticalWorkerTouch(oNpc))
                {
                    string sCriticalReason = GetLocalString(oNpc, DL_L_NPC_CRITICAL_REASON_DBG);
                    if (sCriticalReason == "")
                    {
                        sCriticalReason = "critical_worker_touch";
                    }
                    if (sBypassKind == "warm")
                    {
                        SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, TRUE);
                    }
                    else if (sBypassKind == "budget")
                    {
                        SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, TRUE);
                    }

                    DL_ClearCriticalProcessFailedDebug(oNpc);
                    SetLocalInt(oNpc, DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG, FALSE);
                    if (DL_ProcessAreaNpcByPassMode(oArea, oNpc, nPassMode, nTickStamp, DL_WORKER_BUDGET_MIN, nSlot, nSlot))
                    {
                        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
                        return TRUE;
                    }
                    DL_SetCriticalProcessFailedDebug(oNpc, oArea, nSlot, nCount, nPassMode, "critical_process_failed");
                    if (DL_EmergencyTouchCriticalStaleReachedNpc(oNpc, oArea, nPassMode, nTickStamp, nSlot, nCount, "critical_process_failed"))
                    {
                        return TRUE;
                    }
                }
            }
            else if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
            {
                DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nSlot);
                nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
                if (nCount <= 0)
                {
                    return FALSE;
                }
                if (nCursor >= nCount)
                {
                    nCursor = 0;
                }
            }
        }

        nAttempts = nAttempts + 1;
    }

    return FALSE;
}
