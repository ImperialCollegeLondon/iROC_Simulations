############################################################
# 04_simulate_trial.R
# Simulate one complete CRM trial
############################################################

simulate_crm <- function(
    true_tox,
    N,
    prior,
    target,
    cohort_size = 3,
    start_dose = 1,
    restrict = TRUE,
    stop_threshold = 0.25,
    stop_probability = 0.90,
    conf_level = 0.90) {

  if (length(true_tox) != length(prior)) {
    stop("true_tox and prior must have the same number of dose levels.")
  }

  dose_history <- integer(0)
  tox_history <- integer(0)
  current_dose <- as.integer(start_dose)
  stopped <- FALSE
  stop_posterior <- NA_real_

  fit <- NULL

  while (length(dose_history) < N) {

    n_cohort <- min(cohort_size, N - length(dose_history))

    outcomes <- rbinom(
      n = n_cohort,
      size = 1,
      prob = true_tox[current_dose]
    )

    dose_history <- c(
      dose_history,
      rep(current_dose, n_cohort)
    )

    tox_history <- c(tox_history, outcomes)

    fit <- dfcrm::crm(
      prior = prior,
      target = target,
      tox = tox_history,
      level = dose_history,
      conf.level = conf_level,
      method = "bayes",
      model = "empiric",
      var.est = TRUE
    )

    stop_check <- check_stopping(
      fit = fit,
      threshold = stop_threshold,
      probability = stop_probability
    )

    stop_posterior <- stop_check$probability

    if (isTRUE(stop_check$stop)) {
      stopped <- TRUE
      break
    }

    # dfcrm's recommended MTD is the dose whose fitted toxicity is
    # closest to the target, with sensible boundary behaviour.
    next_dose <- as.integer(fit$mtd)

    # Restrict movement to at most one dose level per cohort.
    # With only two dose levels this does not materially constrain movement.
    if (restrict) {
      next_dose <- max(
        current_dose - 1L,
        min(current_dose + 1L, next_dose)
      )
    }

    next_dose <- max(1L, min(length(prior), next_dose))
    current_dose <- next_dose
  }

  if (is.null(fit)) {
    stop("CRM fit was not created.")
  }

  final_mtd <- as.integer(fit$mtd)

  allocation <- table(
    factor(
      dose_history,
      levels = seq_along(prior)
    )
  )

  list(
    selected.mtd = final_mtd,
    estimated.toxicity = fit$ptox,
    lower.toxicity = fit$ptoxL,
    upper.toxicity = fit$ptoxU,
    doses = dose_history,
    toxicity = tox_history,
    allocation = allocation,
    DLTs = sum(tox_history),
    patients = length(tox_history),
    stopped = stopped,
    stop.posterior = stop_posterior
  )
}

# Backward-compatible alias
simulate.crm <- simulate_crm
