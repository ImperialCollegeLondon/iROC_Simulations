############################################################
# 01_design.R
# Prespecified CRM design parameters
############################################################

design <- list(
  doses = c("Dose 1", "Dose 2"),
  skeleton = c(0.10, 0.30),
  target = 0.20,
  cohort_size = 3,
  sample_sizes = c(12, 15, 18),
  start_dose = 1L,
  nsim = 10000L,
  restrict = TRUE,
  stop_threshold = 0.25,
  stop_probability = 0.90,
  conf_level = 0.90,
  seed = 20260803L
)

stopifnot(
  length(design$doses) == length(design$skeleton),
  all(design$skeleton > 0 & design$skeleton < 1),
  design$target > 0 && design$target < 1,
  design$cohort_size >= 1,
  all(design$sample_sizes >= design$cohort_size)
)
