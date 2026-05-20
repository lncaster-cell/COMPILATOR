// Daily Life worker debug helper boundary.
//
// This include is intentionally introduced before moving implementations out of
// dl_worker_inc.nss.  Keeping this first step declaration-only makes the
// refactor low risk: the legacy definitions remain unchanged while the worker
// debug API is made explicit for the next extraction PR.
//
// Next extraction target:
//   - DL_GetAreaWorkerPassModeDebugLabel
//   - DL_GetAreaTierDebugLabel
//   - DL_SetAreaHotnessDebug
//   - DL_CopyAreaHotnessDebugToNpc
//   - DL_ClearCriticalWorkerDebug
//   - DL_SetCriticalWorkerDebug
//   - DL_SetCriticalProcessFailedDebug
//   - DL_ClearCriticalProcessFailedDebug
//   - DL_SetAreaWorkerPassDebug
//   - DL_SetNpcRegularWorkerDebug
//   - DL_TraceAreaWorkerTickForRegisteredNpc
//
// No behavior lives here yet.
// No runtime code is changed by this include alone.

string DL_GetAreaWorkerPassModeDebugLabel(int nPassMode);
string DL_GetAreaTierDebugLabel(int nTier);
void DL_SetAreaHotnessDebug(object oArea, int nCachedPlayers, int nActualPlayers, int nTierBefore, int nTierAfter, int bHotnessRepaired, int bForcedHotDueToPlayer, int bStaleRepaired);
void DL_CopyAreaHotnessDebugToNpc(object oNpc, object oArea);
void DL_ClearCriticalWorkerDebug(object oNpc);
void DL_SetCriticalWorkerDebug(object oNpc, string sReason);
void DL_SetCriticalProcessFailedDebug(object oNpc, object oArea, int nSlot, int nCount, int nPassMode, string sReason);
void DL_ClearCriticalProcessFailedDebug(object oNpc);
void DL_SetAreaWorkerPassDebug(object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter);
void DL_SetNpcRegularWorkerDebug(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter, int bSeenByRoundRobin, int bProcessedByRoundRobin, string sSkipReason);
void DL_TraceAreaWorkerTickForRegisteredNpc(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursor);
