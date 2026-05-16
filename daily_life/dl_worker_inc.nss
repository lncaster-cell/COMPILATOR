const string DL_L_MODULE_WORKER_SEQ = "dl_module_worker_seq";
const string DL_L_MODULE_WORKER_TICKS = "dl_module_worker_ticks";
const string DL_L_MODULE_WORKER_LAST_PROCESSED = "dl_module_worker_last_processed";
const string DL_L_MODULE_RESYNC_LAST_PROCESSED = "dl_module_resync_last_processed";
const string DL_L_AREA_WORKER_LAST_PROCESSED = "dl_area_worker_last_processed";
const string DL_L_AREA_RESYNC_LAST_PROCESSED = "dl_area_resync_last_processed";
const string DL_L_NPC_LAST_TOUCH_TICK = "dl_npc_last_touch_tick";
const string DL_L_AREA_WORKER_TICK_AREA_DBG = "area_worker_tick_area";
const string DL_L_AREA_WORKER_TICK_SEQ_DBG = "area_worker_tick_seq";
const string DL_L_NPC_WORKER_TOUCH_SEQ_DBG = "npc_worker_touch_seq";
const string DL_L_NPC_LAST_WORKER_TOUCH_HOUR_DBG = "npc_last_worker_touch_hour";
const string DL_L_NPC_LAST_WORKER_TOUCH_MINUTE_DBG = "npc_last_worker_touch_minute";
const string DL_L_NPC_LAST_WORKER_TOUCH_ABS_MIN_DBG = "npc_last_worker_touch_abs_minute";
const string DL_L_NPC_PROCESSED_BY_RR_DBG = "npc_processed_by_round_robin";
const string DL_L_NPC_REGISTRY_SLOT_DBG = "npc_registry_slot";
const string DL_L_NPC_REGISTRY_COUNT_DBG = "npc_registry_count";
const string DL_L_NPC_SLOT_CONTAINS_SELF_DBG = "npc_slot_contains_self";

const int DL_AREA_PASS_MODE_WORKER = 1;
const int DL_AREA_PASS_MODE_RESYNC = 2;
const int DL_AREA_PASS_MODE_WARM = 3;
const string DL_L_AREA_PASS_LAST_CANDIDATES = "dl_area_pass_last_candidates";
const string DL_L_AREA_PASS_FALLBACK_COUNT = "dl_area_pass_fallback_count";
const string DL_L_MODULE_PASS_FALLBACK_COUNT = "dl_module_pass_fallback_count";
const string DL_L_AREA_PASS_FALLBACK_LAST_TICK = "dl_area_pass_fallback_last_tick";
const string DL_L_AREA_REGISTRY_REBUILD_PENDING = "dl_area_registry_rebuild_pending";
const string DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR = "dl_area_registry_rebuild_obj_cursor";
const string DL_L_AREA_REGISTRY_REPAIR_CURSOR = "dl_area_registry_repair_cursor";
const string DL_L_AREA_TRANSITION_HANDOFF_SLOT_PREFIX = "dl_area_transition_handoff_slot_";
const string DL_L_AREA_TRANSITION_HANDOFF_CURSOR = "dl_area_transition_handoff_cursor";

const int DL_FALLBACK_OBJECT_HOP_MULTIPLIER = 8;
const int DL_TRANSITION_HANDOFF_SLOT_COUNT = 4;

void DL_WorkerTouchNpc(object oNpc);

int DL_GetCursorAdvance(int nNpcProcessed, int nCandidatesSeen, int nNpcSeen)
{
    int nAdvance = nNpcProcessed;
    if (nAdvance <= 0)
    {
        // If pass-mode dedupe skipped processing, advance by scanned window size.
        nAdvance = nCandidatesSeen;
    }
    if (nAdvance <= 0)
    {
        // Final safety net to guarantee forward progress.
        nAdvance = 1;
    }

    if (nNpcSeen > 0)
    {
        // Round-robin pass is bounded by registry count; clamp keeps contract explicit.
        nAdvance = DL_ClampInt(nAdvance, 1, nNpcSeen);
    }

    return nAdvance;
}

void DL_MarkAreaRegistryRebuildPending(object oArea)
{
    SetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING, TRUE);
}

void DL_ClearAreaRegistryRebuildPending(object oArea)
{
    DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING);
    DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR);
    DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
}

