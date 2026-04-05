#ifndef DL_CONST_INC_NSS
#define DL_CONST_INC_NSS

#define DL_L_NPC_FAMILY "dl_npc_family"
#define DL_L_NPC_SUBTYPE "dl_npc_subtype"
#define DL_L_SCHEDULE_TEMPLATE "dl_schedule_template"
#define DL_L_NPC_BASE "dl_npc_base"
#define DL_L_NAMED "dl_named"
#define DL_L_PERSISTENT "dl_persistent"
#define DL_L_PERSONAL_OFFSET_MIN "dl_personal_offset_min"
#define DL_L_ALLOWED_DIRECTIVES_MASK "dl_allowed_directives_mask"
#define DL_L_OVERRIDE_KIND "dl_override_kind"
#define DL_L_DIRECTIVE "dl_current_directive"
#define DL_L_ANCHOR_GROUP "dl_current_anchor_group"
#define DL_L_DIALOGUE_MODE "dl_dialogue_mode"
#define DL_L_SERVICE_MODE "dl_service_mode"
#define DL_L_ACTIVITY_KIND "dl_activity_kind"
#define DL_L_AREA_TIER "dl_area_tier"
#define DL_L_RESYNC_PENDING "dl_resync_pending"
#define DL_L_RESYNC_REASON "dl_resync_reason"
#define DL_L_DAY_TYPE_OVERRIDE "dl_day_type_override"
#define DL_L_LAST_SLOT_REVIEW "dl_last_slot_review"
#define DL_L_LAST_SLOT_REVIEW_REASON "dl_last_slot_review_reason"
#define DL_L_LAST_SLOT_ASSIGNED "dl_last_slot_assigned"
#define DL_L_LAST_SLOT_ASSIGNED_REASON "dl_last_slot_assigned_reason"
#define DL_L_SLOT_ASSIGNED_NPC "dl_slot_assigned_npc"
#define DL_L_LAST_BASE_LOST_SLOT "dl_last_base_lost_slot"
#define DL_L_LAST_BASE_LOST_NPC "dl_last_base_lost_npc"
#define DL_L_LAST_BASE_LOST_KIND "dl_last_base_lost_kind"
#define DL_L_FUNCTION_SLOT_ID "dl_function_slot_id"
#define DL_L_SMOKE_TRACE "dl_smoke_trace"

#define DL_DEBUG_NONE 0
#define DL_DEBUG_BASIC 1
#define DL_DEBUG_VERBOSE 2
#define DL_DEBUG_LEVEL DL_DEBUG_BASIC

#define DL_FAMILY_NONE 0
#define DL_FAMILY_LAW 1
#define DL_FAMILY_CRAFT 2
#define DL_FAMILY_TRADE_SERVICE 3
#define DL_FAMILY_CIVILIAN 4
#define DL_FAMILY_ELITE_ADMIN 5
#define DL_FAMILY_CLERGY 6

#define DL_SUBTYPE_NONE 0
#define DL_SUBTYPE_PATROL 1
#define DL_SUBTYPE_GATE_POST 2
#define DL_SUBTYPE_INSPECTION 3
#define DL_SUBTYPE_BLACKSMITH 4
#define DL_SUBTYPE_ARTISAN 5
#define DL_SUBTYPE_LABORER 6
#define DL_SUBTYPE_SHOPKEEPER 7
#define DL_SUBTYPE_INNKEEPER 8
#define DL_SUBTYPE_WANDERING_VENDOR 9
#define DL_SUBTYPE_RESIDENT 10
#define DL_SUBTYPE_HOMELESS 11
#define DL_SUBTYPE_SERVANT 12
#define DL_SUBTYPE_NOBLE 13
#define DL_SUBTYPE_OFFICIAL 14
#define DL_SUBTYPE_SCRIBE 15
#define DL_SUBTYPE_PRIEST 16

#define DL_SCH_NONE 0
#define DL_SCH_EARLY_WORKER 1
#define DL_SCH_SHOP_DAY 2
#define DL_SCH_TAVERN_LATE 3
#define DL_SCH_DUTY_ROTATION_DAY 4
#define DL_SCH_DUTY_ROTATION_NIGHT 5
#define DL_SCH_WANDERING_VENDOR_WINDOW 6
#define DL_SCH_CIVILIAN_HOME 7

