const string DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ = "dl_cache_social_partner_obj";
const string DL_L_NPC_CACHE_CHILL_CHAIR_OBJ = "dl_cache_chill_chair_obj";
const string DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL = "dl_cache_chill_chair_missing_until";
const string DL_L_NPC_CACHE_MEAL_CHAIR_OBJ = "dl_cache_meal_chair_obj";
const string DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL = "dl_cache_meal_chair_missing_until";
const string DL_L_NPC_CHILL_SIT_RETRY_UNTIL = "dl_chill_sit_retry_until";
const string DL_L_NPC_MEAL_SIT_RETRY_UNTIL = "dl_meal_sit_retry_until";
const string DL_L_NPC_MEAL_LEGACY_ACTION_SIT = "dl_meal_legacy_action_sit";
const string DL_L_NPC_CHILL_LEGACY_ACTION_SIT = "dl_chill_legacy_action_sit";
const string DL_L_NPC_FOCUS_ACTION_STAMP = "dl_focus_anchor_action_stamp";
const string DL_L_NPC_FOCUS_ACTION_TARGET = "dl_focus_anchor_action_target";
const string DL_L_WP_CHILL_CHAIR_TAG = "dl_chill_chair_tag";
const string DL_L_NPC_SOCIAL_PROBE_BEFORE = "dl_social_probe_before";
const string DL_L_NPC_SOCIAL_PROBE_AFTER = "dl_social_probe_after";
const string DL_L_NPC_SOCIAL_PROBE_RESULT = "dl_social_probe_result";
const string DL_L_NPC_SOCIAL_PROBE_REASON = "dl_social_probe_reason";
const string DL_L_NPC_SOCIAL_PROBE_DIST = "dl_social_probe_dist";
const string DL_L_NPC_SOCIAL_PROBE_ACTION = "dl_social_probe_action";
const string DL_L_NPC_SOCIAL_PROBE_SEQ = "dl_social_probe_seq";
const string DL_L_NPC_SOCIAL_PROBE_ABS_MIN = "dl_social_probe_abs_min";
const string DL_L_NPC_SOCIAL_PROBE_NOW_DIST = "dl_social_probe_now_dist";
const string DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE = "dl_social_probe_focus_status_before";
const string DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION = "dl_social_probe_current_action";
// Contract note: intentionally shares literal with work status moving marker.
// Domain must be inferred from owner key DL_L_NPC_FOCUS_STATUS (focus domain).
const string DL_FOCUS_STATUS_MOVING_TO_ANCHOR = "moving_to_anchor";
const string DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR = "on_public_anchor";
const string DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR = "on_social_anchor";
const string DL_FOCUS_STATUS_ON_CHILL_ANCHOR = "on_chill_anchor";
const string DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX = "on_meal_anchor";
const string DL_FOCUS_STATUS_ON_MEAL_ANCHOR_SITTING = "on_meal_anchor_sitting";
const string DL_FOCUS_STATUS_SITTING_MEAL_ATTEMPT = "sitting_meal_attempt";
const string DL_FOCUS_STATUS_SITTING_CHILL_ATTEMPT = "sitting_chill_attempt";
const string DL_FOCUS_STATUS_MISSING_CHILL_CHAIR = "missing_chill_chair";
const string DL_FOCUS_STATUS_CHILL_CHAIR_OCCUPIED = "chill_chair_occupied";
// Household seating defaults to waypoint animation: the meal/chill waypoint is
// the NPC body position and facing anchor, and chairs are decoration only.
// Set dl_meal_legacy_action_sit=1 or dl_chill_legacy_action_sit=1 on the NPC
// or waypoint only for hand-verified placeables that should use ActionSit.
const string DL_L_WP_MEAL_CHAIR_TAG = "dl_meal_chair_tag";
// CAP POLICY (worker-hotpath): social partner tag lookup runs during focus
// apply/tick, so it must be bounded to avoid hot worker inflation.
const int DL_SOCIAL_PARTNER_TAG_SEARCH_CAP = 32;
const int DL_CHILL_MISSING_CACHE_TTL_MINUTES = 10;
const int DL_MEAL_MISSING_CACHE_TTL_MINUTES = 10;
const int DL_CHILL_SIT_RETRY_MINUTES = 1;
const int DL_MEAL_SIT_RETRY_MINUTES = 1;
// CAP POLICY (worker-hotpath): near-chair probe is local polish logic, so cap
// is intentionally small to keep seat checks cheap per NPC tick.
const int DL_MEAL_NEAR_CHAIR_SCAN_CAP = 12;
const float DL_MEAL_NEAR_CHAIR_RADIUS = 2.25;
const float DL_MEAL_SIT_VERIFY_DELAY = 4.0;
const float DL_MEAL_LOOP_ANIM_DURATION = 30.0;
const float DL_CHILL_SIT_VERIFY_DELAY = 4.0;
const float DL_CHILL_LOOP_ANIM_DURATION = 30.0;
const string DL_CHILL_ANIM_SIT_IDLE = "sitidle";
