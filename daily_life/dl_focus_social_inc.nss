int DL_ShouldFallbackSocialToPublic(object oNpc)
{
    object oMe = DL_ResolveSocialWaypoint(oNpc);
    if (!GetIsObjectValid(oMe))
    {
        DL_LogChatDebugEvent(oNpc, "fallback_social_public", "fallback social->public reason=missing_social_area_or_anchor");
        return TRUE;
    }

    return FALSE;
}
void DL_SetSocialArrivalProbeFailure(object oNpc, object oAnchor, string sReason, float fDist)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, sReason);
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST, fDist);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, FALSE);
    SetLocalString(
        oNpc,
        DL_L_NPC_SOCIAL_PROBE_AFTER,
        "social_arrival_probe " + sReason +
            " anchor_tag=" + GetTag(oAnchor) +
            " npc_area=" + GetTag(GetArea(oNpc)) +
            " anchor_area=" + GetTag(GetArea(oAnchor)) +
            " dist=" + FloatToString(fDist, 1, 2)
    );
}

int DL_TryStartSocialSceneAtReachedAnchor(object oNpc, object oAnchor, object oPartner, int bPartnerOnAnchor)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        DL_SetSocialArrivalProbeFailure(oNpc, oAnchor, "invalid_object", -1.0);
        return FALSE;
    }

    if (GetArea(oNpc) != GetArea(oAnchor))
    {
        DL_SetSocialArrivalProbeFailure(oNpc, oAnchor, "area_mismatch", GetDistanceBetween(oNpc, oAnchor));
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oAnchor) > DL_WORK_ANCHOR_RADIUS)
    {
        DL_SetSocialArrivalProbeFailure(oNpc, oAnchor, "too_far", GetDistanceBetween(oNpc, oAnchor));
        return FALSE;
    }

    DL_SetAnchorTerminalStatus(
        oNpc,
        DL_L_NPC_FOCUS_STATUS,
        DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR,
        DL_L_NPC_FOCUS_TARGET,
        oAnchor,
        DL_L_NPC_FOCUS_ACTION_STAMP,
        DL_L_NPC_FOCUS_ACTION_TARGET,
        FALSE,
        TRUE,
        TRUE
    );
    DL_ClearTransitionExecutionState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DL_LogChatDebugEvent(oNpc, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR, "on_social_anchor anchor=" + GetTag(oAnchor));
    DL_TickSocialScene(oNpc, oAnchor, oPartner, bPartnerOnAnchor);
    return TRUE;
}
void DL_ExecuteSocialDirective(object oNpc)
{
    object oMe = DL_ResolveSocialWaypoint(oNpc);
    int nProbeSeq = GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_SEQ) + 1;
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_SEQ, nProbeSeq);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN, DL_GetAbsoluteMinute());
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE, GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION, GetCurrentAction(oNpc));
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST, -1.0);
    string sPartnerTag = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PARTNER_TAG);
    object oPartner = DL_ResolveSocialPartnerObject(oNpc, sPartnerTag);
    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);

    int bPartnerReady = GetIsObjectValid(oPartner) &&
        GetLocalInt(oPartner, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL &&
        GetIsObjectValid(oPartnerWp);
    int bPartnerOnAnchor = FALSE;
    if (bPartnerReady)
    {
        bPartnerOnAnchor =
            GetLocalString(oPartner, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
            GetLocalString(oPartner, DL_L_NPC_FOCUS_TARGET) == GetTag(oPartnerWp) &&
            GetDistanceBetween(oPartner, oPartnerWp) <= DL_WORK_ANCHOR_RADIUS;
    }

    object oReachedFocus = DL_ResolveFocusTargetInCurrentArea(oNpc);
    string sFocusTargetTag = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    int bReachedSocialAnchor = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_MOVING_TO_ANCHOR &&
        GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL &&
        GetIsObjectValid(oReachedFocus) &&
        GetDistanceBetween(oNpc, oReachedFocus) <= DL_WORK_ANCHOR_RADIUS &&
        sFocusTargetTag == GetTag(oReachedFocus) &&
        (FindSubString(sFocusTargetTag, "social") >= 0 ||
            (GetIsObjectValid(oMe) && GetTag(oMe) == sFocusTargetTag));
    if (bReachedSocialAnchor)
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearMoveJob(oNpc);
        DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "focus");
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oReachedFocus));
        AssignCommand(oNpc, SetFacing(GetFacing(oReachedFocus)));
        SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST, GetDistanceBetween(oNpc, oReachedFocus));
        SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST, GetDistanceBetween(oNpc, oReachedFocus));
        SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, TRUE);
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "reached_focus_recovered");
        SetLocalString(
            oNpc,
            DL_L_NPC_SOCIAL_PROBE_BEFORE,
            "seq=" + IntToString(nProbeSeq) +
                " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
                " focus_status=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE) +
                " focus_target=" + sFocusTargetTag +
                " reached_tag=" + GetTag(oReachedFocus) +
                " reached_dist=" + FloatToString(GetDistanceBetween(oNpc, oReachedFocus), 1, 2) +
                " current_action=" + IntToString(GetCurrentAction(oNpc))
        );
        SetLocalString(
            oNpc,
            DL_L_NPC_SOCIAL_PROBE_AFTER,
            "seq=" + IntToString(nProbeSeq) +
                " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
                " recovered_reached_focus=1 focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
                " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET)
        );
        DL_TickSocialScene(oNpc, oReachedFocus, oPartner, bPartnerOnAnchor);
        return;
    }

    if (!GetIsObjectValid(oMe))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_social_anchor");
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "missing_social_anchor");
        SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, FALSE);
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER, "missing_social_anchor");
        return;
    }

    string sAnchorTag = GetTag(oMe);
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST, GetDistanceBetween(oNpc, oMe));
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST, GetDistanceBetween(oNpc, oMe));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION, GetCurrentAction(oNpc));
    SetLocalString(
        oNpc,
        DL_L_NPC_SOCIAL_PROBE_BEFORE,
        "seq=" + IntToString(nProbeSeq) +
            " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
            " npc_tag=" + GetTag(oNpc) +
            " focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
            " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
            " oMe_tag=" + GetTag(oMe) +
            " npc_area=" + GetTag(GetArea(oNpc)) +
            " oMe_area=" + GetTag(GetArea(oMe)) +
            " dist=" + FloatToString(GetDistanceBetween(oNpc, oMe), 1, 2) +
            " now_dist=" + FloatToString(GetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST), 1, 2) +
            " current_action=" + IntToString(GetCurrentAction(oNpc)) +
            " bPartnerOnAnchor=" + IntToString(bPartnerOnAnchor)
    );
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "calling_helper");
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER, "calling_helper");
    int bStartedSocialScene = DL_TryStartSocialSceneAtReachedAnchor(oNpc, oMe, oPartner, bPartnerOnAnchor);
    string sProbeFailure = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, bStartedSocialScene);
    SetLocalString(
        oNpc,
        DL_L_NPC_SOCIAL_PROBE_AFTER,
        "seq=" + IntToString(nProbeSeq) +
            " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
            " helper_result=" + IntToString(bStartedSocialScene) +
            " focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
            " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
            " detail=" + sProbeFailure
    );
    if (bStartedSocialScene)
    {
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "started");
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sAnchorTag)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DL_TickSocialScene(oNpc, oMe, oPartner, bPartnerOnAnchor);
        return;
    }

    DL_LogChatDebugEvent(
        oNpc,
        "target_social",
        "target dir=SOCIAL area=" + GetTag(GetArea(oMe)) + " anchor=" + GetTag(oMe) +
            " social_anchor=" + GetTag(oMe) +
            " social_slot=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) +
            " social_partner_tag=" + sPartnerTag +
            " social_partner_valid=" + IntToString(GetIsObjectValid(oPartner))
    );

    DL_ProgressFocusAtTarget(oNpc, oMe, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR, "");

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sAnchorTag)
    {
        DL_TickSocialScene(oNpc, oMe, oPartner, bPartnerOnAnchor);
    }
}
