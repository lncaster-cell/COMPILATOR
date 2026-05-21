#include "dl_activity_archive_anim_inc"
#include "dl_move_job_decl_inc"
#include "dl_transition_inc"


// Compile-compatibility shims/wrappers preserved for include-order stability.
void DL_LogChatDebugEvent(object oNpc, string sKind, string sPayload)
{
    // Intentionally no-op: legacy diagnostic hook retained for compile compatibility.
}

int DL_HasTransitionExecutionState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return DL_IsTransitionExecutionStateActive(oNpc);
}

void DL_ClearTransitionExecutionStateWithReason(object oNpc, string sReason, string sOwner)
{
    DL_ClearTransitionExecutionState(oNpc);

    if (GetIsObjectValid(oNpc) && sReason != "")
    {
        if (sOwner == "")
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sReason);
        }
        else
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "owner=" + sOwner + " reason=" + sReason);
        }
    }
}

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

#include "dl_sched_inc"

int DL_DirectiveUsesFocusState(int nDirective)
{
    return nDirective == DL_DIR_MEAL ||
        nDirective == DL_DIR_SOCIAL ||
        nDirective == DL_DIR_PUBLIC ||
        nDirective == DL_DIR_CHILL;
}

string DL_GetDirectiveDebugLabel(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP)
    {
        return "SLEEP";
    }
    if (nDirective == DL_DIR_WORK)
    {
        return "WORK";
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return "MEAL";
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return "SOCIAL";
    }
    if (nDirective == DL_DIR_PUBLIC)
    {
        return "PUBLIC";
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return "CHILL";
    }
    return "NONE";
}
void DL_LogMarkupIssueOnce(object oNpc, string sKey, string sMessage)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    string sLastKey = GetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY);
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE);
    if (sLastKey == sKey && (nNowAbsMin - nLastMin) < DL_CHAT_MARKUP_COOLDOWN_MIN)
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY, sKey);
    SetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE, nNowAbsMin);
}

void DL_ApplyMaterializationSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirective == DL_DIR_SLEEP)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SLEEP);
        return;
    }

    if (nDirective == DL_DIR_WORK)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_WORK);
        return;
    }

    if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SOCIAL);
        return;
    }

    if (nDirective == DL_DIR_MEAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_MEAL);
        return;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_PUBLIC);
        return;
    }

    if (nDirective == DL_DIR_CHILL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_CHILL);
        return;
    }

    DeleteLocalInt(oNpc, DL_L_NPC_MAT_REQ);
    DeleteLocalString(oNpc, DL_L_NPC_MAT_TAG);
}

#include "dl_anchor_cache_inc"
#include "dl_presentation_inc"
#include "dl_anchor_move_inc"
#include "dl_sleep_inc"
#include "dl_move_job_inc"
#include "dl_work_inc"
#include "dl_focus_inc"

