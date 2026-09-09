############################################################
# 09_tables_figures.R
# Grant-ready tables and figures
############################################################

# ---- Table 1: Main operating characteristics ----
table1 <- operating_characteristics %>%
  mutate(
    `True toxicity` = paste0(
      "(", sprintf("%.2f", Dose1), ", ", sprintf("%.2f", Dose2), ")"
    ),
    `Correct reference dose (%)` = round(100 * Correct_MTD, 1),
    `Select Dose 1 (%)` = round(100 * Select_Dose1, 1),
    `Select Dose 2 (%)` = round(100 * Select_Dose2, 1),
    `Mean DLT rate (%)` = round(100 * Mean_DLT_rate, 1),
    `Mean N` = round(Mean_N, 1),
    `Stop probability (%)` = round(100 * Stop_probability, 1)
  ) %>%
  select(
    Scenario,
    `True toxicity`,
    N,
    `Correct reference dose (%)`,
    `Select Dose 1 (%)`,
    `Select Dose 2 (%)`,
    `Mean DLT rate (%)`,
    `Mean N`,
    `Stop probability (%)`
  )

readr::write_csv(
  table1,
  file.path(PROJECT_ROOT, "tables", "Table1_CRM_operating_characteristics.csv")
)

# ---- Table 2: Dose allocation ----
table2 <- operating_characteristics %>%
  transmute(
    Scenario,
    N,
    `Mean patients Dose 1` = round(Mean_Dose1, 1),
    `Mean patients Dose 2` = round(Mean_Dose2, 1)
  )

readr::write_csv(
  table2,
  file.path(PROJECT_ROOT, "tables", "Table2_Dose_allocation.csv")
)

# ---- Table 3: Safety scenarios ----
table3 <- operating_characteristics %>%
  filter(Scenario %in% c("S4", "S5")) %>%
  transmute(
    Scenario,
    N,
    `Select Dose 1 (%)` = round(100 * Select_Dose1, 1),
    `Select Dose 2 (%)` = round(100 * Select_Dose2, 1),
    `Mean DLT rate (%)` = round(100 * Mean_DLT_rate, 1),
    `Stop probability (%)` = round(100 * Stop_probability, 1)
  )

readr::write_csv(
  table3,
  file.path(PROJECT_ROOT, "tables", "Table3_Safety_scenarios.csv")
)

# ---- Table 4: Precision ----
table4 <- precision_characteristics %>%
  left_join(interval_characteristics, by = c("Scenario", "N")) %>%
  mutate(
    `Mean estimated toxicity (%)` = round(100 * Mean_estimated_toxicity, 1),
    `Within +/-5 percentage points (%)` =
      round(100 * Probability_within_5_percent, 1),
    `Median 90% interval width` = round(Median_interval_width, 3),
    `Mean 90% interval width` = round(Mean_interval_width, 3)
  ) %>%
  select(
    Scenario,
    N,
    `Mean estimated toxicity (%)`,
    `Within +/-5 percentage points (%)`,
    `Median 90% interval width`,
    `Mean 90% interval width`
  )

readr::write_csv(
  table4,
  file.path(PROJECT_ROOT, "tables", "Table4_Toxicity_precision.csv")
)

# ---- Figure 1: Correct reference-dose selection ----
p1 <- operating_characteristics %>%
  ggplot(aes(x = N, y = Correct_MTD, group = Scenario, colour = Scenario)) +
  geom_line() +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 1)) +
  scale_x_continuous(breaks = design$sample_sizes) +
  labs(
    title = "Correct reference-dose selection",
    x = "Maximum sample size",
    y = "Probability"
  ) +
  theme_minimal()

ggsave(
  file.path(PROJECT_ROOT, "figures", "Figure1_Correct_selection.png"),
  p1,
  width = 8,
  height = 5,
  dpi = 300
)

# ---- Figure 2: Mean DLT rate ----
p2 <- operating_characteristics %>%
  ggplot(aes(x = N, y = Mean_DLT_rate, group = Scenario, colour = Scenario)) +
  geom_hline(yintercept = design$target, linetype = "dashed") +
  geom_line() +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_x_continuous(breaks = design$sample_sizes) +
  labs(
    title = "Mean observed DLT rate",
    subtitle = "Dashed line indicates the 20% target",
    x = "Maximum sample size",
    y = "Mean DLT rate"
  ) +
  theme_minimal()

ggsave(
  file.path(PROJECT_ROOT, "figures", "Figure2_Mean_DLT_rate.png"),
  p2,
  width = 8,
  height = 5,
  dpi = 300
)

# ---- Figure 3: Early stopping ----
p3 <- operating_characteristics %>%
  ggplot(aes(x = N, y = Stop_probability, group = Scenario, colour = Scenario)) +
  geom_line() +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  scale_x_continuous(breaks = design$sample_sizes) +
  labs(
    title = "Probability of early stopping for excessive toxicity",
    x = "Maximum sample size",
    y = "Stopping probability"
  ) +
  theme_minimal()

ggsave(
  file.path(PROJECT_ROOT, "figures", "Figure3_Early_stopping.png"),
  p3,
  width = 8,
  height = 5,
  dpi = 300
)

# ---- Figure 4: Posterior interval width ----
p4 <- interval_characteristics %>%
  ggplot(aes(x = N, y = Mean_interval_width, group = Scenario, colour = Scenario)) +
  geom_line() +
  geom_point(size = 2) +
  scale_x_continuous(breaks = design$sample_sizes) +
  labs(
    title = "Mean 90% interval width for selected-dose toxicity",
    x = "Maximum sample size",
    y = "Mean interval width"
  ) +
  theme_minimal()

ggsave(
  file.path(PROJECT_ROOT, "figures", "Figure4_Posterior_precision.png"),
  p4,
  width = 8,
  height = 5,
  dpi = 300
)

cat("Tables and figures generated.\n")
