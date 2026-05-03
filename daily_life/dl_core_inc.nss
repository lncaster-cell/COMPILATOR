// Daily Life core event ingress facade.
// Maintains legacy include API while delegating to focused subsystems.

// dl_res_inc is intentionally first: it owns the Daily Life directive/local
// contract consumed by diagnostics, registry, worker, lifecycle, city/legal
// integrations, and blocked handling.
#include "dl_res_inc"
#include "dl_config_inc"
#include "dl_diag_inc"
#include "dl_registry_inc"
#include "dl_resync_inc"
#include "dl_worker_inc"
#include "dl_lifecycle_inc"
#include "dl_city_response_inc"
#include "dl_legal_inc"
#include "dl_cr_crime_inc"
