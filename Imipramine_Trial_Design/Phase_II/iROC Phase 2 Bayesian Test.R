# ============================================================
# QUICK BAYESIAN TEST: N = 40
#
# Prior/pilot information:
#   Control:   n=6, mean=3.89, SD=3.5
#   Treatment: n=6, mean=3.46, SD=3.5
#
# Contemporary trial:
#   N=40 = 20 per arm
#
# No packages required
# ============================================================

set.seed(12345)


# ============================================================
# 1. PRIOR DATA
# ============================================================

prior_control_n    <- 6
prior_control_mean <- 3.89
prior_control_sd   <- 3.5

prior_treat_n      <- 6
prior_treat_mean   <- 3.46
prior_treat_sd     <- 3.5


# ============================================================
# 2. CONTEMPORARY TRIAL ASSUMPTIONS
# ============================================================

n_per_arm <- 20
total_n   <- 40

# True contemporary control mean
true_control_mean <- 3.875

# Expected contemporary SD
sigma <- 0.285

# True treatment effect = 50% reduction
true_ratio <- 0.50

true_beta <- log10(true_ratio)

true_beta
# -0.30103

true_treatment_mean <-
  true_control_mean + true_beta

true_treatment_mean
# 3.574


# ============================================================
# 3. SUCCESS RULE
# ============================================================

# Success if posterior probability that
# treatment mean < control mean exceeds 97.5%

success_threshold <- 0.975


# ============================================================
# 4. SIMULATIONS
# ============================================================

n_sim <- 10000

success   <- numeric(n_sim)
post_prob <- numeric(n_sim)

posterior_control   <- numeric(n_sim)
posterior_treatment <- numeric(n_sim)


# ============================================================
# 5. PRIOR PRECISIONS
# ============================================================

# Variance of each prior mean

prior_control_var <-
  prior_control_sd^2 /
  prior_control_n

prior_treat_var <-
  prior_treat_sd^2 /
  prior_treat_n


# Prior precision

prior_control_precision <-
  1 / prior_control_var

prior_treat_precision <-
  1 / prior_treat_var


# ============================================================
# 6. RUN SIMULATION
# ============================================================

for (i in 1:n_sim) {
  
  
  # ----------------------------------------------------------
  # Simulate contemporary control arm
  # ----------------------------------------------------------
  
  control <- rnorm(
    n_per_arm,
    mean = true_control_mean,
    sd = sigma
  )
  
  
  # ----------------------------------------------------------
  # Simulate contemporary treatment arm
  # ----------------------------------------------------------
  
  treatment <- rnorm(
    n_per_arm,
    mean = true_treatment_mean,
    sd = sigma
  )
  
  
  # ----------------------------------------------------------
  # Contemporary likelihood precision
  # ----------------------------------------------------------
  
  current_precision <-
    n_per_arm / sigma^2
  
  
  # ----------------------------------------------------------
  # Posterior control mean
  # ----------------------------------------------------------
  
  control_post_precision <-
    prior_control_precision +
    current_precision
  
  
  control_post_var <-
    1 / control_post_precision
  
  
  control_post_mean <-
    (
      prior_control_mean *
        prior_control_precision +
        
        mean(control) *
        current_precision
    ) /
    control_post_precision
  
  
  # ----------------------------------------------------------
  # Posterior treatment mean
  # ----------------------------------------------------------
  
  treat_post_precision <-
    prior_treat_precision +
    current_precision
  
  
  treat_post_var <-
    1 / treat_post_precision
  
  
  treat_post_mean <-
    (
      prior_treat_mean *
        prior_treat_precision +
        
        mean(treatment) *
        current_precision
    ) /
    treat_post_precision
  
  
  # Store posterior means
  
  posterior_control[i] <-
    control_post_mean
  
  posterior_treatment[i] <-
    treat_post_mean
  
  
  # ----------------------------------------------------------
  # Posterior treatment effect
  #
  # beta = treatment - control
  # ----------------------------------------------------------
  
  beta_post_mean <-
    treat_post_mean -
    control_post_mean
  
  
  beta_post_var <-
    treat_post_var +
    control_post_var
  
  
  beta_post_sd <-
    sqrt(beta_post_var)
  
  
  # ----------------------------------------------------------
  # Probability treatment is better
  #
  # Lower outcome = better
  #
  # P(beta < 0)
  # ----------------------------------------------------------
  
  post_prob[i] <-
    pnorm(
      0,
      mean = beta_post_mean,
      sd = beta_post_sd
    )
  
  
  # ----------------------------------------------------------
  # Trial success
  # ----------------------------------------------------------
  
  success[i] <-
    post_prob[i] >
    success_threshold
  
}


# ============================================================
# 7. RESULTS
# ============================================================

estimated_power <-
  mean(success)

mean_post_prob <-
  mean(post_prob)


cat(
  "\n",
  "========================================\n",
  "BAYESIAN N = 44 TEST\n",
  "========================================\n",
  "\n",
  "Contemporary N             :", total_n, "\n",
  "Patients per arm           :", n_per_arm, "\n",
  "\n",
  "Prior control              : n=6, mean=3.89, SD=3.5\n",
  "Prior treatment            : n=6, mean=3.46, SD=3.5\n",
  "\n",
  "True contemporary control  :", true_control_mean, "\n",
  "True treatment reduction   : 50%\n",
  "Contemporary SD            :", sigma, "\n",
  "\n",
  "Probability of success     :",
  round(estimated_power, 3), "\n",
  "\n",
  "Mean posterior probability :",
  round(mean_post_prob, 3), "\n",
  "\n",
  "Mean posterior control     :",
  round(mean(posterior_control), 3), "\n",
  "\n",
  "Mean posterior treatment   :",
  round(mean(posterior_treatment), 3), "\n",
  "\n",
  "========================================\n"
)