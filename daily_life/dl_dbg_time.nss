// Deep Debug helper: attach to a placeable OnUsed event.
// Shows current module time and nearest Daily Life NPC runtime/navigation/focus state.
// Intended for builder/runtime smoke tests only.

#include "dl_runtime_contract_inc"
#include "dl_diag_inc"

const float DL_DBG_NPC_SCAN_RADIUS = 30.0;

string DL_DbgPad2(int nValue)
{
    if (nValue < 0)
    {
        nValue = 0;
    }
    if (nValue < 10)
    {
        return "0" + IntToString(nValue);
    }
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

object DL_DbgFindNearestDailyLifeNpc(object oUser)
{
    if (!GetIsObjectValid(oUser))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oUser);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

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

void DL_DbgSay(object oPC, string sText)
{
    SendMessageToPC(oPC, sText);
    FloatingTextStringOnCreature(sText, oPC, FALSE);
}

string DL_DbgTransitionTag(string sFromZone, string sToZone)
{
    if (sFromZone == "" || sToZone == "")
    {
        return "";
    }
    return sFromZone + "__" + sToZone;
}

string DL_DbgRouteKey(string sCurrentZone, string sTargetZone)
{
    if (sCurrentZone == "" || sTargetZone == "")
    {
        return "";
    }
    return "route_" + sCurrentZone + "__" + sTargetZone;
}

object DL_DbgFindWaypointByTagInArea(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT && GetTag(oObj) == sTag)
        {
            return oObj;
        }

        oObj = GetNextObjectInArea(oArea);
    }

    return OBJECT_INVALID;
}

object DL_DbgFindObjectByTagInArea(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        if (GetTag(oObj) == sTag)
        {
            return oObj;
        }

        oObj = GetNextObjectInArea(oArea);
    }

    return OBJECT_INVALID;
}

string DL_DbgObjTagOrNone(object oObj)
{
    if (!GetIsObjectValid(oObj))
    {
        return "NONE";
    }
    return GetTag(oObj);
}

string DL_DbgAreaTagOrNone(object oObj)
{
    if (!GetIsObjectValid(oObj))
    {
        return "NONE";
    }

    object oArea = GetArea(oObj);
    if (!GetIsObjectValid(oArea))
    {
        return "NONE";
    }

    return GetTag(oArea);
}

