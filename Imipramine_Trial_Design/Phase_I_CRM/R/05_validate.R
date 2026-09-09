############################################################
# 05_validate.R
# Validation / smoke tests
############################################################

validate_crm_project <- function(design) {

  set.seed(design$seed)

  # 1. Basic target scenario
  trial <- simulate_crm(
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
    trial$patients <= 12,
    sum(trial$allocation) == trial$patients,
    trial$selected.mtd %in% seq_along(design$skeleton),
    trial$DLTs >= 0,
    trial$DLTs <= trial$patients,
    length(trial$estimated.toxicity) == length(design$skeleton),
    length(trial$lower.toxicity) == length(design$skeleton),
    length(trial$upper.toxicity) == length(design$skeleton)
  )

  # 2. Extreme toxicity should trigger the posterior stopping rule
  fit_extreme <- dfcrm::crm(
    prior = design$skeleton,
    target = design$target,
    tox = rep(1, 12),
    level = rep(1, 12)
  )

  stop_extreme <- check_stopping(
    fit_extreme,
    threshold = design$stop_threshold,
    probability = design$stop_probability
  )

  stopifnot(
    stop_extreme$probability > design$stop_probability,
    isTRUE(stop_extreme$stop)
  )

  cat("Validation checks passed.\n")
  invisible(TRUE)
}

validate_crm_project(design)
