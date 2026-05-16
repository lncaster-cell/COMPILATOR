// Deep Chair Debug helper: attach to a placeable OnUsed event.
// Shows Daily Life runtime/navigation/focus/chair state for nearest NPC.
// Intended for builder/runtime smoke tests only.

#include "dl_runtime_contract_inc"
#include "dl_diag_inc"

const float DL_DBG_NPC_SCAN_RADIUS = 30.0;
const int DL_DBG_NEAR_SCAN_CAP = 12;

string DL_DbgPad2(int nValue)
{
    if (nValue < 0) nValue = 0;
    if (nValue < 10) return "0" + IntToString(nValue);
    return IntToString(nValue);
}

string DL_DbgDirectiveLabel(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP) return "SLEEP";
    if (nDirective == DL_DIR_WORK) return "WORK";
    if (nDirective == DL_DIR_SOCIAL) return "SOCIAL";
    if (nDirective == DL_DIR_MEAL) return "MEAL";
    if (nDirective == DL_DIR_PUBLIC) return "PUBLIC";
    if (nDirective == DL_DIR_CHILL) return "CHILL";
    return "NONE";
}

void DL_DbgSay(object oPC, string sText)
{
    SendMessageToPC(oPC, sText);
    FloatingTextStringOnCreature(sText, oPC, FALSE);
}

string DL_DbgFloat(float fValue)
{
    return FloatToString(fValue, 1, 2);
}

string DL_DbgObjTagOrNone(object oObj)
{
    if (!GetIsObjectValid(oObj)) return "NONE";
    return GetTag(oObj);
}

string DL_DbgAreaTagOrNone(object oObj)
{
    if (!GetIsObjectValid(oObj)) return "NONE";
    object oArea = GetArea(oObj);
    if (!GetIsObjectValid(oArea)) return "NONE";
    return GetTag(oArea);
}

string DL_DbgBool(int bValue)
{
    if (bValue) return "1";
    return "0";
}

int DL_DbgIsChairTagCandidate(string sTag)
{
    if (sTag == "") return FALSE;
    if (FindSubString(sTag, "chair") >= 0) return TRUE;
    if (FindSubString(sTag, "Chair") >= 0) return TRUE;
    if (FindSubString(sTag, "seat") >= 0) return TRUE;
    if (FindSubString(sTag, "Seat") >= 0) return TRUE;
    if (FindSubString(sTag, "stul") >= 0) return TRUE;
    if (FindSubString(sTag, "Stul") >= 0) return TRUE;
    return FALSE;
}

object DL_DbgFindNearestDailyLifeNpc(object oUser)
{
    if (!GetIsObjectValid(oUser)) return OBJECT_INVALID;

    object oArea = GetArea(oUser);
    if (!GetIsObjectValid(oArea)) return OBJECT_INVALID;

    object oBest = OBJECT_INVALID;
    float fBestDistance = DL_DBG_NPC_SCAN_RADIUS + 1.0;
    object oCandidate = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oCandidate))
    {
        if (DL_IsPipelineNpc(oCandidate) && GetLocalString(oCandidate, DL_L_NPC_PROFILE_ID) != "")
        {
            float fDistance = GetDistanceBetween(oUser, oCandidate);
            if (fDistance <= DL_DBG_NPC_SCAN_RADIUS && fDistance < fBestDistance)
            {
                oBest = oCandidate;
                fBestDistance = fDistance;
            }
        }
        oCandidate = GetNextObjectInArea(oArea);
    }
    return oBest;
}

object DL_DbgFindObjectByTagInArea(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "") return OBJECT_INVALID;

    int nIndex = 0;
    object oObj = GetObjectByTag(sTag, nIndex);
    while (GetIsObjectValid(oObj) && nIndex < 64)
    {
        if (GetArea(oObj) == oArea) return oObj;
        nIndex = nIndex + 1;
        oObj = GetObjectByTag(sTag, nIndex);
    }
    return OBJECT_INVALID;
}

