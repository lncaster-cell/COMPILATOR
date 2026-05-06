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
            "[DL DEBUG] time=" + DL_DbgPad2(GetTimeHour()) + ":" + DL_DbgPad2(GetTimeMinute()) + ":" + DL_DbgPad2(GetTimeSecond()) +
            " date=" + IntToString(GetCalendarYear()) + "/" + IntToString(GetCalendarMonth()) + "/" + IntToString(GetCalendarDay()) +
            " nearest_npc=NONE within " + FloatToString(DL_DBG_NPC_SCAN_RADIUS, 1, 1) + "m"
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
    string sStoredCurrent = GetLocalString(oNpc, "dl_npc_nav_zone_current");
    string sFocusTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    object oFocusTarget = DL_DbgFindObjectByTagInArea(oArea, sFocusTarget);
    string sFocusDist = "NA";
    if (GetIsObjectValid(oFocusTarget)) sFocusDist = DL_DbgFloat(GetDistanceBetween(oNpc, oFocusTarget));

    DL_DbgSay(oPC,
        "[DL DEBUG] time=" + DL_DbgPad2(GetTimeHour()) + ":" + DL_DbgPad2(GetTimeMinute()) + ":" + DL_DbgPad2(GetTimeSecond()) +
        " date=" + IntToString(GetCalendarYear()) + "/" + IntToString(GetCalendarMonth()) + "/" + IntToString(GetCalendarDay()) +
        " npc=" + GetName(oNpc) +
        " tag=" + GetTag(oNpc) +
        " profile=" + GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) +
        " area=" + DL_DbgAreaTagOrNone(oNpc) +
        " current_action=" + IntToString(GetCurrentAction(oNpc))
    );

    DL_DbgSay(oPC,
        "[DL DEBUG] now_dir=" + DL_DbgDirectiveLabel(nNowDirective) +
        " stored_dir=" + DL_DbgDirectiveLabel(nStoredDirective) +
        " state=" + GetLocalString(oNpc, DL_L_NPC_STATE) +
        " problem=" + DL_GetNpcProblemSummary(oNpc)
    );

    if (bVerbose)
    {
        DL_DbgSay(oPC,
            "[DL DEBUG] worker npc_seq=" + IntToString(GetLocalInt(oNpc, "dl_npc_worker_seq")) +
            " module_seq=" + IntToString(GetLocalInt(GetModule(), "dl_module_worker_seq")) +
            " module_ticks=" + IntToString(GetLocalInt(GetModule(), "dl_module_worker_ticks")) +
            " area_last_processed=" + IntToString(GetLocalInt(oArea, "dl_area_worker_last_processed")) +
            " reg_on=" + IntToString(GetLocalInt(oNpc, "dl_reg_on")) +
            " reg_slot=" + IntToString(GetLocalInt(oNpc, "dl_npc_reg_slot")) +
            " reg_count=" + IntToString(GetLocalInt(oArea, "dl_reg_count")) +
            " area_tier=" + IntToString(GetLocalInt(oArea, "dl_area_tier"))
        );
    }

    if (bVerbose || nNowDirective == DL_DIR_SLEEP || nStoredDirective == DL_DIR_SLEEP)
    {
        DL_DbgSay(oPC,
            "[DL DEBUG] sleep_status=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) +
            " sleep_target=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) +
            " sleep_diag=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC)
        );
    }

    if (bVerbose || nNowDirective == DL_DIR_WORK || nStoredDirective == DL_DIR_WORK)
    {
        DL_DbgSay(oPC,
            "[DL DEBUG] work_status=" + GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) +
            " work_target=" + GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) +
            " work_diag=" + GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC)
        );
    }

    DL_DbgSay(oPC,
        "[DL DEBUG] focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
        " focus_target=" + sFocusTarget +
        " focus_dist=" + sFocusDist +
        " focus_diag=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC)
    );

    DL_DbgSay(oPC,
        "[DL DEBUG] transition_status=" + sTransitionStatus +
        " transition_target=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) +
        " transition_diag=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC)
    );

    DL_DbgSay(oPC,
        "[DL DEBUG] nav_current=" + sCurrentZone +
        " nav_target=" + sTargetZone +
        " nav_next=" + sNextZone +
        " nav_reason=" + GetLocalString(oNpc, "dl_nav_debug_reason") +
        " stored_current=" + sStoredCurrent
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

    DL_DbgSay(oPC,
        "[DL DEBUG] seating_modes meal_npc=" + DL_DbgBool(GetLocalInt(oNpc, "dl_meal_waypoint_mode")) +
        " meal_wp=" + DL_DbgBool(GetIsObjectValid(oMealModeTarget) && GetLocalInt(oMealModeTarget, "dl_meal_waypoint_mode")) +
        " chill_npc=" + DL_DbgBool(GetLocalInt(oNpc, "dl_chill_waypoint_mode")) +
        " chill_wp=" + DL_DbgBool(GetIsObjectValid(oFocusTarget) && GetLocalInt(oFocusTarget, "dl_chill_waypoint_mode")) +
        " meal_waypoint=" + sMealWaypointTag +
        " focus_target_tag=" + sFocusTarget
    );

    object oCachedChair = GetLocalObject(oNpc, "dl_cache_chill_chair_obj");
    object oCachedMealChair = GetLocalObject(oNpc, "dl_cache_meal_chair_obj");
    object oCachedSitter = OBJECT_INVALID;
    object oCachedMealSitter = OBJECT_INVALID;
    string sCachedDist = "NA";
    string sCachedMealDist = "NA";
    if (GetIsObjectValid(oCachedChair))
    {
        oCachedSitter = GetSittingCreature(oCachedChair);
        if (GetIsObjectValid(oFocusTarget)) sCachedDist = DL_DbgFloat(GetDistanceBetweenLocations(GetLocation(oCachedChair), GetLocation(oFocusTarget)));
    }
    if (GetIsObjectValid(oCachedMealChair))
    {
        oCachedMealSitter = GetSittingCreature(oCachedMealChair);
        if (GetIsObjectValid(oFocusTarget)) sCachedMealDist = DL_DbgFloat(GetDistanceBetweenLocations(GetLocation(oCachedMealChair), GetLocation(oFocusTarget)));
    }

    DL_DbgSay(oPC,
        "[DL DEBUG] seating_secondary cached_chill_chair=" + DL_DbgObjTagOrNone(oCachedChair) +
        " cached_chill_dist=" + sCachedDist +
        " cached_chill_sitter=" + DL_DbgObjTagOrNone(oCachedSitter) +
        " cached_chill_npc_is_sitter=" + DL_DbgBool(oCachedSitter == oNpc) +
        " cached_meal_chair=" + DL_DbgObjTagOrNone(oCachedMealChair) +
        " cached_meal_dist=" + sCachedMealDist +
        " cached_meal_sitter=" + DL_DbgObjTagOrNone(oCachedMealSitter) +
        " cached_meal_npc_is_sitter=" + DL_DbgBool(oCachedMealSitter == oNpc)
    );

    if (bVerbose)
    {
        DL_DbgSay(oPC,
            "[DL DEBUG] focus_issue_target=" + GetLocalString(oNpc, "dl_focus_anchor_action_target") +
            " focus_issue_stamp=" + IntToString(GetLocalInt(oNpc, "dl_focus_anchor_action_stamp")) +
            " chill_retry_until=" + IntToString(GetLocalInt(oNpc, "dl_chill_sit_retry_until")) +
            " meal_retry_until=" + IntToString(GetLocalInt(oNpc, "dl_meal_sit_retry_until")) +
            " cache_chair_missing_until=" + IntToString(GetLocalInt(oNpc, "dl_cache_chill_chair_missing_until"))
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
            "[DL DEBUG] route_key=" + sRouteKey +
            " route_value=" + sRouteValue +
            " entry=" + sEntryTag +
            " entry_valid=" + DL_DbgBool(GetIsObjectValid(oEntry)) +
            " entry_dist=" + sEntryDist +
            " exit=" + sExitTag +
            " exit_valid=" + DL_DbgBool(GetIsObjectValid(oExit)) +
            " exit_area=" + DL_DbgAreaTagOrNone(oExit)
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
