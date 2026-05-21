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
        SetLocalString(oNpc, "dl_transition_registry_problem", DL_TRANSITION_REGISTRY_PROBLEM_TARGET_AREA_WORKER_NOT_TICKING_OR_NOT_OWNING_NPC);
    }
    else if (GetLocalString(oNpc, "dl_transition_registry_problem") == DL_TRANSITION_REGISTRY_PROBLEM_TARGET_AREA_WORKER_NOT_TICKING_OR_NOT_OWNING_NPC)
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
            if (oNpcArea == oArea)
            {
                SetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG, FALSE);
                DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, DL_AREA_PASS_MODE_WORKER, 0, 0, 0, FALSE, FALSE, "");
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
