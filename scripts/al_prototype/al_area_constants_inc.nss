// Shared constants for Area tick pipeline.

const string AL_AREA_MODE_LOCAL_KEY = "al_area_heat";

const int AL_AREA_MODE_COLD = 0;
const int AL_AREA_MODE_WARM = 1;
const int AL_AREA_MODE_HOT = 2;
const int AL_AREA_MODE_OFF = 3;

const float AL_TICK_PERIOD_COLD = 45.0;
const float AL_TICK_PERIOD_WARM = 30.0;
const float AL_TICK_PERIOD = 45.0;
const float AL_TICK_PERIOD_HOT = 15.0;
const int AL_SYNC_TICK_INTERVAL = 4;
const int AL_TICK_WARM_REPEATS = 2;

const int AL_ROUTE_REPEAT_MIN_GAP_SECONDS_HOT = 2;
const int AL_ROUTE_REPEAT_MIN_GAP_SECONDS_WARM = 6;
