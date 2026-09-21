run_scenario <- function(total_n, true_ratio, spec = default_spec(), n_sim = 20000,
                         sdlog_sigma = spec$sdlog_sigma, seed = NULL) {
  stopifnot(total_n %% 2 == 0, total_n >= 4, true_ratio > 0, n_sim > 0)
  if (!is.null(seed)) set.seed(seed)

  n_control <- total_n / 2
  n_treat <- total_n / 2
  true_beta <- log10(true_ratio)
  true_treatment_mean <- spec$true_control_mean + true_beta
  pri <- combine_prior_sources(spec)
  sigma0_sq <- spec$sigma_central^2

  success <- logical(n_sim)
  post_prob <- numeric(n_sim)
  sigma_true_store <- numeric(n_sim)
  sigma_est_store <- numeric(n_sim)

  for (j in seq_len(n_sim)) {
    sigma_true <- rlnorm(1, meanlog = log(spec$sigma_central), sdlog = sdlog_sigma)
    sigma_true_store[j] <- sigma_true

    control <- rnorm(n_control, spec$true_control_mean, sigma_true)
    treatment <- rnorm(n_treat, true_treatment_mean, sigma_true)

    sse <- (n_control - 1) * var(control) + (n_treat - 1) * var(treatment)
    df_data <- n_control + n_treat - 2
    nu_post <- spec$nu0 + df_data
    sigma_post_sq <- (spec$nu0 * sigma0_sq + sse) / nu_post
    sigma_est_store[j] <- sqrt(sigma_post_sq)

    c_data_prec <- n_control / sigma_post_sq
    t_data_prec <- n_treat / sigma_post_sq
    c_post_prec <- pri$control_precision + c_data_prec
    t_post_prec <- pri$treatment_precision + t_data_prec

    c_post_mean <- (pri$control_mean * pri$control_precision + mean(control) * c_data_prec) / c_post_prec
    t_post_mean <- (pri$treatment_mean * pri$treatment_precision + mean(treatment) * t_data_prec) / t_post_prec

    beta_mean <- t_post_mean - c_post_mean
    beta_sd <- sqrt(1 / c_post_prec + 1 / t_post_prec)
    post_prob[j] <- pnorm(0, mean = beta_mean, sd = beta_sd)
    success[j] <- post_prob[j] > spec$success_threshold
  }

  p <- mean(success)
  mcse <- sqrt(p * (1 - p) / n_sim)
  data.frame(
    total_n = total_n, n_per_arm = n_control, true_ratio = true_ratio,
    reduction_percent = 100 * (1 - true_ratio), true_beta = true_beta,
    sigma_central = spec$sigma_central, sdlog = sdlog_sigma,
    probability_success = p, MCSE = mcse,
    mean_posterior_probability = mean(post_prob),
    mean_true_SD = mean(sigma_true_store), median_true_SD = median(sigma_true_store),
    mean_estimated_SD = mean(sigma_est_store),
    q025_true_SD = unname(quantile(sigma_true_store, 0.025)),
    q975_true_SD = unname(quantile(sigma_true_store, 0.975))
  )
}

run_grid <- function(sample_sizes = seq(36, 50, by = 2),
                     true_ratios = c(1.00, 0.75, 0.70, 0.60, 0.50),
                     spec = default_spec(), n_sim = 20000,
                     sdlog_sigma = spec$sdlog_sigma, seed = 20260921) {
  set.seed(seed)
  out <- vector("list", length(sample_sizes) * length(true_ratios))
  k <- 1L
  for (N in sample_sizes) {
    for (r in true_ratios) {
      message("Running N=", N, ", ratio=", r)
      out[[k]] <- run_scenario(N, r, spec, n_sim, sdlog_sigma, seed = NULL)
      k <- k + 1L
    }
  }
  do.call(rbind, out)
}

# Approximate the largest central/median SD that retains a requested
# probability of trial success. Uses common random numbers (same seed at
# each candidate SD) to reduce Monte Carlo noise during the bisection.
find_max_sigma_for_target <- function(target_probability,
                                      total_n = 40,
                                      true_ratio = 0.50,
                                      spec = default_spec(),
                                      n_sim = 20000,
                                      sdlog_sigma = 0.15,
                                      lower = 0.15,
                                      upper = 0.70,
                                      tolerance = 0.001,
                                      seed = 20260921) {
  stopifnot(target_probability > 0, target_probability < 1, lower > 0, upper > lower)

  eval_sigma <- function(sigma) {
    s <- spec
    s$sigma_central <- sigma
    run_scenario(total_n, true_ratio, s, n_sim, sdlog_sigma, seed = seed)
  }

  low_res <- eval_sigma(lower)
  high_res <- eval_sigma(upper)
  if (low_res$probability_success < target_probability)
    stop("Lower SD bound does not achieve the requested target; reduce 'lower'.")
  if (high_res$probability_success >= target_probability)
    stop("Upper SD bound still achieves the requested target; increase 'upper'.")

  while ((upper - lower) > tolerance) {
    mid <- (lower + upper) / 2
    mid_res <- eval_sigma(mid)
    message("Target=", target_probability, ", candidate SD=", round(mid, 4),
            ", P(success)=", round(mid_res$probability_success, 4))
    if (mid_res$probability_success >= target_probability) lower <- mid else upper <- mid
  }

  final <- eval_sigma(lower)
  data.frame(
    target_probability = target_probability,
    total_n = total_n,
    n_per_arm = total_n / 2,
    true_ratio = true_ratio,
    reduction_percent = 100 * (1 - true_ratio),
    sdlog = sdlog_sigma,
    max_central_SD_approx = lower,
    next_upper_SD = upper,
    probability_success_at_max = final$probability_success,
    MCSE = final$MCSE,
    tolerance = tolerance
  )
}
