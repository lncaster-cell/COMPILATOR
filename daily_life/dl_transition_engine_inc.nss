// Daily Life unified transition execution engine.
// Canonical input contract:
// - oNpc: NPC being transitioned
// - oEntryWp: route-discovered transition entry waypoint
// - sDiagPrefix: execution context prefix ("", "routed", "cross_area", ...)
// Maintenance contract:
// - Any new transition behavior/change must be implemented in this file only.
// - Wrapper includes may only delegate to DL_ExecuteTransitionEngine.

int DL_EngineJumpNpcToTransitionExit(object oNpc, location lExit, string sStatus = "", string sDiagnostic = "")
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    object oExitArea = GetAreaFromLocation(lExit);
    if (!DL_CanRunTransitionForArea(oExitArea))
    {
        if (sStatus != "")
        {
            DL_SetTransitionState(oNpc, sStatus, sDiagnostic, "");
        }
        return FALSE;
    }

    DL_DispatchJumpToLocation(oNpc, lExit);
    return TRUE;
}

void DL_TransitionPrepareAndJump(object oNpc, object oExitWp, location lExit, string sStatus, string sDiag, string sDiagContext = "")
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);
    DL_SetTransitionState(oNpc, sStatus, sDiag, "");
    DL_EngineJumpNpcToTransitionExit(oNpc, lExit, sStatus, sDiag);
}

int DL_ExecuteTransitionDriver(object oNpc, object oEntryWp, location lExit, object oExitWp, string sDiagContext = "", string sJumpDiagnostic = DL_TRANSITION_DIAG_IN_PROGRESS)
{
    if (!DL_IsValidTransitionContext(oNpc, oEntryWp))
    {
        return FALSE;
    }

    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    if (sDriver == "" || sDriver == DL_TRANSITION_DRIVER_NONE || sDriver == DL_TRANSITION_DRIVER_TRIGGER)
    {
        DL_TransitionPrepareAndJump(oNpc, oExitWp, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sJumpDiagnostic, sDiagContext);
        return TRUE;
    }

    if (sDriver == DL_TRANSITION_DRIVER_DOOR)
    {
        object oDoor = DL_ResolveTransitionDriverObject(oEntryWp);
        if (!GetIsObjectValid(oDoor) || GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
        {
            DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_DRIVER_MISSING, DL_TRANSITION_DIAG_DRIVER_REQUIRED, sDiagContext);
            return TRUE;
        }

        AssignCommand(oNpc, ClearAllActions(TRUE));
        if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
        {
            AssignCommand(oNpc, DoDoorAction(oDoor, DOOR_ACTION_OPEN));
        }
        DL_TransitionPrepareAndJump(oNpc, oExitWp, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sJumpDiagnostic, sDiagContext);
        return TRUE;
    }

    DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_DRIVER_UNKNOWN, DL_TRANSITION_DIAG_DRIVER_UNKNOWN, sDiagContext);
    return TRUE;
}

int DL_ExecuteTransitionEngine(object oNpc, object oEntryWp, string sDiagPrefix)
{
    if (!DL_IsValidTransitionContext(oNpc, oEntryWp))
    {
        return FALSE;
    }

    if (!DL_WaypointHasTransition(oEntryWp))
    {
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
    // Transition context payload; status/diagnostics are always written via
    // DL_SetTransitionState to keep a single diagnostics API.
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_ID, sTransitionId);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, GetTag(oEntryWp));

    if (sExitTag == "" && (sKind == "" || sTransitionId == "") && !DL_IsAutoNavTag(GetTag(oEntryWp)))
    {
        DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_METADATA_MISSING, DL_TRANSITION_DIAG_METADATA_REQUIRED, sDiagPrefix);
        return TRUE;
    }

    if (!DL_IsWithinAnchorRadius(oNpc, oEntryWp, DL_TRANSITION_ENTRY_RADIUS))
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != DL_TRANSITION_STATUS_MOVING_TO_ENTRY)
        {
            DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_MOVING_TO_ENTRY, DL_TRANSITION_DIAG_MOVING_TO_ENTRY, sDiagPrefix);
            DL_DispatchMoveToLocation(oNpc, GetLocation(oEntryWp), TRUE);
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oEntryWp);
    if (!GetIsObjectValid(oExitWp))
    {
        DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_EXIT_MISSING, DL_TRANSITION_DIAG_EXIT_REQUIRED, sDiagPrefix);
        return TRUE;
    }

    location lExit = GetLocation(oExitWp);
    DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_TRANSITIONING, DL_TRANSITION_DIAG_IN_PROGRESS, sDiagPrefix);
    return DL_ExecuteTransitionDriver(oNpc, oEntryWp, lExit, oExitWp, sDiagPrefix + "_" + DL_TRANSITION_DIAG_IN_PROGRESS);
}
