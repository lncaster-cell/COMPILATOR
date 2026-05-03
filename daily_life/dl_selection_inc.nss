// Unified deterministic selection/scoring helpers.
// Domain adapters provide score and stable tie keys.

int DL_GetSelectionScoreInf()
{
    return 1000000;
}

int DL_SelectionCompare(int nCandidateScore, int nBestScore, string sCandidateTieKey, string sBestTieKey)
{
    if (nCandidateScore < nBestScore)
    {
        return TRUE;
    }

    if (nCandidateScore > nBestScore)
    {
        return FALSE;
    }

    if (sBestTieKey == "")
    {
        return TRUE;
    }

    if (sCandidateTieKey == "")
    {
        return FALSE;
    }

    string sCandidateNorm = GetStringLowerCase(sCandidateTieKey);
    string sBestNorm = GetStringLowerCase(sBestTieKey);
    if (sCandidateNorm == sBestNorm)
    {
        return FALSE;
    }

    return GetStringLength(sCandidateNorm) < GetStringLength(sBestNorm);
}

string DL_SelectionBuildTieKey(object oPrimary, object oSecondary, int nOrdinal)
{
    string sPrimary = GetIsObjectValid(oPrimary) ? GetTag(oPrimary) : "~";
    string sSecondary = GetIsObjectValid(oSecondary) ? GetTag(oSecondary) : "~";
    return sPrimary + "|" + sSecondary + "|" + IntToString(nOrdinal);
}

// Transition-routing contract:
// all candidate comparisons for transition routing must go through this helper
// to preserve deterministic score and tie-break behavior.
int DL_SelectionConsiderTransitionCandidate(
    int nCandidateScore,
    object oTiePrimary,
    object oTieSecondary,
    int nOrdinal,
    int nBestScore,
    string sBestTieKey
)
{
    string sCandidateTieKey = DL_SelectionBuildTieKey(oTiePrimary, oTieSecondary, nOrdinal);
    return DL_SelectionCompare(nCandidateScore, nBestScore, sCandidateTieKey, sBestTieKey);
}
