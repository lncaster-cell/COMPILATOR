object DL_ResolveSocialPartnerObject(object oNpc, string sPartnerTag)
{
    if (!GetIsObjectValid(oNpc) || sPartnerTag == "")
    {
        DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
    if (GetIsObjectValid(oCached) &&
        oCached != oNpc &&
        GetTag(oCached) == sPartnerTag &&
        DL_IsActivePipelineNpc(oCached) &&
        GetArea(oCached) == GetArea(oNpc))
    {
        return oCached;
    }

    int bTagFound = FALSE;
    int bTagFoundOutsideArea = FALSE;
    object oPartner = OBJECT_INVALID;
    int nTagIndex = 0;
    object oCandidate = GetObjectByTag(sPartnerTag, nTagIndex);
    while (GetIsObjectValid(oCandidate) && nTagIndex < DL_SOCIAL_PARTNER_TAG_SEARCH_CAP)
    {
        bTagFound = TRUE;

        if (oCandidate == oNpc)
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "social_partner_self");
        }
        else if (!DL_IsActivePipelineNpc(oCandidate))
        {
            // Keep scanning for a suitable active pipeline NPC.
        }
        else if (GetArea(oCandidate) == GetArea(oNpc))
        {
            oPartner = oCandidate;
            break;
        }
        else
        {
            bTagFoundOutsideArea = TRUE;
        }

        nTagIndex = nTagIndex + 1;
        oCandidate = GetObjectByTag(sPartnerTag, nTagIndex);
    }

    if (!GetIsObjectValid(oPartner))
    {
        DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
        if (bTagFoundOutsideArea)
        {
        }
        else if (!bTagFound)
        {
        }
        return OBJECT_INVALID;
    }

    SetLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ, oPartner);
    return oPartner;
}
object DL_GetNpcCachedPlaceableByTagInArea(object oNpc, string sCacheLocal, string sTag, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sCacheLocal);
    if (GetIsObjectValid(oCached) &&
        GetTag(oCached) == sTag &&
        GetObjectType(oCached) == OBJECT_TYPE_PLACEABLE &&
        GetArea(oCached) == oArea)
    {
        return oCached;
    }
    DeleteLocalObject(oNpc, sCacheLocal);

    int nNth = 0;
    while (nNth < DL_WAYPOINT_TAG_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTag, nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetObjectType(oCandidate) == OBJECT_TYPE_PLACEABLE && GetArea(oCandidate) == oArea)
        {
            SetLocalObject(oNpc, sCacheLocal, oCandidate);
            return oCandidate;
        }

        nNth = nNth + 1;
    }

    return OBJECT_INVALID;
}
string DL_ResolveMealKind(object oNpc)
{
    int nNow = DL_GetNowMinuteOfDay();
    int nWake = DL_GetNpcWakeHour(oNpc);
    int nSleepHours = DL_GetNpcSleepHours(oNpc);
    int nSleepStart = DL_NormalizeMinuteOfDay((nWake * 60) - (nSleepHours * 60));
    int bWeekend = DL_GetWeekendType() != 0;
    int bHasWorkWindow = DL_NpcHasWorkDirectiveWindow(oNpc, bWeekend);
    int nShiftLen = bHasWorkWindow ? DL_GetNpcShiftLength(oNpc, bWeekend) : 0;
    int nShiftStartHour = DL_GetNpcShiftStart(oNpc);
    if (nShiftStartHour == 0 && GetLocalInt(oNpc, DL_L_NPC_SHIFT_LENGTH) <= 0 && bHasWorkWindow)
    {
        nShiftStartHour = 8;
    }
    int nShiftStart = nShiftStartHour * 60;
    string sTag = GetTag(oNpc);
    int nMealOffset = DL_GetTagDeterministicOffset(sTag, 21, 10);
    int nBreakfastStart = DL_NormalizeMinuteOfDay((nWake * 60) - 15 + nMealOffset);
    int nLunchStart = DL_NormalizeMinuteOfDay(nShiftStart + 240 - 15 + nMealOffset);
    int nDinnerStart = DL_NormalizeMinuteOfDay(nSleepStart - 75 + nMealOffset);

    if (DL_MinuteInWindow(nNow, nBreakfastStart, DL_SCHED_BREAKFAST_DURATION_MINUTES))
    {
        return DL_MEAL_KIND_BREAKFAST;
    }
    if (nShiftLen >= 8 && DL_MinuteInWindow(nNow, nLunchStart, DL_SCHED_LUNCH_DURATION_MINUTES))
    {
        return DL_MEAL_KIND_LUNCH;
    }
    if (DL_MinuteInWindow(nNow, nDinnerStart, DL_SCHED_DINNER_DURATION_MINUTES))
    {
        return DL_MEAL_KIND_DINNER;
    }
    return DL_MEAL_KIND_DINNER;
}
object DL_ResolveMealWaypoint(object oNpc, string sMealKind)
{
    object oTargetArea = OBJECT_INVALID;
    if (sMealKind == DL_MEAL_KIND_LUNCH)
    {
        oTargetArea = DL_GetMealArea(oNpc);
        if (!GetIsObjectValid(oTargetArea))
        {
            oTargetArea = DL_GetWorkArea(oNpc);
            if (GetIsObjectValid(oTargetArea))
            {
            }
        }
    }