int DL_GetModuleCacheEpoch()
{
    object oModule = GetModule();
    int nEpoch = GetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH);
    if (nEpoch <= 0)
    {
        nEpoch = 1;
        SetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH, nEpoch);
    }
    return nEpoch;
}
void DL_ConsumeModuleCacheResetRequest()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_FORCE_CACHE_RESET) != TRUE)
    {
        return;
    }

    int nEpoch = DL_GetModuleCacheEpoch() + 1;
    SetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH, nEpoch);
    DeleteLocalInt(oModule, DL_L_MODULE_FORCE_CACHE_RESET);
}
void DL_ClearAreaNavigationCache(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int i = 0;
    while (i < DL_AREA_NAV_ROUTE_CAP)
    {
        DeleteLocalObject(oArea, DL_GetAreaNavigationSlotKey(i));
        i = i + 1;
    }
    DeleteLocalInt(oArea, DL_L_AREA_NAV_READY);
    DeleteLocalInt(oArea, DL_L_AREA_NAV_COUNT);
}
void DL_MaybeRefreshAreaCachesForEpoch(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    DL_ConsumeModuleCacheResetRequest();
    int nEpoch = DL_GetModuleCacheEpoch();
    if (GetLocalInt(oArea, DL_L_AREA_FORCE_CACHE_RESET) == TRUE ||
        GetLocalInt(oArea, DL_L_AREA_CACHE_EPOCH) != nEpoch)
    {
        DL_ClearAreaNavigationCache(oArea);
        SetLocalInt(oArea, DL_L_AREA_CACHE_EPOCH, nEpoch);
        DeleteLocalInt(oArea, DL_L_AREA_FORCE_CACHE_RESET);
    }
}
void DL_ClearNpcWaypointCaches(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SLEEP_APPROACH);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SLEEP_BED);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_FORGE);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_CRAFT);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_POST);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_TRADE);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_PRIMARY);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_SECONDARY);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_FETCH);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_MEAL);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_A);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_B);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_PUBLIC);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_CHILL_SEAT);
    DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
}
void DL_ClearNpcAreaCaches(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_HOME_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_PUBLIC_AREA);
}
void DL_ClearNpcRuntimeCaches(object oNpc)
{
    DL_ClearNpcWaypointCaches(oNpc);
    DL_ClearNpcAreaCaches(oNpc);
}
void DL_MaybeRefreshNpcCachesForEpoch(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        DL_MaybeRefreshAreaCachesForEpoch(oArea);
    }
    else
    {
        DL_ConsumeModuleCacheResetRequest();
    }

    int nEpoch = DL_GetModuleCacheEpoch();
    if (GetLocalInt(oNpc, DL_L_NPC_FORCE_CACHE_RESET) == TRUE ||
        GetLocalInt(oNpc, DL_L_NPC_CACHE_EPOCH) != nEpoch)
    {
        DL_ClearNpcRuntimeCaches(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_CACHE_EPOCH, nEpoch);
        DeleteLocalInt(oNpc, DL_L_NPC_FORCE_CACHE_RESET);
    }
}

void DL_SetInteractionModes(object oNpc, string sDialogue, string sService)
{
    SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, sDialogue);
    SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, sService);
}
int DL_IsProfileServiceAvailable(string sProfile)
{
    return sProfile != DL_PROFILE_GATE_POST;
}
void DL_ApplyIdleLikeDirectiveState(object oNpc, int bSocial)
{
    DL_ClearMoveJob(oNpc);
    SetLocalString(oNpc, DL_L_NPC_STATE, bSocial ? DL_STATE_SOCIAL : DL_STATE_IDLE);
    DL_SetInteractionModes(
        oNpc,
        bSocial ? DL_DIALOGUE_SOCIAL : DL_DIALOGUE_IDLE,
        DL_SERVICE_OFF
    );
    DL_ClearSleepExecutionState(oNpc);
    DL_ClearWorkExecutionState(oNpc);
    DL_ClearFocusExecutionState(oNpc);
    DL_ClearActivityPresentation(oNpc);
}
int DL_ResolveEffectiveDirective(object oNpc, int nDirective)
{
    if (nDirective == DL_DIR_SOCIAL && DL_ShouldFallbackSocialToPublic(oNpc))
    {
        return DL_DIR_PUBLIC;
    }

    return nDirective;
}
int DL_ShouldUseDirectiveFastPath(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (DL_HasTransitionExecutionState(oNpc))
    {
        return FALSE;
    }

    if (DL_GetNpcProblemSummary(oNpc) != "ok")
    {
        return FALSE;
    }

    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        return GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE) == DL_SLEEP_PHASE_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == DL_SLEEP_STATUS_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_WORK)
    {
        return GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == DL_WORK_STATUS_ON_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_MEAL)
    {
        string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        return GetSubString(sFocusStatus, 0, 15) == "on_meal_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "" &&
               !DL_HasMoveJob(oNpc);
    }

    if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "" &&
               !DL_HasMoveJob(oNpc);
    }

    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    return FALSE;
}
void DL_RefreshWorkPresentationOnFastPath(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_WORK ||
        GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) != DL_WORK_STATUS_ON_ANCHOR ||
        GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) == "")
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE);
    if (nLastMin > 0 && (nNowAbsMin - nLastMin) < DL_WORK_FASTPATH_PRESENTATION_REFRESH_MINUTES)
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE, nNowAbsMin);
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
}

