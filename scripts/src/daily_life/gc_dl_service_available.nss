#include "daily_life/dl_all_inc"

int StartingConditional()
{
    return DL_HasServiceMode(OBJECT_SELF, DL_SERVICE_AVAILABLE);
}