    if (!GetIsObjectValid(oTargetArea))
    {
        oTargetArea = DL_GetHomeArea(oNpc);
        if (GetIsObjectValid(oTargetArea) && sMealKind == DL_MEAL_KIND_LUNCH)
        {
        }
    }

    object oMeal = DL_GetAreaAnchorWaypoint(oNpc, oTargetArea, "dl_anchor_meal", DL_L_NPC_CACHE_MEAL, FALSE);
    if (GetIsObjectValid(oMeal))
    {
        return oMeal;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    oMeal = DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_MEAL,
        oTargetArea,
        "dl_meal_",
        "",
        "dl_meal_" + IntToString(nSlot)
    );
    if (GetIsObjectValid(oMeal))
    {
        return oMeal;
    }

    DL_LogMarkupIssueOnce(
        oNpc,
        "missing_meal_anchor_" + GetTag(oTargetArea),
        "Area " + GetTag(oTargetArea) + " needs area local dl_anchor_meal or waypoint dl_meal_" + IntToString(nSlot) + " for NPC " + GetTag(oNpc) + "."
    );
    return OBJECT_INVALID;
}
object DL_ResolveSocialWaypoint(object oNpc)
{
    object oArea = DL_GetSocialArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetWorkArea(oNpc);
    }
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sSlot = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT);
    object oWaypoint = OBJECT_INVALID;
    if (sSlot == "a")
    {
        oWaypoint = DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_social_a", DL_L_NPC_CACHE_SOCIAL_A, FALSE);
    }
    else if (sSlot == "b")
    {
        oWaypoint = DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_social_b", DL_L_NPC_CACHE_SOCIAL_B, FALSE);
    }

    if (GetIsObjectValid(oWaypoint))
    {
        return oWaypoint;
    }

    return DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_social", DL_L_NPC_CACHE_SOCIAL_A, TRUE);
}
object DL_ResolvePublicWaypoint(object oNpc)
{
    object oArea = DL_GetPublicArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetSocialArea(oNpc);
    }
    if (!GetIsObjectValid(oArea))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "missing_public_area",
            "NPC " + GetTag(oNpc) + " has no public/social area for PUBLIC directive."
        );
        return OBJECT_INVALID;
    }
    return DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_public", DL_L_NPC_CACHE_PUBLIC, TRUE);
}
object DL_ResolveChillWaypoint(object oNpc)
{
    int nNowAbs = DL_GetAbsoluteMinute();
    int nMissingUntil = GetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
    if (nMissingUntil > nNowAbs)
    {
        return OBJECT_INVALID;
    }

    object oArea = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    object oSeat = DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_CHILL_SEAT,
        oArea,
        "dl_chill_",
        "_seat",
        "dl_chill_seat_" + IntToString(nSlot)
    );

    if (GetIsObjectValid(oSeat))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
        return oSeat;
    }

    SetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL, nNowAbs + DL_CHILL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}
