#include "dl_social_scene_inc"

#include "dl_focus_contract_inc"

int DL_ShouldIssueFocusMoveAction(object oNpc, object oTarget)
{
    return DL_ShouldIssueAnchorMoveAction(
        oNpc,
        oTarget,
        DL_L_NPC_FOCUS_STATUS,
        DL_FOCUS_STATUS_MOVING_TO_ANCHOR,
        DL_L_NPC_FOCUS_ACTION_TARGET,
        DL_L_NPC_FOCUS_ACTION_STAMP
    );
}
string DL_GetFocusMoveOwner(object oNpc)
{
    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (nDirective == DL_DIR_MEAL) return DL_MOVE_OWNER_MEAL;
    if (nDirective == DL_DIR_SOCIAL) return DL_MOVE_OWNER_SOCIAL;
    if (nDirective == DL_DIR_PUBLIC) return DL_MOVE_OWNER_PUBLIC;
    if (nDirective == DL_DIR_CHILL) return DL_MOVE_OWNER_CHILL;
    return "focus";
}
void DL_IssueFocusMoveAction(object oNpc, object oTarget)
{
    DL_BeginAnchorMoveJob(
        oNpc,
        oTarget,
        DL_L_NPC_FOCUS_STATUS,
        DL_FOCUS_STATUS_MOVING_TO_ANCHOR,
        DL_L_NPC_FOCUS_TARGET,
        DL_L_NPC_FOCUS_ACTION_TARGET,
        DL_GetFocusMoveOwner(oNpc),
        "anchor",
        DL_WORK_ANCHOR_RADIUS
    );
}
void DL_ClearFocusExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
    DL_ClearSocialSceneState(oNpc);
    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DL_ClearTransitionExecutionState(oNpc);
}

#include "dl_focus_resolve_inc"

// AUDIT(#864): CANONICAL FOCUS PROGRESSION with known overlap debt.
// This block bridges focus presentation with movement/finalization outcomes;
// refactor only in single-theme PRs to avoid duplicating closure logic.
int DL_ProgressFocusAtTarget(object oNpc, object oTarget, string sOnAnchorStatus, string sAnim)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    int bFinalizedTransition = DL_NavTryFinalizeCompletedTransition(oNpc, oTarget);
    if (bFinalizedTransition)
    {
        DL_LogChatDebugEvent(
            oNpc,
            "post_transition_complete",
            "post_transition_complete" +
                " npc_area=" + GetLocalString(oNpc, "dl_nav_debug_npc_area") +
                " target_area=" + GetLocalString(oNpc, "dl_nav_debug_target_area") +
                " current_zone=" + GetLocalString(oNpc, "dl_nav_debug_current_zone") +
                " target_zone=" + GetLocalString(oNpc, "dl_nav_debug_target_zone") +
                " old_transition_status=" + GetLocalString(oNpc, "dl_nav_debug_old_transition_status") +
                " focus_target=" + GetLocalString(oNpc, "dl_nav_debug_focus_target") +
                " current_action=" + IntToString(GetLocalInt(oNpc, "dl_nav_debug_current_action"))
        );
    }
    if (!bFinalizedTransition && DL_NavTryAdvanceFromAnchorForOwner(oNpc, oTarget, DL_GetFocusMoveOwner(oNpc)))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldIssueFocusMoveAction(oNpc, oTarget))
        {
            DL_IssueFocusMoveAction(oNpc, oTarget);
        }
        return TRUE;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DL_ClearMoveJob(oNpc);
    DL_ClearTransitionExecutionStateWithReason(oNpc, "owner_clear", "focus");
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, sOnAnchorStatus);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
    AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
    if (sAnim != "")
    {
        PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
    DL_LogChatDebugEvent(oNpc, sOnAnchorStatus, sOnAnchorStatus + " anchor=" + GetTag(oTarget));
    return TRUE;
}
int DL_ApplyFocusWaypointAnimation(object oNpc, object oAnchor, string sStableStatus, string sAnim, float fLoopDuration)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    string sAnchorTag = GetTag(oAnchor);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == sStableStatus &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sAnchorTag)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        return TRUE;
    }

    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
    DL_ClearTransitionExecutionState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, sStableStatus);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sAnchorTag);

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, SetFacing(GetFacing(oAnchor)));

    int bPlayedCustom = FALSE;
    if (sAnim != "")
    {
        bPlayedCustom = PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
    if (!bPlayedCustom)
    {
        AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_SIT_CHAIR, 1.0, fLoopDuration));
    }

    DL_LogChatDebugEvent(
        oNpc,
        sStableStatus,
        sStableStatus + " waypoint_animation anchor=" + sAnchorTag + " anim=" + sAnim + " custom=" + IntToString(bPlayedCustom)
    );
    return TRUE;
}



#include "dl_focus_meal_inc"



#include "dl_focus_chill_inc"

#include "dl_focus_public_inc"

#include "dl_focus_social_inc"
