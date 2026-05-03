const string DL_L_MODULE_CACHE_METRIC_PREFIX = "dl_metric_cache_";
const string DL_L_CACHE_CTX_PREFIX = "dl_cache_ctx_";
const string DL_L_CACHE_MISS_TICK_SUFFIX = "miss_tick";
const string DL_L_AREA_TAG_CACHE_PREFIX = "dl_area_tag_cache_";
const string DL_L_TICK_MEMO_PREFIX = "dl_tick_memo_";
const string DL_L_TICK_MEMO_MISS_PREFIX = "dl_tick_memo_miss_";

const int DL_TAG_ENUM_DEFAULT_CAP = 32;
const int DL_WAYPOINT_TAG_SEARCH_CAP = 64;

void DL_InvalidateCachedObject(object oOwner, string sCacheLocal);
void DL_RecordCacheMetricBatch(object oArea, string sScope, int nHitDelta, int nMissDelta);

int DL_GetSafeTagSearchCap(int nRequestedCap)
{
    if (nRequestedCap <= 0)
    {
        return DL_TAG_ENUM_DEFAULT_CAP;
    }

    return nRequestedCap;
}

string DL_BuildAreaTagCacheKey(string sTag, int nObjectType, object oArea)
{
    return DL_L_AREA_TAG_CACHE_PREFIX + ObjectToString(oArea) + "_" + IntToString(nObjectType) + "_" + sTag;
}

object DL_GetAreaScopedCachedObjectByTag(object oOwner, string sTag, int nObjectType, object oArea)
{
    if (!GetIsObjectValid(oOwner) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    string sLocal = DL_BuildAreaTagCacheKey(sTag, nObjectType, oArea);
    object oCached = GetLocalObject(oOwner, sLocal);
    if (DL_IsCachedObjectValidForTagInArea(oCached, sTag, nObjectType, oArea))
    {
        return oCached;
    }

    if (GetIsObjectValid(oCached))
    {
        DeleteLocalObject(oOwner, sLocal);
    }

    return OBJECT_INVALID;
}

void DL_SetAreaScopedCachedObjectByTag(object oOwner, string sTag, int nObjectType, object oArea, object oValue)
{
    if (!GetIsObjectValid(oOwner) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return;
    }

    string sLocal = DL_BuildAreaTagCacheKey(sTag, nObjectType, oArea);
    if (!GetIsObjectValid(oValue))
    {
        DeleteLocalObject(oOwner, sLocal);
        return;
    }

    SetLocalObject(oOwner, sLocal, oValue);
}

object DL_FindObjectByTagWithChecks(
    string sTag,
    int nSearchCap,
    int nObjectType,
    object oArea,
    object oExclude,
    int bRequireActivePipelineNpc
)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    int nCap = DL_GetSafeTagSearchCap(nSearchCap);
    if (GetIsObjectValid(oArea))
    {
        object oAreaCached = DL_GetAreaScopedCachedObjectByTag(OBJECT_SELF, sTag, nObjectType, oArea);
        if (GetIsObjectValid(oAreaCached) &&
            (!GetIsObjectValid(oExclude) || oAreaCached != oExclude) &&
            (!bRequireActivePipelineNpc || DL_IsActivePipelineNpc(oAreaCached)))
        {
            return oAreaCached;
        }
    }
    int nNth = 0;
    while (nNth < nCap)
    {
        object oCandidate = GetObjectByTag(sTag, nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetIsObjectValid(oExclude) && oCandidate == oExclude)
        {
            nNth = nNth + 1;
            continue;
        }

        if (nObjectType >= 0 && GetObjectType(oCandidate) != nObjectType)
        {
            nNth = nNth + 1;
            continue;
        }

        if (GetIsObjectValid(oArea) && GetArea(oCandidate) != oArea)
        {
            nNth = nNth + 1;
            continue;
        }

        if (bRequireActivePipelineNpc && !DL_IsActivePipelineNpc(oCandidate))
        {
            nNth = nNth + 1;
            continue;
        }

        if (GetIsObjectValid(oArea))
        {
            DL_SetAreaScopedCachedObjectByTag(OBJECT_SELF, sTag, nObjectType, oArea, oCandidate);
        }
        return oCandidate;
    }

