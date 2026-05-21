int DL_GetModuleCacheEpoch()
{
    object oModule = GetModule();
    int nEpoch = GetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH);
    if (nEpoch <= 0)
    {
        nEpoch = 1;
        SetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH, nEpoch);
    }
    return nEpoch;
}
void DL_ConsumeModuleCacheResetRequest()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_FORCE_CACHE_RESET) != TRUE)
    {
        return;
    }

    int nEpoch = DL_GetModuleCacheEpoch() + 1;
    SetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH, nEpoch);
    DeleteLocalInt(oModule, DL_L_MODULE_FORCE_CACHE_RESET);
}
void DL_ClearAreaNavigationCache(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int i = 0;
    while (i < DL_AREA_NAV_ROUTE_CAP)
    {
        DeleteLocalObject(oArea, DL_GetAreaNavigationSlotKey(i));
        i = i + 1;
    }
    DeleteLocalInt(oArea, DL_L_AREA_NAV_READY);
    DeleteLocalInt(oArea, DL_L_AREA_NAV_COUNT);
}
void DL_MaybeRefreshAreaCachesForEpoch(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    DL_ConsumeModuleCacheResetRequest();
    int nEpoch = DL_GetModuleCacheEpoch();
    if (GetLocalInt(oArea, DL_L_AREA_FORCE_CACHE_RESET) == TRUE ||
        GetLocalInt(oArea, DL_L_AREA_CACHE_EPOCH) != nEpoch)
    {
        DL_ClearAreaNavigationCache(oArea);
        SetLocalInt(oArea, DL_L_AREA_CACHE_EPOCH, nEpoch);
        DeleteLocalInt(oArea, DL_L_AREA_FORCE_CACHE_RESET);
    }
}
void DL_ClearNpcWaypointCaches(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SLEEP_APPROACH);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SLEEP_BED);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_FORGE);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_CRAFT);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_POST);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_TRADE);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_PRIMARY);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_SECONDARY);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_FETCH);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_MEAL);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_A);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_B);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_PUBLIC);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_CHILL_SEAT);
    DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
}
void DL_ClearNpcAreaCaches(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_HOME_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_PUBLIC_AREA);
}
void DL_ClearNpcRuntimeCaches(object oNpc)
{
    DL_ClearNpcWaypointCaches(oNpc);
    DL_ClearNpcAreaCaches(oNpc);
}
void DL_MaybeRefreshNpcCachesForEpoch(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        DL_MaybeRefreshAreaCachesForEpoch(oArea);
    }
    else
    {
        DL_ConsumeModuleCacheResetRequest();
    }

    int nEpoch = DL_GetModuleCacheEpoch();
    if (GetLocalInt(oNpc, DL_L_NPC_FORCE_CACHE_RESET) == TRUE ||
        GetLocalInt(oNpc, DL_L_NPC_CACHE_EPOCH) != nEpoch)
    {
        DL_ClearNpcRuntimeCaches(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_CACHE_EPOCH, nEpoch);
        DeleteLocalInt(oNpc, DL_L_NPC_FORCE_CACHE_RESET);
    }
}

