const string DL_L_NPC_BLOCKED_DIAGNOSTIC = "dl_npc_blocked_diagnostic";
const string DL_L_NPC_DIAG_LAST_SIG = "dl_npc_diag_last_sig";

string DL_GetDirectiveLabel(int nDirective)
{
    if (nDirective == DL_DIR_NONE)
    {
        return "none";
    }
    if (nDirective == DL_DIR_SLEEP)
    {
        return "sleep";
    }
    if (nDirective == DL_DIR_WORK)
    {
        return "work";
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return "social";
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return "meal";
    }
    if (nDirective == DL_DIR_PUBLIC)
    {
        return "public";
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return "chill";
    }
    return "none";
}

string DL_GetNpcProblemSummary(object oNpc)
{
    object oCurrentArea = GetArea(oNpc);
    object oRegisteredArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    if (GetLocalString(oNpc, "dl_post_jump_result") == "post_jump_finalizer_complete" &&
        GetIsObjectValid(oCurrentArea) &&
        oRegisteredArea == oCurrentArea &&
        GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc")
    {
        DeleteLocalString(oNpc, "dl_transition_registry_problem");
    }

    if (GetIsObjectValid(oCurrentArea) &&
        oCurrentArea != oRegisteredArea)
    {
        return "registry_area_mismatch";
    }

    int nStoredDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    int nResolvedDirective = DL_ResolveEffectiveDirective(oNpc, DL_ResolveNpcDirective(oNpc));
    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nLastWorkerAbsMin = GetLocalInt(oNpc, "npc_last_worker_touch_abs_minute");
    int nAreaTick = 0;
    if (GetIsObjectValid(oCurrentArea))
    {
        nAreaTick = GetLocalInt(oCurrentArea, "dl_worker_tick");
    }
    int nNpcWorkerTick = GetLocalInt(oNpc, "area_worker_tick_seq");
    if (nResolvedDirective != nStoredDirective &&
        GetIsObjectValid(oCurrentArea) &&
        oRegisteredArea == oCurrentArea &&
        DL_IsActivePipelineNpc(oNpc) &&
        ((nAreaTick > 0 && nNpcWorkerTick > 0 && (nAreaTick - nNpcWorkerTick) > 1) ||
            (nLastWorkerAbsMin > 0 && (nNowAbsMin - nLastWorkerAbsMin) > 1)))
    {
        return "regular_worker_not_touching_registered_npc";
    }

    string sHandoffDiag = GetLocalString(oNpc, "dl_transition_registry_problem");
    if (sHandoffDiag != "")
    {
        return sHandoffDiag;
    }

    if (nResolvedDirective != nStoredDirective)
    {
        return "directive_mismatch:" + DL_GetDirectiveLabel(nStoredDirective) + "->" + DL_GetDirectiveLabel(nResolvedDirective);
    }

    if (DL_HasMoveJob(oNpc) && !DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nStoredDirective))
    {
        return "move_owner_directive_mismatch:" + GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) + "->" + DL_GetDirectiveLabel(nStoredDirective);
    }

    if (!DL_IsFocusStateCompatibleWithDirective(oNpc, nStoredDirective))
    {
        return "focus_directive_mismatch:" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) + "->" + DL_GetDirectiveLabel(nStoredDirective);
    }

    string sMoveDiag = GetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    if (sMoveDiag != "")
    {
        return "move:" + sMoveDiag;
    }

    string sTransitionDiag = GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
    if (sTransitionDiag != "")
    {
        return "transition:" + sTransitionDiag;
    }

    string sSleepDiag = GetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    if (sSleepDiag != "")
    {
        return "sleep:" + sSleepDiag;
    }

    string sWorkDiag = GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    if (sWorkDiag != "")
    {
        return "work:" + sWorkDiag;
    }

    string sFocusDiag = GetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    if (sFocusDiag != "")
    {
        return "focus:" + sFocusDiag;
    }

    string sBlockedDiag = GetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC);
    if (sBlockedDiag != "")
    {
        return "blocked:" + sBlockedDiag;
    }

    string sMoveResult = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    if (sMoveResult != "" && sMoveResult != DL_MOVE_RESULT_REACHED)
    {
        return "move_status:" + sMoveResult;
    }

    string sTransitionStatus = GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    if (sTransitionStatus == "transitioning" &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == "" &&
        !DL_HasMoveJob(oNpc) &&
        DL_HasDistantSameAreaDirectiveAnchor(oNpc, GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE)))
    {
        return "transitioning_no_focus_move_anchor";
    }
    if (sTransitionStatus != "" && sTransitionStatus != "transitioning")
    {
        return "transition_status:" + sTransitionStatus;
    }

    string sSleepStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    if (sSleepStatus != "" && sSleepStatus != "on_bed")
    {
        return "sleep_status:" + sSleepStatus;
    }

    string sWorkStatus = GetLocalString(oNpc, DL_L_NPC_WORK_STATUS);
    if (sWorkStatus != "" && sWorkStatus != "on_anchor")
    {
        return "work_status:" + sWorkStatus;
    }

    string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    if (sFocusStatus != "" &&
        sFocusStatus != "on_chill_anchor" &&
        sFocusStatus != "on_public_anchor" &&
        sFocusStatus != "on_social_anchor" &&
        GetSubString(sFocusStatus, 0, 15) != "on_meal_anchor")
    {
        return "focus:" + sFocusStatus;
    }

    return "ok";
}

