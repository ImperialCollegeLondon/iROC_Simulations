############################################################
# 03_stopping_rule.R
# Bayesian excessive-toxicity stopping rule
#
# Stop if:
#   P(p1 > 0.25 | accumulated data) > 0.90
#
# This implementation matches the empiric model parameterisation
# in dfcrm 0.2.2.1:
#   p_j(beta) = prior_j ^ exp(beta)
############################################################

prob_dose1_exceeds <- function(fit, threshold = 0.25) {

  if (fit$model != "empiric" || fit$method != "bayes") {
    stop("Stopping-rule function currently supports Bayesian empiric CRM only.")
  }

  prior <- fit$prior
  tox <- fit$tox
  level <- fit$level

  if (prior[1] >= 1 || threshold <= 0 || threshold >= 1) {
    stop("Invalid prior or threshold.")
  }

  # Solve prior[1]^exp(beta) > threshold.
  # For 0 < prior[1] < 1 this corresponds to beta < beta_cutoff.
  beta_cutoff <- log(log(threshold) / log(prior[1]))

  x <- prior[level]
  y <- tox
  w <- rep(1, length(y))
  scale <- sqrt(fit$prior.var)

  posterior_kernel <- function(beta) {
    dfcrm:::crmh(beta, x, y, w, scale)
  }

  numerator <- integrate(
    posterior_kernel,
    lower = -Inf,
    upper = beta_cutoff,
    abs.tol = 1e-10
  )$value

  denominator <- integrate(
    posterior_kernel,
    lower = -Inf,
    upper = Inf,
    abs.tol = 1e-10
  )$value

  numerator / denominator
}

check_stopping <- function(
    fit,
    threshold = 0.25,
    probability = 0.90) {

  posterior_probability <- prob_dose1_exceeds(
    fit = fit,
    threshold = threshold
  )

  list(
    probability = posterior_probability,
    stop = posterior_probability > probability
  )
}

# Backward-compatible alias used in earlier development scripts
check.stopping <- check_stopping