string DL_DbgFloat(float fValue)
{
    return FloatToString(fValue, 1, 2);
}

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC))
    {
        oPC = GetFirstPC();
    }

    if (!GetIsObjectValid(oPC))
    {
        return;
    }

    string sTime = "[DL DEBUG] time=" + DL_DbgPad2(GetTimeHour()) + ":" + DL_DbgPad2(GetTimeMinute()) + ":" + DL_DbgPad2(GetTimeSecond()) +
                   " date=" + IntToString(GetCalendarYear()) + "/" + IntToString(GetCalendarMonth()) + "/" + IntToString(GetCalendarDay());
    DL_DbgSay(oPC, sTime);

    object oNpc = DL_DbgFindNearestDailyLifeNpc(oPC);
    if (!GetIsObjectValid(oNpc))
    {
        DL_DbgSay(oPC, "[DL DEBUG] nearest_npc=NONE within " + FloatToString(DL_DBG_NPC_SCAN_RADIUS, 1, 1) + "m");
        return;
    }

    int nNowDirective = DL_ResolveNpcDirective(oNpc);
    int nStoredDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);

    string sNpc = "[DL DEBUG] npc=" + GetName(oNpc) +
                  " tag=" + GetTag(oNpc) +
                  " profile=" + GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) +
                  " area=" + DL_DbgAreaTagOrNone(oNpc) +
                  " action=" + IntToString(GetCurrentAction(oNpc)) +
                  " dist=" + DL_DbgFloat(GetDistanceBetween(oPC, oNpc));
    DL_DbgSay(oPC, sNpc);

    string sDirective = "[DL DEBUG] now_dir=" + DL_DbgDirectiveLabel(nNowDirective) +
                        " stored_dir=" + DL_DbgDirectiveLabel(nStoredDirective) +
                        " state=" + GetLocalString(oNpc, DL_L_NPC_STATE) +
                        " problem=" + DL_GetNpcProblemSummary(oNpc);
    DL_DbgSay(oPC, sDirective);

    string sSleep = "[DL DEBUG] sleep_status=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) +
                    " sleep_target=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) +
                    " sleep_diag=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_DbgSay(oPC, sSleep);

    string sWork = "[DL DEBUG] work_status=" + GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) +
                   " work_target=" + GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) +
                   " work_diag=" + GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    DL_DbgSay(oPC, sWork);

    string sFocusTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    object oFocusTarget = DL_DbgFindObjectByTagInArea(GetArea(oNpc), sFocusTarget);
    string sFocusDist = "NA";
    if (GetIsObjectValid(oFocusTarget))
    {
        sFocusDist = DL_DbgFloat(GetDistanceBetween(oNpc, oFocusTarget));
    }

    string sFocus = "[DL DEBUG] focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
                    " focus_target=" + sFocusTarget +
                    " focus_target_valid=" + (GetIsObjectValid(oFocusTarget) ? "1" : "0") +
                    " focus_target_area=" + DL_DbgAreaTagOrNone(oFocusTarget) +
                    " focus_dist=" + sFocusDist +
                    " focus_diag=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DL_DbgSay(oPC, sFocus);

    string sFocusIssue = "[DL DEBUG] focus_issue_target=" + GetLocalString(oNpc, "dl_focus_anchor_action_target") +
                         " focus_issue_stamp=" + IntToString(GetLocalInt(oNpc, "dl_focus_anchor_action_stamp")) +
                         " chill_retry_until=" + IntToString(GetLocalInt(oNpc, "dl_chill_sit_retry_until")) +
                         " meal_retry_until=" + IntToString(GetLocalInt(oNpc, "dl_meal_sit_retry_until"));
    DL_DbgSay(oPC, sFocusIssue);

    string sTransition = "[DL DEBUG] transition_status=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) +
                         " transition_target=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) +
                         " transition_diag=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
    DL_DbgSay(oPC, sTransition);

    string sCurrentZone = GetLocalString(oNpc, "dl_nav_debug_current");
    string sTargetZone = GetLocalString(oNpc, "dl_nav_debug_target");
    string sNextZone = GetLocalString(oNpc, "dl_nav_debug_next");
    string sStoredCurrent = GetLocalString(oNpc, "dl_npc_nav_zone_current");

    string sNav = "[DL DEBUG] nav_current=" + sCurrentZone +
                  " nav_target=" + sTargetZone +
                  " nav_next=" + sNextZone +
                  " nav_reason=" + GetLocalString(oNpc, "dl_nav_debug_reason") +
                  " stored_current=" + sStoredCurrent;
    DL_DbgSay(oPC, sNav);

    object oArea = GetArea(oNpc);
    string sRouteKey = DL_DbgRouteKey(sStoredCurrent, sTargetZone);
    string sRouteValue = "";
    if (GetIsObjectValid(oArea) && sRouteKey != "")
    {
        sRouteValue = GetLocalString(oArea, sRouteKey);
    }

    string sEntryTag = DL_DbgTransitionTag(sStoredCurrent, sRouteValue);
    string sExitTag = DL_DbgTransitionTag(sRouteValue, sStoredCurrent);
    object oEntry = DL_DbgFindWaypointByTagInArea(oArea, sEntryTag);
    object oExit = GetWaypointByTag(sExitTag);

    string sEntryDist = "NA";
    if (GetIsObjectValid(oEntry))
    {
        sEntryDist = DL_DbgFloat(GetDistanceBetween(oNpc, oEntry));
    }

    string sNavRoute = "[DL DEBUG] route_key=" + sRouteKey +
                       " route_value=" + sRouteValue +
                       " entry=" + sEntryTag +
                       " entry_valid=" + (GetIsObjectValid(oEntry) ? "1" : "0") +
                       " entry_dist=" + sEntryDist +
                       " exit=" + sExitTag +
                       " exit_valid=" + (GetIsObjectValid(oExit) ? "1" : "0") +
                       " exit_area=" + DL_DbgAreaTagOrNone(oExit);
    DL_DbgSay(oPC, sNavRoute);
}
