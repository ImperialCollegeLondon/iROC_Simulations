############################################################
# 00_setup.R
# Project setup and package loading
############################################################

required_packages <- c(
  "dfcrm",
  "dplyr",
  "tidyr",
  "purrr",
  "ggplot2",
  "scales",
  "readr",
  "knitr",
  "flextable",
  "officer",
  "rmarkdown",
  "here"
)

installed <- rownames(installed.packages())
missing <- setdiff(required_packages, installed)

if (length(missing) > 0) {
  install.packages(missing, dependencies = TRUE)
}

suppressPackageStartupMessages({
  library(dfcrm)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(ggplot2)
  library(scales)
  library(readr)
  library(knitr)
  library(flextable)
  library(officer)
  library(rmarkdown)
  library(here)
})

PROJECT_ROOT <- here::here()

for (d in c("output", "tables", "figures", "reports")) {
  dir.create(file.path(PROJECT_ROOT, d), showWarnings = FALSE, recursive = TRUE)
}

# Reproducibility
set.seed(20260803)

# Record software environment
capture.output(
  sessionInfo(),
  file = file.path(PROJECT_ROOT, "output", "sessionInfo.txt")
)

dfcrm_version <- as.character(packageVersion("dfcrm"))
if (dfcrm_version != "0.2.2.1") {
  warning(
    "This project was validated against dfcrm 0.2.2.1. ",
    "Current version is ", dfcrm_version,
    ". Re-run validation checks before using results."
  )
}

cat("CRM simulation environment loaded.\n")
cat("Project root:", PROJECT_ROOT, "\n")
cat("dfcrm version:", dfcrm_version, "\n")
