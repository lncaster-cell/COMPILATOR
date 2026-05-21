// Step 05+: resolver/materialization skeleton.
string DL_GetNpcProblemSummary(object oNpc);
// Scope: basic BLACKSMITH/GATE_POST/TRADER WORK/SLEEP window split.

string DL_L_NPC_DIRECTIVE = "dl_npc_directive";
const string DL_L_NPC_MAT_REQ = "dl_npc_mat_req";
const string DL_L_NPC_MAT_TAG = "dl_npc_mat_tag";
const string DL_L_NPC_DIALOGUE_MODE = "dl_npc_dialogue_mode";
const string DL_L_NPC_SERVICE_MODE = "dl_npc_service_mode";
const string DL_L_NPC_PROFILE_ID = "dl_profile_id";
const string DL_L_NPC_STATE = "dl_state";
const string DL_L_NPC_SLEEP_PHASE = "dl_npc_sleep_phase";
string DL_L_NPC_SLEEP_STATUS = "dl_npc_sleep_status";
const string DL_L_NPC_SLEEP_TARGET = "dl_npc_sleep_target";
const string DL_L_NPC_SLEEP_DIAGNOSTIC = "dl_npc_sleep_diagnostic";
const string DL_L_NPC_WORK_KIND = "dl_npc_work_kind";
const string DL_L_NPC_WORK_TARGET = "dl_npc_work_target";
string DL_L_NPC_WORK_STATUS = "dl_npc_work_status";
const string DL_L_NPC_WORK_DIAGNOSTIC = "dl_npc_work_diagnostic";
const string DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE = "dl_work_fastpath_presentation_minute";
const string DL_L_NPC_GUARD_SHIFT_START = "dl_guard_shift_start";
const string DL_L_NPC_ACTIVITY_ID = "dl_npc_activity_id";
const string DL_L_NPC_ANIM_SET = "dl_npc_anim_set";
const string DL_L_NPC_CACHE_SLEEP_APPROACH = "dl_cache_sleep_approach";
const string DL_L_NPC_CACHE_SLEEP_BED = "dl_cache_sleep_bed";
const string DL_L_NPC_CACHE_WORK_FORGE = "dl_cache_work_forge";
const string DL_L_NPC_CACHE_WORK_CRAFT = "dl_cache_work_craft";
const string DL_L_NPC_CACHE_WORK_POST = "dl_cache_work_post";
const string DL_L_NPC_CACHE_WORK_TRADE = "dl_cache_work_trade";
const string DL_L_NPC_CACHE_MEAL = "dl_cache_meal";
const string DL_L_NPC_CACHE_SOCIAL_A = "dl_cache_social_a";
const string DL_L_NPC_CACHE_SOCIAL_B = "dl_cache_social_b";
const string DL_L_NPC_CACHE_PUBLIC = "dl_cache_public";
const string DL_L_NPC_CACHE_CHILL_SEAT = "dl_cache_chill_seat";
const string DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL = "dl_cache_chill_seat_missing_until";
const string DL_L_NPC_CACHE_WORK_PRIMARY = "dl_cache_work_primary";
const string DL_L_NPC_CACHE_WORK_SECONDARY = "dl_cache_work_secondary";
const string DL_L_NPC_CACHE_WORK_FETCH = "dl_cache_work_fetch";
const string DL_L_NPC_CACHE_HOME_AREA = "dl_cache_home_area";
const string DL_L_NPC_CACHE_WORK_AREA = "dl_cache_work_area";
const string DL_L_NPC_CACHE_MEAL_AREA = "dl_cache_meal_area";
const string DL_L_NPC_CACHE_SOCIAL_AREA = "dl_cache_social_area";
const string DL_L_NPC_CACHE_PUBLIC_AREA = "dl_cache_public_area";
string DL_L_NPC_FOCUS_STATUS = "dl_npc_focus_status";
string DL_L_NPC_FOCUS_TARGET = "dl_npc_focus_target";
const string DL_L_NPC_FOCUS_DIAGNOSTIC = "dl_npc_focus_diagnostic";
const string DL_L_NPC_SOCIAL_SLOT = "dl_social_slot";
const string DL_L_NPC_SOCIAL_PARTNER_TAG = "dl_social_partner_tag";
const string DL_L_NPC_WEEKEND_MODE = "dl_weekend_mode";
const string DL_L_NPC_WEEKEND_SHIFT_LENGTH = "dl_weekend_shift_length";
const string DL_L_NPC_HOME_AREA_TAG = "dl_home_area_tag";
const string DL_L_NPC_HOME_SLOT = "dl_home_slot";
const string DL_L_NPC_WORK_AREA_TAG = "dl_work_area_tag";
const string DL_L_NPC_MEAL_AREA_TAG = "dl_meal_area_tag";
const string DL_L_NPC_SOCIAL_AREA_TAG = "dl_social_area_tag";
const string DL_L_NPC_PUBLIC_AREA_TAG = "dl_public_area_tag";
const string DL_L_NPC_WAKE_HOUR = "dl_wake_hour";
const string DL_L_NPC_SLEEP_HOURS = "dl_sleep_hours";
const string DL_L_NPC_SHIFT_START = "dl_shift_start";
const string DL_L_NPC_SHIFT_LENGTH = "dl_shift_length";
const string DL_L_NPC_DIAG_LAST_KEY = "dl_diag_last_key";
const string DL_L_NPC_DIAG_LAST_MINUTE = "dl_diag_last_minute";
const string DL_L_NPC_LAST_DIRECTIVE_CLEANUP = "dl_last_directive_cleanup";
const string DL_L_MODULE_CACHE_EPOCH = "dl_cache_epoch";
const string DL_L_MODULE_FORCE_CACHE_RESET = "dl_force_cache_reset";
const string DL_L_AREA_CACHE_EPOCH = "dl_area_cache_epoch";
const string DL_L_AREA_FORCE_CACHE_RESET = "dl_force_area_cache_reset";
const string DL_L_NPC_CACHE_EPOCH = "dl_npc_cache_epoch";
const string DL_L_NPC_FORCE_CACHE_RESET = "dl_force_npc_cache_reset";

