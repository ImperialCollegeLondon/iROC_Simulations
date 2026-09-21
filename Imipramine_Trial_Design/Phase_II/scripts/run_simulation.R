# Run from RStudio Console with: source("scripts/run_simulation.R")
# Or from a terminal at repository root: Rscript scripts/run_simulation.R
source("R/spec.R")
source("R/simulate.R")

spec <- default_spec()
n_sim <- 20000
sample_sizes <- seq(36, 50, by = 2)  # 36, 38, 40, 42, 44, 46, 48, 50
true_ratios <- c(1.00, 0.75, 0.70, 0.60, 0.50)

# 1) Main sample-size x treatment-effect grid
results <- run_grid(
  sample_sizes = sample_sizes,
  true_ratios = true_ratios,
  spec = spec,
  n_sim = n_sim,
  sdlog_sigma = 0.15,
  seed = 20260921
)
write.csv(results, "results/operating_characteristics.csv", row.names = FALSE)
print(results, digits = 4, row.names = FALSE)

# 2) SD-variability sensitivity at the target 50% reduction
sd_values <- c(0.00, 0.10, 0.15, 0.20, 0.25)
sd_results <- do.call(rbind, lapply(sample_sizes, function(N) {
  do.call(rbind, lapply(sd_values, function(s) {
    run_scenario(N, 0.50, spec, n_sim = n_sim, sdlog_sigma = s)
  }))
}))
write.csv(sd_results, "results/sd_sensitivity.csv", row.names = FALSE)

# 3) N=40: approximate largest CENTRAL/MEDIAN SD compatible with
#    90% and 80% probability of trial success, assuming a true 50%
#    reduction and sdlog variability = 0.15.
#    This is a Monte Carlo threshold estimate, not an exact boundary.
sd_thresholds <- do.call(rbind, lapply(c(0.90, 0.80), function(target) {
  find_max_sigma_for_target(
    target_probability = target,
    total_n = 40,
    true_ratio = 0.50,
    spec = spec,
    n_sim = n_sim,
    sdlog_sigma = 0.15,
    lower = 0.15,
    upper = 0.70,
    tolerance = 0.001,
    seed = 20260921
  )
}))
write.csv(sd_thresholds, "results/n40_sd_thresholds.csv", row.names = FALSE)

cat("\nFinished. Results written to the results/ folder.\n")
print(sd_thresholds, digits = 4, row.names = FALSE)
