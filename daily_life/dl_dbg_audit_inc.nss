// Daily Life subsystem audit helpers for the existing placeable debug script.
// This is an include, not a separate entry script.

// Forward declaration: implemented by the debug entry script that includes this file.
void DL_DbgSay(object oPC, string sText);

string DL_AuditPF(int bPass)
{
    return bPass ? "PASS" : "FAIL";
}

string DL_AuditYN(int bValue)
{
    return bValue ? "yes" : "no";
}

string DL_AuditObjTag(object oObj)
{
    if (!GetIsObjectValid(oObj))
    {
        return "INVALID";
    }
    string sTag = GetTag(oObj);
    return sTag == "" ? "<no_tag>" : sTag;
}

string DL_AuditAreaTag(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return "INVALID";
    }
    string sTag = GetTag(oArea);
    return sTag == "" ? "<area_no_tag>" : sTag;
}

string DL_AuditObjAreaTag(object oObj)
{
    if (!GetIsObjectValid(oObj))
    {
        return "INVALID";
    }
    return DL_AuditAreaTag(GetArea(oObj));
}

void DL_AuditFail(object oNpc, string sKey)
{
    if (GetIsObjectValid(oNpc) && sKey != "" && GetLocalString(oNpc, "dl_dbg_first_fail") == "")
    {
        SetLocalString(oNpc, "dl_dbg_first_fail", sKey);
    }
}
void DL_AuditAddFixHint(object oNpc, string sHint)
{
    if (!GetIsObjectValid(oNpc) || sHint == "")
    {
        return;
    }

    string sNow = GetLocalString(oNpc, "dl_dbg_fix_hints");
    if (sNow == "")
    {
        SetLocalString(oNpc, "dl_dbg_fix_hints", sHint);
        return;
    }

    if (FindSubString(sNow, sHint) >= 0)
    {
        return;
    }

    SetLocalString(oNpc, "dl_dbg_fix_hints", sNow + " || " + sHint);
}

object DL_AuditFindWpInArea(string sTag, object oArea)
{
    if (sTag == "" || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }
    return DL_FindObjectByTagInAreaDeterministic(sTag, OBJECT_TYPE_WAYPOINT, oArea, DL_WAYPOINT_TAG_SEARCH_CAP);
}

void DL_AuditRuntime(object oPC, object oNpc)
{
    object oArea = GetArea(oNpc);
    int bRuntime = DL_IsRuntimeEnabled();
    int bPipeline = DL_IsPipelineNpc(oNpc);
    int bActive = DL_IsActivePipelineNpc(oNpc);

    if (!bRuntime) { DL_AuditFail(oNpc, "runtime_disabled"); DL_AuditAddFixHint(oNpc, "runtime: enable module locals dl_enabled=1 and dl_contract_version=a0"); }
    if (!bPipeline) { DL_AuditFail(oNpc, "npc_not_pipeline"); DL_AuditAddFixHint(oNpc, "pipeline: NPC not registered as Daily Life actor/profile"); }
    if (!bActive) { DL_AuditFail(oNpc, "npc_not_active_pipeline"); DL_AuditAddFixHint(oNpc, "pipeline: NPC is not active in current area tier/runtime"); }

    DL_DbgSay(oPC, "[DL AUDIT RUNTIME] runtime=" + DL_AuditPF(bRuntime) +
                    " pipeline=" + DL_AuditPF(bPipeline) +
                    " active=" + DL_AuditPF(bActive) +
                    " tier=" + IntToString(DL_GetAreaTier(oArea)) +
                    " tick=" + IntToString(DL_GetAreaTick(oArea)));
    DL_DbgSay(oPC, "[DL AUDIT RUNTIME] resync=" + DL_AuditYN(GetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING)) +
                    " reason=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_RESYNC_REASON)) +
                    " worker_seq=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_WORKER_SEQ)));
}

void DL_AuditAreas(object oPC, object oNpc)
{
    object oCurrent = GetArea(oNpc);
    object oHome = DL_GetHomeArea(oNpc);
    object oWork = DL_GetWorkArea(oNpc);
    object oMeal = DL_GetMealArea(oNpc);
    object oSocial = DL_GetSocialArea(oNpc);
    object oPublic = DL_GetPublicArea(oNpc);

    if (!GetIsObjectValid(oHome)) { DL_AuditFail(oNpc, "home_area_invalid"); DL_AuditAddFixHint(oNpc, "areas: set npc local dl_home_area_tag or place NPC in valid area"); }

    DL_DbgSay(oPC, "[DL AUDIT AREA] current=" + DL_AuditAreaTag(oCurrent) +
                    " home=" + DL_AuditAreaTag(oHome) +
                    " work=" + DL_AuditAreaTag(oWork));
    DL_DbgSay(oPC, "[DL AUDIT AREA] meal=" + DL_AuditAreaTag(oMeal) +
                    " social=" + DL_AuditAreaTag(oSocial) +
                    " public=" + DL_AuditAreaTag(oPublic));
    DL_DbgSay(oPC, "[DL AUDIT AREA] home_key=" + GetLocalString(oNpc, DL_L_NPC_HOME_AREA_TAG) +
                    " work_key=" + GetLocalString(oNpc, DL_L_NPC_WORK_AREA_TAG) +
                    " meal_key=" + GetLocalString(oNpc, DL_L_NPC_MEAL_AREA_TAG));
}

