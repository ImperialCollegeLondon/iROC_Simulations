############################################################
# 02_scenarios.R
# True toxicity scenarios used for operating characteristics
############################################################

scenarios <- list(
  S1 = c(0.05, 0.15),
  S2 = c(0.10, 0.20),
  S3 = c(0.15, 0.25),
  S4 = c(0.20, 0.35),
  S5 = c(0.30, 0.45)
)

scenario_metadata <- data.frame(
  Scenario = names(scenarios),
  Dose1 = vapply(scenarios, `[`, numeric(1), 1),
  Dose2 = vapply(scenarios, `[`, numeric(1), 2),
  Reference_dose = c(2L, 2L, 2L, 1L, 1L),
  Description = c(
    "Both doses below target; Dose 2 closest",
    "Dose 2 at the 20% target",
    "Boundary scenario (15%, 25%); reference Dose 2",
    "Dose 1 at target; Dose 2 overly toxic",
    "Both doses above target; Dose 1 is safer/closest available"
  ),
  stringsAsFactors = FALSE
)

# Note: S3 is equidistant from 20% in exact arithmetic.
# A reference dose is explicitly prespecified to avoid floating-point tie behaviour.
# In S5, "Reference_dose" means the closest/safer available dose; it is NOT
# intended to imply that Dose 1 is clinically acceptable.

reference_dose <- function(scenario_name) {
  scenario_metadata$Reference_dose[
    match(scenario_name, scenario_metadata$Scenario)
  ]
}