object DL_ResolveChillChairObject(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return OBJECT_INVALID;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nMissingUntil = GetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
    if (nMissingUntil > nNowAbs)
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oSeat);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sChairTag = GetLocalString(oSeat, DL_L_WP_CHILL_CHAIR_TAG);
    object oChair = OBJECT_INVALID;
    if (sChairTag != "")
    {
        oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_OBJ, sChairTag, oArea);
        if (GetIsObjectValid(oChair))
        {
            return oChair;
        }
    }

    string sNpcTag = GetTag(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_OBJ, "dl_chill_" + sNpcTag + "_chair", oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_OBJ, "dl_chill_chair_" + IntToString(nSlot), oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    SetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL, nNowAbs + DL_CHILL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}
int DL_IsMealChairTagCandidate(string sTag)
{
    if (sTag == "")
    {
        return FALSE;
    }
    if (FindSubString(sTag, "chair") >= 0)
    {
        return TRUE;
    }
    if (FindSubString(sTag, "Chair") >= 0)
    {
        return TRUE;
    }
    if (FindSubString(sTag, "seat") >= 0)
    {
        return TRUE;
    }
    if (FindSubString(sTag, "Seat") >= 0)
    {
        return TRUE;
    }
    return FALSE;
}
object DL_FindNearestMealChairObject(object oNpc, object oMeal)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oMeal);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nNth = 1;
    while (nNth <= DL_MEAL_NEAR_CHAIR_SCAN_CAP)
    {
        object oCandidate = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, GetLocation(oMeal), nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetArea(oCandidate) == oArea &&
            GetDistanceBetweenLocations(GetLocation(oCandidate), GetLocation(oMeal)) <= DL_MEAL_NEAR_CHAIR_RADIUS &&
            DL_IsMealChairTagCandidate(GetTag(oCandidate)))
        {
            return oCandidate;
        }

        nNth = nNth + 1;
    }

    return OBJECT_INVALID;
}
object DL_ResolveMealChairObject(object oNpc, object oMeal)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal))
    {
        return OBJECT_INVALID;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nMissingUntil = GetLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
    if (nMissingUntil > nNowAbs)
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oMeal);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ);
    if (GetIsObjectValid(oCached) &&
        GetObjectType(oCached) == OBJECT_TYPE_PLACEABLE &&
        GetArea(oCached) == oArea &&
        DL_IsMealChairTagCandidate(GetTag(oCached)))
    {
        return oCached;
    }

    string sChairTag = GetLocalString(oMeal, DL_L_WP_MEAL_CHAIR_TAG);
    object oChair = OBJECT_INVALID;
    if (sChairTag != "")
    {
        oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, sChairTag, oArea);
        if (GetIsObjectValid(oChair))
        {
            DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
            return oChair;
        }
    }

    string sNpcTag = GetTag(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, "dl_meal_" + sNpcTag + "_chair", oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, "dl_meal_chair_" + IntToString(nSlot), oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    oChair = DL_FindNearestMealChairObject(oNpc, oMeal);
    if (GetIsObjectValid(oChair))
    {
        SetLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, oChair);
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    SetLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL, nNowAbs + DL_MEAL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}
int DL_ShouldAttemptMealActionSit(object oNpc, object oMeal, object oChair)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal) || !GetIsObjectValid(oChair))
    {
        return FALSE;
    }

    string sChairTag = GetTag(oChair);
    if (sChairTag == "")
    {
        return FALSE;
    }

    if (GetLocalString(oMeal, DL_L_WP_MEAL_CHAIR_TAG) == sChairTag)
    {
        return TRUE;
    }

    string sNpcTag = GetTag(oNpc);
    if (sChairTag == "dl_meal_" + sNpcTag + "_chair")
    {
        return TRUE;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    if (sChairTag == "dl_meal_chair_" + IntToString(nSlot))
    {
        return TRUE;
    }

    return FALSE;
}
