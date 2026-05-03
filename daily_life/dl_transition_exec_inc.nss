// Daily Life canonical Transition Executor.
//
// Contract:
// - exactly one canonical executor API: DL_ExecuteTransitionViaEntryWaypoint.
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Uses existing transition metadata and driver semantics from dl_transition_inc.

int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_PREPARE, "", "", "dl_tm_transition_dispatch_count");
    int bExecuted = DL_TryExecuteTransitionEntryWaypoint(oNpc, oEntryWp);
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_FINALIZE);
    return bExecuted;
}

int DL_TryExecuteRoutedTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    // deprecated shim: use canonical DL_ExecuteTransitionViaEntryWaypoint directly.
    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntryWp, DL_DIAG_CTX_ROUTED);
}
