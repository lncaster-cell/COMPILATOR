// Daily Life Nav/Transition v2 foundation.
//
// Minimal static route executor. This file is intentionally not wired into
// sleep/work/meal yet.
//
// Builder contract v1:
// - transition waypoint tag: <from_zone>__<to_zone>
// - route local string: route_<current_zone>__<target_zone> = <next_zone>
//
// Example:
//   waypoint: blacksmith_workshop__blacksmith_hall
//   waypoint: blacksmith_hall__blacksmith_workshop
//   area local: route_blacksmith_workshop__theater = blacksmith_hall

const string DL_NAV_V2_DELIMITER = "__";
const string DL_NAV_V2_ROUTE_PREFIX = "route_";

const string DL_L_NPC_NAV_ZONE_CURRENT = "dl_npc_nav_zone_current";
const string DL_L_NPC_NAV_V2_STATUS = "dl_npc_nav_v2_status";
const string DL_L_NPC_NAV_V2_TARGET = "dl_npc_nav_v2_target";
const string DL_L_NPC_NAV_V2_DIAGNOSTIC = "dl_npc_nav_v2_diagnostic";

const string DL_L_AREA_NAV_V2_READY = "dl_nav_v2_ready";
const string DL_L_AREA_NAV_V2_COUNT = "dl_nav_v2_count";
const string DL_L_AREA_NAV_V2_SLOT_PREFIX = "dl_nav_v2_slot_";

const int DL_NAV_V2_ROUTE_CAP = 64;
const float DL_NAV_V2_ENTRY_RADIUS = 1.60;

string DL_NavV2GetSlotKey(int nSlot)
{
    if (nSlot < 0)
    {
        nSlot = 0;
    }

    return DL_L_AREA_NAV_V2_SLOT_PREFIX + IntToString(nSlot);
}

int DL_NavV2FindDelimiter(string sValue)
{
    return FindSubString(sValue, DL_NAV_V2_DELIMITER);
}

int DL_NavV2IsTransitionTag(string sTag)
{
    int nDelimiter = DL_NavV2FindDelimiter(sTag);
    if (nDelimiter <= 0)
    {
        return FALSE;
    }

    if (nDelimiter >= GetStringLength(sTag) - 2)
    {
        return FALSE;
    }

    return TRUE;
}

string DL_NavV2GetFromZoneFromTag(string sTag)
{
    int nDelimiter = DL_NavV2FindDelimiter(sTag);
    if (nDelimiter <= 0)
    {
        return "";
    }

    return GetSubString(sTag, 0, nDelimiter);
}

string DL_NavV2GetToZoneFromTag(string sTag)
{
    int nDelimiter = DL_NavV2FindDelimiter(sTag);
    if (nDelimiter <= 0)
    {
        return "";
    }

    int nStart = nDelimiter + 2;
    return GetSubString(sTag, nStart, GetStringLength(sTag) - nStart);
}

string DL_NavV2MakeTransitionTag(string sFromZone, string sToZone)
{
    if (sFromZone == "" || sToZone == "")
    {
        return "";
    }

    return sFromZone + DL_NAV_V2_DELIMITER + sToZone;
}

string DL_NavV2MakeRouteKey(string sCurrentZone, string sTargetZone)
{
    if (sCurrentZone == "" || sTargetZone == "")
    {
        return "";
    }

    return DL_NAV_V2_ROUTE_PREFIX + sCurrentZone + DL_NAV_V2_DELIMITER + sTargetZone;
}

void DL_NavV2ClearState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalString(oNpc, DL_L_NPC_NAV_V2_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_NAV_V2_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_NAV_V2_DIAGNOSTIC);
}

void DL_NavV2SetState(object oNpc, string sStatus, string sTarget, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_NAV_V2_STATUS, sStatus);
    SetLocalString(oNpc, DL_L_NPC_NAV_V2_TARGET, sTarget);

    if (sDiagnostic == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_NAV_V2_DIAGNOSTIC);
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_NAV_V2_DIAGNOSTIC, sDiagnostic);
    }
}

string DL_NavV2GetNpcCurrentZone(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return "";
    }

    return GetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
}

void DL_NavV2SetNpcCurrentZone(object oNpc, string sZone)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (sZone == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT, sZone);
}

string DL_NavV2GetNextZone(object oNpc, string sTargetZone)
{
    if (!GetIsObjectValid(oNpc) || sTargetZone == "")
    {
        return "";
    }

    string sCurrentZone = DL_NavV2GetNpcCurrentZone(oNpc);
    string sRouteKey = DL_NavV2MakeRouteKey(sCurrentZone, sTargetZone);
    if (sRouteKey == "")
    {
        return "";
    }

    object oArea = GetArea(oNpc);
    string sNextZone = "";
    if (GetIsObjectValid(oArea))
    {
        sNextZone = GetLocalString(oArea, sRouteKey);
    }

    if (sNextZone != "")
    {
        return sNextZone;
    }

    return GetLocalString(GetModule(), sRouteKey);
}

void DL_NavV2ClearAreaCache(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int i = 0;
    while (i < DL_NAV_V2_ROUTE_CAP)
    {
        DeleteLocalObject(oArea, DL_NavV2GetSlotKey(i));
        i = i + 1;
    }

    DeleteLocalInt(oArea, DL_L_AREA_NAV_V2_READY);
    DeleteLocalInt(oArea, DL_L_AREA_NAV_V2_COUNT);
}

