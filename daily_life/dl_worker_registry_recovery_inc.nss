int DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(object oArea, object oNpc, int nSlot)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNpc))
    {
        return FALSE;
    }
    // Registry owner path: physical stale removal + slot-repair live in dl_registry_inc.
    // Worker keeps only bounded call-site context/routing.
    return DL_RemoveStaleNpcReferenceFromAreaRegistry(oArea, oNpc);
}

int DL_IsNpcRegistryOwnerForArea(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    return GetArea(oNpc) == oArea && GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea;
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
        GetLocalString(oNpc, "dl_transition_registry_problem") == DL_TRANSITION_REGISTRY_PROBLEM_TARGET_AREA_WORKER_NOT_TICKING_OR_NOT_OWNING_NPC)
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
