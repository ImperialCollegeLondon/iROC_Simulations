############################################################
# 06_run_simulations.R
# Run repeated CRM simulations efficiently
############################################################

trial_to_row <- function(trial, scenario, N, reference_dose) {

  selected <- trial$selected.mtd

  selected_est <- trial$estimated.toxicity[selected]
  selected_lower <- trial$lower.toxicity[selected]
  selected_upper <- trial$upper.toxicity[selected]

  data.frame(
    Scenario = scenario,
    N = N,
    Reference_dose = reference_dose,
    Selected_dose = selected,
    Correct_MTD = as.integer(selected == reference_dose),
    DLTs = trial$DLTs,
    DLT_rate = trial$DLTs / trial$patients,
    Patients = trial$patients,
    Dose1_n = as.numeric(trial$allocation[1]),
    Dose2_n = as.numeric(trial$allocation[2]),
    Stopped = as.integer(trial$stopped),
    Stop_posterior = trial$stop.posterior,
    Selected_est_tox = selected_est,
    Selected_lower_tox = selected_lower,
    Selected_upper_tox = selected_upper,
    Selected_interval_width = selected_upper - selected_lower,
    stringsAsFactors = FALSE
  )
}

run_setting <- function(
    true_tox,
    scenario,
    reference_dose,
    N,
    nsim,
    design,
    seed_offset = 0L) {

  set.seed(design$seed + seed_offset)

  rows <- vector("list", nsim)

  for (i in seq_len(nsim)) {
    trial <- simulate_crm(
      true_tox = true_tox,
      N = N,
      prior = design$skeleton,
      target = design$target,
      cohort_size = design$cohort_size,
      start_dose = design$start_dose,
      restrict = design$restrict,
      stop_threshold = design$stop_threshold,
      stop_probability = design$stop_probability,
      conf_level = design$conf_level
    )

    rows[[i]] <- trial_to_row(
      trial = trial,
      scenario = scenario,
      N = N,
      reference_dose = reference_dose
    )
  }

  dplyr::bind_rows(rows)
}

run_all_simulations <- function(scenarios, design) {

  output <- list()
  counter <- 0L

  for (scenario in names(scenarios)) {
    ref <- reference_dose(scenario)

    for (N in design$sample_sizes) {
      counter <- counter + 1L

      cat(
        "Running", scenario,
        "| N =", N,
        "| nsim =", design$nsim, "\n"
      )

      output[[paste0(scenario, "_N", N)]] <- run_setting(
        true_tox = scenarios[[scenario]],
        scenario = scenario,
        reference_dose = ref,
        N = N,
        nsim = design$nsim,
        design = design,
        seed_offset = counter * 100000L
      )
    }
  }

  dplyr::bind_rows(output)
}
