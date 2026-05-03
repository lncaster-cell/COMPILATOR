// Minimal compile-order declarations only.
// Keep this include small: no constants, no default args, no domain implementation.

void DL_ExecuteSleepDirective(object oNpc);
void DL_ExecuteWorkDirective(object oNpc);
void DL_ExecuteMealDirective(object oNpc);
void DL_ExecuteSocialDirective(object oNpc);
void DL_ExecutePublicDirective(object oNpc);
void DL_ExecuteChillDirective(object oNpc);

object DL_FindObjectByTagInAreaDeterministic(string sTag, int nObjectType, object oArea, int nSearchCap);