string DL_GetAreaTransitionHandoffSlotKey(int nSlot)
{
    if (nSlot < 0)
    {
        nSlot = 0;
    }
    return DL_L_AREA_TRANSITION_HANDOFF_SLOT_PREFIX + IntToString(nSlot);
}

void DL_SetTransitionRegistryHandoffDebug(object oNpc, object oOldArea, object oTargetArea)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    object oNpcArea = GetArea(oNpc);
    string sOldArea = "";
    string sTargetArea = "";
    string sRegisteredArea = "";
    string sNpcArea = "";

    if (GetIsObjectValid(oOldArea))
    {
        sOldArea = GetTag(oOldArea);
    }
    else
    {
        sOldArea = GetLocalString(oNpc, "dl_transition_registry_old_area");
    }
    if (GetIsObjectValid(oTargetArea))
    {
        sTargetArea = GetTag(oTargetArea);
    }
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredArea = GetTag(oRegisteredArea);
    }
    if (GetIsObjectValid(oNpcArea))
    {
        sNpcArea = GetTag(oNpcArea);
    }

    SetLocalString(oNpc, "dl_transition_registry_handoff", "transition_registry_handoff");
    SetLocalString(oNpc, "dl_transition_registry_old_area", sOldArea);
    SetLocalString(oNpc, "dl_transition_registry_target_area", sTargetArea);
    SetLocalString(oNpc, "dl_transition_registry_registered_area", sRegisteredArea);
    SetLocalString(oNpc, "dl_transition_registry_npc_area", sNpcArea);
    SetLocalString(oNpc, "dl_transition_registry_npc_tag", GetTag(oNpc));
    SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredArea);
    SetLocalString(oNpc, "dl_transition_registry_current_physical_area", sNpcArea);
    SetLocalString(oNpc, "dl_transition_registry_registry_area_before_repair", GetLocalString(oNpc, "dl_registry_area_before_repair"));
    SetLocalString(oNpc, "dl_transition_registry_registry_area_after_repair", GetLocalString(oNpc, "dl_registry_area_after_repair"));
    SetLocalString(oNpc, "dl_transition_registry_worker_touch_area", GetLocalString(oNpc, "dl_worker_touch_area"));
    SetLocalInt(oNpc, "dl_transition_registry_repair_current_tick", GetLocalInt(oNpc, "dl_registry_repair_current_tick"));
    SetLocalInt(oNpc, "dl_transition_registry_repair_owner_changed", GetLocalInt(oNpc, "dl_registry_repair_owner_changed"));
    SetLocalInt(oNpc, "dl_transition_registry_reg_on", GetLocalInt(oNpc, DL_L_NPC_REG_ON));
    SetLocalInt(oNpc, "dl_transition_registry_reg_slot", GetLocalInt(oNpc, DL_L_NPC_REG_SLOT));
    SetLocalInt(oNpc, "dl_transition_registry_rebuild_pending", GetLocalInt(oTargetArea, DL_L_AREA_REGISTRY_REBUILD_PENDING));
    SetLocalInt(oNpc, "dl_transition_registry_resync_pending", GetLocalInt(oTargetArea, DL_L_AREA_ENTER_RESYNC_PENDING));
    if (GetLocalInt(oTargetArea, DL_L_AREA_REGISTRY_REBUILD_PENDING) == TRUE &&
        GetLocalString(oNpc, "dl_transition_registry_worker_tick_area") != sTargetArea)
    {
        SetLocalString(oNpc, "dl_transition_registry_problem", "target_area_worker_not_ticking_or_not_owning_npc");
    }
    else if (GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc")
    {
        DeleteLocalString(oNpc, "dl_transition_registry_problem");
    }
}