object DL_ResolveFocusTargetInCurrentArea(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    if (sTarget == "")
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nIndex = 0;
    object oCandidate = GetObjectByTag(sTarget, nIndex);
    while (GetIsObjectValid(oCandidate) && nIndex < DL_WAYPOINT_TAG_SEARCH_CAP)
    {
        if (GetArea(oCandidate) == oArea)
        {
            return oCandidate;
        }

        nIndex = nIndex + 1;
        oCandidate = GetObjectByTag(sTarget, nIndex);
    }

    return OBJECT_INVALID;
}

int DL_IsFocusRecoverySocialTarget(object oNpc, object oTarget)
{
    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL)
    {
        return TRUE;
    }

    object oSocial = DL_ResolveSocialWaypoint(oNpc);
    if (GetIsObjectValid(oSocial) && oSocial == oTarget)
    {
        return TRUE;
    }

    return FALSE;
}

void DL_RecoverReachedFocusAnchorMoveState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != DL_FOCUS_STATUS_MOVING_TO_ANCHOR)
    {
        return;
    }

    object oTarget = DL_ResolveFocusTargetInCurrentArea(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        return;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        return;
    }

    if (DL_IsFocusRecoverySocialTarget(oNpc, oTarget))
    {
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
        AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
        return;
    }

    if (GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
    {
        return;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
}

object DL_ResolveDirectiveAnchorForMoveBridge(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        return DL_ResolvePublicWaypoint(oNpc);
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return DL_ResolveSocialWaypoint(oNpc);
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return DL_ResolveMealWaypoint(oNpc, DL_ResolveMealKind(oNpc));
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return DL_ResolveChillWaypoint(oNpc);
    }

    return OBJECT_INVALID;
}

string DL_GetDirectiveMoveOwnerForBridge(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP) return DL_MOVE_OWNER_SLEEP;
    if (nDirective == DL_DIR_WORK) return DL_MOVE_OWNER_WORK;
    if (nDirective == DL_DIR_PUBLIC) return DL_MOVE_OWNER_PUBLIC;
    if (nDirective == DL_DIR_SOCIAL) return DL_MOVE_OWNER_SOCIAL;
    if (nDirective == DL_DIR_MEAL) return DL_MOVE_OWNER_MEAL;
    if (nDirective == DL_DIR_CHILL) return DL_MOVE_OWNER_CHILL;
    return "";
}

string DL_GetDirectiveDestinationZone(object oNpc, int nDirective)
{
    if (GetIsObjectValid(oNpc) &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == DL_GetDirectiveMoveOwnerForBridge(nDirective) &&
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "")
    {
        return GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oAnchor))
    {
        return "";
    }

    string sZone = DL_NavGetAnchorZoneId(oAnchor);
    if (sZone != "")
    {
        return sZone;
    }

    return DL_NavGetAreaZoneId(GetArea(oAnchor));
}

int DL_IsTransitionMoveJobCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sPhase = GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    if (sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        // Legacy transition-owned jobs are accepted only through the explicit
        // transition compatibility checks below.
    }
    else
    {
        if (sPhase != DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA)
        {
            return FALSE;
        }

        if (sOwner != DL_GetDirectiveMoveOwnerForBridge(nDirective))
        {
            return FALSE;
        }
    }

    string sDirectiveZone = DL_GetDirectiveDestinationZone(oNpc, nDirective);
    if (sDirectiveZone == "")
    {
        return FALSE;
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (GetIsObjectValid(oAnchor))
    {
        if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea == oAnchorArea)
        {
            return FALSE;
        }
    }

    string sMoveTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sMoveTargetZone == "" && sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        sMoveTargetZone = GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    }
    if (sMoveTargetZone != sDirectiveZone)
    {
        return FALSE;
    }

    string sMoveTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    string sNextZone = DL_NavGetNextZone(oNpc, sDirectiveZone);
    if (sCurrentZone == "" || sNextZone == "")
    {
        return FALSE;
    }

    return sMoveTargetTag == DL_NavMakeTransitionTag(sCurrentZone, sNextZone);
}

