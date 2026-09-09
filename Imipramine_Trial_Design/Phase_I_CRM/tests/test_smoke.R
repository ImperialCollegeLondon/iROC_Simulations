# Simple smoke test
source(file.path("R", "00_setup.R"))
source(file.path("R", "01_design.R"))
source(file.path("R", "02_scenarios.R"))
source(file.path("R", "03_stopping_rule.R"))
source(file.path("R", "04_simulate_trial.R"))
source(file.path("R", "05_validate.R"))

test_trial <- simulate_crm(
  true_tox = c(0.10, 0.20),
  N = 12,
  prior = design$skeleton,
  target = design$target,
  cohort_size = design$cohort_size,
  start_dose = design$start_dose,
  restrict = design$restrict,
  stop_threshold = design$stop_threshold,
  stop_probability = design$stop_probability,
  conf_level = design$conf_level
)

stopifnot(
  test_trial$selected.mtd %in% c(1, 2),
  test_trial$patients <= 12,
  sum(test_trial$allocation) == test_trial$patients
)

cat("Smoke test passed.\n")
