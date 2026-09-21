default_spec <- function() {
  list(
    true_control_mean = 3.875,
    sigma_central = 0.285,
    sdlog_sigma = 0.15,
    nu0 = 4,
    success_threshold = 0.975,
    existing = list(
      control = list(n = 6, mean = 3.90, sd = 1.50),
      treatment = list(n = 6, mean = 3.45, sd = 1.50),
      weight = 1.00
    ),
    initial = list(
      control = list(n = 6, mean = 3.90, sd = 1.50),
      treatment = list(n = 9, mean = 3.45, sd = 1.50),
      weight = 1.00
    )
  )
}

combine_prior_sources <- function(spec = default_spec()) {
  e <- spec$existing; i <- spec$initial
  ec <- e$control$n * e$weight / e$control$sd^2
  et <- e$treatment$n * e$weight / e$treatment$sd^2
  ic <- i$control$n * i$weight / i$control$sd^2
  it <- i$treatment$n * i$weight / i$treatment$sd^2

  cp <- ec + ic; tp <- et + it
  list(
    control_mean = (e$control$mean * ec + i$control$mean * ic) / cp,
    control_precision = cp,
    treatment_mean = (e$treatment$mean * et + i$treatment$mean * it) / tp,
    treatment_precision = tp
  )
}
