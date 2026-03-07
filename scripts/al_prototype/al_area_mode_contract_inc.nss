#include "al_area_constants_inc"

// Area mode contract helpers.
// This include intentionally provides only read/check API wrappers,
// without introducing scheduler/runtime policy changes.

int AL_GetAreaModeLegacyDefault(object oArea)
{
    if (GetLocalInt(oArea, "al_player_count") > 0)
    {
        return AL_AREA_MODE_HOT;
    }

    return AL_AREA_MODE_COLD;
}

int AL_IsAreaModeFlagsEnabled(object oArea)
{
    return GetLocalInt(oArea, AL_AREA_MODE_FLAGS_ENABLED_LOCAL_KEY) == TRUE;
}

int AL_GetAreaModeOrLegacy(object oArea)
{
    // Legacy behavior remains default until per-area mode flags are enabled.
    if (!AL_IsAreaModeFlagsEnabled(oArea))
    {
        return AL_GetAreaModeLegacyDefault(oArea);
    }

    int iMode = GetLocalInt(oArea, AL_AREA_MODE_LOCAL_KEY);
    if (iMode == AL_AREA_MODE_HOT
        || iMode == AL_AREA_MODE_WARM
        || iMode == AL_AREA_MODE_COLD
        || iMode == AL_AREA_MODE_OFF)
    {
        return iMode;
    }

    return AL_GetAreaModeLegacyDefault(oArea);
}

int AL_IsAreaModeHot(object oArea)
{
    return AL_GetAreaModeOrLegacy(oArea) == AL_AREA_MODE_HOT;
}

int AL_IsAreaModeWarm(object oArea)
{
    return AL_GetAreaModeOrLegacy(oArea) == AL_AREA_MODE_WARM;
}

int AL_IsAreaModeCold(object oArea)
{
    return AL_GetAreaModeOrLegacy(oArea) == AL_AREA_MODE_COLD;
}

int AL_IsAreaModeOff(object oArea)
{
    return AL_GetAreaModeOrLegacy(oArea) == AL_AREA_MODE_OFF;
}
