// SOCIAL directive owns routing and stable anchor focus only.
// This Social Scene layer owns staged, non-looping presentation gestures.
// It is worker tick-driven and cancellable through focus cleanup; it avoids
// DelayCommand chains, NPC heartbeats, global managers, and area scans.

const string DL_L_NPC_SOCIAL_SCENE_ID = "dl_social_scene_id";
const string DL_L_NPC_SOCIAL_SCENE_STEP = "dl_social_scene_step";
const string DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE = "dl_social_scene_next_minute";
const string DL_L_NPC_SOCIAL_SCENE_ROLE = "dl_social_scene_role";
const string DL_L_NPC_SOCIAL_SCENE_LAST_ANIM = "dl_social_scene_last_anim";
const string DL_L_NPC_SOCIAL_SCENE_ANCHOR = "dl_social_scene_anchor";

const string DL_SOCIAL_SCENE_DEFAULT = "social_default";
const int DL_SOCIAL_SCENE_SOLO_WAIT_MINUTES = 3;

int DL_GetSocialSceneStepCount(string sSceneId)
{
    if (sSceneId == DL_SOCIAL_SCENE_DEFAULT) return 5;
    return 5;
}

int DL_GetSocialSceneStepWaitMinutes(string sSceneId, int nStep)
{
    if (sSceneId == DL_SOCIAL_SCENE_DEFAULT)
    {
        if (nStep == 2) return 2;
        if (nStep == 4) return 2;
        return 1;
    }

    return 1;
}

string DL_GetSocialSceneStepAnim(string sSceneId, int nStep, string sRole)
{
    if (sSceneId != DL_SOCIAL_SCENE_DEFAULT) sSceneId = DL_SOCIAL_SCENE_DEFAULT;

    if (sRole == "b")
    {
        if (nStep == 0) return "listen";
        if (nStep == 1) return "nodyes";
        if (nStep == 2) return "chuckle";
        if (nStep == 3) return "talknormal02";
        if (nStep == 4) return "sigh";
    }

    if (nStep == 0) return "talknormal";
    if (nStep == 1) return "pause";
    if (nStep == 2) return "talklaugh";
    if (nStep == 3) return "listen";
    if (nStep == 4) return "shrug";

    return "pause";
}

string DL_GetSocialSceneSoloAnim(int nStep)
{
    if (nStep == 0) return "bored";
    if (nStep == 1) return "sigh";
    return "shrug";
}

void DL_ClearSocialSceneState(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;

    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_STEP);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ROLE);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR);
}

int DL_SocialSceneIsRealAnim(string sAnim)
{
    if (sAnim == "") return FALSE;
    if (sAnim == "pause") return FALSE;
    return TRUE;
}

void DL_TickSocialScene(object oNpc, object oAnchor, object oPartner, int bPartnerOnAnchor)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor)) return;

    string sAnchorTag = GetTag(oAnchor);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "on_social_anchor") return;
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != sAnchorTag) return;

    if (GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR) != sAnchorTag)
    {
        DL_ClearSocialSceneState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR, sAnchorTag);
    }

    string sSceneId = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID);
    if (sSceneId == "")
    {
        sSceneId = DL_SOCIAL_SCENE_DEFAULT;
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID, sSceneId);
    }

    string sRole = "a";
    if (GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) == "b") sRole = "b";
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ROLE, sRole);

    int nNow = DL_GetAbsoluteMinute();
    if (nNow < GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE)) return;

    int nStep = GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_STEP);
    int nStepCount = DL_GetSocialSceneStepCount(sSceneId);
    if (nStepCount <= 0) nStepCount = 1;
    if (nStep < 0 || nStep >= nStepCount) nStep = 0;

    int bSolo = !GetIsObjectValid(oPartner) || !bPartnerOnAnchor;
    string sLastAnim = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM);
    string sAnim = "";
    int nWait = 1;
    int nNextStep = 0;

    if (bSolo)
    {
        int nSoloStep = nStep % 3;
        sAnim = DL_GetSocialSceneSoloAnim(nSoloStep);
        if (sAnim == sLastAnim)
        {
            nSoloStep = (nSoloStep + 1) % 3;
            sAnim = DL_GetSocialSceneSoloAnim(nSoloStep);
        }
        nWait = DL_SOCIAL_SCENE_SOLO_WAIT_MINUTES;
        if (nSoloStep == 0) nWait = 2;
        nNextStep = (nSoloStep + 1) % nStepCount;
    }
    else
    {
        sAnim = DL_GetSocialSceneStepAnim(sSceneId, nStep, sRole);
        nWait = DL_GetSocialSceneStepWaitMinutes(sSceneId, nStep);
        nNextStep = (nStep + 1) % nStepCount;

        if (sAnim == sLastAnim && nStepCount > 1)
        {
            int nTry = 1;
            while (nTry < nStepCount)
            {
                int nCandidateStep = (nStep + nTry) % nStepCount;
                string sCandidateAnim = DL_GetSocialSceneStepAnim(sSceneId, nCandidateStep, sRole);
                if (sCandidateAnim != sLastAnim)
                {
                    sAnim = sCandidateAnim;
                    nWait = DL_GetSocialSceneStepWaitMinutes(sSceneId, nCandidateStep);
                    nNextStep = (nCandidateStep + 1) % nStepCount;
                    break;
                }
                nTry = nTry + 1;
            }
        }
    }

    if (nWait < 1) nWait = 1;

    if (DL_SocialSceneIsRealAnim(sAnim))
    {
        PlayCustomAnimation(oNpc, sAnim, FALSE);
    }

    SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM, sAnim);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_STEP, nNextStep);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE, nNow + nWait);
}
