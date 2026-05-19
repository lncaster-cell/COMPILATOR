#include "nw_i0_plot"

void DL_SetupSendToAll(string sMessage)
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);
        oPC = GetNextPC();
    }
}

int DL_SetupIsVerbose()
{
    if (GetLocalInt(GetModule(), "dl_setup_verbose") == 1)
    {
        return TRUE;
    }

    if (GetLocalInt(OBJECT_SELF, "dl_setup_verbose") == 1)
    {
        return TRUE;
    }

    return FALSE;
}

void DL_SetupPrintOk(string sMessage)
{
    if (DL_SetupIsVerbose())
    {
        DL_SetupSendToAll("OK " + sMessage);
    }
}

void DL_SetupPrintWarn(string sMessage)
{
    DL_SetupSendToAll("WARN " + sMessage);
}

void DL_SetupPrintError(string sMessage)
{
    DL_SetupSendToAll("ERROR " + sMessage);
}

void DL_SetupPrintResult(string sNpcTag, int nErrors, int nWarnings)
{
    DL_SetupSendToAll("DL_SETUP " + sNpcTag + " RESULT errors=" + IntToString(nErrors) + " warnings=" + IntToString(nWarnings));
    DL_SetupSendToAll("DL_SETUP " + sNpcTag + " END");
}

int DL_SetupCheckRequiredStringLocal(object oNpc, string sLocalName, int nErrors)
{
    string sValue = GetLocalString(oNpc, sLocalName);
    if (sValue == "")
    {
        DL_SetupPrintError("missing local " + sLocalName);
        return nErrors + 1;
    }

    DL_SetupPrintOk("local " + sLocalName + "=" + sValue);
    return nErrors;
}

int DL_SetupCheckRequiredHomeSlot(object oNpc, int nErrors)
{
    string sSlot = GetLocalString(oNpc, "dl_home_slot");
    if (sSlot == "")
    {
        int nSlotInt = GetLocalInt(oNpc, "dl_home_slot");
        if (nSlotInt > 0)
        {
            sSlot = IntToString(nSlotInt);
        }
    }

    if (sSlot == "")
    {
        DL_SetupPrintError("missing local dl_home_slot");
        return nErrors + 1;
    }

    DL_SetupPrintOk("local dl_home_slot=" + sSlot);
    return nErrors;
}

object DL_SetupResolveAreaByTag(string sAreaTag)
{
    object oArea = GetObjectByTag(sAreaTag, 0);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    return oArea;
}

int DL_SetupCheckAreaTag(string sLabel, string sAreaTag, int nErrors)
{
    if (sAreaTag == "")
    {
        return nErrors;
    }

    object oArea = DL_SetupResolveAreaByTag(sAreaTag);
    if (!GetIsObjectValid(oArea))
    {
        DL_SetupPrintError("local " + sLabel + "=" + sAreaTag + " area_resolved=0");
        return nErrors + 1;
    }

    DL_SetupPrintOk("local " + sLabel + "=" + sAreaTag + " area_resolved=1");
    return nErrors;
}

object DL_SetupFindTagInArea(object oArea, string sTag)
{
    object oObj = GetObjectByTag(sTag, 0);
    while (GetIsObjectValid(oObj))
    {
        if (GetArea(oObj) == oArea)
        {
            return oObj;
        }
        oObj = GetObjectByTag(sTag, 1);
    }
    return OBJECT_INVALID;
}

int DL_SetupCheckWaypointInArea(object oArea, string sWpTag, string sLabel, int nErrors, int bWarnOnly)
{
    if (!GetIsObjectValid(oArea))
    {
        return nErrors;
    }

    object oWp = DL_SetupFindTagInArea(oArea, sWpTag);
    if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT)
    {
        if (bWarnOnly)
        {
            DL_SetupPrintWarn("missing " + sLabel + " tag=" + sWpTag + " area=" + GetTag(oArea));
            return nErrors;
        }
        DL_SetupPrintError("missing " + sLabel + " tag=" + sWpTag + " area=" + GetTag(oArea));
        return nErrors + 1;
    }

    DL_SetupPrintOk(sLabel + " tag=" + sWpTag + " area=" + GetTag(oArea));
    return nErrors;
}

