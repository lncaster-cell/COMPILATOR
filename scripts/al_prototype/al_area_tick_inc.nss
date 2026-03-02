#include "al_area_constants_inc"
#include "al_npc_reg_inc"
#include "al_route_cache_inc"

// Shared Area tick helper: scheduled every 45s while players are present.
// NPC registry synchronization is handled here at the area level only.

int AL_ComputeTimeSlot()
{
    // GetTimeHour() is expected to be in the 0..23 range.
    int iSlot = GetTimeHour() / 4;
    if (iSlot > AL_SLOT_MAX)
    {
        iSlot = AL_SLOT_MAX;
    }

    return iSlot;
}

void AreaTick(object oArea, int nToken)
{
    if (GetLocalInt(oArea, "al_player_count") <= 0)
    {
        return;
    }

    if (nToken != GetLocalInt(oArea, "al_tick_token"))
    {
        return;
    }

    int iSyncTick = GetLocalInt(oArea, "al_sync_tick") + 1;
    int bSynced = FALSE;
    if (iSyncTick >= AL_SYNC_TICK_INTERVAL)
    {
        iSyncTick = 0;
        AL_SyncAreaNPCRegistry(oArea);
        bSynced = TRUE;
    }
    SetLocalInt(oArea, "al_sync_tick", iSyncTick);

    int iSlot = AL_ComputeTimeSlot();

    if (iSlot == GetLocalInt(oArea, "al_slot"))
    {
        DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
        return;
    }

    if (!bSynced)
    {
        AL_SyncAreaNPCRegistry(oArea);
    }
    SetLocalInt(oArea, "al_slot", iSlot);
    AL_BroadcastUserEvent(oArea, AL_EVT_SLOT_0 + iSlot);
    DelayCommand(AL_TICK_PERIOD, AreaTick(oArea, nToken));
}
