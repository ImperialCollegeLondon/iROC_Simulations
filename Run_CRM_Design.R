############################################################
# Master runner: CRM Phase I sample-size simulations
############################################################

source(file.path("R", "00_setup.R"))
source(file.path("R", "01_design.R"))
source(file.path("R", "02_scenarios.R"))
source(file.path("R", "03_stopping_rule.R"))
source(file.path("R", "04_simulate_trial.R"))
source(file.path("R", "05_validate.R"))
source(file.path("R", "06_run_simulations.R"))

# Production simulations
trial_results <- run_all_simulations(
  scenarios = scenarios,
  design = design
)

saveRDS(
  trial_results,
  file.path(PROJECT_ROOT, "output", "trial_results.rds")
)

source(file.path("R", "07_operating_characteristics.R"))
source(file.path("R", "08_precision_analysis.R"))
source(file.path("R", "09_tables_figures.R"))

cat("\nCRM analysis complete.\n")
cat("Outputs written to:\n")
cat("  ", file.path(PROJECT_ROOT, "output"), "\n")
cat("  ", file.path(PROJECT_ROOT, "tables"), "\n")
cat("  ", file.path(PROJECT_ROOT, "figures"), "\n")