    return OBJECT_INVALID;
}

string DL_GetCacheMetricKey(string sScope, string sMetric)
{
    return DL_L_MODULE_CACHE_METRIC_PREFIX + sScope + "_" + sMetric;
}

void DL_RecordCacheMetric(object oArea, string sScope, int bHit)
{
    if (bHit)
    {
        DL_RecordCacheMetricBatch(oArea, sScope, 1, 0);
        return;
    }

    DL_RecordCacheMetricBatch(oArea, sScope, 0, 1);
}

void DL_RecordCacheMetricBatch(object oArea, string sScope, int nHitDelta, int nMissDelta)
{
    if (sScope == "")
    {
        return;
    }

    object oModule = GetModule();
    if (nHitDelta != 0)
    {
        string sModuleHit = DL_GetCacheMetricKey("module_" + sScope, "hit");
        SetLocalInt(oModule, sModuleHit, GetLocalInt(oModule, sModuleHit) + nHitDelta);
    }
    if (nMissDelta != 0)
    {
        string sModuleMiss = DL_GetCacheMetricKey("module_" + sScope, "miss");
        SetLocalInt(oModule, sModuleMiss, GetLocalInt(oModule, sModuleMiss) + nMissDelta);
    }

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (nHitDelta != 0)
    {
        string sAreaHit = DL_GetCacheMetricKey("area_" + sScope, "hit");
        SetLocalInt(oArea, sAreaHit, GetLocalInt(oArea, sAreaHit) + nHitDelta);
    }
    if (nMissDelta != 0)
    {
        string sAreaMiss = DL_GetCacheMetricKey("area_" + sScope, "miss");
        SetLocalInt(oArea, sAreaMiss, GetLocalInt(oArea, sAreaMiss) + nMissDelta);
    }
}

int DL_IsCachedObjectValidForTagInArea(object oCached, string sTag, int nObjectType, object oArea)
{
    return GetIsObjectValid(oCached) &&
        GetTag(oCached) == sTag &&
        GetObjectType(oCached) == nObjectType &&
        GetArea(oCached) == oArea;
}

string DL_GetCachedObjectContextKey(string sCacheLocal, string sSuffix)
{
    return DL_L_CACHE_CTX_PREFIX + sCacheLocal + "_" + sSuffix;
}

string DL_BuildTickMemoKey(object oOwner, int nTickStamp, string sTag, int nObjectType, object oArea, string sLookupMode)
{
    return DL_L_TICK_MEMO_PREFIX +
        ObjectToString(oOwner) + "_" +
        IntToString(nTickStamp) + "_" +
        sTag + "_" +
        IntToString(nObjectType) + "_" +
        ObjectToString(oArea) + "_" +
        sLookupMode;
}

string DL_BuildTickMemoMissKey(object oOwner, int nTickStamp, string sTag, int nObjectType, object oArea, string sLookupMode)
{
    return DL_L_TICK_MEMO_MISS_PREFIX +
        ObjectToString(oOwner) + "_" +
        IntToString(nTickStamp) + "_" +
        sTag + "_" +
        IntToString(nObjectType) + "_" +
        ObjectToString(oArea) + "_" +
        sLookupMode;
}

object DL_GetTickMemoizedLookup(object oMemoStore, object oOwner, int nTickStamp, string sTag, int nObjectType, object oArea, string sLookupMode, int &bIsMiss)
{
    bIsMiss = FALSE;
    if (!GetIsObjectValid(oMemoStore) || !GetIsObjectValid(oOwner) || sTag == "" || sLookupMode == "")
    {
        return OBJECT_INVALID;
    }

    string sMemoKey = DL_BuildTickMemoKey(oOwner, nTickStamp, sTag, nObjectType, oArea, sLookupMode);
    object oMemoized = GetLocalObject(oMemoStore, sMemoKey);
    if (GetIsObjectValid(oMemoized) &&
        GetTag(oMemoized) == sTag &&
        GetObjectType(oMemoized) == nObjectType &&
        (!GetIsObjectValid(oArea) || GetArea(oMemoized) == oArea))
    {
        return oMemoized;
    }

