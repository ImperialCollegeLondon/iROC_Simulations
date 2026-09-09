############################################################
# 07_operating_characteristics.R
# Main operating-characteristic summaries
############################################################

if (!exists("trial_results")) {
  trial_results <- readRDS(
    file.path(PROJECT_ROOT, "output", "trial_results.rds")
  )
}

operating_characteristics <- trial_results %>%
  group_by(Scenario, N, Reference_dose) %>%
  summarise(
    Correct_MTD = mean(Correct_MTD),
    Select_Dose1 = mean(Selected_dose == 1),
    Select_Dose2 = mean(Selected_dose == 2),
    Mean_DLT = mean(DLTs),
    Mean_DLT_rate = mean(DLT_rate),
    Mean_N = mean(Patients),
    Mean_Dose1 = mean(Dose1_n),
    Mean_Dose2 = mean(Dose2_n),
    Stop_probability = mean(Stopped),
    .groups = "drop"
  ) %>%
  left_join(
    scenario_metadata %>%
      select(Scenario, Dose1, Dose2, Description),
    by = "Scenario"
  ) %>%
  relocate(Scenario, Dose1, Dose2, Description, N, Reference_dose)

readr::write_csv(
  operating_characteristics,
  file.path(PROJECT_ROOT, "output", "operating_characteristics.csv")
)
