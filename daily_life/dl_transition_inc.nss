// Daily Life simple transition/navigation helper.
// Builder contract:
//   waypoint tag: <from_zone>__<to_zone>
//   route local:  route_<current_zone>__<target_zone> = <next_zone>

const string DL_L_NPC_NAV_ZONE_CURRENT = "dl_npc_nav_zone_current";
const string DL_L_NPC_TRANSITION_STATUS = "dl_npc_transition_status";
const string DL_L_NPC_TRANSITION_TARGET = "dl_npc_transition_target";
const string DL_L_NPC_TRANSITION_DIAGNOSTIC = "dl_npc_transition_diagnostic";

const string DL_NAV_DELIMITER = "__";
const string DL_NAV_ROUTE_PREFIX = "route_";
const float DL_NAV_ENTRY_RADIUS = 1.60;
const int DL_NAV_AREA_SCAN_CAP = 128;

const string DL_L_AREA_NAV_READY = "dl_area_nav_ready";
const string DL_L_AREA_NAV_COUNT = "dl_area_nav_count";
const string DL_L_AREA_NAV_SLOT_PREFIX = "dl_area_nav_";
const int DL_AREA_NAV_ROUTE_CAP = 32;
const string DL_L_AREA_NAV_ZONE_ID = "dl_nav_zone_id";

string DL_GetAreaNavigationSlotKey(int nSlot)
{
    if (nSlot < 0) nSlot = 0;
    return DL_L_AREA_NAV_SLOT_PREFIX + IntToString(nSlot);
}

string DL_NavMakeTransitionTag(string sFromZone, string sToZone)
{
    if (sFromZone == "" || sToZone == "") return "";
    return sFromZone + DL_NAV_DELIMITER + sToZone;
}

string DL_NavMakeRouteKey(string sCurrentZone, string sTargetZone)
{
    if (sCurrentZone == "" || sTargetZone == "") return "";
    return DL_NAV_ROUTE_PREFIX + sCurrentZone + DL_NAV_DELIMITER + sTargetZone;
}

string DL_NavGetNpcCurrentZone(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return "";
    return GetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
}

void DL_NavSetNpcCurrentZone(object oNpc, string sZone)
{
    if (!GetIsObjectValid(oNpc)) return;
    if (sZone == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
        return;
    }
    SetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT, sZone);
}

void DL_ClearTransitionExecutionState(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
}

void DL_NavSetState(object oNpc, string sStatus, string sTargetZone, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc)) return;
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, sStatus);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, sTargetZone);
    if (sDiagnostic == "") DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
    else SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sDiagnostic);
}

string DL_NavGetNextZone(object oNpc, string sTargetZone)
{
    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    string sRouteKey = DL_NavMakeRouteKey(sCurrentZone, sTargetZone);
    if (sRouteKey == "") return "";

    object oArea = GetArea(oNpc);
    string sNextZone = "";
    if (GetIsObjectValid(oArea)) sNextZone = GetLocalString(oArea, sRouteKey);
    if (sNextZone != "") return sNextZone;

    return GetLocalString(GetModule(), sRouteKey);
}

object DL_NavFindTransitionInArea(object oArea, string sFromZone, string sToZone)
{
    if (!GetIsObjectValid(oArea)) return OBJECT_INVALID;

    string sTag = DL_NavMakeTransitionTag(sFromZone, sToZone);
    if (sTag == "") return OBJECT_INVALID;

    int nScanned = 0;
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj) && nScanned < DL_NAV_AREA_SCAN_CAP)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT && GetTag(oObj) == sTag)
        {
            return oObj;
        }
        oObj = GetNextObjectInArea(oArea);
        nScanned = nScanned + 1;
    }

    return OBJECT_INVALID;
}


string DL_NavGetAreaZoneId(object oArea)
{
    if (!GetIsObjectValid(oArea)) return "";

    string sZone = GetLocalString(oArea, DL_L_AREA_NAV_ZONE_ID);
    if (sZone != "") return sZone;

    return GetTag(oArea);
}