    if (GetIsObjectValid(oMemoized))
    {
        DeleteLocalObject(oMemoStore, sMemoKey);
    }

    string sMissKey = DL_BuildTickMemoMissKey(oOwner, nTickStamp, sTag, nObjectType, oArea, sLookupMode);
    bIsMiss = GetLocalInt(oMemoStore, sMissKey) == nTickStamp;
    return OBJECT_INVALID;
}

void DL_SetTickMemoizedLookup(object oMemoStore, object oOwner, int nTickStamp, string sTag, int nObjectType, object oArea, string sLookupMode, object oValue)
{
    if (!GetIsObjectValid(oMemoStore) || !GetIsObjectValid(oOwner) || sTag == "" || sLookupMode == "")
    {
        return;
    }

    string sMemoKey = DL_BuildTickMemoKey(oOwner, nTickStamp, sTag, nObjectType, oArea, sLookupMode);
    string sMissKey = DL_BuildTickMemoMissKey(oOwner, nTickStamp, sTag, nObjectType, oArea, sLookupMode);
    if (GetIsObjectValid(oValue))
    {
        SetLocalObject(oMemoStore, sMemoKey, oValue);
        DeleteLocalInt(oMemoStore, sMissKey);
        return;
    }

    DeleteLocalObject(oMemoStore, sMemoKey);
    SetLocalInt(oMemoStore, sMissKey, nTickStamp);
}

int DL_IsCacheMissSuppressedThisTick(object oOwner, string sCacheLocal, int nNowTick)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return FALSE;
    }

    return GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, DL_L_CACHE_MISS_TICK_SUFFIX)) == nNowTick;
}

void DL_MarkCacheMissThisTick(object oOwner, string sCacheLocal, int nNowTick)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return;
    }

    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, DL_L_CACHE_MISS_TICK_SUFFIX), nNowTick);
}

void DL_ClearCacheMissSuppressedTick(object oOwner, string sCacheLocal)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return;
    }

    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, DL_L_CACHE_MISS_TICK_SUFFIX));
}

void DL_SetCachedObject(object oOwner, string sCacheLocal, object oValue, string sTag, int nObjectType, object oArea, int nTier, int nLifecycleSeq)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return;
    }

    if (!GetIsObjectValid(oValue))
    {
        DL_InvalidateCachedObject(oOwner, sCacheLocal);
        return;
    }

    SetLocalObject(oOwner, sCacheLocal, oValue);
    SetLocalString(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tag"), sTag);
    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "type"), nObjectType);
    SetLocalObject(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "area"), oArea);
    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tier"), nTier);
    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "life"), nLifecycleSeq);
}

void DL_InvalidateCachedObject(object oOwner, string sCacheLocal)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return;
    }

    DeleteLocalObject(oOwner, sCacheLocal);
    DeleteLocalString(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tag"));
    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "type"));
    DeleteLocalObject(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "area"));
    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tier"));
    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "life"));
    DL_ClearCacheMissSuppressedTick(oOwner, sCacheLocal);
}

int DL_IsCachedObjectValid(object oOwner, string sCacheLocal, string sExpectedTag, int nExpectedObjectType, object oExpectedArea, int nExpectedTier, int nExpectedLifecycleSeq)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return FALSE;
    }

    object oCached = GetLocalObject(oOwner, sCacheLocal);
    if (!GetIsObjectValid(oCached))
    {
        return FALSE;
    }

    if (GetLocalString(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tag")) != sExpectedTag) return FALSE;
    if (GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "type")) != nExpectedObjectType) return FALSE;
    if (GetLocalObject(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "area")) != oExpectedArea) return FALSE;
    if (GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tier")) != nExpectedTier) return FALSE;
    if (GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "life")) != nExpectedLifecycleSeq) return FALSE;

    return GetTag(oCached) == sExpectedTag && GetObjectType(oCached) == nExpectedObjectType && GetArea(oCached) == oExpectedArea;
}

