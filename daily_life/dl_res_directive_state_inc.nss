void DL_SetInteractionModes(object oNpc, string sDialogue, string sService)
{
    SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, sDialogue);
    SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, sService);
}
int DL_IsProfileServiceAvailable(string sProfile)
{
    return sProfile != DL_PROFILE_GATE_POST;
}
void DL_ApplyIdleLikeDirectiveState(object oNpc, int bSocial)
{
    DL_ClearMoveJob(oNpc);
    SetLocalString(oNpc, DL_L_NPC_STATE, bSocial ? DL_STATE_SOCIAL : DL_STATE_IDLE);
    DL_SetInteractionModes(
        oNpc,
        bSocial ? DL_DIALOGUE_SOCIAL : DL_DIALOGUE_IDLE,
        DL_SERVICE_OFF
    );
    DL_ClearSleepExecutionState(oNpc);
    DL_ClearWorkExecutionState(oNpc);
    DL_ClearFocusExecutionState(oNpc);
    DL_ClearActivityPresentation(oNpc);
}
int DL_ResolveEffectiveDirective(object oNpc, int nDirective)
{
    if (nDirective == DL_DIR_SOCIAL && DL_ShouldFallbackSocialToPublic(oNpc))
    {
        return DL_DIR_PUBLIC;
    }

    return nDirective;
}
int DL_ShouldUseDirectiveFastPath(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (DL_HasTransitionExecutionState(oNpc))
    {
        return FALSE;
    }

    if (DL_GetNpcProblemSummary(oNpc) != "ok")
    {
        return FALSE;
    }

    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        return GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE) == DL_SLEEP_PHASE_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == DL_SLEEP_STATUS_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_WORK)
    {
        return GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == DL_WORK_STATUS_ON_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_MEAL)
    {
        string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        return GetSubString(sFocusStatus, 0, GetStringLength(DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX)) == DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "" &&
               !DL_HasMoveJob(oNpc);
    }

    if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "" &&
               !DL_HasMoveJob(oNpc);
    }

    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_CHILL_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    return FALSE;
}
void DL_RefreshWorkPresentationOnFastPath(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_WORK ||
        GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) != DL_WORK_STATUS_ON_ANCHOR ||
        GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) == "")
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE);
    if (nLastMin > 0 && (nNowAbsMin - nLastMin) < DL_WORK_FASTPATH_PRESENTATION_REFRESH_MINUTES)
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE, nNowAbsMin);
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
}