object DL_DbgFindPlaceableByTagInArea(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "") return OBJECT_INVALID;

    int nIndex = 0;
    object oObj = GetObjectByTag(sTag, nIndex);
    while (GetIsObjectValid(oObj) && nIndex < 64)
    {
        if (GetArea(oObj) == oArea && GetObjectType(oObj) == OBJECT_TYPE_PLACEABLE) return oObj;
        nIndex = nIndex + 1;
        oObj = GetObjectByTag(sTag, nIndex);
    }
    return OBJECT_INVALID;
}

void DL_DbgPrintChairObject(object oPC, string sLabel, object oNpc, object oSeat, string sChairTag)
{
    object oArea = GetArea(oNpc);
    object oChair = DL_DbgFindPlaceableByTagInArea(oArea, sChairTag);
    object oSitter = OBJECT_INVALID;
    string sDist = "NA";
    if (GetIsObjectValid(oChair))
    {
        oSitter = GetSittingCreature(oChair);
        if (GetIsObjectValid(oSeat)) sDist = DL_DbgFloat(GetDistanceBetweenLocations(GetLocation(oChair), GetLocation(oSeat)));
    }

    DL_DbgSay(oPC,
        "[DL DEBUG] " + sLabel +
        " tag=" + sChairTag +
        " valid=" + DL_DbgBool(GetIsObjectValid(oChair)) +
        " objtag=" + DL_DbgObjTagOrNone(oChair) +
        " dist_to_seat=" + sDist +
        " sitter=" + DL_DbgObjTagOrNone(oSitter) +
        " npc_is_sitter=" + DL_DbgBool(oSitter == oNpc) +
        " area=" + DL_DbgAreaTagOrNone(oChair)
    );
}

void DL_DbgPrintCandidateChair(object oPC, object oNpc, object oSeat, int nRank)
{
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oSeat)) return;

    object oCandidate = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, GetLocation(oSeat), nRank);
    if (!GetIsObjectValid(oCandidate)) return;

    float fDist = GetDistanceBetweenLocations(GetLocation(oCandidate), GetLocation(oSeat));
    object oSitter = GetSittingCreature(oCandidate);

    DL_DbgSay(oPC,
        "[DL DEBUG] near_placeable_" + IntToString(nRank) +
        " tag=" + GetTag(oCandidate) +
        " dist=" + DL_DbgFloat(fDist) +
        " chair_candidate=" + DL_DbgBool(DL_DbgIsChairTagCandidate(GetTag(oCandidate))) +
        " sitter=" + DL_DbgObjTagOrNone(oSitter) +
        " npc_is_sitter=" + DL_DbgBool(oSitter == oNpc) +
        " area=" + DL_DbgAreaTagOrNone(oCandidate)
    );
}

string DL_DbgTransitionTag(string sFromZone, string sToZone)
{
    if (sFromZone == "" || sToZone == "") return "";
    return sFromZone + "__" + sToZone;
}

string DL_DbgRouteKey(string sCurrentZone, string sTargetZone)
{
    if (sCurrentZone == "" || sTargetZone == "") return "";
    return "route_" + sCurrentZone + "__" + sTargetZone;
}

object DL_DbgFindWaypointByTagInArea(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "") return OBJECT_INVALID;

    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT && GetTag(oObj) == sTag) return oObj;
        oObj = GetNextObjectInArea(oArea);
    }
    return OBJECT_INVALID;
}

object DL_DbgResolveAreaByTag(string sAreaTag)
{
    if (sAreaTag == "") return OBJECT_INVALID;

    int nIndex = 0;
    object oObj = GetObjectByTag(sAreaTag, nIndex);
    while (GetIsObjectValid(oObj) && nIndex < 32)
    {
        if (DL_IsAreaObject(oObj)) return oObj;
        nIndex = nIndex + 1;
        oObj = GetObjectByTag(sAreaTag, nIndex);
    }
    return OBJECT_INVALID;
}