object DL_GetCachedObject(object oOwner, string sCacheLocal, string sExpectedTag, int nExpectedObjectType, object oExpectedArea, int nExpectedTier, int nExpectedLifecycleSeq)
{
    if (!DL_IsCachedObjectValid(oOwner, sCacheLocal, sExpectedTag, nExpectedObjectType, oExpectedArea, nExpectedTier, nExpectedLifecycleSeq))
    {
        return OBJECT_INVALID;
    }

    return GetLocalObject(oOwner, sCacheLocal);
}


object DL_GetNpcCachedObjectByTagInArea(
    object oNpc,
    string sCacheLocal,
    string sTag,
    int nObjectType,
    object oArea,
    int nSearchCap,
    string sMetricScope
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    int nNowTick = DL_GetAreaTick(oArea);
    if (DL_IsCacheMissSuppressedThisTick(oNpc, sCacheLocal, nNowTick))
    {
        return OBJECT_INVALID;
    }

    int nTier = DL_GetAreaTier(oArea);
    int nLifecycleSeq = GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ);
    object oCached = DL_GetCachedObject(oNpc, sCacheLocal, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
    {
        DL_ClearCacheMissSuppressedTick(oNpc, sCacheLocal);
        DL_RecordCacheMetric(oArea, sMetricScope, TRUE);
        return oCached;
    }

    DL_InvalidateCachedObject(oNpc, sCacheLocal);

    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, nObjectType, oArea, nSearchCap);
    if (GetIsObjectValid(oResolved))
    {
        DL_SetCachedObject(oNpc, sCacheLocal, oResolved, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
        DL_SetAreaScopedCachedObjectByTag(oNpc, sTag, nObjectType, oArea, oResolved);
        DL_ClearCacheMissSuppressedTick(oNpc, sCacheLocal);
        DL_RecordCacheMetric(oArea, sMetricScope, FALSE);
        return oResolved;
    }

    DL_MarkCacheMissThisTick(oNpc, sCacheLocal, nNowTick);
    DL_RecordCacheMetric(oArea, sMetricScope, FALSE);
    return OBJECT_INVALID;
}
object DL_FindObjectByTagInAreaDeterministic(string sTag, int nObjectType, object oArea, int nSearchCap)
{
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    return DL_FindObjectByTagWithChecks(sTag, nSearchCap, nObjectType, oArea, OBJECT_INVALID, FALSE);
}


// Public cache API: npc-scoped cache keyed by (tag,type,area,tier,life-seq).
// Expected lifetime: until any context component changes.
// Invalidation triggers: explicit invalidate call, area/tier change, or NPC event-seq bump.
object DL_ResolveCachedObjectByTagInArea(
    object oOwner,
    string sCacheLocal,
    string sTag,
    int nObjectType,
    object oArea,
    int nTier,
    int nLifecycleSeq,
    int nSearchCap
)
{
    if (!GetIsObjectValid(oOwner) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    int nNowTick = DL_GetAreaTick(oArea);
    if (DL_IsCacheMissSuppressedThisTick(oOwner, sCacheLocal, nNowTick))
    {
        return OBJECT_INVALID;
    }

    object oCached = DL_GetCachedObject(oOwner, sCacheLocal, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
    {
        DL_ClearCacheMissSuppressedTick(oOwner, sCacheLocal);
        return oCached;
    }

    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, nObjectType, oArea, nSearchCap);
    if (GetIsObjectValid(oResolved))
    {
        DL_SetCachedObject(oOwner, sCacheLocal, oResolved, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
        DL_SetAreaScopedCachedObjectByTag(oOwner, sTag, nObjectType, oArea, oResolved);
        DL_ClearCacheMissSuppressedTick(oOwner, sCacheLocal);
        return oResolved;
    }

    DL_MarkCacheMissThisTick(oOwner, sCacheLocal, nNowTick);
    DL_InvalidateCachedObject(oOwner, sCacheLocal);
    return OBJECT_INVALID;
}
