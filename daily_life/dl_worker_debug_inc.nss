string DL_GetAreaWorkerPassModeDebugLabel(int nPassMode)
{
    if (nPassMode == 1) return "worker";
    if (nPassMode == 2) return "resync";
    if (nPassMode == 3) return "warm";
    return "unknown";
}

string DL_GetAreaTierDebugLabel(int nTier)
{
    if (nTier == DL_TIER_HOT) return "HOT";
    if (nTier == DL_TIER_WARM) return "WARM";
    if (nTier == DL_TIER_FROZEN) return "FROZEN";
    return "UNKNOWN";
}

void DL_SetAreaHotnessDebug(object oArea, int nCachedPlayers, int nActualPlayers, int nTierBefore, int nTierAfter, int bHotnessRepaired, int bForcedHotDueToPlayer, int bStaleRepaired)
{
    if (!GetIsObjectValid(oArea)) { return; }
    SetLocalInt(oArea, "area_cached_player_count", nCachedPlayers);
    SetLocalInt(oArea, "area_actual_player_count", nActualPlayers);
    SetLocalString(oArea, "area_tier_before_lifecycle", DL_GetAreaTierDebugLabel(nTierBefore));
    SetLocalString(oArea, "area_tier_after_lifecycle", DL_GetAreaTierDebugLabel(nTierAfter));
    SetLocalInt(oArea, "area_hotness_repaired", bHotnessRepaired);
    SetLocalInt(oArea, "area_worker_forced_hot_due_to_player", bForcedHotDueToPlayer);
    SetLocalInt(oArea, "area_player_count_stale_repaired", bStaleRepaired);
}

void DL_CopyAreaHotnessDebugToNpc(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea)) { return; }
    SetLocalInt(oNpc, "area_cached_player_count", GetLocalInt(oArea, "area_cached_player_count"));
    SetLocalInt(oNpc, "area_actual_player_count", GetLocalInt(oArea, "area_actual_player_count"));
    SetLocalString(oNpc, "area_tier_before_lifecycle", GetLocalString(oArea, "area_tier_before_lifecycle"));
    SetLocalString(oNpc, "area_tier_after_lifecycle", GetLocalString(oArea, "area_tier_after_lifecycle"));
    SetLocalInt(oNpc, "area_hotness_repaired", GetLocalInt(oArea, "area_hotness_repaired"));
    SetLocalInt(oNpc, "area_worker_forced_hot_due_to_player", GetLocalInt(oArea, "area_worker_forced_hot_due_to_player"));
    SetLocalInt(oNpc, "area_player_count_stale_repaired", GetLocalInt(oArea, "area_player_count_stale_repaired"));
    SetLocalInt(oNpc, "area_hotness_bug_player_present", GetLocalInt(oArea, "area_hotness_bug_player_present"));
}

void DL_ClearCriticalWorkerDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) { return; }
    SetLocalInt(oNpc, "critical_worker_touch", FALSE);
    DeleteLocalString(oNpc, "critical_reason");
}

void DL_SetCriticalWorkerDebug(object oNpc, string sReason)
{
    if (!GetIsObjectValid(oNpc)) { return; }
    SetLocalInt(oNpc, "critical_worker_touch", TRUE);
    SetLocalString(oNpc, "critical_reason", sReason);
}