void DL_QueueTransitionRegistryHandoff(object oTargetArea, object oNpc)
{
    if (!DL_IsAreaObject(oTargetArea) || !GetIsObjectValid(oNpc))
    {
        return;
    }

    int nSlot = -1;
    int i = 0;
    while (i < DL_TRANSITION_HANDOFF_SLOT_COUNT)
    {
        object oQueued = GetLocalObject(oTargetArea, DL_GetAreaTransitionHandoffSlotKey(i));
        if (oQueued == oNpc)
        {
            nSlot = i;
            i = DL_TRANSITION_HANDOFF_SLOT_COUNT;
        }
        else if (nSlot < 0 && !GetIsObjectValid(oQueued))
        {
            nSlot = i;
        }
        i = i + 1;
    }

    if (nSlot < 0)
    {
        nSlot = GetLocalInt(oTargetArea, DL_L_AREA_TRANSITION_HANDOFF_CURSOR);
        if (nSlot < 0 || nSlot >= DL_TRANSITION_HANDOFF_SLOT_COUNT)
        {
            nSlot = 0;
        }
        SetLocalInt(oTargetArea, DL_L_AREA_TRANSITION_HANDOFF_CURSOR, (nSlot + 1) % DL_TRANSITION_HANDOFF_SLOT_COUNT);
    }

    SetLocalObject(oTargetArea, DL_GetAreaTransitionHandoffSlotKey(nSlot), oNpc);
}

void DL_RequestTransitionRegistryHandoff(object oNpc, object oOldArea, object oTargetArea)
{
    if (!GetIsObjectValid(oNpc) || !DL_IsAreaObject(oTargetArea))
    {
        return;
    }

    DL_MarkAreaRegistryRebuildPending(oTargetArea);
    DL_QueueTransitionRegistryHandoff(oTargetArea, oNpc);

    DL_EnsureAreaPlayerCountSeeded(oTargetArea);
    if (DL_GetAreaTier(oTargetArea) == DL_TIER_HOT || DL_GetAreaPlayerCount(oTargetArea) > 0)
    {
        DL_TransitionAreaToHot(oTargetArea, TRUE);
    }

    DL_SetTransitionRegistryHandoffDebug(oNpc, oOldArea, oTargetArea);
}

void DL_RepairAreaRegistrySlot(object oArea, int nSlot, int nCount)
{
    int nLastSlot = nCount - 1;
    object oTailNpc = OBJECT_INVALID;
    if (nSlot != nLastSlot)
    {
        oTailNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nLastSlot);
    }

    DL_DeleteAreaRegistrySlot(oArea, nLastSlot);

    if (nSlot != nLastSlot)
    {
        DL_SetAreaRegistryNpcAtSlot(oArea, nSlot, oTailNpc);
        if (GetIsObjectValid(oTailNpc))
        {
            SetLocalInt(oTailNpc, DL_L_NPC_REG_SLOT, nSlot);
            SetLocalObject(oTailNpc, DL_L_NPC_REG_AREA, oArea);
        }
    }

    SetLocalInt(oArea, DL_L_AREA_REG_COUNT, nLastSlot);
    SetLocalInt(oArea, DL_L_AREA_REG_SEQ, GetLocalInt(oArea, DL_L_AREA_REG_SEQ) + 1);
}

void DL_SetNpcRegularWorkerDebug(object oNpc, object oArea, int nTickStamp, int bProcessedByRoundRobin)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return;
    }

    int nSlot = GetLocalInt(oNpc, DL_L_NPC_REG_SLOT);
    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    int bSlotContainsSelf = FALSE;
    if (nSlot >= 0 && nSlot < nCount)
    {
        bSlotContainsSelf = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot) == oNpc;
    }

    SetLocalString(oNpc, DL_L_AREA_WORKER_TICK_AREA_DBG, GetTag(oArea));
    SetLocalInt(oNpc, DL_L_AREA_WORKER_TICK_SEQ_DBG, nTickStamp);
    SetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG, bProcessedByRoundRobin);
    SetLocalInt(oNpc, DL_L_NPC_REGISTRY_SLOT_DBG, nSlot);
    SetLocalInt(oNpc, DL_L_NPC_REGISTRY_COUNT_DBG, nCount);
    SetLocalInt(oNpc, DL_L_NPC_SLOT_CONTAINS_SELF_DBG, bSlotContainsSelf);
}

