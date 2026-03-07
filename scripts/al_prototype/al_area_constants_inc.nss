// Shared constants for Area tick pipeline.

// Area mode contract (authoritative enum).
const int AL_AREA_MODE_OFF = 0;
const int AL_AREA_MODE_COLD = 1;
const int AL_AREA_MODE_WARM = 2;
const int AL_AREA_MODE_HOT = 3;

// Area mode transition reasons (authoritative enum).
const int AL_AREA_TRANSITION_REASON_UNSPECIFIED = 0;
const int AL_AREA_TRANSITION_REASON_LEGACY_PLAYERS_PRESENT = 1;
const int AL_AREA_TRANSITION_REASON_LEGACY_EMPTY = 2;
const int AL_AREA_TRANSITION_REASON_ENTER_FIRST_PLAYER = 3;
const int AL_AREA_TRANSITION_REASON_EXIT_LAST_PLAYER = 4;
const int AL_AREA_TRANSITION_REASON_NEIGHBOR_HEAT = 5;
const int AL_AREA_TRANSITION_REASON_CONTENT_OVERRIDE = 6;
const int AL_AREA_TRANSITION_REASON_SCRIPT_OVERRIDE = 7;
const int AL_AREA_TRANSITION_REASON_ADMIN_OVERRIDE = 8;

// Area-local keys for mode flags and diagnostics.
const string AL_AREA_MODE_LOCAL_KEY = "al_area_mode";
const string AL_AREA_MODE_FLAGS_ENABLED_LOCAL_KEY = "al_area_mode_flags_enabled";
const string AL_AREA_MODE_REASON_LOCAL_KEY = "al_area_mode_reason";
const string AL_AREA_MODE_PREV_LOCAL_KEY = "al_area_mode_prev";
const string AL_AREA_MODE_CHANGED_TS_LOCAL_KEY = "al_area_mode_changed_ts";

const float AL_TICK_PERIOD = 45.0;
const float AL_TICK_PERIOD_WARM = 15.0;
const int AL_SYNC_TICK_INTERVAL = 4;
const int AL_TICK_WARM_REPEATS = 2;

const string AL_AREA_MODE_LOCAL_KEY = "al_area_mode";

const int AL_AREA_MODE_HOT = 1;
const int AL_AREA_MODE_WARM = 2;
const int AL_AREA_MODE_COLD = 3;
const int AL_AREA_MODE_OFF = 4;