int DL_ProcessTransitionMoveInApply(object oNpc, int nEffectiveDirective)
{
    if (!DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nEffectiveDirective))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_TICKED_DBG, TRUE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MISMATCH_SUPPRESSED_DBG, TRUE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REACHED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, FALSE);

    if (!DL_IsTransitionStatusActive(GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS)))
    {
        DL_NavSetState(oNpc, "moving_to_entry", GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE), "");
    }

    DL_TickMoveJob(oNpc);
    if (GetLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG) == TRUE)
    {
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG, TRUE);
    }

    if (DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED || DL_IsMoveJobAtTargetNow(oNpc))
    {
        object oTargetWp = DL_ResolveMoveJobTarget(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REACHED_DBG, TRUE);
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG, TRUE);
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oTargetWp))
        {
            SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, TRUE);
        }
        else
        {
            SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, FALSE);
        }
        return TRUE;
    }

    return TRUE;
}

int DL_IsMoveJobOwnerCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    if (sOwner == "")
    {
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA)
    {
        return DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nDirective);
    }

    if (sOwner == DL_MOVE_OWNER_PUBLIC) return nDirective == DL_DIR_PUBLIC;
    if (sOwner == DL_MOVE_OWNER_SOCIAL) return nDirective == DL_DIR_SOCIAL;
    if (sOwner == DL_MOVE_OWNER_MEAL) return nDirective == DL_DIR_MEAL;
    if (sOwner == DL_MOVE_OWNER_CHILL) return nDirective == DL_DIR_CHILL;
    if (sOwner == DL_MOVE_OWNER_WORK) return nDirective == DL_DIR_WORK;
    if (sOwner == DL_MOVE_OWNER_SLEEP) return nDirective == DL_DIR_SLEEP;
    if (sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        return DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nDirective);
    }

    return FALSE;
}

int DL_IsFocusStateCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    if (sFocusStatus == "")
    {
        return TRUE;
    }

    if (sFocusStatus == DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR) return nDirective == DL_DIR_PUBLIC;
    if (sFocusStatus == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR) return nDirective == DL_DIR_SOCIAL;
    if (GetSubString(sFocusStatus, 0, 15) == "on_meal_anchor") return nDirective == DL_DIR_MEAL;
    if (sFocusStatus == "on_chill_anchor") return nDirective == DL_DIR_CHILL;

    if (sFocusStatus == DL_FOCUS_STATUS_MOVING_TO_ANCHOR)
    {
        return DL_DirectiveUsesFocusState(nDirective) &&
               DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nDirective);
    }

    return DL_DirectiveUsesFocusState(nDirective);
}

void DL_ClearDirectiveChangeDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP);
}

void DL_PreemptOldDirectiveState(object oNpc, int nPrevDirective, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sOldMoveOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sOldMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    int bHadMoveJob = DL_HasMoveJob(oNpc);
    int bClearedFocus = FALSE;
    int bTriggeredFocusCleanup = FALSE;
    int bClearedTransition = FALSE;
    int bHadTransitionExecutionState = FALSE;

    SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, bHadMoveJob);
    SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER, sOldMoveOwner);
    SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET, sOldMoveTarget);
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV, DL_GetDirectiveDebugLabel(nPrevDirective));
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT, DL_GetDirectiveDebugLabel(nEffectiveDirective));

    DL_ClearMoveJob(oNpc);

    if (DL_DirectiveUsesFocusState(nPrevDirective) ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "" ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "")
    {
        DL_ClearFocusExecutionState(oNpc);
        bClearedFocus = TRUE;
        bTriggeredFocusCleanup = TRUE;
    }

    bHadTransitionExecutionState = DL_HasTransitionExecutionState(oNpc);
    if (bHadTransitionExecutionState)
    {
        DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "res");
        bClearedTransition = TRUE;
    }

    if (DL_DirectiveUsesFocusState(nPrevDirective) ||
        nPrevDirective == DL_DIR_WORK ||
        nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearActivityPresentation(oNpc);
    }

    SetLocalString(
        oNpc,
        DL_L_NPC_LAST_DIRECTIVE_CLEANUP,
        "prev=" + DL_GetDirectiveDebugLabel(nPrevDirective) +
            " next=" + DL_GetDirectiveDebugLabel(nEffectiveDirective) +
            " old_move_owner=" + sOldMoveOwner +
            " old_move_target=" + sOldMoveTarget +
            " cleared_move=" + IntToString(bHadMoveJob) +
            " cleared_focus=" + IntToString(bClearedFocus) +
            " focus_cleanup_triggered=" + IntToString(bTriggeredFocusCleanup) +
            " had_transition_state=" + IntToString(bHadTransitionExecutionState) +
            " cleared_transition=" + IntToString(bClearedTransition)
    );
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP, GetLocalString(oNpc, DL_L_NPC_LAST_DIRECTIVE_CLEANUP));
}

