// Daily Life canonical Transition Executor.
//
// Contract:
// - exactly one canonical executor API: DL_ExecuteTransitionViaEntryWaypoint.
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Canonical execution path is DL_ExecuteTransitionEngine; legacy wrappers in dl_transition_inc only delegate to it.

int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix)
{
    if (!DL_IsValidTransitionContext(oNpc, oEntryWp))
    {
        return FALSE;
    }

    // Business logic starts after guard-section.
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_PREPARE, "", "", "dl_tm_transition_dispatch_count");
    int bExecuted = DL_ExecuteTransitionEngine(oNpc, oEntryWp, sDiagPrefix);
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_FINALIZE);
    return bExecuted;
}

int DL_TryExecuteRoutedTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    // deprecated shim: use canonical DL_ExecuteTransitionViaEntryWaypoint directly.
    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntryWp, DL_DIAG_CTX_ROUTED);
}


int DL_TryAdvanceViaTransitionOrRouteEx(object oNpc, object oTargetWp, string sRouteContext, int bMarkSleepNavigation)
{
    if (!DL_IsValidTransitionContext(oNpc, oTargetWp))
    {
        return FALSE;
    }

    // Business logic starts after guard-section.
    int bHasTransition = GetIsObjectValid(DL_TryGetTransitionExitWaypoint(oTargetWp));
    if (bHasTransition)
    {
        if (DL_ExecuteTransitionViaEntryWaypoint(oNpc, oTargetWp, sRouteContext))
        {
            if (bMarkSleepNavigation)
            {
                DL_MarkSleepNavigationInProgress(oNpc, GetTag(oTargetWp));
            }
            return TRUE;
        }
    }

    if (DL_TryRouteToTarget(oNpc, oTargetWp))
    {
        if (bMarkSleepNavigation)
        {
            DL_MarkSleepNavigationInProgress(oNpc, GetTag(oTargetWp));
        }
        return TRUE;
    }

    return FALSE;
}

int DL_TryAdvanceViaTransitionOrRoute(object oNpc, object oTargetWp, string sRouteContext)
{
    return DL_TryAdvanceViaTransitionOrRouteEx(oNpc, oTargetWp, sRouteContext, FALSE);
}
