void DL_ExecutePublicDirective(object oNpc)
{
    object oPublic = DL_ResolvePublicWaypoint(oNpc);
    if (!GetIsObjectValid(oPublic))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_public_anchor");
        return;
    }

    string sAnim = "pause";
    if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
    {
        sAnim = "talk01";
    }
    DL_ProgressFocusAtTarget(oNpc, oPublic, DL_FOCUS_STATUS_ON_PUBLIC_ANCHOR, sAnim);
}