void DL_LogNpcDiagnostic(object oNpc, string sSource)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeLogEnabled())
    {
        return;
    }

    string sProblem = DL_GetNpcProblemSummary(oNpc);
    object oCurrentArea = GetArea(oNpc);
    object oRegisteredArea = GetLocalObject(oNpc, "dl_npc_reg_area");
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

    int nRegSlot = GetLocalInt(oNpc, "dl_npc_reg_slot");
    int bSlotContainsNpc = FALSE;
    if (GetIsObjectValid(oRegisteredArea) && nRegSlot >= 0)
    {
        bSlotContainsNpc = GetLocalObject(oRegisteredArea, "dl_reg_slot_" + IntToString(nRegSlot)) == oNpc;
    }

    string sLog = "[DL][NPC] src=" + sSource +
                  " npc=" + GetName(oNpc) +
                  " hour=" + IntToString(GetTimeHour()) +
                  " profile=" + GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) +
                  " npc_area=" + sCurrentArea +
                  " registered_area=" + sRegisteredArea +
                  " reg_on=" + IntToString(GetLocalInt(oNpc, "dl_reg_on")) +
                  " reg_slot=" + IntToString(nRegSlot) +
                  " slot_contains_npc=" + IntToString(bSlotContainsNpc) +
                  " repair_attempted=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_attempted")) +
                  " repair_success=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_success")) +
                  " repair_failed=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_failed")) +
                  " repair_failed_reason=" + GetLocalString(oNpc, "dl_registry_repair_failed_reason") +
                  " current_physical_area=" + GetLocalString(oNpc, "dl_registry_current_physical_area") +
                  " registry_area_before_repair=" + GetLocalString(oNpc, "dl_registry_area_before_repair") +
                  " registry_area_after_repair=" + GetLocalString(oNpc, "dl_registry_area_after_repair") +
                  " worker_touch_area=" + GetLocalString(oNpc, "dl_worker_touch_area") +
                  " repair_current_tick=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_current_tick")) +
                  " repair_owner_changed=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_owner_changed")) +
                  " handoff_problem=" + GetLocalString(oNpc, "dl_transition_registry_problem") +
                  " directive=" + DL_GetDirectiveLabel(GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE)) +
                  " state=" + GetLocalString(oNpc, DL_L_NPC_STATE) +
                  " problem=" + sProblem +
                  " sleep_status=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) +
                  " sleep_target=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) +
                  " work_status=" + GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) +
                  " work_target=" + GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) +
                  " transition_status=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) +
                  " transition_target=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) +
                  " directive_preempted_old_move=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE)) +
                  " old_move_owner=" + GetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER) +
                  " old_move_target=" + GetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET) +
                  " directive_change_prev=" + GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV) +
                  " directive_change_next=" + GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT) +
                  " directive_change_cleanup=" + GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP) +
                  " area_worker_tick_area=" + GetLocalString(oNpc, "area_worker_tick_area") +
                  " area_worker_tick_seq=" + IntToString(GetLocalInt(oNpc, "area_worker_tick_seq")) +
                  " npc_worker_touch_seq=" + IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq")) +
                  " npc_last_worker_touch_hour=" + IntToString(GetLocalInt(oNpc, "npc_last_worker_touch_hour")) +
                  " npc_last_worker_touch_minute=" + IntToString(GetLocalInt(oNpc, "npc_last_worker_touch_minute")) +
                  " npc_processed_by_round_robin=" + IntToString(GetLocalInt(oNpc, "npc_processed_by_round_robin")) +
                  " npc_registry_slot=" + IntToString(GetLocalInt(oNpc, "npc_registry_slot")) +
                  " npc_registry_count=" + IntToString(GetLocalInt(oNpc, "npc_registry_count")) +
                  " npc_slot_contains_self=" + IntToString(GetLocalInt(oNpc, "npc_slot_contains_self"));

    DL_LogRuntime(sLog);
}

string DL_GetNpcDiagnosticSignature(object oNpc)
{
    return DL_GetDirectiveLabel(GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE)) + "|" +
           GetLocalString(oNpc, DL_L_NPC_STATE) + "|" +
           DL_GetNpcProblemSummary(oNpc) + "|" +
           IntToString(GetLocalInt(oNpc, "dl_registry_repair_attempted")) + "|" +
           IntToString(GetLocalInt(oNpc, "dl_registry_repair_success")) + "|" +
           IntToString(GetLocalInt(oNpc, "dl_registry_repair_failed")) + "|" +
           GetLocalString(oNpc, "dl_registry_repair_failed_reason") + "|" +
           GetLocalString(oNpc, "dl_transition_registry_problem") + "|" +
           GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) + "|" +
           GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) + "|" +
           GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) + "|" +
           GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) + "|" +
           GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) + "|" +
           GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) + "|" +
           IntToString(GetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE)) + "|" +
           GetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER) + "|" +
           GetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET) + "|" +
           GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV) + "|" +
           GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT) + "|" +
           GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP) + "|" +
           GetLocalString(oNpc, "area_worker_tick_area") + "|" +
           IntToString(GetLocalInt(oNpc, "area_worker_tick_seq")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_last_worker_touch_hour")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_last_worker_touch_minute")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_processed_by_round_robin")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_registry_slot")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_registry_count")) + "|" +
           IntToString(GetLocalInt(oNpc, "npc_slot_contains_self"));
}

void DL_MaybeLogNpcDiagnostic(object oNpc, string sSource, int bForce)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sSignature = DL_GetNpcDiagnosticSignature(oNpc);
    if (!bForce && GetLocalString(oNpc, DL_L_NPC_DIAG_LAST_SIG) == sSignature)
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_DIAG_LAST_SIG, sSignature);
    DL_LogNpcDiagnostic(oNpc, sSource);
}