void DL_NavV2BuildAreaCache(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, DL_L_AREA_NAV_V2_READY) == TRUE)
    {
        return;
    }

    DL_NavV2ClearAreaCache(oArea);

    int nCount = 0;
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj) && nCount < DL_NAV_V2_ROUTE_CAP)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT && DL_NavV2IsTransitionTag(GetTag(oObj)))
        {
            SetLocalObject(oArea, DL_NavV2GetSlotKey(nCount), oObj);
            nCount = nCount + 1;
        }

        oObj = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, DL_L_AREA_NAV_V2_COUNT, nCount);
    SetLocalInt(oArea, DL_L_AREA_NAV_V2_READY, TRUE);
}

int DL_NavV2GetAreaCacheCount(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    DL_NavV2BuildAreaCache(oArea);

    int nCount = GetLocalInt(oArea, DL_L_AREA_NAV_V2_COUNT);
    if (nCount < 0)
    {
        return 0;
    }
    if (nCount > DL_NAV_V2_ROUTE_CAP)
    {
        return DL_NAV_V2_ROUTE_CAP;
    }

    return nCount;
}

object DL_NavV2GetCachedTransitionAt(object oArea, int nSlot)
{
    if (!GetIsObjectValid(oArea) || nSlot < 0 || nSlot >= DL_NAV_V2_ROUTE_CAP)
    {
        return OBJECT_INVALID;
    }

    DL_NavV2BuildAreaCache(oArea);
    return GetLocalObject(oArea, DL_NavV2GetSlotKey(nSlot));
}

object DL_NavV2FindTransitionInArea(object oArea, string sFromZone, string sToZone)
{
    if (!GetIsObjectValid(oArea) || sFromZone == "" || sToZone == "")
    {
        return OBJECT_INVALID;
    }

    string sWantedTag = DL_NavV2MakeTransitionTag(sFromZone, sToZone);
    int nCount = DL_NavV2GetAreaCacheCount(oArea);
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_NavV2GetCachedTransitionAt(oArea, i);
        if (GetIsObjectValid(oEntry) && GetTag(oEntry) == sWantedTag && GetArea(oEntry) == oArea)
        {
            return oEntry;
        }

        i = i + 1;
    }

    return OBJECT_INVALID;
}

object DL_NavV2FindExitWaypoint(object oNpc, string sFromZone, string sToZone)
{
    if (!GetIsObjectValid(oNpc) || sFromZone == "" || sToZone == "")
    {
        return OBJECT_INVALID;
    }

    object oCurrentArea = GetArea(oNpc);
    object oExit = DL_NavV2FindTransitionInArea(oCurrentArea, sToZone, sFromZone);
    if (GetIsObjectValid(oExit))
    {
        return oExit;
    }

    string sExitTag = DL_NavV2MakeTransitionTag(sToZone, sFromZone);
    oExit = GetWaypointByTag(sExitTag);
    if (GetIsObjectValid(oExit) && GetObjectType(oExit) == OBJECT_TYPE_WAYPOINT)
    {
        return oExit;
    }

    return OBJECT_INVALID;
}

int DL_NavV2IsValidLocation(location lTarget)
{
    object oArea = GetAreaFromLocation(lTarget);
    return GetIsObjectValid(oArea);
}

int DL_NavV2TryAdvanceToZone(object oNpc, string sTargetZone)
{
    if (!GetIsObjectValid(oNpc) || sTargetZone == "")
    {
        return FALSE;
    }

    string sCurrentZone = DL_NavV2GetNpcCurrentZone(oNpc);
    if (sCurrentZone == "")
    {
        DL_NavV2SetState(oNpc, "failed", sTargetZone, "missing_current_zone");
        return FALSE;
    }

    if (sCurrentZone == sTargetZone)
    {
        DL_NavV2ClearState(oNpc);
        return FALSE;
    }

    string sNextZone = DL_NavV2GetNextZone(oNpc, sTargetZone);
    if (sNextZone == "")
    {
        DL_NavV2SetState(oNpc, "failed", sTargetZone, "route_missing");
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    object oEntry = DL_NavV2FindTransitionInArea(oArea, sCurrentZone, sNextZone);
    if (!GetIsObjectValid(oEntry))
    {
        DL_NavV2SetState(oNpc, "failed", DL_NavV2MakeTransitionTag(sCurrentZone, sNextZone), "entry_missing");
        return FALSE;
    }

    object oExit = DL_NavV2FindExitWaypoint(oNpc, sCurrentZone, sNextZone);
    if (!GetIsObjectValid(oExit))
    {
        DL_NavV2SetState(oNpc, "failed", DL_NavV2MakeTransitionTag(sNextZone, sCurrentZone), "exit_missing");
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oEntry) > DL_NAV_V2_ENTRY_RADIUS)
    {
        DL_NavV2SetState(oNpc, "moving_to_entry", GetTag(oEntry), "");
        AssignCommand(oNpc, ClearAllActions(TRUE));
        AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntry), TRUE));
        return TRUE;
    }

    location lExit = GetLocation(oExit);
    if (!DL_NavV2IsValidLocation(lExit))
    {
        DL_NavV2SetState(oNpc, "failed", GetTag(oExit), "invalid_exit_location");
        return FALSE;
    }

    DL_NavV2SetState(oNpc, "transitioning", GetTag(oEntry), "");
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lExit));
    DL_NavV2SetNpcCurrentZone(oNpc, sNextZone);
    return TRUE;
}