void DL_AuditSleep(object oPC, object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oHome))
    {
        oHome = DL_GetNpcCurrentAreaFallback(oNpc);
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    string sApproachTag = "dl_sleep_approach_" + IntToString(nSlot);
    string sBedTag = "dl_sleep_bed_" + IntToString(nSlot);
    string sApproachAnchor = "dl_anchor_sleep_approach_" + IntToString(nSlot);
    string sBedAnchor = "dl_anchor_sleep_bed_" + IntToString(nSlot);

    object oApproachArea = DL_AuditFindWpInArea(sApproachTag, oHome);
    object oBedArea = DL_AuditFindWpInArea(sBedTag, oHome);
    object oApproachLegacy = GetWaypointByTag(sApproachTag);
    object oBedLegacy = GetWaypointByTag(sBedTag);
    object oApproachResolved = DL_ResolveSleepApproachWaypoint(oNpc);
    object oBedResolved = DL_ResolveSleepBedWaypoint(oNpc);

    if (!GetIsObjectValid(oApproachResolved)) { DL_AuditFail(oNpc, "sleep_approach_unresolved"); DL_AuditAddFixHint(oNpc, "sleep: add/verify dl_sleep_approach_<slot> or area anchor dl_anchor_sleep_approach_<slot>"); }
    if (!GetIsObjectValid(oBedResolved)) { DL_AuditFail(oNpc, "sleep_bed_unresolved"); DL_AuditAddFixHint(oNpc, "sleep: add/verify dl_sleep_bed_<slot> or area anchor dl_anchor_sleep_bed_<slot>"); }

    string sApproachAnchorValue = GetIsObjectValid(oHome) ? GetLocalString(oHome, sApproachAnchor) : "";
    string sBedAnchorValue = GetIsObjectValid(oHome) ? GetLocalString(oHome, sBedAnchor) : "";

    DL_DbgSay(oPC, "[DL AUDIT SLEEP] slot=" + IntToString(nSlot) +
                    " home=" + DL_AuditAreaTag(oHome) +
                    " approach_tag=" + sApproachTag +
                    " bed_tag=" + sBedTag);
    DL_DbgSay(oPC, "[DL AUDIT SLEEP] area_approach=" + DL_AuditPF(GetIsObjectValid(oApproachArea)) +
                    " legacy_approach=" + DL_AuditPF(GetIsObjectValid(oApproachLegacy)) +
                    " resolved_approach=" + DL_AuditObjTag(oApproachResolved));
    DL_DbgSay(oPC, "[DL AUDIT SLEEP] area_bed=" + DL_AuditPF(GetIsObjectValid(oBedArea)) +
                    " legacy_bed=" + DL_AuditPF(GetIsObjectValid(oBedLegacy)) +
                    " resolved_bed=" + DL_AuditObjTag(oBedResolved));
    DL_DbgSay(oPC, "[DL AUDIT SLEEP] anchor_approach=" + sApproachAnchorValue +
                    " anchor_bed=" + sBedAnchorValue +
                    " legacy_areas=" + DL_AuditObjAreaTag(oApproachLegacy) + "/" + DL_AuditObjAreaTag(oBedLegacy));
}

void DL_AuditWork(object oPC, object oNpc)
{
    string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
    object oWork = DL_GetWorkArea(oNpc);
    string sPrimaryAnchor = GetIsObjectValid(oWork) ? GetLocalString(oWork, "dl_anchor_work_primary") : "";
    string sSecondaryAnchor = GetIsObjectValid(oWork) ? GetLocalString(oWork, "dl_anchor_work_secondary") : "";
    string sFetchAnchor = GetIsObjectValid(oWork) ? GetLocalString(oWork, "dl_anchor_work_fetch") : "";

    DL_DbgSay(oPC, "[DL AUDIT WORK] profile=" + sProfile +
                    " work_area=" + DL_AuditAreaTag(oWork) +
                    " primary_anchor=" + sPrimaryAnchor +
                    " secondary_anchor=" + sSecondaryAnchor +
                    " fetch_anchor=" + sFetchAnchor);

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        object oForgeArea = DL_AuditFindWpInArea("dl_work_forge", oWork);
        object oCraftArea = DL_AuditFindWpInArea("dl_work_craft", oWork);
        object oForgeLegacy = GetWaypointByTag("dl_work_forge");
        object oCraftLegacy = GetWaypointByTag("dl_work_craft");
        object oForge = DL_ResolveBlacksmithForgeWaypoint(oNpc);
        object oCraft = DL_ResolveBlacksmithCraftWaypoint(oNpc);
        object oFetch = DL_ResolveBlacksmithFetchWaypoint(oNpc);
        if (!GetIsObjectValid(oForge) || !GetIsObjectValid(oCraft)) { DL_AuditFail(oNpc, "work_blacksmith_required_unresolved"); DL_AuditAddFixHint(oNpc, "work: add/verify dl_work_forge + dl_work_craft or anchors dl_anchor_work_primary/secondary in work area"); }
        DL_DbgSay(oPC, "[DL AUDIT WORK] forge_area=" + DL_AuditPF(GetIsObjectValid(oForgeArea)) +
                        " forge_legacy=" + DL_AuditPF(GetIsObjectValid(oForgeLegacy)) +
                        " craft_area=" + DL_AuditPF(GetIsObjectValid(oCraftArea)) +
                        " craft_legacy=" + DL_AuditPF(GetIsObjectValid(oCraftLegacy)));
        DL_DbgSay(oPC, "[DL AUDIT WORK] blacksmith forge=" + DL_AuditObjTag(oForge) +
                        " craft=" + DL_AuditObjTag(oCraft) +
                        " fetch_optional=" + DL_AuditObjTag(oFetch) +
                        " kind_now=" + DL_ResolveBlacksmithWorkKindAtHour(oNpc));
    }
}