int DL_HasDistantSameAreaDirectiveAnchor(object oNpc, int nDirective)
{
    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea != oAnchorArea)
    {
        return FALSE;
    }

    return GetDistanceBetween(oNpc, oAnchor) > DL_WORK_ANCHOR_RADIUS;
}

int DL_BridgeLegacyDirectiveAnchorMoveJob(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc) || DL_HasMoveJob(oNpc) || !DL_DirectiveUsesFocusState(nDirective))
    {
        return FALSE;
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea != oAnchorArea)
    {
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oAnchor) <= DL_WORK_ANCHOR_RADIUS)
    {
        return FALSE;
    }

    string sOwner = DL_GetDirectiveMoveOwnerForBridge(nDirective);
    if (sOwner == "")
    {
        return FALSE;
    }

    string sReason = "bridge_" + sOwner + "_anchor";
    if (nDirective == DL_DIR_PUBLIC &&
        (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) == "transitioning" ||
            GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == ""))
    {
        sReason = "bridge_public_anchor_after_transition";
    }

    DL_ClearTransitionExecutionState(oNpc);
    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    // Canonical focus/anchor move command path:
    // keep all move-job issue state through DL_IssueFocusMoveAction.
    DL_IssueFocusMoveAction(oNpc, oAnchor);
    string sAnchorZone = DL_NavGetAnchorZoneId(oAnchor);
    DL_NavSetDebug(oNpc, DL_NavGetNpcCurrentZone(oNpc), sAnchorZone, sAnchorZone, sReason);
    return TRUE;
}

void DL_SetReachedFinalizeDebug(object oNpc, int bAttempted, int bSuccess, string sReason, int nDirective, string sOwner, string sTargetTag)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_ATTEMPTED_DBG, bAttempted);
    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_SUCCESS_DBG, bSuccess);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_REASON_DBG, sReason);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_DIRECTIVE_DBG, DL_GetDirectiveDebugLabel(nDirective));
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_OWNER_DBG, sOwner);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_TARGET_DBG, sTargetTag);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_AFTER_REACHED_FINALIZE_DBG, GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS));
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_AFTER_REACHED_FINALIZE_DBG, GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT));
}