void DL_ClearStaleTransitionHandoffProblemIfOwned(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oCurrentArea = GetArea(oNpc);
    object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    if (GetLocalString(oNpc, "dl_post_jump_result") == "post_jump_finalizer_complete" &&
        GetIsObjectValid(oCurrentArea) &&
        oRegisteredArea == oCurrentArea &&
        GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc")
    {
        DeleteLocalString(oNpc, "dl_transition_registry_problem");
    }
}

int DL_RunAreaRegistryFallbackIntegrityRepair(object oArea, int nRepairBudget)
{
    if (nRepairBudget < DL_WORKER_BUDGET_MIN)
    {
        nRepairBudget = DL_WORKER_BUDGET_MIN;
    }

    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
        return FALSE;
    }

    int nCursor = GetLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    int nScanned = 0;
    int bMutated = FALSE;
    while (nScanned < nRepairBudget && nCount > 0)
    {
        int nSlot = (nCursor + nScanned) % nCount;
        object oCandidate = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);

        int bSlotValid = GetIsObjectValid(oCandidate) &&
                         GetObjectType(oCandidate) == OBJECT_TYPE_CREATURE &&
                         GetIsPC(oCandidate) == FALSE &&
                         GetIsDM(oCandidate) == FALSE &&
                         GetLocalInt(oCandidate, DL_L_NPC_REG_ON) == TRUE &&
                         GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) == oArea &&
                         GetLocalInt(oCandidate, DL_L_NPC_REG_SLOT) == nSlot;

        if (!bSlotValid)
        {
            DL_RepairAreaRegistrySlot(oArea, nSlot, nCount);
            nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
            bMutated = TRUE;
            if (nCount <= 0)
            {
                nCursor = 0;
                break;
            }
            if (nCursor >= nCount)
            {
                nCursor = 0;
            }
            continue;
        }

        nScanned = nScanned + 1;
    }

    if (nCount > 0)
    {
        SetLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR, (nCursor + nScanned) % nCount);
    }
    else
    {
        DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
    }

    return bMutated;
}

int DL_RunAreaRegistryFallbackCatchupScan(object oArea, int nTickStamp, int nScanBudget)
{
    if (nScanBudget < DL_WORKER_BUDGET_MIN)
    {
        nScanBudget = DL_WORKER_BUDGET_MIN;
    }

    SetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_LAST_TICK, nTickStamp);
    SetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_COUNT, GetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_COUNT) + 1);
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_PASS_FALLBACK_COUNT, GetLocalInt(oModule, DL_L_MODULE_PASS_FALLBACK_COUNT) + 1);

    int nObjCursor = GetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR);
    if (nObjCursor < 0)
    {
        nObjCursor = 0;
    }

    int nObjectHopBudget = nScanBudget * DL_FALLBACK_OBJECT_HOP_MULTIPLIER;
    if (nObjectHopBudget < nScanBudget)
    {
        nObjectHopBudget = nScanBudget;
    }

    object oObj = GetFirstObjectInArea(oArea);
    int nSkipped = 0;
    while (GetIsObjectValid(oObj) && nSkipped < nObjCursor && nSkipped < nObjectHopBudget)
    {
        oObj = GetNextObjectInArea(oArea);
        nSkipped = nSkipped + 1;
    }

    if (nSkipped < nObjCursor && !GetIsObjectValid(oObj))
    {
        nObjCursor = 0;
        oObj = GetFirstObjectInArea(oArea);
    }

    int nVisitedObjects = 0;
    int nScannedActive = 0;
    int bReachedEnd = FALSE;

    while (GetIsObjectValid(oObj) && nScannedActive < nScanBudget && nVisitedObjects < nObjectHopBudget)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_CREATURE && DL_IsActivePipelineNpc(oObj))
        {
            nScannedActive = nScannedActive + 1;
            DL_EnsureNpcRegisteredInCurrentArea(oObj);
        }

        oObj = GetNextObjectInArea(oArea);
        nVisitedObjects = nVisitedObjects + 1;
    }

    if (!GetIsObjectValid(oObj))
    {
        bReachedEnd = TRUE;
    }

    if (bReachedEnd)
    {
        SetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR, 0);
    }
    else
    {
        SetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR, nObjCursor + nVisitedObjects);
    }

    return bReachedEnd;
}

int DL_RunAreaRegistryFallbackRecovery(object oArea, int nTickStamp, int nScanBudget)
{
    if (nScanBudget < DL_WORKER_BUDGET_MIN)
    {
        nScanBudget = DL_WORKER_BUDGET_MIN;
    }

    DL_RunAreaRegistryFallbackIntegrityRepair(oArea, nScanBudget);
    int bCatchupDone = DL_RunAreaRegistryFallbackCatchupScan(oArea, nTickStamp, nScanBudget);
    if (bCatchupDone)
    {
        DL_ClearAreaRegistryRebuildPending(oArea);
    }
    else
    {
        DL_MarkAreaRegistryRebuildPending(oArea);
    }

    return GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
}

