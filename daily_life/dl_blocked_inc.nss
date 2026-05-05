const string DL_L_NPC_BLOCKED_OBJ = "dl_npc_blocked_obj";
const string DL_L_NPC_BLOCKED_TAG = "dl_npc_blocked_tag";
const string DL_L_NPC_BLOCKED_TYPE = "dl_npc_blocked_type";
const string DL_L_NPC_BLOCKED_BUSY = "dl_npc_blocked_busy";

const float DL_BLOCKED_OPEN_COOLDOWN = 3.0;
const float DL_BLOCKED_REISSUE_DELAY = 2.2;
const float DL_BLOCKED_SECOND_REISSUE_DELAY = 4.8;

void DL_ClearNpcBlockedSignal(object oNpc)
{
    DeleteLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_TAG);
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE);
}

void DL_ClearNpcBlockedTransientDiagnostic(object oNpc)
{
    string sDiagnostic = GetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC);
    if (sDiagnostic == "opening_blocking_door" || sDiagnostic == "blocked_busy")
    {
        DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC);
    }
}

void DL_ClearNpcBlockedBusy(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY);
    DL_ClearNpcBlockedTransientDiagnostic(oNpc);
}

int DL_IsBlockedRecoveryDirective(int nDirective)
{
    if (nDirective == DL_DIR_WORK)
    {
        return TRUE;
    }
    if (nDirective == DL_DIR_SLEEP)
    {
        return TRUE;
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return TRUE;
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return TRUE;
    }
    if (nDirective == DL_DIR_PUBLIC)
    {
        return TRUE;
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return TRUE;
    }
    return FALSE;
}

void DL_PrepareNpcDirectiveReissueAfterBlocked(object oNpc, int nDirective)
{
    DL_ClearNpcBlockedBusy(oNpc);
    DL_ClearNpcBlockedTransientDiagnostic(oNpc);

    if (nDirective == DL_DIR_SLEEP)
    {
        DL_ClearSleepActionIssueState(oNpc);
        return;
    }

    if (nDirective == DL_DIR_WORK)
    {
        if (GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == "moving_to_anchor")
        {
            DeleteLocalString(oNpc, DL_L_NPC_WORK_STATUS);
        }
        return;
    }

    if (nDirective == DL_DIR_MEAL ||
        nDirective == DL_DIR_SOCIAL ||
        nDirective == DL_DIR_PUBLIC ||
        nDirective == DL_DIR_CHILL)
    {
        string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        if (sFocusStatus == "moving_to_anchor" || sFocusStatus == "moving_social_pair")
        {
            DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        }
    }
}

void DL_ReissueNpcDirectiveAfterBlocked(object oNpc)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (DL_IsBlockedRecoveryDirective(nDirective))
    {
        DL_PrepareNpcDirectiveReissueAfterBlocked(oNpc, nDirective);
        DL_ApplyDirectiveSkeleton(oNpc, nDirective);
        return;
    }
}

void DL_RequestNpcBlockedSignal(object oNpc, object oBlocker)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (!GetIsObjectValid(oBlocker))
    {
        return;
    }

    SetLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ, oBlocker);
    SetLocalString(oNpc, DL_L_NPC_BLOCKED_TAG, GetTag(oBlocker));
    SetLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE, GetObjectType(oBlocker));

    SetLocalInt(oNpc, DL_L_NPC_EVENT_KIND, DL_NPC_EVENT_BLOCKED);
    SetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ, GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ) + 1);

    SignalEvent(oNpc, EventUserDefined(DL_UD_PIPELINE_NPC_EVENT));
}

void DL_HandleNpcBlocked(object oNpc)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY) == TRUE)
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_busy");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    object oBlocker = GetLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    if (!GetIsObjectValid(oBlocker))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_invalid_object");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    if (GetObjectType(oBlocker) != OBJECT_TYPE_DOOR)
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_by_creature");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (!DL_IsBlockedRecoveryDirective(nDirective))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_outside_route_directive");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    if (!GetIsDoorActionPossible(oBlocker, DOOR_ACTION_OPEN))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "door_open_not_possible");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY, TRUE);
    SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "opening_blocking_door");
    DL_ClearNpcBlockedSignal(oNpc);

    AssignCommand(oNpc, DoDoorAction(oBlocker, DOOR_ACTION_OPEN));
    DelayCommand(DL_BLOCKED_REISSUE_DELAY, DL_ReissueNpcDirectiveAfterBlocked(oNpc));
    DelayCommand(DL_BLOCKED_OPEN_COOLDOWN, DL_ClearNpcBlockedBusy(oNpc));
    DelayCommand(DL_BLOCKED_SECOND_REISSUE_DELAY, DL_ReissueNpcDirectiveAfterBlocked(oNpc));
}