int DL_FinalizeReachedDirectiveMoveJob(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_USED_FOCUS_DBG, FALSE);


    if (!DL_HasMoveJob(oNpc))
    {
        DL_SetReachedFinalizeDebug(oNpc, FALSE, FALSE, "no_move_job", nEffectiveDirective, "", "");
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "checking", nEffectiveDirective, sOwner, sTargetTag);

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        object oUnreachedTarget = DL_ResolveMoveJobTarget(oNpc);
        if (!GetIsObjectValid(oUnreachedTarget))
        {
            DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "missing_target", nEffectiveDirective, sOwner, sTargetTag);
            return FALSE;
        }

        object oNpcAreaCheck = GetArea(oNpc);
        object oTargetAreaCheck = GetArea(oUnreachedTarget);
        if (!GetIsObjectValid(oNpcAreaCheck) || !GetIsObjectValid(oTargetAreaCheck) || oNpcAreaCheck != oTargetAreaCheck)
        {
            DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "target_area_mismatch", nEffectiveDirective, sOwner, sTargetTag);
            return FALSE;
        }

        DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "target_not_reached", nEffectiveDirective, sOwner, sTargetTag);
        return FALSE;
    }

    DL_MarkMoveJobReachedNow(oNpc, "finalize_at_target");
    object oTarget = DL_ResolveMoveJobTarget(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "missing_target_after_reach", nEffectiveDirective, sOwner, sTargetTag);
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_REACHED);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_REACHED_FINALIZED_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_OWNER_DBG, sOwner);
    SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_TARGET_DBG, sTargetTag);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "res");

    if (sOwner == DL_MOVE_OWNER_PUBLIC && nEffectiveDirective == DL_DIR_PUBLIC)
    {
        string sAnim = "pause";
        if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
        {
            sAnim = "talk01";
        }
        DL_ClearMoveJob(oNpc);
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
        PlayCustomAnimation(oNpc, sAnim, TRUE);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "public_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SOCIAL && nEffectiveDirective == DL_DIR_SOCIAL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteSocialDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "social_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_MEAL && nEffectiveDirective == DL_DIR_MEAL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteMealDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "meal_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_CHILL && nEffectiveDirective == DL_DIR_CHILL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteChillDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "chill_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_WORK && nEffectiveDirective == DL_DIR_WORK)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteWorkDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "work_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SLEEP && nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteSleepDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "sleep_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        return TRUE;
    }

    DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "owner_directive_mismatch", nEffectiveDirective, sOwner, sTargetTag);
    return FALSE;
}

void DL_TraceApplyPipeline(object oNpc, string sStage)
{
}

int DL_IsDirectiveStableAfterReachedFinalize(object oNpc, int nEffectiveDirective)
{
    // Stable-stage mapping (general "arrived and settled" stage -> owner status):
    // PUBLIC  -> DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR
    // SOCIAL  -> DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR
    // MEAL    -> DL_FOCUS_STATUS_ON_MEAL_ANCHOR_PREFIX*
    // CHILL   -> DL_FOCUS_STATUS_ON_CHILL_ANCHOR
    // WORK    -> DL_WORK_STATUS_ON_ANCHOR
    // SLEEP   -> DL_SLEEP_STATUS_ON_BED
    if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_MEAL)
    {
        return GetSubString(GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS), 0, 15) == "on_meal_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_WORK)
    {
        return GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == DL_WORK_STATUS_ON_ANCHOR &&
               GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        return GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == DL_SLEEP_STATUS_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
    }
    return TRUE;
}

void DL_VerifyReachedFinalizeClosure(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if ((DL_HasMoveJob(oNpc) && GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING) ||
        !DL_IsDirectiveStableAfterReachedFinalize(oNpc, nEffectiveDirective))
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC, DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
    }
}

// AUDIT(#864): EMERGENCY CLOSURE for reached-but-not-closed contradictions.
// Preserve as narrow invariant repair until overlap debt is reduced with runtime evidence.
int DL_EmergencyCloseReachedMoveInvariant(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    if (sTargetTag == "")
    {
        sTargetTag = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    }

    if (sOwner == DL_MOVE_OWNER_PUBLIC && nEffectiveDirective == DL_DIR_PUBLIC && sTargetTag != "")
    {
        DL_ClearMoveJob(oNpc);
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        SetLocalInt(oNpc, DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_OWNER_DBG, sOwner);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_TARGET_DBG, sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SOCIAL && nEffectiveDirective == DL_DIR_SOCIAL && sTargetTag != "")
    {
        DL_ClearMoveJob(oNpc);
        DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_FOCUS_STATUS_ON_SOCIAL_ANCHOR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        SetLocalInt(oNpc, DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_OWNER_DBG, sOwner);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_TARGET_DBG, sTargetTag);
        return TRUE;
    }

    return FALSE;
}