int DL_SetupCheckAreaAnchor(object oArea, string sLocalName, int nErrors, int bWarnOnly)
{
    if (!GetIsObjectValid(oArea))
    {
        return nErrors;
    }

    string sTag = GetLocalString(oArea, sLocalName);
    if (sTag == "")
    {
        if (bWarnOnly)
        {
            DL_SetupPrintWarn("missing area local " + sLocalName + " on " + GetTag(oArea));
            return nErrors;
        }
        DL_SetupPrintError("missing area local " + sLocalName + " on " + GetTag(oArea));
        return nErrors + 1;
    }

    return DL_SetupCheckWaypointInArea(oArea, sTag, "anchor " + sLocalName, nErrors, bWarnOnly);
}

void DL_SetupPrintNavZone(object oObj, string sLabel)
{
    if (!GetIsObjectValid(oObj))
    {
        return;
    }

    string sZone = GetLocalString(oObj, "dl_nav_zone_id");
    if (sZone == "")
    {
        DL_SetupPrintWarn(sLabel + " dl_nav_zone_id missing; fallback inference may be used");
        return;
    }

    DL_SetupPrintOk(sLabel + " dl_nav_zone_id=" + sZone);
}

void DL_SetupPrintAnchorNavZone(object oArea, string sAnchorLocal)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    string sAnchorTag = GetLocalString(oArea, sAnchorLocal);
    if (sAnchorTag == "")
    {
        return;
    }

    object oAnchor = DL_SetupFindTagInArea(oArea, sAnchorTag);
    if (!GetIsObjectValid(oAnchor))
    {
        return;
    }

    string sZone = GetLocalString(oAnchor, "dl_nav_zone_id");
    if (sZone == "")
    {
        DL_SetupPrintWarn("anchor " + sAnchorTag + " dl_nav_zone_id missing; zone may be inferred from transition or area default");
        return;
    }

    DL_SetupPrintOk("anchor " + sAnchorTag + " dl_nav_zone_id=" + sZone);
}

int DL_SetupCheckRoute(object oSourceArea, object oModule, string sFromZone, string sTargetZone, int nErrors)
{
    string sKey = "route_" + sFromZone + "__" + sTargetZone;
    string sNext = "";

    if (GetIsObjectValid(oSourceArea))
    {
        sNext = GetLocalString(oSourceArea, sKey);
    }

    if (sNext == "")
    {
        sNext = GetLocalString(oModule, sKey);
    }

    if (sNext == "")
    {
        DL_SetupPrintError("missing " + sKey);
        return nErrors + 1;
    }

    DL_SetupPrintOk(sKey + "=" + sNext);
    return nErrors;
}

int DL_SetupCheckTransitionWaypoint(string sWpTag, string sExpectedAreaTag, int nErrors)
{
    object oWp = GetObjectByTag(sWpTag, 0);
    if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT)
    {
        DL_SetupPrintError("missing transition tag=" + sWpTag);
        return nErrors + 1;
    }

    object oFoundArea = GetArea(oWp);
    string sFoundAreaTag = "";
    if (GetIsObjectValid(oFoundArea))
    {
        sFoundAreaTag = GetTag(oFoundArea);
    }

    DL_SetupPrintOk("transition tag=" + sWpTag + " found_area=" + sFoundAreaTag);

    if (sExpectedAreaTag != "" && sFoundAreaTag != "" && sFoundAreaTag != sExpectedAreaTag)
    {
        DL_SetupPrintWarn("transition tag=" + sWpTag + " expected_area=" + sExpectedAreaTag + " found_area=" + sFoundAreaTag);
    }

    return nErrors;
}

