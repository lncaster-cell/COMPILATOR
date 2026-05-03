// Compile-order forward declarations for Daily Life include graph.
// This file contains declarations only; implementations remain in their domain includes.

void DL_ExecuteSleepDirective(object oNpc);
void DL_ExecuteWorkDirective(object oNpc);
void DL_ExecuteMealDirective(object oNpc);
void DL_ExecuteSocialDirective(object oNpc);
void DL_ExecutePublicDirective(object oNpc);
void DL_ExecuteChillDirective(object oNpc);

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective);

void DL_ClearTransitionExecutionState(object oNpc);
void DL_RegisterNpc(object oNpc);
void DL_UnregisterNpc(object oNpc);
void DL_ReconcileNpcAreaRegistration(object oNpc);
void DL_RequestResync(object oNpc, int nReason);
void DL_ProcessResync(object oNpc);

object DL_FindObjectByTagInAreaDeterministic(string sTag, int nObjectType, object oArea, int nSearchCap);

string DL_LegacyAdapterResolveExitTagFromKindId(string sKind, string sTransitionId);
object DL_LegacyAdapterResolveGlobalTransitionWaypointByTag(string sTag);
int DL_LegacyAdapterIsTransitionDriverTypeMatch(object oDriver, string sDriverType);

int DL_IsTransitionNavigableTarget(object oTarget);

void DL_LogInvalidAreaTagIssue(object oNpc, string sContext, string sAreaTag);
void DL_LogMissingAnchorIssue(object oNpc, string sContext, string sAnchorTag);
void DL_LogForeignWaypointIssue(object oNpc, string sContext, object oWaypoint, object oExpectedArea);