void DL_DetectApplyMoveRegression(object oNpc, int bReachedOrClearedEarlier, int nMoveTicketBefore, string sMoveTargetBefore, string sStage, int nEffectiveDirective)
{
    if (!bReachedOrClearedEarlier)
    {
        return;
    }

    if (sMoveTargetBefore != "" &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING &&
        GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nMoveTicketBefore &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sMoveTargetBefore)
    {
        SetLocalInt(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG, sStage);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG, "same_tick_reopened_reached_move");
        if (DL_IsMoveJobAtTargetNow(oNpc))
        {
            int nGuardTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
            string sGuardOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
            string sGuardTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
            DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective);
            if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
            {
                if (GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nGuardTicket &&
                    GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == sGuardOwner &&
                    GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sGuardTarget)
                {
                    DL_EmergencyCloseReachedMoveInvariant(oNpc, nEffectiveDirective);
                }
                else
                {
                }
            }
        }
    }
}

// AUDIT(#864): APPLY-EXIT INVARIANT ENFORCER (emergency/fallback boundary).
// Purpose is to prevent stale running/moving_to_anchor contradictions after apply.
void DL_EnforceReachedMoveApplyExitInvariant(object oNpc, int nEffectiveDirective)
{
    if (DL_IsMoveJobAtTargetNow(oNpc) &&
        (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING ||
            GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_FOCUS_STATUS_MOVING_TO_ANCHOR))
    {
        int nGuardTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
        string sGuardOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
        string sGuardTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
        SetLocalInt(oNpc, DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG, TRUE);
        if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
        {
            DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
        }
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
        {
            if (GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nGuardTicket &&
                GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == sGuardOwner &&
                GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sGuardTarget)
            {
                DL_EmergencyCloseReachedMoveInvariant(oNpc, nEffectiveDirective);
            }
            else
            {
            }
        }
    }
}

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DL_MaybeRefreshNpcCachesForEpoch(oNpc);

    int nEffectiveDirective = DL_ResolveEffectiveDirective(oNpc, nDirective);
    int nPrevDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    int nApplyStartMoveTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    string sApplyStartMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    DL_TraceApplyPipeline(oNpc, "APPLY_ENTER");

    if (nPrevDirective != nEffectiveDirective)
    {
        DL_PreemptOldDirectiveState(oNpc, nPrevDirective, nEffectiveDirective);
    }
    else
    {
        DL_ClearDirectiveChangeDebug(oNpc);
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) != DL_MOVE_OWNER_TRANSITION &&
            GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) != DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA &&
            DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective) &&
            DL_IsMoveJobAtTargetNow(oNpc))
        {
            DL_TraceApplyPipeline(oNpc, "BEFORE_FINALIZE_REACHED");
            if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
            {
                DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            }
            DL_TraceApplyPipeline(oNpc, "AFTER_FINALIZE_REACHED");
        }
        DL_RecoverReachedFocusAnchorMoveState(oNpc);
        if (DL_ProcessTransitionMoveInApply(oNpc, nEffectiveDirective))
        {
            DL_TraceApplyPipeline(oNpc, "APPLY_EXIT");
            return;
        }
        if (!DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective))
        {
            string sBadMoveOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
            string sBadMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
            DL_ClearMoveJob(oNpc);
            SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, TRUE);
            SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER, sBadMoveOwner);
            SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET, sBadMoveTarget);
            SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV, DL_GetDirectiveDebugLabel(nPrevDirective));
            SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT, DL_GetDirectiveDebugLabel(nEffectiveDirective));
            SetLocalString(
                oNpc,
                DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP,
                "move_owner_mismatch_cleared old_move_owner=" + sBadMoveOwner +
                    " old_move_target=" + sBadMoveTarget
            );
        }
        DL_BridgeLegacyDirectiveAnchorMoveJob(oNpc, nEffectiveDirective);
    }

    int nMoveTicketBefore = nApplyStartMoveTicket;
    string sMoveTargetBefore = sApplyStartMoveTarget;
    string sMoveResultBeforeTick = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    int bReachedOrClearedEarlier = sMoveResultBeforeTick == DL_MOVE_RESULT_REACHED || !DL_HasMoveJob(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET_BEFORE_DBG, nMoveTicketBefore);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_BEFORE_TICK_DBG, sMoveResultBeforeTick);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG);
    SetLocalInt(oNpc, DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG, FALSE);

    int bMoveJobTicked = FALSE;
    if (nPrevDirective == nEffectiveDirective && DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective))
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_TICK_MOVE_JOB");
        bMoveJobTicked = DL_TickMoveJob(oNpc);
        if (bMoveJobTicked && DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED)
        {
            DL_TraceApplyPipeline(oNpc, "BEFORE_FINALIZE_REACHED");
            if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
            {
                DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            }
            DL_TraceApplyPipeline(oNpc, "AFTER_FINALIZE_REACHED");
            bReachedOrClearedEarlier = TRUE;
        }
        DL_TraceApplyPipeline(oNpc, "AFTER_TICK_MOVE_JOB");
    }
    else
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_TICK_MOVE_JOB");
        DL_TraceApplyPipeline(oNpc, "AFTER_TICK_MOVE_JOB");
    }

    if (!DL_HasMoveJob(oNpc) || GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_REACHED)
    {
        bReachedOrClearedEarlier = TRUE;
    }
    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_TICK_MOVE_JOB", nEffectiveDirective);

    if (bMoveJobTicked && DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_RUNNING)
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_FINALIZE_REACHED");
        if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
        {
            DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            bReachedOrClearedEarlier = TRUE;
        }
        DL_TraceApplyPipeline(oNpc, "AFTER_FINALIZE_REACHED");
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
        {
            DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
        }
    }

    int nMoveTicketAfter = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    string sMoveResultAfterTick = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET_AFTER_DBG, nMoveTicketAfter);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_AFTER_TICK_DBG, sMoveResultAfterTick);
    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "BEFORE_DIRECTIVE_EXECUTOR", nEffectiveDirective);

    if (nPrevDirective == nEffectiveDirective && DL_ShouldUseDirectiveFastPath(oNpc, nEffectiveDirective))
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_DIRECTIVE_EXECUTOR");
        if (nEffectiveDirective == DL_DIR_WORK)
        {
            DL_RefreshWorkPresentationOnFastPath(oNpc);
        }
        DL_TraceApplyPipeline(oNpc, "AFTER_DIRECTIVE_EXECUTOR");

        DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_DIRECTIVE_EXECUTOR", nEffectiveDirective);
        DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
        DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
        DL_TraceApplyPipeline(oNpc, "APPLY_EXIT");
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DIRECTIVE, nEffectiveDirective);

    DL_TraceApplyPipeline(oNpc, "BEFORE_DIRECTIVE_EXECUTOR");
    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearWorkExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SLEEP);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SLEEP, DL_SERVICE_OFF);
        DL_ApplyArchiveActivityPresentation(oNpc, nEffectiveDirective);
        DL_ExecuteSleepDirective(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_WORK);
        string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
        DL_SetInteractionModes(
            oNpc,
            DL_DIALOGUE_WORK,
            DL_IsProfileServiceAvailable(sProfile) ? DL_SERVICE_AVAILABLE : DL_SERVICE_OFF
        );

        DL_ClearSleepExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        DeleteLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE);
        DL_ExecuteWorkDirective(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_MEAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_MEAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteMealDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SOCIAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SOCIAL, DL_SERVICE_OFF);
        DL_ExecuteSocialDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_PUBLIC);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecutePublicDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_CHILL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_CHILL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteChillDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else
    {
        DL_ApplyIdleLikeDirectiveState(oNpc, FALSE);
    }
    DL_TraceApplyPipeline(oNpc, "AFTER_DIRECTIVE_EXECUTOR");

    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_DIRECTIVE_EXECUTOR", nEffectiveDirective);
    DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
    DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
    DL_TraceApplyPipeline(oNpc, "APPLY_EXIT");
}