#define DL_DAY_WEEKDAY 1
#define DL_DAY_REST 2
#define DL_DAY_CRISIS 3

#define DL_WIN_NONE 0
#define DL_WIN_SLEEP 1
#define DL_WIN_MORNING_PREP 2
#define DL_WIN_WORK_CORE 3
#define DL_WIN_SERVICE_CORE 4
#define DL_WIN_PUBLIC_IDLE 5
#define DL_WIN_SOCIAL 6
#define DL_WIN_LATE_SOCIAL 7
#define DL_WIN_DAY_DUTY 8
#define DL_WIN_NIGHT_DUTY 9

#define DL_BASE_NONE 0
#define DL_BASE_HOME 1
#define DL_BASE_WORKSHOP 2
#define DL_BASE_SHOP 3
#define DL_BASE_TAVERN 4
#define DL_BASE_BARRACKS 5
#define DL_BASE_TEMPLE 6
#define DL_BASE_OFFICE 7

#define DL_AG_NONE 0
#define DL_AG_SLEEP 1
#define DL_AG_WORK 2
#define DL_AG_SERVICE 3
#define DL_AG_SOCIAL 4
#define DL_AG_DUTY 5
#define DL_AG_GATE 6
#define DL_AG_PATROL_POINT 7
#define DL_AG_STREET_NEAR_BASE 8
#define DL_AG_WAIT 9
#define DL_AG_HIDE 10

#define DL_DIR_NONE 0
#define DL_DIR_SLEEP 1
#define DL_DIR_WORK 2
#define DL_DIR_SERVICE 3
#define DL_DIR_SOCIAL 4
#define DL_DIR_DUTY 5
#define DL_DIR_PUBLIC_PRESENCE 6
#define DL_DIR_HOLD_POST 7
#define DL_DIR_LOCKDOWN_BASE 8
#define DL_DIR_HIDE_SAFE 9
#define DL_DIR_ABSENT 10
#define DL_DIR_UNASSIGNED 11

#define DL_DLG_NONE 0
#define DL_DLG_WORK 1
#define DL_DLG_OFF_DUTY 2
#define DL_DLG_INSPECTION 3
#define DL_DLG_LOCKDOWN 4
#define DL_DLG_HIDE 5
#define DL_DLG_UNAVAILABLE 6

#define DL_SERVICE_NONE 0
#define DL_SERVICE_AVAILABLE 1
#define DL_SERVICE_LIMITED 2
#define DL_SERVICE_DISABLED 3

#define DL_ACT_NONE 0
#define DL_ACT_SLEEP 1
#define DL_ACT_WORK 2
#define DL_ACT_SERVICE_IDLE 3
#define DL_ACT_SOCIAL 4
#define DL_ACT_DUTY_IDLE 5
#define DL_ACT_HIDE 6

#define DL_OVR_NONE 0
#define DL_OVR_FIRE 1
#define DL_OVR_QUARANTINE 2

#define DL_AREA_FROZEN 0
#define DL_AREA_WARM 1
#define DL_AREA_HOT 2

#define DL_RESYNC_NONE 0
#define DL_RESYNC_AREA_ENTER 1
#define DL_RESYNC_TIER_UP 2
#define DL_RESYNC_SAVE_LOAD 3
#define DL_RESYNC_TIME_JUMP 4
#define DL_RESYNC_OVERRIDE_END 5
#define DL_RESYNC_WORKER 6
#define DL_RESYNC_SLOT_ASSIGNED 7
#define DL_RESYNC_BASE_LOST 8

#define DL_BUDGET_HOT 6
#define DL_BUDGET_WARM 2
#define DL_BUDGET_FROZEN 0

#define DL_GetDefaultWorkerBudget() (DL_BUDGET_HOT)

#define DL_GetDefaultAreaTierBudget(nTier) (((nTier) == DL_AREA_HOT) ? DL_BUDGET_HOT : (((nTier) == DL_AREA_WARM) ? DL_BUDGET_WARM : DL_BUDGET_FROZEN))

#endif // DL_CONST_INC_NSS
