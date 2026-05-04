const string DL_L_AREA_INDEX_RUNTIME_SEQ = "dl_idx_runtime_seq";
const string DL_L_AREA_INDEX_BUILT_SEQ = "dl_idx_built_seq";
const string DL_L_AREA_INDEX_NPC_COUNT = "dl_idx_npc_count";
const string DL_L_AREA_INDEX_WP_COUNT = "dl_idx_wp_count";
const string DL_L_AREA_INDEX_WP_PREFIX = "dl_idx_wp_tag_";
const string DL_L_AREA_INDEX_WP_REBUILD_PENDING = "dl_idx_wp_rebuild_pending";
const string DL_L_AREA_INDEX_WP_REBUILD_CURSOR = "dl_idx_wp_rebuild_cursor";
const string DL_L_AREA_INDEX_WP_REBUILD_PASS = "dl_idx_wp_rebuild_pass";
const string DL_L_AREA_INDEX_NPC_DIRTY = "dl_idx_npc_dirty";

const int DL_AREA_INDEX_WP_REBUILD_BUDGET = 16;
const int DL_AREA_INDEX_WP_FALLBACK_CAP = 12;

void DL_InvalidateAreaIndex(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ, GetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ) + 1);
    SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING, TRUE);
    SetLocalInt(oArea, DL_L_AREA_INDEX_NPC_DIRTY, TRUE);
}

string DL_GetAreaIndexWpSlotKey(string sTag)
{
    return DL_L_AREA_INDEX_WP_PREFIX + sTag;
}

void DL_RecountAreaNpcIndex(object oArea)
{
    object oObj = GetFirstObjectInArea(oArea);
    int nNpcCount = 0;
    while (GetIsObjectValid(oObj))
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_CREATURE && DL_IsActivePipelineNpc(oObj))
        {
            nNpcCount = nNpcCount + 1;
        }
        oObj = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, DL_L_AREA_INDEX_NPC_COUNT, nNpcCount);
    DeleteLocalInt(oArea, DL_L_AREA_INDEX_NPC_DIRTY);
}

int DL_AdvanceWaypointIndexRebuild(object oArea, int nBudget)
{
    if (nBudget <= 0)
    {
        nBudget = DL_AREA_INDEX_WP_REBUILD_BUDGET;
    }

    int nCursor = GetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_CURSOR);
    if (nCursor < 0)
    {
        nCursor = 0;
    }

    int nPass = GetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PASS);
    if (nPass <= 0)
    {
        nPass = 1;
        DeleteLocalInt(oArea, DL_L_AREA_INDEX_WP_COUNT);
    }

    object oObj = GetFirstObjectInArea(oArea);
    int nSkipped = 0;
    while (GetIsObjectValid(oObj) && nSkipped < nCursor)
    {
        oObj = GetNextObjectInArea(oArea);
        nSkipped = nSkipped + 1;
    }

    if (nSkipped < nCursor && !GetIsObjectValid(oObj))
    {
        nCursor = 0;
        oObj = GetFirstObjectInArea(oArea);
    }

    int nProcessed = 0;
    while (GetIsObjectValid(oObj) && nProcessed < nBudget)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT)
        {
            string sTag = GetTag(oObj);
            if (sTag != "")
            {
                if (nPass <= 1 || !GetIsObjectValid(GetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag))))
                {
                    SetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag), oObj);
                }
                SetLocalInt(oArea, DL_L_AREA_INDEX_WP_COUNT, GetLocalInt(oArea, DL_L_AREA_INDEX_WP_COUNT) + 1);
            }
        }

        oObj = GetNextObjectInArea(oArea);
        nProcessed = nProcessed + 1;
    }

    if (GetIsObjectValid(oObj))
    {
        SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_CURSOR, nCursor + nProcessed);
        SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PASS, nPass);
        SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING, TRUE);
        return FALSE;
    }

    if (nPass <= 1)
    {
        SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_CURSOR, 0);
        SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PASS, 2);
        SetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING, TRUE);
        return FALSE;
    }

    DeleteLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_CURSOR);
    DeleteLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PASS);
    DeleteLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING);
    return TRUE;
}

void DL_EnsureAreaIndexBuilt(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nRuntimeSeq = GetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ);
    int nBuiltSeq = GetLocalInt(oArea, DL_L_AREA_INDEX_BUILT_SEQ);

    if (nBuiltSeq == nRuntimeSeq && GetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING) != TRUE && GetLocalInt(oArea, DL_L_AREA_INDEX_NPC_DIRTY) != TRUE)
    {
        return;
    }

    if (GetLocalInt(oArea, DL_L_AREA_INDEX_NPC_DIRTY) == TRUE || nBuiltSeq != nRuntimeSeq)
    {
        DL_RecountAreaNpcIndex(oArea);
    }

    if (GetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING) == TRUE || nBuiltSeq != nRuntimeSeq)
    {
        DL_AdvanceWaypointIndexRebuild(oArea, DL_AREA_INDEX_WP_REBUILD_BUDGET);
    }

    SetLocalInt(oArea, DL_L_AREA_INDEX_BUILT_SEQ, nRuntimeSeq);
}

object DL_IndexGetWaypointByTag(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    DL_EnsureAreaIndexBuilt(oArea);

    object oWp = GetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag));
    if (GetIsObjectValid(oWp) && GetObjectType(oWp) == OBJECT_TYPE_WAYPOINT && GetArea(oWp) == oArea && GetTag(oWp) == sTag)
    {
        DL_RecordCacheMetricBatch(oArea, "index", 1, 0);
        return oWp;
    }

    if (GetLocalInt(oArea, DL_L_AREA_INDEX_WP_REBUILD_PENDING) == TRUE)
    {
        object oScan = GetFirstObjectInArea(oArea);
        int nScanned = 0;
        while (GetIsObjectValid(oScan) && nScanned < DL_AREA_INDEX_WP_FALLBACK_CAP)
        {
            if (GetObjectType(oScan) == OBJECT_TYPE_WAYPOINT && GetTag(oScan) == sTag)
            {
                SetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag), oScan);
                DL_RecordCacheMetricBatch(oArea, "index", 1, 0);
                return oScan;
            }
            oScan = GetNextObjectInArea(oArea);
            nScanned = nScanned + 1;
        }
    }

    DL_RecordCacheMetricBatch(oArea, "index", 0, 1);
    return OBJECT_INVALID;
}