int DL_ProcessAreaNpcByPassMode(object oNpc, int nPassMode, int nTickStamp)
{
    if ((nPassMode == DL_AREA_PASS_MODE_WORKER || nPassMode == DL_AREA_PASS_MODE_WARM) &&
        GetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK) == nTickStamp)
    {
        return FALSE;
    }

    if (nPassMode == DL_AREA_PASS_MODE_RESYNC)
    {
        DL_RequestResync(oNpc, DL_RESYNC_AREA_ENTER);
        DL_ProcessResync(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
        return TRUE;
    }

    if (nPassMode == DL_AREA_PASS_MODE_WARM)
    {
        if (!DL_IsActivePipelineNpc(oNpc))
        {
            return FALSE;
        }

        if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
        {
            return FALSE;
        }

        DL_SetNpcRegularWorkerDebug(oNpc, GetArea(oNpc), nTickStamp, TRUE);
        DL_WorkerTouchNpc(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
        return TRUE;
    }

    DL_SetNpcRegularWorkerDebug(oNpc, GetArea(oNpc), nTickStamp, TRUE);
    DL_WorkerTouchNpc(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
    return TRUE;
}

int DL_RunAreaNpcRoundRobinPass(object oArea, int nCursor, int nBudget, int nPassMode, int nTickStamp)
{
    if (nCursor < 0)
    {
        nCursor = 0;
    }

    if (nBudget < DL_WORKER_BUDGET_MIN)
    {
        nBudget = DL_WORKER_BUDGET_MIN;
    }

    int nNpcProcessed = 0;
    int nCandidates = 0;
    int nNpcRegistered = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nNpcRegistered < 0)
    {
        nNpcRegistered = 0;
    }

    // Recovery path only: bounded scan when registry is empty or has stale slots.
    if (nNpcRegistered == 0)
    {
        DL_MarkAreaRegistryRebuildPending(oArea);
        nNpcRegistered = DL_RunAreaRegistryFallbackRecovery(oArea, nTickStamp, nBudget);
        if (nNpcRegistered == 0)
        {
            SetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN, 0);
            SetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES, 0);
            return 0;
        }
    }

    if (nCursor >= nNpcRegistered)
    {
        nCursor = nCursor % nNpcRegistered;
    }

    int nAttempts = 0;
    int bFallbackNeeded = FALSE;
    while (nAttempts < nNpcRegistered && nNpcProcessed < nBudget)
    {
        int nSlot = (nCursor + nAttempts) % nNpcRegistered;
        object oCandidate = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);
        nCandidates = nCandidates + 1;

        if (GetIsObjectValid(oCandidate))
        {
            if (GetObjectType(oCandidate) == OBJECT_TYPE_CREATURE &&
                GetIsPC(oCandidate) == FALSE &&
                GetIsDM(oCandidate) == FALSE &&
                GetLocalInt(oCandidate, DL_L_NPC_REG_ON) == TRUE &&
                GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) == oArea &&
                GetLocalInt(oCandidate, DL_L_NPC_REG_SLOT) == nSlot &&
                DL_IsActivePipelineNpc(oCandidate))
            {
                if (DL_ProcessAreaNpcByPassMode(oCandidate, nPassMode, nTickStamp))
                {
                    nNpcProcessed = nNpcProcessed + 1;
                }
            }
            else if (DL_IsActivePipelineNpc(oCandidate))
            {
                if (GetArea(oCandidate) == oArea)
                {
                    DL_EnsureNpcRegisteredInCurrentArea(oCandidate);
                    if (GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) == oArea &&
                        DL_ProcessAreaNpcByPassMode(oCandidate, nPassMode, nTickStamp))
                    {
                        nNpcProcessed = nNpcProcessed + 1;
                    }
                }
                else
                {
                    DL_EnsureNpcRegisteredInCurrentArea(oCandidate);
                }
                bFallbackNeeded = TRUE;
            }
            else if (GetLocalInt(oCandidate, DL_L_NPC_REG_ON) == TRUE)
            {
                DL_UnregisterNpc(oCandidate);
                bFallbackNeeded = TRUE;
            }
        }
        else
        {
            bFallbackNeeded = TRUE;
        }

        nAttempts = nAttempts + 1;
    }

    if (bFallbackNeeded)
    {
        DL_MarkAreaRegistryRebuildPending(oArea);
    }

    if (nPassMode == DL_AREA_PASS_MODE_WORKER || nPassMode == DL_AREA_PASS_MODE_WARM)
    {
        int nLastCatchupTick = GetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_LAST_TICK);
        int bCatchupDue = GetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING) == TRUE ||
            nLastCatchupTick <= 0 ||
            (nTickStamp >= nLastCatchupTick && (nTickStamp - nLastCatchupTick) >= DL_WARM_MAINTENANCE_INTERVAL_TICKS);
        if (bCatchupDue)
        {
            int nCatchupBudget = nBudget - nNpcProcessed;
            if (nCatchupBudget < DL_WORKER_BUDGET_MIN)
            {
                nCatchupBudget = DL_WORKER_BUDGET_MIN;
            }
            DL_RunAreaRegistryFallbackCatchupScan(oArea, nTickStamp, nCatchupBudget);
            nNpcRegistered = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
        }
    }

    if (GetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING) == TRUE)
    {
        nNpcRegistered = DL_RunAreaRegistryFallbackRecovery(oArea, nTickStamp, nBudget);
    }

    SetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN, nNpcRegistered);
    SetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES, nCandidates);
    return nNpcProcessed;
}

