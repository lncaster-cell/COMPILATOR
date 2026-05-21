string DL_GetAreaWorkerPassModeDebugLabel(int nPassMode)
{
    if (nPassMode == DL_AREA_PASS_MODE_WORKER) return "worker";
    if (nPassMode == DL_AREA_PASS_MODE_RESYNC) return "resync";
    if (nPassMode == DL_AREA_PASS_MODE_WARM) return "warm";
    return "unknown";
}

string DL_GetAreaTierDebugLabel(int nTier)
{
    if (nTier == DL_TIER_HOT) return "HOT";
    if (nTier == DL_TIER_WARM) return "WARM";
    if (nTier == DL_TIER_FROZEN) return "FROZEN";
    return "UNKNOWN";
}

void DL_SetAreaHotnessDebug(
    object oArea,
    int nCachedPlayers,
    int nActualPlayers,
    int nTierBefore,
    int nTierAfter,
    int bHotnessRepaired,
    int bForcedHotDueToPlayer,
    int bStaleRepaired
)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oArea, DL_L_AREA_CACHED_PLAYER_COUNT_DBG, nCachedPlayers);
    SetLocalInt(oArea, DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG, nActualPlayers);
    SetLocalString(oArea, DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG, DL_GetAreaTierDebugLabel(nTierBefore));
    SetLocalString(oArea, DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG, DL_GetAreaTierDebugLabel(nTierAfter));
    SetLocalInt(oArea, DL_L_AREA_HOTNESS_REPAIRED_DBG, bHotnessRepaired);
    SetLocalInt(oArea, DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG, bForcedHotDueToPlayer);
    SetLocalInt(oArea, DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG, bStaleRepaired);
}

void DL_CopyAreaHotnessDebugToNpc(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_AREA_CACHED_PLAYER_COUNT_DBG, GetLocalInt(oArea, DL_L_AREA_CACHED_PLAYER_COUNT_DBG));
    SetLocalInt(oNpc, DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG, GetLocalInt(oArea, DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG));
    SetLocalString(oNpc, DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG, GetLocalString(oArea, DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG));
    SetLocalString(oNpc, DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG, GetLocalString(oArea, DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG));
    SetLocalInt(oNpc, DL_L_AREA_HOTNESS_REPAIRED_DBG, GetLocalInt(oArea, DL_L_AREA_HOTNESS_REPAIRED_DBG));
    SetLocalInt(oNpc, DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG, GetLocalInt(oArea, DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG));
    SetLocalInt(oNpc, DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG, GetLocalInt(oArea, DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG));
    SetLocalInt(oNpc, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG, GetLocalInt(oArea, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG));
}

void DL_ClearCriticalWorkerDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_WORKER_TOUCH_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_REASON_DBG);
}

void DL_SetCriticalWorkerDebug(object oNpc, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_WORKER_TOUCH_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_CRITICAL_REASON_DBG, sReason);
}

void DL_SetCriticalProcessFailedDebug(object oNpc, object oArea, int nSlot, int nCount, int nPassMode, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_SEEN_NOT_TOUCHED_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_CRITICAL_PROCESS_FAILED_REASON_DBG, sReason);
    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_SLOT_DBG, nSlot);
    if (GetIsObjectValid(oArea))
    {
        SetLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG, GetTag(oArea));
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG, "");
    }
    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_REGISTRY_COUNT_DBG, nCount);
    SetLocalString(oNpc, DL_L_NPC_CRITICAL_PASS_MODE_DBG, DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
}

void DL_ClearCriticalProcessFailedDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_SEEN_NOT_TOUCHED_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_PROCESS_FAILED_REASON_DBG);
    DeleteLocalInt(oNpc, DL_L_NPC_CRITICAL_SLOT_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG);
    DeleteLocalInt(oNpc, DL_L_NPC_CRITICAL_REGISTRY_COUNT_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_PASS_MODE_DBG);
}

void DL_SetAreaWorkerPassDebug(object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalString(oArea, DL_L_AREA_WORKER_TICK_AREA_DBG, GetTag(oArea));
    SetLocalInt(oArea, DL_L_AREA_WORKER_TICK_SEQ_DBG, nTickStamp);
    SetLocalString(oArea, DL_L_AREA_WORKER_PASS_MODE_DBG, DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    SetLocalInt(oArea, DL_L_AREA_WORKER_BUDGET_DBG, nBudget);
    SetLocalInt(oArea, DL_L_AREA_WORKER_CURSOR_BEFORE_DBG, nCursorBefore);
    SetLocalInt(oArea, DL_L_AREA_WORKER_CURSOR_AFTER_DBG, nCursorAfter);
}

void DL_SetNpcRegularWorkerDebug(
    object oNpc,
    object oArea,
    int nTickStamp,
    int nPassMode,
    int nBudget,
    int nCursorBefore,
    int nCursorAfter,
    int bSeenByRoundRobin,
    int bProcessedByRoundRobin,
    string sSkipReason
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return;
    }

    if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
    {
        DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nCursorBefore);
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
    SetLocalString(oNpc, DL_L_AREA_WORKER_PASS_MODE_DBG, DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    SetLocalInt(oNpc, DL_L_AREA_WORKER_BUDGET_DBG, nBudget);
    SetLocalInt(oNpc, DL_L_AREA_WORKER_CURSOR_BEFORE_DBG, nCursorBefore);
    SetLocalInt(oNpc, DL_L_AREA_WORKER_CURSOR_AFTER_DBG, nCursorAfter);
    SetLocalInt(oNpc, DL_L_NPC_SEEN_BY_RR_DBG, bSeenByRoundRobin);
    SetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG, bProcessedByRoundRobin);
    SetLocalInt(oNpc, DL_L_NPC_REGISTRY_SLOT_DBG, nSlot);
    SetLocalInt(oNpc, DL_L_NPC_REGISTRY_COUNT_DBG, nCount);
    SetLocalInt(oNpc, DL_L_NPC_SLOT_CONTAINS_SELF_DBG, bSlotContainsSelf);
    DL_CopyAreaHotnessDebugToNpc(oNpc, oArea);
    if (sSkipReason == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_TOUCH_SKIPPED_REASON_DBG);
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_TOUCH_SKIPPED_REASON_DBG, sSkipReason);
    }
}

void DL_TraceAreaWorkerTickForRegisteredNpc(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursor)
{
    // INTENTIONAL NO-OP CONTRACT (2026-05 stage):
    // Keep this shim as a stable callsite target for critical-worker instrumentation hooks.
    // Runtime diagnostics for worker touch/reached/finalize invariants are owned by
    // DL_SetNpcRegularWorkerDebug and related debug-local writers, so this function must
    // not emit alternate tracing that could duplicate or conflict with active invariants.
}
