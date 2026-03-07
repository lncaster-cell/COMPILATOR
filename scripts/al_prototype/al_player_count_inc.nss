// Player counting helper for Ambient Life presence tracking.

int AL_IsCountedPlayer(object oPc)
{
    if (!GetIsObjectValid(oPc))
    {
        return FALSE;
    }

    if (!GetIsPC(oPc))
    {
        return FALSE;
    }

    // Server policy: do not count DMs in area population.
    if (GetIsDM(oPc))
    {
        return FALSE;
    }

    // Add other server-specific filters here (service clients, etc.) if needed.
    return TRUE;
}

// Handles a counted player leaving an area.
// Returns TRUE when the area became empty after decrement.
int AL_OnPlayerExitCount(object oPlayer, object oArea)
{
    if (!GetIsObjectValid(oPlayer) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    if (GetLocalInt(oPlayer, "al_exit_counted") == 1)
    {
        return FALSE;
    }

    SetLocalInt(oPlayer, "al_exit_counted", 1);

    int iPlayers = GetLocalInt(oArea, "al_player_count") - 1;
    if (iPlayers < 0)
    {
        iPlayers = 0;
    }

    SetLocalInt(oArea, "al_player_count", iPlayers);
    return (iPlayers == 0);
}