const string DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE = "directive_preempted_old_move";
const string DL_L_NPC_DBG_OLD_MOVE_OWNER = "old_move_owner";
const string DL_L_NPC_DBG_OLD_MOVE_TARGET = "old_move_target";
const string DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV = "directive_change_prev";
const string DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT = "directive_change_next";
const string DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP = "directive_change_cleanup";
const string DL_L_NPC_MOVE_TICKET_BEFORE_DBG = "move_ticket_before";
const string DL_L_NPC_MOVE_TICKET_AFTER_DBG = "move_ticket_after";
const string DL_L_NPC_MOVE_RESULT_BEFORE_TICK_DBG = "move_result_before_tick";
const string DL_L_NPC_MOVE_RESULT_AFTER_TICK_DBG = "move_result_after_tick";
const string DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG = "move_result_regressed_to_running";
const string DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG = "move_result_regression_reason";
const string DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG = "move_result_regression_stage";
const string DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG = "invariant_violation_reached_move_still_running";
const string DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG = "reached_finalize_returned_true_but_state_still_running";
const string DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG = "reached_invariant_emergency_closed";
const string DL_L_NPC_REACHED_INVARIANT_OWNER_DBG = "reached_invariant_owner";
const string DL_L_NPC_REACHED_INVARIANT_TARGET_DBG = "reached_invariant_target";
const string DL_L_NPC_TRANSITION_MOVE_TICKED_DBG = "transition_move_ticked";
const string DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG = "transition_move_reissued";
const string DL_L_NPC_TRANSITION_MOVE_REACHED_DBG = "transition_move_reached";
const string DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG = "transition_execute_attempted";
const string DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG = "transition_execute_success";
const string DL_L_NPC_TRANSITION_MISMATCH_SUPPRESSED_DBG = "transition_mismatch_suppressed";

string DL_L_NPC_MOVE_OWNER = "dl_move_owner";
const string DL_L_NPC_MOVE_PHASE = "dl_move_phase";
string DL_L_NPC_MOVE_TARGET_TAG = "dl_move_target_tag";
string DL_L_NPC_MOVE_TARGET_AREA = "dl_move_target_area";
string DL_L_NPC_MOVE_RADIUS = "dl_move_radius";
string DL_L_NPC_MOVE_TICKET = "dl_move_ticket";
string DL_L_NPC_MOVE_RESULT = "dl_move_result";
const string DL_L_NPC_MOVE_DIAGNOSTIC = "dl_move_diagnostic";
const string DL_L_NPC_MOVE_TARGET_OBJ = "dl_move_target_obj";