void DL_AuditMealSocial(object oPC, object oNpc)
{
    string sMealKind = DL_ResolveMealKind(oNpc);
    object oMealArea = DL_GetMealArea(oNpc);
    object oMeal = DL_ResolveMealWaypoint(oNpc, sMealKind);
    string sMealAnchor = GetIsObjectValid(oMealArea) ? GetLocalString(oMealArea, "dl_anchor_meal") : "";
    if (!GetIsObjectValid(oMeal)) { DL_AuditFail(oNpc, "meal_unresolved"); DL_AuditAddFixHint(oNpc, "meal: add/verify dl_anchor_meal in meal/work/home fallback area"); }

    DL_DbgSay(oPC, "[DL AUDIT MEAL] kind=" + sMealKind +
                    " area=" + DL_AuditAreaTag(oMealArea) +
                    " anchor=" + sMealAnchor +
                    " resolved=" + DL_AuditObjTag(oMeal));

    int nNowDirective = DL_ResolveNpcDirective(oNpc);
    if (nNowDirective != DL_DIR_SOCIAL && nNowDirective != DL_DIR_PUBLIC)
    {
        DL_DbgSay(oPC, "[DL AUDIT SOCIAL] skip=inactive now_dir=" + IntToString(nNowDirective));
        return;
    }

    object oPublic = DL_ResolvePublicWaypoint(oNpc);
    object oReserved = GetLocalObject(oNpc, DL_L_NPC_SOCIAL_RESERVED_WP);
    DL_DbgSay(oPC, "[DL AUDIT SOCIAL] kind=" + DL_GetNpcSocialKind(oNpc) +
                    " social_area=" + DL_AuditAreaTag(DL_GetSocialArea(oNpc)) +
                    " public_wp=" + DL_AuditObjTag(oPublic) +
                    " reserved=" + DL_AuditObjTag(oReserved));
}

void DL_AuditTransitionBlocked(object oPC, object oNpc)
{
    string sTransitionStatus = GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    if (sTransitionStatus == "")
    {
        DL_DbgSay(oPC, "[DL AUDIT TRANSITION] skip=idle");
        DL_DbgSay(oPC, "[DL AUDIT BLOCKED] skip=idle");
        return;
    }

    object oBlocked = GetLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    DL_DbgSay(oPC, "[DL AUDIT TRANSITION] status=" + sTransitionStatus +
                    " target=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) +
                    " diag=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC));
    DL_DbgSay(oPC, "[DL AUDIT BLOCKED] obj=" + DL_AuditObjTag(oBlocked) +
                    " type=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE)) +
                    " busy=" + DL_AuditYN(GetLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY)) +
                    " diag=" + GetLocalString(oNpc, "dl_npc_blocked_diagnostic"));
}

void DL_DbgRunSubsystemAudit(object oPC, object oNpc)
{
    if (!GetIsObjectValid(oPC) || !GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalString(oNpc, "dl_dbg_first_fail");
    DeleteLocalString(oNpc, "dl_dbg_fix_hints");
    DL_AuditRuntime(oPC, oNpc);
    DL_AuditAreas(oPC, oNpc);
    DL_AuditSleep(oPC, oNpc);
    DL_AuditWork(oPC, oNpc);
    DL_AuditMealSocial(oPC, oNpc);
    DL_AuditTransitionBlocked(oPC, oNpc);

    string sFirstFail = GetLocalString(oNpc, "dl_dbg_first_fail");
    if (sFirstFail == "")
    {
        DL_DbgSay(oPC, "[DL AUDIT VERDICT] overall=PASS first_fail=NONE");
    }
    else
    {
        DL_DbgSay(oPC, "[DL AUDIT VERDICT] overall=FAIL first_fail=" + sFirstFail);
        DL_DbgSay(oPC, "[DL AUDIT FIX] " + GetLocalString(oNpc, "dl_dbg_fix_hints"));
    }
}
