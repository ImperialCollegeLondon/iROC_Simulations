############################################################
# 08_precision_analysis.R
# Accuracy and precision of estimated toxicity at selected dose
############################################################

if (!exists("trial_results")) {
  trial_results <- readRDS(
    file.path(PROJECT_ROOT, "output", "trial_results.rds")
  )
}

precision_characteristics <- trial_results %>%
  mutate(
    Within_5pct_target =
      Selected_est_tox > (design$target - 0.05) &
      Selected_est_tox < (design$target + 0.05)
  ) %>%
  group_by(Scenario, N) %>%
  summarise(
    Mean_estimated_toxicity = mean(Selected_est_tox),
    SD_estimated_toxicity = sd(Selected_est_tox),
    Probability_within_5_percent = mean(Within_5pct_target),
    .groups = "drop"
  )

interval_characteristics <- trial_results %>%
  group_by(Scenario, N) %>%
  summarise(
    Mean_interval_width = mean(Selected_interval_width),
    Median_interval_width = median(Selected_interval_width),
    SD_interval_width = sd(Selected_interval_width),
    Lower_quartile = quantile(Selected_interval_width, 0.25),
    Upper_quartile = quantile(Selected_interval_width, 0.75),
    .groups = "drop"
  )

readr::write_csv(
  precision_characteristics,
  file.path(PROJECT_ROOT, "output", "precision_characteristics.csv")
)

readr::write_csv(
  interval_characteristics,
  file.path(PROJECT_ROOT, "output", "interval_characteristics.csv")
)