int DL_RunTransitionRegistryHandoffTick(object oArea, int nTickStamp)
{
    if (!DL_IsAreaObject(oArea))
    {
        return 0;
    }

    int nTouched = 0;
    int i = 0;
    while (i < DL_TRANSITION_HANDOFF_SLOT_COUNT)
    {
        string sSlotKey = DL_GetAreaTransitionHandoffSlotKey(i);
        object oNpc = GetLocalObject(oArea, sSlotKey);
        if (GetIsObjectValid(oNpc))
        {
            object oNpcArea = GetArea(oNpc);
            object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
            string sRegisteredAreaBefore = "";
            string sNpcArea = "";
            if (GetIsObjectValid(oRegisteredArea))
            {
                sRegisteredAreaBefore = GetTag(oRegisteredArea);
            }
            if (GetIsObjectValid(oNpcArea))
            {
                sNpcArea = GetTag(oNpcArea);
            }

            SetLocalString(oNpc, "dl_transition_registry_worker_tick_area", GetTag(oArea));
            SetLocalInt(oNpc, "dl_transition_registry_handoff_slot", i);
            SetLocalInt(oNpc, "dl_transition_registry_handoff_seen", TRUE);
            SetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called", FALSE);
            SetLocalString(oNpc, "dl_transition_registry_npc_area", sNpcArea);
            SetLocalString(oNpc, "dl_transition_registry_reg_area_before", sRegisteredAreaBefore);
            SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredAreaBefore);
            DL_SetTransitionRegistryHandoffDebug(oNpc, OBJECT_INVALID, oArea);

            if (oNpcArea == oArea)
            {
                SetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG, FALSE);
                DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, FALSE);
                DL_WorkerTouchNpc(oNpc);
                DL_ClearStaleTransitionHandoffProblemIfOwned(oNpc);
                SetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called", TRUE);
                SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
                oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
                string sRegisteredAreaAfterTouch = "";
                if (GetIsObjectValid(oRegisteredArea))
                {
                    sRegisteredAreaAfterTouch = GetTag(oRegisteredArea);
                }
                SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredAreaAfterTouch);
                DL_SetTransitionRegistryHandoffDebug(oNpc, OBJECT_INVALID, oArea);
                if (oRegisteredArea == oArea)
                {
                    DeleteLocalObject(oArea, sSlotKey);
                    nTouched = nTouched + 1;
                }
                else
                {
                    DL_MarkAreaRegistryRebuildPending(oArea);
                }
            }
            else
            {
                DL_MarkAreaRegistryRebuildPending(oArea);
                DL_SetTransitionRegistryHandoffDebug(oNpc, OBJECT_INVALID, oArea);
            }
        }
        i = i + 1;
    }

    return nTouched;
}