void main()
{
    string sNpcTag = "blacksmith01";
    int nErrors = 0;
    int nWarnings = 0;

    DL_SetupSendToAll("DL_SETUP " + sNpcTag + " BEGIN");

    object oNpc = GetObjectByTag(sNpcTag, 0);
    if (!GetIsObjectValid(oNpc))
    {
        DL_SetupSendToAll("ERROR npc not found tag=" + sNpcTag);
        DL_SetupPrintResult(sNpcTag, 1, 0);
        return;
    }

    DL_SetupPrintOk("npc exists area=" + GetTag(GetArea(oNpc)));

    nErrors = DL_SetupCheckRequiredStringLocal(oNpc, "dl_profile_id", nErrors);

    string sHomeAreaTag = GetLocalString(oNpc, "dl_home_area_tag");
    string sMealAreaTag = GetLocalString(oNpc, "dl_meal_area_tag");
    string sWorkAreaTag = GetLocalString(oNpc, "dl_work_area_tag");
    string sPublicAreaTag = GetLocalString(oNpc, "dl_public_area_tag");
    string sSocialAreaTag = GetLocalString(oNpc, "dl_social_area_tag");
    string sSocialSlot = GetLocalString(oNpc, "dl_social_slot");
    string sSocialPartner = GetLocalString(oNpc, "dl_social_partner_tag");

    nErrors = DL_SetupCheckRequiredStringLocal(oNpc, "dl_home_area_tag", nErrors);
    nErrors = DL_SetupCheckRequiredHomeSlot(oNpc, nErrors);
    nErrors = DL_SetupCheckRequiredStringLocal(oNpc, "dl_meal_area_tag", nErrors);

    if (sWorkAreaTag == "") { DL_SetupPrintWarn("missing local dl_work_area_tag"); nWarnings = nWarnings + 1; }
    else { DL_SetupPrintOk("local dl_work_area_tag=" + sWorkAreaTag); }
    if (sPublicAreaTag == "") { DL_SetupPrintWarn("missing local dl_public_area_tag"); nWarnings = nWarnings + 1; }
    else { DL_SetupPrintOk("local dl_public_area_tag=" + sPublicAreaTag); }
    if (sSocialAreaTag == "") { DL_SetupPrintWarn("missing local dl_social_area_tag"); nWarnings = nWarnings + 1; }
    else { DL_SetupPrintOk("local dl_social_area_tag=" + sSocialAreaTag); }
    if (sSocialSlot == "") { DL_SetupPrintWarn("missing local dl_social_slot"); nWarnings = nWarnings + 1; }
    else { DL_SetupPrintOk("local dl_social_slot=" + sSocialSlot); }
    if (sSocialPartner == "") { DL_SetupPrintWarn("missing local dl_social_partner_tag"); nWarnings = nWarnings + 1; }
    else { DL_SetupPrintOk("local dl_social_partner_tag=" + sSocialPartner); }

    nErrors = DL_SetupCheckAreaTag("dl_home_area_tag", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckAreaTag("dl_meal_area_tag", sMealAreaTag, nErrors);
    nErrors = DL_SetupCheckAreaTag("dl_work_area_tag", sWorkAreaTag, nErrors);
    nErrors = DL_SetupCheckAreaTag("dl_public_area_tag", sPublicAreaTag, nErrors);
    nErrors = DL_SetupCheckAreaTag("dl_social_area_tag", sSocialAreaTag, nErrors);

    object oHomeArea = DL_SetupResolveAreaByTag(sHomeAreaTag);
    object oMealArea = DL_SetupResolveAreaByTag(sMealAreaTag);
    object oWorkArea = DL_SetupResolveAreaByTag(sWorkAreaTag);
    object oPublicArea = DL_SetupResolveAreaByTag(sPublicAreaTag);
    object oSocialArea = DL_SetupResolveAreaByTag(sSocialAreaTag);
    object oModule = GetModule();

    string sAreaList = "";
    if (GetIsObjectValid(oHomeArea)) { sAreaList = GetTag(oHomeArea); }
    if (GetIsObjectValid(oMealArea) && oMealArea != oHomeArea) { if (sAreaList != "") sAreaList += ", "; sAreaList += GetTag(oMealArea); }
    if (GetIsObjectValid(oWorkArea) && oWorkArea != oHomeArea && oWorkArea != oMealArea) { if (sAreaList != "") sAreaList += ", "; sAreaList += GetTag(oWorkArea); }
    if (GetIsObjectValid(oPublicArea) && oPublicArea != oHomeArea && oPublicArea != oMealArea && oPublicArea != oWorkArea) { if (sAreaList != "") sAreaList += ", "; sAreaList += GetTag(oPublicArea); }
    if (GetIsObjectValid(oSocialArea) && oSocialArea != oHomeArea && oSocialArea != oMealArea && oSocialArea != oWorkArea && oSocialArea != oPublicArea) { if (sAreaList != "") sAreaList += ", "; sAreaList += GetTag(oSocialArea); }
    if (sAreaList != "")
    {
        DL_SetupPrintWarn("area script introspection unavailable; manually verify dl_a_hb/dl_a_enter/dl_a_exit on areas: " + sAreaList);
        nWarnings = nWarnings + 1;
    }

    string sHomeSlot = GetLocalString(oNpc, "dl_home_slot");
    if (sHomeSlot == "")
    {
        int nSlotInt = GetLocalInt(oNpc, "dl_home_slot");
        if (nSlotInt > 0) { sHomeSlot = IntToString(nSlotInt); }
    }

    if (GetIsObjectValid(oMealArea))
    {
        string sMealAnchor = GetLocalString(oMealArea, "dl_anchor_meal");
        if (sMealAnchor != "")
        {
            nErrors = DL_SetupCheckWaypointInArea(oMealArea, sMealAnchor, "meal anchor", nErrors, FALSE);
        }
        else
        {
            nErrors = DL_SetupCheckWaypointInArea(oMealArea, "dl_meal_" + sHomeSlot, "meal fallback", nErrors, FALSE);
        }
    }

    nErrors = DL_SetupCheckWaypointInArea(oHomeArea, "dl_chill_seat_" + sHomeSlot, "chill fallback", nErrors, FALSE);
    nErrors = DL_SetupCheckWaypointInArea(oHomeArea, "dl_sleep_approach_" + sHomeSlot, "sleep approach", nErrors, FALSE);
    nErrors = DL_SetupCheckWaypointInArea(oHomeArea, "dl_sleep_bed_" + sHomeSlot, "sleep bed", nErrors, TRUE);

    nErrors = DL_SetupCheckAreaAnchor(oPublicArea, "dl_anchor_public", nErrors, FALSE);

    if (GetIsObjectValid(oSocialArea))
    {
        if (sSocialSlot == "a")
        {
            string sA = GetLocalString(oSocialArea, "dl_anchor_social_a");
            if (sA != "") nErrors = DL_SetupCheckWaypointInArea(oSocialArea, sA, "social slot a anchor", nErrors, FALSE);
            else nErrors = DL_SetupCheckAreaAnchor(oSocialArea, "dl_anchor_social", nErrors, FALSE);
        }
        else if (sSocialSlot == "b")
        {
            string sB = GetLocalString(oSocialArea, "dl_anchor_social_b");
            if (sB != "") nErrors = DL_SetupCheckWaypointInArea(oSocialArea, sB, "social slot b anchor", nErrors, FALSE);
            else nErrors = DL_SetupCheckAreaAnchor(oSocialArea, "dl_anchor_social", nErrors, FALSE);
        }
        else
        {
            nErrors = DL_SetupCheckAreaAnchor(oSocialArea, "dl_anchor_social", nErrors, FALSE);
        }
    }

    DL_SetupPrintNavZone(oHomeArea, "area " + sHomeAreaTag);
    DL_SetupPrintNavZone(oMealArea, "area " + sMealAreaTag);
    DL_SetupPrintNavZone(oWorkArea, "area " + sWorkAreaTag);
    DL_SetupPrintNavZone(oPublicArea, "area " + sPublicAreaTag);
    DL_SetupPrintNavZone(oSocialArea, "area " + sSocialAreaTag);
    DL_SetupPrintAnchorNavZone(oPublicArea, "dl_anchor_public");
    DL_SetupPrintAnchorNavZone(oSocialArea, "dl_anchor_social");
    DL_SetupPrintAnchorNavZone(oSocialArea, "dl_anchor_social_a");
    DL_SetupPrintAnchorNavZone(oSocialArea, "dl_anchor_social_b");

    nErrors = DL_SetupCheckTransitionWaypoint("gotha_smith_bedroom__gotha_smith_main", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_smith_main__gotha_smith_bedroom", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_smith_backroom__gotha_smith_main", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_smith_main__gotha_smith_backroom", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_smith_main__gotha_cavenue", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_cavenue__gotha_smith_main", sHomeAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_cavenue__gotha_tavern", sPublicAreaTag, nErrors);
    nErrors = DL_SetupCheckTransitionWaypoint("gotha_tavern__gotha_cavenue", sPublicAreaTag, nErrors);

    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_bedroom", "gotha_cavenue", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_backroom", "gotha_cavenue", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_main", "gotha_cavenue", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_bedroom", "gotha_tavern", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_backroom", "gotha_tavern", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_main", "gotha_tavern", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_cavenue", "gotha_tavern", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_cavenue", "gotha_smith_bedroom", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_cavenue", "gotha_smith_backroom", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_cavenue", "gotha_smith_main", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_tavern", "gotha_cavenue", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_tavern", "gotha_smith_bedroom", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_tavern", "gotha_smith_backroom", nErrors);
    nErrors = DL_SetupCheckRoute(oPublicArea, oModule, "gotha_tavern", "gotha_smith_main", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_bedroom", "gotha_smith_main", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_backroom", "gotha_smith_main", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_main", "gotha_smith_bedroom", nErrors);
    nErrors = DL_SetupCheckRoute(oHomeArea, oModule, "gotha_smith_main", "gotha_smith_backroom", nErrors);

    DL_SetupPrintResult(sNpcTag, nErrors, nWarnings);
}