void DL_SetCriticalProcessFailedDebug(object oNpc, object oArea, int nSlot, int nCount, int nPassMode, string sReason)
{
    if (!GetIsObjectValid(oNpc)) { return; }
    SetLocalInt(oNpc, "critical_seen_but_not_touched", TRUE);
    SetLocalString(oNpc, "critical_process_failed_reason", sReason);
    SetLocalInt(oNpc, "critical_slot", nSlot);
    if (GetIsObjectValid(oArea)) SetLocalString(oNpc, "critical_area", GetTag(oArea));
    else SetLocalString(oNpc, "critical_area", "");
    SetLocalInt(oNpc, "critical_registry_count", nCount);
    SetLocalString(oNpc, "critical_pass_mode", DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    DL_BsmithTraceStage(oNpc, "WORKER_SKIP", "reason=critical_seen_but_not_touched critical_process_failed_reason=" + sReason + " critical_slot=" + IntToString(nSlot) + " critical_area=" + GetLocalString(oNpc, "critical_area") + " critical_registry_count=" + IntToString(nCount) + " critical_pass_mode=" + DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
}

void DL_ClearCriticalProcessFailedDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) { return; }
    SetLocalInt(oNpc, "critical_seen_but_not_touched", FALSE);
    DeleteLocalString(oNpc, "critical_process_failed_reason");
    DeleteLocalInt(oNpc, "critical_slot");
    DeleteLocalString(oNpc, "critical_area");
    DeleteLocalInt(oNpc, "critical_registry_count");
    DeleteLocalString(oNpc, "critical_pass_mode");
}

void DL_SetAreaWorkerPassDebug(object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter)
{
    if (!GetIsObjectValid(oArea)) { return; }
    SetLocalString(oArea, "area_worker_tick_area", GetTag(oArea));
    SetLocalInt(oArea, "area_worker_tick_seq", nTickStamp);
    SetLocalString(oArea, "area_worker_pass_mode", DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    SetLocalInt(oArea, "area_worker_budget", nBudget);
    SetLocalInt(oArea, "area_worker_cursor_before", nCursorBefore);
    SetLocalInt(oArea, "area_worker_cursor_after", nCursorAfter);
}

void DL_SetNpcRegularWorkerDebug(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter, int bSeenByRoundRobin, int bProcessedByRoundRobin, string sSkipReason)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea)) { return; }
    if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
    {
        DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nCursorBefore);
        return;
    }
    int nSlot = GetLocalInt(oNpc, DL_L_NPC_REG_SLOT);
    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    int bSlotContainsSelf = FALSE;
    if (nSlot >= 0 && nSlot < nCount) bSlotContainsSelf = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot) == oNpc;
    SetLocalString(oNpc, "area_worker_tick_area", GetTag(oArea));
    SetLocalInt(oNpc, "area_worker_tick_seq", nTickStamp);
    SetLocalString(oNpc, "area_worker_pass_mode", DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    SetLocalInt(oNpc, "area_worker_budget", nBudget);
    SetLocalInt(oNpc, "area_worker_cursor_before", nCursorBefore);
    SetLocalInt(oNpc, "area_worker_cursor_after", nCursorAfter);
    SetLocalInt(oNpc, "npc_seen_by_round_robin", bSeenByRoundRobin);
    SetLocalInt(oNpc, "npc_processed_by_round_robin", bProcessedByRoundRobin);
    SetLocalInt(oNpc, "npc_registry_slot", nSlot);
    SetLocalInt(oNpc, "npc_registry_count", nCount);
    SetLocalInt(oNpc, "npc_slot_contains_self", bSlotContainsSelf);
    DL_CopyAreaHotnessDebugToNpc(oNpc, oArea);
    if (sSkipReason == "") DeleteLocalString(oNpc, "npc_touch_skipped_reason");
    else
    {
        SetLocalString(oNpc, "npc_touch_skipped_reason", sSkipReason);
        DL_BsmithTraceStage(oNpc, "WORKER_SKIP", "reason=" + sSkipReason);
    }
}

void DL_TraceAreaWorkerTickForRegisteredNpc(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursor)
{
    if (!GetIsObjectValid(oNpc) || GetTag(oNpc) != "blacksmith01") return;
    string sAreaTag = "";
    if (GetIsObjectValid(oArea)) sAreaTag = GetTag(oArea);
    DL_BsmithTraceStage(oNpc, "AREA_WORKER_TICK", "area=" + sAreaTag + " tick=" + IntToString(nTickStamp) + " pass=" + DL_GetAreaWorkerPassModeDebugLabel(nPassMode) + " budget=" + IntToString(nBudget) + " cursor=" + IntToString(nCursor));
}