const string DL_MOVE_RESULT_RUNNING = "running";
const string DL_MOVE_RESULT_REACHED = "reached";
const string DL_MOVE_RESULT_FAILED = "failed";

const string DL_MOVE_OWNER_SLEEP = "sleep";
const string DL_MOVE_OWNER_WORK = "work";
const string DL_MOVE_OWNER_MEAL = "meal";
const string DL_MOVE_OWNER_SOCIAL = "social";
const string DL_MOVE_OWNER_PUBLIC = "public";
const string DL_MOVE_OWNER_CHILL = "chill";
const string DL_MOVE_OWNER_TRANSITION = "transition";

const string DL_PROFILE_BLACKSMITH = "blacksmith";
const string DL_PROFILE_GATE_POST = "gate_post";
const string DL_PROFILE_TRADER = "trader";
const string DL_PROFILE_DOMESTIC_WORKER = "domestic_worker";

const string DL_STATE_IDLE = "idle";
const string DL_STATE_SLEEP = "sleep";
const string DL_STATE_WORK = "work";
const string DL_STATE_SOCIAL = "social";
const string DL_STATE_MEAL = "meal";
const string DL_STATE_PUBLIC = "public";
const string DL_STATE_CHILL = "chill";

const string DL_DIALOGUE_IDLE = "idle";
const string DL_DIALOGUE_SLEEP = "sleep";
const string DL_DIALOGUE_WORK = "work";
const string DL_DIALOGUE_SOCIAL = "social";

const string DL_SERVICE_OFF = "off";
const string DL_SERVICE_AVAILABLE = "available";

const string DL_MAT_SLEEP = "sleep";
const string DL_MAT_WORK = "work";
const string DL_MAT_SOCIAL = "social";
const string DL_MAT_MEAL = "meal";
const string DL_MAT_PUBLIC = "public";
const string DL_MAT_CHILL = "chill";

const int DL_DIR_NONE = 0;
const int DL_DIR_SLEEP = 1;
const int DL_DIR_WORK = 2;
const int DL_DIR_SOCIAL = 3;
const int DL_DIR_MEAL = 4;
const int DL_DIR_PUBLIC = 5;
const int DL_DIR_CHILL = 6;
const int DL_SLEEP_PHASE_NONE = 0;
const int DL_SLEEP_PHASE_MOVING = 1;
const int DL_SLEEP_PHASE_JUMPING = 2;
const int DL_SLEEP_PHASE_ON_BED = 3;

const float DL_SLEEP_APPROACH_RADIUS = 1.50;
const float DL_SLEEP_BED_RADIUS = 1.10;
const float DL_WORK_ANCHOR_RADIUS = 1.60;

const string DL_WORK_KIND_FORGE = "forge";
const string DL_WORK_KIND_CRAFT = "craft";
const string DL_WORK_KIND_FETCH = "fetch";
const string DL_WORK_KIND_POST = "post";
const string DL_WORK_KIND_TRADE = "trade";
const string DL_WORK_KIND_DOMESTIC = "domestic";
const string DL_WEEKEND_MODE_OFF_PUBLIC = "off_public";
const string DL_WEEKEND_MODE_REDUCED_WORK = "reduced_work";
const string DL_MEAL_KIND_BREAKFAST = "breakfast";
const string DL_MEAL_KIND_LUNCH = "lunch";
const string DL_MEAL_KIND_DINNER = "dinner";
const int DL_CHAT_MARKUP_COOLDOWN_MIN = 120;
const int DL_WORK_FASTPATH_PRESENTATION_REFRESH_MINUTES = 30;

// Forward declarations for symbols implemented in includes that are
// textually attached later in this file.
int DL_IsActivePipelineNpc(object oNpc);
int DL_IsAreaObject(object oObject);
object DL_GetHomeArea(object oNpc);
object DL_GetWorkArea(object oNpc);
object DL_ResolveChillWaypoint(object oNpc);
int DL_ShouldFallbackSocialToPublic(object oNpc);
void DL_MaybeRefreshNpcCachesForEpoch(object oNpc);
void DL_MaybeRefreshAreaCachesForEpoch(object oArea);

