const string DL_L_MODULE_CACHE_METRIC_PREFIX = "dl_metric_cache_";
const string DL_L_CACHE_CTX_PREFIX = "dl_cache_ctx_";
const string DL_L_CACHE_MISS_TICK_SUFFIX = "miss_tick";

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

    int nTier = DL_GetAreaTier(oArea);
    int nLifecycleSeq = GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ);
    object oCached = DL_GetCachedObject(oNpc, sCacheLocal, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
    {
        DL_RecordCacheMetric(oArea, sMetricScope, TRUE);
        return oCached;
    }

    DL_InvalidateCachedObject(oNpc, sCacheLocal);

    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, nObjectType, oArea, nSearchCap);
    if (GetIsObjectValid(oResolved))
    {
        DL_SetCachedObject(oNpc, sCacheLocal, oResolved, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
        DL_RecordCacheMetric(oArea, sMetricScope, FALSE);
        return oResolved;
    }

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

    object oCached = DL_GetCachedObject(oOwner, sCacheLocal, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
    {
        return oCached;
    }

    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, nObjectType, oArea, nSearchCap);
    if (GetIsObjectValid(oResolved))
    {
        DL_SetCachedObject(oOwner, sCacheLocal, oResolved, sTag, nObjectType, oArea, nTier, nLifecycleSeq);
        return oResolved;
    }

    DL_InvalidateCachedObject(oOwner, sCacheLocal);
    return OBJECT_INVALID;
}