object DL_DbgResolveNpcConfiguredArea(object oNpc, string sAreaLocal)
{
    if (!GetIsObjectValid(oNpc)) return OBJECT_INVALID;

    string sAreaTag = GetLocalString(oNpc, sAreaLocal);
    if (sAreaTag != "") return DL_DbgResolveAreaByTag(sAreaTag);

    return GetArea(oNpc);
}

string DL_DbgAreaConfiguredTag(object oNpc, string sAreaLocal)
{
    string sAreaTag = GetLocalString(oNpc, sAreaLocal);
    if (sAreaTag != "") return sAreaTag;
    return "<current>";
}

string DL_DbgAnchorValidText(object oArea, string sAnchorLocal)
{
    string sWpTag = "";
    if (GetIsObjectValid(oArea)) sWpTag = GetLocalString(oArea, sAnchorLocal);
    object oWp = DL_DbgFindWaypointByTagInArea(oArea, sWpTag);
    return sWpTag + ":" + DL_DbgBool(GetIsObjectValid(oWp));
}

void DL_DbgPrintSocialPublicConfig(object oPC, object oNpc)
{
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oNpc)) return;

    object oSocialArea = DL_DbgResolveNpcConfiguredArea(oNpc, DL_L_NPC_SOCIAL_AREA_TAG);
    object oPublicArea = DL_DbgResolveNpcConfiguredArea(oNpc, DL_L_NPC_PUBLIC_AREA_TAG);

    DL_DbgSay(oPC,
        "[DL] social area=" + DL_DbgAreaConfiguredTag(oNpc, DL_L_NPC_SOCIAL_AREA_TAG) +
        ":" + DL_DbgBool(GetIsObjectValid(oSocialArea)) +
        " slot=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) +
        " a=" + DL_DbgAnchorValidText(oSocialArea, "dl_anchor_social_a") +
        " b=" + DL_DbgAnchorValidText(oSocialArea, "dl_anchor_social_b") +
        " any=" + DL_DbgAnchorValidText(oSocialArea, "dl_anchor_social") +
        " public=" + DL_DbgAreaConfiguredTag(oNpc, DL_L_NPC_PUBLIC_AREA_TAG) +
        ":" + DL_DbgBool(GetIsObjectValid(oPublicArea)) +
        " p=" + DL_DbgAnchorValidText(oPublicArea, "dl_anchor_public")
    );
}


void DL_DbgPrintSocialSceneState(object oPC, object oNpc)
{
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oNpc)) return;

    DL_DbgSay(oPC,
        "[DL] social_scene id=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID) +
        " step=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_STEP)) +
        " next=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE)) +
        " role=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ROLE) +
        " active=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_ACTIVE)) +
        " phase=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_PHASE)) +
        " pool=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_POOL) +
        " anim=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM) +
        " play_result=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_PLAY_RESULT)) +
        " anchor=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR)
    );
    DL_DbgSay(oPC,
        "[DL] social_probe seq=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_SEQ)) +
        " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
        " result=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT)) +
        " reason=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON) +
        " dist=" + DL_DbgFloat(GetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST)) +
        " now_dist=" + DL_DbgFloat(GetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST)) +
        " focus_before=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE) +
        " action=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION)) +
        " before=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_BEFORE) +
        " after=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER)
    );
}

