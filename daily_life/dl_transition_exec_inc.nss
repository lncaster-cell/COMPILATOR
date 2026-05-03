// Daily Life canonical Transition Executor.
//
// Contract:
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Canonical execution path is DL_ExecuteTransitionEngine; legacy wrappers in dl_transition_inc only delegate to it.

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
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    return DL_TryExecuteTransitionEntryWaypoint(oNpc, oEntryWp);
}