void DL_NavSyncCurrentZoneFromArea(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;
    if (GetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT) != "") return;

    string sCurrentZone = DL_NavGetAreaZoneId(GetArea(oNpc));
    if (sCurrentZone != "")
    {
        SetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT, sCurrentZone);
    }
}

void DL_NavPrepareTargetZoneFromAnchor(object oNpc, object oTargetAnchor)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTargetAnchor)) return;

    DL_NavSyncCurrentZoneFromArea(oNpc);

    string sTargetZone = DL_NavGetAreaZoneId(GetArea(oTargetAnchor));
    if (sTargetZone == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, sTargetZone);
}

int DL_WaypointHasTransition(object oWp)
{
    if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT) return FALSE;
    string sTag = GetTag(oWp);
    int nDelimiter = FindSubString(sTag, DL_NAV_DELIMITER);
    if (nDelimiter <= 0) return FALSE;
    if (nDelimiter >= GetStringLength(sTag) - 2) return FALSE;
    return TRUE;
}


object DL_ResolveTransitionExitWaypointFromEntry(object oEntryWp)
{
    if (!GetIsObjectValid(oEntryWp) || GetObjectType(oEntryWp) != OBJECT_TYPE_WAYPOINT)
    {
        return OBJECT_INVALID;
    }

    string sTag = GetTag(oEntryWp);
    int nDelimiter = FindSubString(sTag, DL_NAV_DELIMITER);
    if (nDelimiter <= 0 || nDelimiter >= GetStringLength(sTag) - 2)
    {
        return OBJECT_INVALID;
    }

    string sFrom = GetSubString(sTag, 0, nDelimiter);
    int nToStart = nDelimiter + 2;
    string sTo = GetSubString(sTag, nToStart, GetStringLength(sTag) - nToStart);
    if (sFrom == "" || sTo == "")
    {
        return OBJECT_INVALID;
    }

    return GetWaypointByTag(DL_NavMakeTransitionTag(sTo, sFrom));
}

int DL_NavTryAdvanceToZone(object oNpc, string sTargetZone)
{
    if (!GetIsObjectValid(oNpc) || sTargetZone == "") return FALSE;

    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    if (sCurrentZone == "")
    {
        DL_NavSetState(oNpc, "idle", sTargetZone, "current_zone_missing");
        return FALSE;
    }

    if (sCurrentZone == sTargetZone)
    {
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    string sNextZone = DL_NavGetNextZone(oNpc, sTargetZone);
    if (sNextZone == "")
    {
        DL_NavSetState(oNpc, "failed", sTargetZone, "route_missing");
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    object oEntry = DL_NavFindTransitionInArea(oArea, sCurrentZone, sNextZone);
    object oExit = OBJECT_INVALID;

    if (GetIsObjectValid(oEntry))
    {
        oExit = GetWaypointByTag(DL_NavMakeTransitionTag(sNextZone, sCurrentZone));
    }

    if (!GetIsObjectValid(oEntry) || !GetIsObjectValid(oExit))
    {
        DL_NavSetState(oNpc, "failed", sTargetZone, "transition_missing");
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oEntry) > DL_NAV_ENTRY_RADIUS)
    {
        AssignCommand(oNpc, ClearAllActions(TRUE));
        AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntry), TRUE));
        DL_NavSetState(oNpc, "moving_to_entry", sTargetZone, "");
        return TRUE;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(GetLocation(oExit)));
    DL_NavSetNpcCurrentZone(oNpc, sNextZone);
    DL_NavSetState(oNpc, "transitioning", sTargetZone, "");
    return TRUE;
}

int DL_TryUseNavigationRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget)) return FALSE;
    string sTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sTargetZone == "") return FALSE;
    return DL_NavTryAdvanceToZone(oNpc, sTargetZone);
}

int DL_TryExecuteTransitionAtWaypoint(object oNpc, object oTargetWp)
{
    if (!GetIsObjectValid(oNpc)) return FALSE;
    string sTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sTargetZone == "") return FALSE;
    return DL_NavTryAdvanceToZone(oNpc, sTargetZone);
}