void main()
{
    object oDebug = OBJECT_SELF;
    object oPC = GetLastUsedBy();
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC)) oPC = GetFirstPC();
    if (!GetIsObjectValid(oPC)) return;

    int bVerbose = GetLocalInt(oDebug, "dl_dbg_verbose");
    if (!bVerbose) bVerbose = GetLocalInt(GetModule(), "dl_dbg_verbose");
    int bVerboseChairs = GetLocalInt(oDebug, "dl_dbg_verbose_chairs");
    if (!bVerboseChairs) bVerboseChairs = GetLocalInt(GetModule(), "dl_dbg_verbose_chairs");

    object oNpc = DL_DbgFindNearestDailyLifeNpc(oPC);
    if (!GetIsObjectValid(oNpc))
    {
        DL_DbgSay(oPC,
            "[DL] " + DL_DbgPad2(GetTimeHour()) + ":" + DL_DbgPad2(GetTimeMinute()) +
            " npc=NONE range=" + FloatToString(DL_DBG_NPC_SCAN_RADIUS, 1, 1)
        );
        return;
    }

    object oArea = GetArea(oNpc);
    int nNowDirective = DL_ResolveNpcDirective(oNpc);
    int nStoredDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    string sTransitionStatus = GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    string sCurrentZone = GetLocalString(oNpc, "dl_nav_debug_current");
    string sTargetZone = GetLocalString(oNpc, "dl_nav_debug_target");
    string sNextZone = GetLocalString(oNpc, "dl_nav_debug_next");
    string sNavReason = GetLocalString(oNpc, "dl_nav_debug_reason");
    string sStoredCurrent = GetLocalString(oNpc, "dl_npc_nav_zone_current");
    string sFocusTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    object oFocusTarget = DL_DbgFindObjectByTagInArea(oArea, sFocusTarget);
    string sFocusDist = "NA";
    if (GetIsObjectValid(oFocusTarget)) sFocusDist = DL_DbgFloat(GetDistanceBetween(oNpc, oFocusTarget));

    DL_DbgSay(oPC,
        "[DL] " + DL_DbgPad2(GetTimeHour()) + ":" + DL_DbgPad2(GetTimeMinute()) +
        " npc=" + GetTag(oNpc) +
        " area=" + DL_DbgAreaTagOrNone(oNpc) +
        " dir=" + DL_DbgDirectiveLabel(nNowDirective) + "/" + DL_DbgDirectiveLabel(nStoredDirective) +
        " state=" + GetLocalString(oNpc, DL_L_NPC_STATE) +
        " problem=" + DL_GetNpcProblemSummary(oNpc)
    );

    DL_DbgSay(oPC,
        "[DL] focus=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
        " target=" + sFocusTarget +
        " dist=" + sFocusDist +
        " diag=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC) +
        " trans=" + sTransitionStatus +
        ":" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC) +
        " nav=" + sCurrentZone + "->" + sNextZone + "->" + sTargetZone +
        " reason=" + sNavReason
    );

    DL_DbgSay(oPC,
        "[DL] move_owner=" + GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) +
        " move_phase=" + GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) +
        " move_target_tag=" + GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) +
        " move_target_area=" + GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_AREA) +
        " move_result=" + GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) +
        " move_diagnostic=" + GetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC) +
        " move_ticket=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET))
    );

    DL_DbgSay(oPC,
        "[DL] directive_preempted_old_move=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE)) +
        " old_move_owner=" + GetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER) +
        " old_move_target=" + GetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET) +
        " directive_change_prev=" + GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV) +
        " directive_change_next=" + GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT) +
        " directive_change_cleanup=" + GetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP)
    );

    DL_DbgSay(oPC,
        "[DL] area_worker_tick_area=" + GetLocalString(oNpc, "area_worker_tick_area") +
        " area_worker_tick_seq=" + IntToString(GetLocalInt(oNpc, "area_worker_tick_seq")) +
        " area_worker_pass_mode=" + GetLocalString(oNpc, "area_worker_pass_mode") +
        " area_worker_budget=" + IntToString(GetLocalInt(oNpc, "area_worker_budget")) +
        " area_cached_player_count=" + IntToString(GetLocalInt(oNpc, "area_cached_player_count")) +
        " area_actual_player_count=" + IntToString(GetLocalInt(oNpc, "area_actual_player_count")) +
        " area_tier_before_lifecycle=" + GetLocalString(oNpc, "area_tier_before_lifecycle") +
        " area_tier_after_lifecycle=" + GetLocalString(oNpc, "area_tier_after_lifecycle") +
        " area_hotness_repaired=" + IntToString(GetLocalInt(oNpc, "area_hotness_repaired")) +
        " area_worker_forced_hot_due_to_player=" + IntToString(GetLocalInt(oNpc, "area_worker_forced_hot_due_to_player")) +
        " area_player_count_stale_repaired=" + IntToString(GetLocalInt(oNpc, "area_player_count_stale_repaired")) +
        " area_hotness_bug_player_present=" + IntToString(GetLocalInt(oNpc, "area_hotness_bug_player_present")) +
        " area_worker_cursor_before=" + IntToString(GetLocalInt(oNpc, "area_worker_cursor_before")) +
        " area_worker_cursor_after=" + IntToString(GetLocalInt(oNpc, "area_worker_cursor_after")) +
        " npc_seen_by_round_robin=" + IntToString(GetLocalInt(oNpc, "npc_seen_by_round_robin")) +
        " npc_processed_by_round_robin=" + IntToString(GetLocalInt(oNpc, "npc_processed_by_round_robin")) +
        " npc_touch_skipped_reason=" + GetLocalString(oNpc, "npc_touch_skipped_reason") +
        " npc_worker_touch_seq_before=" + IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq_before")) +
        " npc_worker_touch_seq_after=" + IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq_after")) +
        " npc_worker_touch_seq=" + IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq")) +
        " npc_last_worker_touch_hour=" + IntToString(GetLocalInt(oNpc, "npc_last_worker_touch_hour")) +
        " npc_last_worker_touch_minute=" + IntToString(GetLocalInt(oNpc, "npc_last_worker_touch_minute")) +
        " npc_registry_slot=" + IntToString(GetLocalInt(oNpc, "npc_registry_slot")) +
        " npc_registry_count=" + IntToString(GetLocalInt(oNpc, "npc_registry_count")) +
        " npc_slot_contains_self=" + IntToString(GetLocalInt(oNpc, "npc_slot_contains_self"))
    );

    if (sNavReason == "finalize_skip_target_invalid" ||
        sNavReason == "finalize_skip_area_invalid" ||
        sNavReason == "finalize_skip_area_mismatch")
    {
        DL_DbgSay(oPC,
            "[DL] transition_finalize_skip" +
            " reason=" + sNavReason +
            " npc_area=" + GetLocalString(oNpc, "dl_nav_debug_npc_area") +
            " target_area=" + GetLocalString(oNpc, "dl_nav_debug_target_area") +
            " transition_status=" + GetLocalString(oNpc, "dl_nav_debug_old_transition_status") +
            " transition_target=" + GetLocalString(oNpc, "dl_nav_debug_transition_target") +
            " anchor_tag=" + GetLocalString(oNpc, "dl_nav_debug_anchor_tag")
        );
    }

    if (sNavReason == "post_transition_complete")
    {
        DL_DbgSay(oPC,
            "[DL] post_transition_complete" +
            " npc_area=" + GetLocalString(oNpc, "dl_nav_debug_npc_area") +
            " target_area=" + GetLocalString(oNpc, "dl_nav_debug_target_area") +
            " current_zone=" + GetLocalString(oNpc, "dl_nav_debug_current_zone") +
            " target_zone=" + GetLocalString(oNpc, "dl_nav_debug_target_zone") +
            " old_transition_status=" + GetLocalString(oNpc, "dl_nav_debug_old_transition_status") +
            " focus_target=" + GetLocalString(oNpc, "dl_nav_debug_focus_target") +
            " current_action=" + IntToString(GetLocalInt(oNpc, "dl_nav_debug_current_action"))
        );
    }

    object oRegisteredArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    string sCurrentRegistryArea = "";
    int bRegistryAreaMismatch = FALSE;
    if (GetIsObjectValid(oRegisteredArea))
    {
        sCurrentRegistryArea = GetTag(oRegisteredArea);
    }
    if (GetIsObjectValid(GetArea(oNpc)) && GetArea(oNpc) != oRegisteredArea)
    {
        bRegistryAreaMismatch = TRUE;
    }

    if (bRegistryAreaMismatch == TRUE)
    {
        int nRegSlot = GetLocalInt(oNpc, "dl_npc_reg_slot");
        int bSlotContainsNpc = FALSE;
        if (GetIsObjectValid(oRegisteredArea) && nRegSlot >= 0)
        {
            bSlotContainsNpc = GetLocalObject(oRegisteredArea, "dl_reg_slot_" + IntToString(nRegSlot)) == oNpc;
        }

        DL_DbgSay(oPC,
            "[DL] registry_area_mismatch" +
            " npc_area=" + DL_DbgAreaTagOrNone(oNpc) +
            " registered_area=" + sCurrentRegistryArea +
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
            " area_enter_npc_touch=" + IntToString(GetLocalInt(oNpc, "dl_area_enter_npc_touch")) +
            " area_enter_area=" + GetLocalString(oNpc, "dl_area_enter_area") +
            " area_enter_npc_area=" + GetLocalString(oNpc, "dl_area_enter_npc_area") +
            " area_enter_reg_area_after=" + GetLocalString(oNpc, "dl_area_enter_reg_area_after") +
            " post_jump_finalizer_called=" + IntToString(GetLocalInt(oNpc, "dl_post_jump_finalizer_called")) +
            " post_jump_current_area=" + GetLocalString(oNpc, "dl_post_jump_current_area") +
            " post_jump_expected_area=" + GetLocalString(oNpc, "dl_post_jump_expected_area") +
            " post_jump_registered_area_after=" + GetLocalString(oNpc, "dl_post_jump_registered_area_after") +
            " post_jump_worker_touch_called=" + IntToString(GetLocalInt(oNpc, "dl_post_jump_worker_touch_called")) +
            " post_jump_result=" + GetLocalString(oNpc, "dl_post_jump_result") +
            " repair_current_tick=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_current_tick")) +
            " repair_owner_changed=" + IntToString(GetLocalInt(oNpc, "dl_registry_repair_owner_changed"))
        );
    }

    if (GetLocalString(oNpc, "dl_transition_registry_handoff") == "transition_registry_handoff")
    {
        DL_DbgSay(oPC,
            "[DL] transition_registry_handoff" +
            " target_area=" + GetLocalString(oNpc, "dl_transition_registry_target_area") +
            " queued_npc=" + GetLocalString(oNpc, "dl_transition_registry_npc_tag") +
            " npc_area=" + GetLocalString(oNpc, "dl_transition_registry_npc_area") +
            " old_area=" + GetLocalString(oNpc, "dl_transition_registry_old_area") +
            " reg_area_before=" + GetLocalString(oNpc, "dl_transition_registry_reg_area_before") +
            " reg_area_after=" + GetLocalString(oNpc, "dl_transition_registry_reg_area_after") +
            " registered_area=" + GetLocalString(oNpc, "dl_transition_registry_registered_area") +
            " current_registered_area=" + sCurrentRegistryArea +
            " reg_on=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_reg_on")) +
            " reg_slot=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_reg_slot")) +
            " worker_tick_area=" + GetLocalString(oNpc, "dl_transition_registry_worker_tick_area") +
            " handoff_slot=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_handoff_slot")) +
            " handoff_seen=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_handoff_seen")) +
            " handoff_touch_called=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called")) +
            " registry_area_mismatch=" + IntToString(bRegistryAreaMismatch) +
            " target_area_rebuild_pending=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_rebuild_pending")) +
            " target_area_resync_pending=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_resync_pending")) +
            " handoff_problem=" + GetLocalString(oNpc, "dl_transition_registry_problem") +
            " current_physical_area=" + GetLocalString(oNpc, "dl_transition_registry_current_physical_area") +
            " registry_area_before_repair=" + GetLocalString(oNpc, "dl_transition_registry_registry_area_before_repair") +
            " registry_area_after_repair=" + GetLocalString(oNpc, "dl_transition_registry_registry_area_after_repair") +
            " worker_touch_area=" + GetLocalString(oNpc, "dl_transition_registry_worker_touch_area") +
            " area_enter_npc_touch=" + IntToString(GetLocalInt(oNpc, "dl_area_enter_npc_touch")) +
            " area_enter_area=" + GetLocalString(oNpc, "dl_area_enter_area") +
            " area_enter_npc_area=" + GetLocalString(oNpc, "dl_area_enter_npc_area") +
            " area_enter_reg_area_after=" + GetLocalString(oNpc, "dl_area_enter_reg_area_after") +
            " post_jump_finalizer_called=" + IntToString(GetLocalInt(oNpc, "dl_post_jump_finalizer_called")) +
            " post_jump_current_area=" + GetLocalString(oNpc, "dl_post_jump_current_area") +
            " post_jump_expected_area=" + GetLocalString(oNpc, "dl_post_jump_expected_area") +
            " post_jump_registered_area_after=" + GetLocalString(oNpc, "dl_post_jump_registered_area_after") +
            " post_jump_worker_touch_called=" + IntToString(GetLocalInt(oNpc, "dl_post_jump_worker_touch_called")) +
            " post_jump_result=" + GetLocalString(oNpc, "dl_post_jump_result") +
            " repair_current_tick=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_repair_current_tick")) +
            " repair_owner_changed=" + IntToString(GetLocalInt(oNpc, "dl_transition_registry_repair_owner_changed"))
        );
    }

    int bSocialRelevant = nNowDirective == DL_DIR_SOCIAL ||
        nStoredDirective == DL_DIR_SOCIAL ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_social_anchor";

    if (bSocialRelevant ||
        nStoredDirective == DL_DIR_PUBLIC ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC) == "missing_public_anchor")
    {
        DL_DbgPrintSocialPublicConfig(oPC, oNpc);
    }

    if (bVerbose || bSocialRelevant)
    {
        DL_DbgPrintSocialSceneState(oPC, oNpc);
    }

    if (bVerbose)
    {
        DL_DbgSay(oPC,
            "[DL] worker npc_seq=" + IntToString(GetLocalInt(oNpc, "dl_npc_worker_seq")) +
            " module_seq=" + IntToString(GetLocalInt(GetModule(), "dl_module_worker_seq")) +
            " ticks=" + IntToString(GetLocalInt(GetModule(), "dl_module_worker_ticks")) +
            " processed=" + IntToString(GetLocalInt(oArea, "dl_area_worker_last_processed")) +
            " reg=" + IntToString(GetLocalInt(oNpc, "dl_reg_on")) +
            "/" + IntToString(GetLocalInt(oNpc, "dl_npc_reg_slot")) +
            "/" + IntToString(GetLocalInt(oArea, "dl_reg_count")) +
            " tier=" + IntToString(GetLocalInt(oArea, "dl_area_tier"))
        );

        DL_DbgSay(oPC,
            "[DL] sleep=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) +
            ":" + GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) +
            ":" + GetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC) +
            " work=" + GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) +
            ":" + GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) +
            ":" + GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC)
        );

        object oCachedMeal = GetLocalObject(oNpc, "dl_cache_meal");
        object oMealModeTarget = oCachedMeal;
        string sMealWaypointTag = DL_DbgObjTagOrNone(oCachedMeal);
        if (!GetIsObjectValid(oCachedMeal) && GetIsObjectValid(oFocusTarget))
        {
            string sFocusTag = GetTag(oFocusTarget);
            if (sFocusTag == "dl_anchor_meal" || FindSubString(sFocusTag, "dl_meal_") == 0)
            {
                oMealModeTarget = oFocusTarget;
                sMealWaypointTag = sFocusTag;
            }
        }

        int bMealLegacyNpc = GetLocalInt(oNpc, "dl_meal_legacy_action_sit");
        int bMealLegacyWp = GetIsObjectValid(oMealModeTarget) && GetLocalInt(oMealModeTarget, "dl_meal_legacy_action_sit");
        int bChillLegacyNpc = GetLocalInt(oNpc, "dl_chill_legacy_action_sit");
        int bChillLegacyWp = GetIsObjectValid(oFocusTarget) && GetLocalInt(oFocusTarget, "dl_chill_legacy_action_sit");

        DL_DbgSay(oPC,
            "[DL] seating meal=" + DL_DbgBool(bMealLegacyNpc || bMealLegacyWp) +
            " chill=" + DL_DbgBool(bChillLegacyNpc || bChillLegacyWp) +
            " meal_wp=" + sMealWaypointTag +
            " focus_wp=" + sFocusTarget +
            " issue=" + GetLocalString(oNpc, "dl_focus_anchor_action_target") +
            ":" + IntToString(GetLocalInt(oNpc, "dl_focus_anchor_action_stamp"))
        );
    }

    if (bVerbose || sTransitionStatus != "")
    {
        string sRouteKey = DL_DbgRouteKey(sStoredCurrent, sTargetZone);
        string sRouteValue = "";
        if (GetIsObjectValid(oArea) && sRouteKey != "") sRouteValue = GetLocalString(oArea, sRouteKey);

        string sEntryTag = DL_DbgTransitionTag(sStoredCurrent, sRouteValue);
        string sExitTag = DL_DbgTransitionTag(sRouteValue, sStoredCurrent);
        object oEntry = DL_DbgFindWaypointByTagInArea(oArea, sEntryTag);
        object oExit = GetWaypointByTag(sExitTag);
        string sEntryDist = "NA";
        if (GetIsObjectValid(oEntry)) sEntryDist = DL_DbgFloat(GetDistanceBetween(oNpc, oEntry));

        DL_DbgSay(oPC,
            "[DL] route " + sRouteKey + "=" + sRouteValue +
            " entry=" + sEntryTag + ":" + DL_DbgBool(GetIsObjectValid(oEntry)) +
            " d=" + sEntryDist +
            " exit=" + sExitTag + ":" + DL_DbgBool(GetIsObjectValid(oExit)) +
            " area=" + DL_DbgAreaTagOrNone(oExit)
        );
    }

    if (bVerboseChairs && GetIsObjectValid(oFocusTarget))
    {
        string sExplicitChairTag = GetLocalString(oFocusTarget, "dl_chill_chair_tag");
        string sMealChairTag = GetLocalString(oFocusTarget, "dl_meal_chair_tag");
        DL_DbgPrintChairObject(oPC, "chill_chair_explicit", oNpc, oFocusTarget, sExplicitChairTag);
        DL_DbgPrintChairObject(oPC, "meal_chair_explicit", oNpc, oFocusTarget, sMealChairTag);
        DL_DbgPrintChairObject(oPC, "chill_chair_by_npc", oNpc, oFocusTarget, "dl_chill_" + GetTag(oNpc) + "_chair");
        DL_DbgPrintChairObject(oPC, "chill_chair_by_slot", oNpc, oFocusTarget, "dl_chill_chair_" + IntToString(GetLocalInt(oNpc, "dl_home_slot")));

        int i = 1;
        while (i <= DL_DBG_NEAR_SCAN_CAP)
        {
            DL_DbgPrintCandidateChair(oPC, oNpc, oFocusTarget, i);
            i = i + 1;
        }
    }
}