void DL_WorkerTouchNpc(object oNpc)
{
    object oCurrentArea = GetArea(oNpc);
    object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    string sCurrentArea = "";
    string sRegisteredArea = "";
    if (GetIsObjectValid(oCurrentArea))
    {
        sCurrentArea = GetTag(oCurrentArea);
    }
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredArea = GetTag(oRegisteredArea);
    }
    SetLocalString(oNpc, "dl_registry_current_physical_area", sCurrentArea);
    SetLocalString(oNpc, "dl_registry_area_before_repair", sRegisteredArea);
    SetLocalString(oNpc, "dl_worker_touch_area", sCurrentArea);

    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (oRegisteredArea != oCurrentArea)
    {
        if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
        {
            SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "registry_repair_verify_failed");
            DL_MaybeLogNpcDiagnostic(oNpc, "worker_registry_repair", TRUE);
            return;
        }
    }

    if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "registry_repair_verify_failed");
        DL_MaybeLogNpcDiagnostic(oNpc, "worker_registry_repair", TRUE);
        return;
    }

    oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    sRegisteredArea = "";
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredArea = GetTag(oRegisteredArea);
    }
    SetLocalString(oNpc, "dl_registry_area_after_repair", sRegisteredArea);
    DL_SetNpcRegularWorkerDebug(oNpc, oCurrentArea, DL_GetAreaTick(oCurrentArea), GetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG));
    DL_ClearStaleTransitionHandoffProblemIfOwned(oNpc);
    if (GetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC) == "registry_repair_verify_failed")
    {
        DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC);
    }

    object oModule = GetModule();
    int nWorkerSeq = GetLocalInt(oModule, DL_L_MODULE_WORKER_SEQ) + 1;
    SetLocalInt(oModule, DL_L_MODULE_WORKER_SEQ, nWorkerSeq);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_SEQ, nWorkerSeq);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_DBG, nWorkerSeq);
    SetLocalInt(oNpc, DL_L_NPC_LAST_WORKER_TOUCH_HOUR_DBG, GetTimeHour());
    SetLocalInt(oNpc, DL_L_NPC_LAST_WORKER_TOUCH_MINUTE_DBG, GetTimeMinute());
    SetLocalInt(oNpc, DL_L_NPC_LAST_WORKER_TOUCH_ABS_MIN_DBG, DL_GetAbsoluteMinute());

    int nDirective = DL_ResolveNpcDirective(oNpc);
    DL_ApplyDirectiveSkeleton(oNpc, nDirective);

    if (DL_GetNpcProblemSummary(oNpc) != "ok")
    {
        DL_MaybeLogNpcDiagnostic(oNpc, "worker", FALSE);
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_DIAG_LAST_SIG);
    }
}

void DL_RunAreaEnterResyncTick(object oArea)
{
    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (DL_GetAreaTier(oArea) != DL_TIER_HOT)
    {
        return;
    }

    if (GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING) != TRUE)
    {
        return;
    }

    int nBudget = DL_GetAreaResyncBudget(oArea);
    nBudget = DL_ConsumeModuleNpcBudget(nBudget);
    if (nBudget <= 0)
    {
        SetLocalInt(oArea, DL_L_AREA_RESYNC_LAST_PROCESSED, 0);
        object oModuleNoBudget = GetModule();
        SetLocalInt(oModuleNoBudget, DL_L_MODULE_RESYNC_LAST_PROCESSED, 0);
        return;
    }

    int nCursor = GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_CURSOR);
    int nTickStamp = DL_GetAreaTick(oArea);
    int nNpcProcessed = DL_RunAreaNpcRoundRobinPass(oArea, nCursor, nBudget, DL_AREA_PASS_MODE_RESYNC, nTickStamp);
    int nNpcSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN);

    SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_TOUCHED, nNpcProcessed);
    SetLocalInt(oArea, DL_L_AREA_RESYNC_LAST_PROCESSED, nNpcProcessed);
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_RESYNC_LAST_PROCESSED, nNpcProcessed);

    if (nNpcSeen <= 0)
    {
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_CURSOR, 0);
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING, FALSE);
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE, GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE) + 1);
        return;
    }

    int nCandidatesSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES);
    int nCursorAdvance = DL_GetCursorAdvance(nNpcProcessed, nCandidatesSeen, nNpcSeen);
    int nNextCursor = (nCursor + nCursorAdvance) % nNpcSeen;
    SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_CURSOR, nNextCursor);

    if (nNextCursor == 0)
    {
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING, FALSE);
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE, GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE) + 1);
    }
}

