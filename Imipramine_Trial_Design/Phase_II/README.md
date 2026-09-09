# Phase II – Imipramine Study Design Simulations

This directory is reserved for the Phase II statistical design and simulation work.

It is intentionally separate from the Phase I CRM analysis so that the assumptions, methods, simulations and outputs for each phase can be documented and reproduced independently.

## Suggested structure

```text
Phase_II/
├── README.md
├── Run_PhaseII_Design.R
├── R/
│   ├── 00_setup.R
│   ├── 01_design.R
│   ├── 02_scenarios.R
│   ├── 03_simulation_functions.R
│   ├── 04_run_simulations.R
│   ├── 05_operating_characteristics.R
│   └── 06_tables_figures.R
├── output/
├── tables/
├── figures/
└── reports/
```

## Reproducing Phase II

Once the Phase II scripts are added, the intended entry point is:

```r
source("Run_PhaseII_Design.R")
```

## To be documented

When the Phase II design is finalised, this README should describe:

- study objective and estimand;
- primary outcome;
- treatment groups or design arms;
- null and alternative assumptions;
- sample-size criteria;
- type I error and power, where applicable;
- interim or stopping rules;
- simulation scenarios;
- operating characteristics;
- software and package versions;
- instructions for reproducing all tables and figures.