void DL_RunAreaWarmMaintenanceTick(object oArea)
{
    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (DL_GetAreaTier(oArea) != DL_TIER_WARM)
    {
        return;
    }

    int nTickStamp = DL_GetAreaTick(oArea);
    int nLastTick = GetLocalInt(oArea, DL_L_AREA_LAST_WARM_MAINT_TICK);
    if (nTickStamp >= nLastTick && (nTickStamp - nLastTick) < DL_WARM_MAINTENANCE_INTERVAL_TICKS)
    {
        return;
    }
    SetLocalInt(oArea, DL_L_AREA_LAST_WARM_MAINT_TICK, nTickStamp);

    int nBudget = DL_WORKER_BUDGET_MIN;
    nBudget = DL_ConsumeModuleNpcBudget(nBudget);
    if (nBudget <= 0)
    {
        SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, 0);
        object oModuleNoBudget = GetModule();
        SetLocalInt(oModuleNoBudget, DL_L_MODULE_WORKER_LAST_PROCESSED, 0);
        return;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    int nNpcProcessed = DL_RunAreaNpcRoundRobinPass(oArea, nCursor, nBudget, DL_AREA_PASS_MODE_WARM, nTickStamp);
    int nNpcSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN);

    if (nNpcSeen <= 0)
    {
        DL_SetAreaWorkerCursor(oArea, 0);
    }
    else
    {
        int nCandidatesSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES);
        int nCursorAdvance = DL_GetCursorAdvance(nNpcProcessed, nCandidatesSeen, nNpcSeen);
        DL_SetAreaWorkerCursor(oArea, (nCursor + nCursorAdvance) % nNpcSeen);
    }

    SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, nNpcProcessed);
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_WORKER_LAST_PROCESSED, nNpcProcessed);
}

void DL_RunAreaWorkerTick(object oArea)
{
    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    int nAreaTickSeq = DL_AdvanceAreaTick(oArea);
    SetLocalString(oArea, DL_L_AREA_WORKER_TICK_AREA_DBG, GetTag(oArea));
    SetLocalInt(oArea, DL_L_AREA_WORKER_TICK_SEQ_DBG, nAreaTickSeq);
    DL_BootstrapAreaTier(oArea);
    DL_MaybeReconcileAreaPlayerCount(oArea);
    DL_UpdateAreaTierLifecycle(oArea);

    int nHandoffTouched = DL_RunTransitionRegistryHandoffTick(oArea, DL_GetAreaTick(oArea));

    int nTier = DL_GetAreaTier(oArea);
    if (nTier == DL_TIER_FROZEN)
    {
        return;
    }
    if (nTier == DL_TIER_WARM)
    {
        DL_RunAreaWarmMaintenanceTick(oArea);
        return;
    }

    DL_RunAreaEnterResyncTick(oArea);

    int nBudget = DL_GetAreaWorkerBudget(oArea);
    nBudget = DL_ConsumeModuleNpcBudget(nBudget);
    if (nBudget <= 0)
    {
        object oModuleNoBudget = GetModule();
        SetLocalInt(oModuleNoBudget, DL_L_MODULE_WORKER_TICKS, GetLocalInt(oModuleNoBudget, DL_L_MODULE_WORKER_TICKS) + 1);
        SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, 0);
        SetLocalInt(oModuleNoBudget, DL_L_MODULE_WORKER_LAST_PROCESSED, 0);
        return;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    int nTickStamp = DL_GetAreaTick(oArea);
    int nNpcProcessed = DL_RunAreaNpcRoundRobinPass(oArea, nCursor, nBudget, DL_AREA_PASS_MODE_WORKER, nTickStamp) + nHandoffTouched;
    int nNpcSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN);

    if (nNpcSeen <= 0)
    {
        DL_SetAreaWorkerCursor(oArea, 0);
    }
    else
    {
        int nCandidatesSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES);
        int nCursorAdvance = DL_GetCursorAdvance(nNpcProcessed, nCandidatesSeen, nNpcSeen);
        DL_SetAreaWorkerCursor(oArea, (nCursor + nCursorAdvance) % nNpcSeen);
    }

    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_WORKER_TICKS, GetLocalInt(oModule, DL_L_MODULE_WORKER_TICKS) + 1);
    SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, nNpcProcessed);
    SetLocalInt(oModule, DL_L_MODULE_WORKER_LAST_PROCESSED, nNpcProcessed);
}
