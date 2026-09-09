# CRM Phase I Sample Size Simulations – Imipramine Grant

This repository contains a reproducible simulation framework for a two-dose Bayesian Continual Reassessment Method (CRM) Phase I dose-finding design using the R package `dfcrm`.

## Primary design

- Dose levels: 2
- Prior CRM skeleton: `(0.10, 0.30)`
- Target DLT probability: `0.20`
- Cohort size: 3
- Starting dose: Dose 1
- Candidate maximum sample sizes: 12, 15, 18
- Bayesian empiric CRM
- Excessive-toxicity stopping rule:

\[
P(p_1 > 0.25 \mid \mathrm{data}) > 0.90
\]

where \(p_1\) is the DLT probability at Dose 1.

The project was developed and validated against `dfcrm` version **0.2.2.1**.

## How cohort decisions are made

At the end of each cohort, `dfcrm::crm()` is refitted using **all accumulated DLT data**. The empiric CRM produces a model-based estimated DLT probability for every dose level, including doses not yet administered.

The next cohort is assigned to the dose recommended by `dfcrm` as closest to the 20% toxicity target, subject to the dose-movement restriction. With only two dose levels, the one-level restriction does not materially constrain escalation/de-escalation.

The excessive-toxicity stopping rule is a separate safety mechanism. Recruitment stops if there is greater than 90% posterior probability that the DLT probability at Dose 1 exceeds 25%.

## True toxicity scenarios

| Scenario | Dose 1 | Dose 2 | Interpretation |
|---|---:|---:|---|
| S1 | 0.05 | 0.15 | Both below target; Dose 2 closest |
| S2 | 0.10 | 0.20 | Dose 2 at target |
| S3 | 0.15 | 0.25 | Boundary scenario |
| S4 | 0.20 | 0.35 | Dose 1 at target, Dose 2 too toxic |
| S5 | 0.30 | 0.45 | Both doses above target |

**Important:** S3 is exactly equidistant from the 20% target in exact arithmetic. A reference dose is explicitly prespecified in `02_scenarios.R` so floating-point behaviour cannot silently determine the label. In S5, the reference dose is the safer/closest available dose; this should not be interpreted as saying that Dose 1 is clinically acceptable.

## Repository structure

```text
CRM_PhaseI_Imipramine/
├── CRM_PhaseI_Imipramine.Rproj
├── Run_CRM_Design.R
├── README.md
├── .gitignore
├── .here
├── R/
│   ├── 00_setup.R
│   ├── 01_design.R
│   ├── 02_scenarios.R
│   ├── 03_stopping_rule.R
│   ├── 04_simulate_trial.R
│   ├── 05_validate.R
│   ├── 06_run_simulations.R
│   ├── 07_operating_characteristics.R
│   ├── 08_precision_analysis.R
│   └── 09_tables_figures.R
├── tests/
│   └── test_smoke.R
├── output/
├── tables/
├── figures/
└── reports/
```

## Reproduce the analysis

Open `CRM_PhaseI_Imipramine.Rproj` in RStudio and run:

```r
source("Run_CRM_Design.R")
```

The master script:

1. loads and checks packages,
2. defines the design and scenarios,
3. loads the exact Bayesian stopping rule,
4. validates the simulator,
5. runs all scenario/sample-size combinations,
6. saves trial-level simulation results,
7. calculates operating characteristics,
8. calculates toxicity-estimation precision,
9. writes grant-ready tables and figures.

With the default settings this runs:

- 5 toxicity scenarios
- 3 candidate sample sizes
- 10,000 simulations per combination

for a total of **150,000 simulated CRM trials**.

## Main outputs

`output/operating_characteristics.csv` includes:

- correct reference-dose selection probability
- probability of selecting Dose 1 and Dose 2
- mean number of DLTs
- mean DLT rate
- mean realised sample size
- mean allocation to each dose
- probability of early stopping

`output/precision_characteristics.csv` includes:

- mean selected-dose toxicity estimate
- SD of the selected-dose toxicity estimate
- probability that the selected-dose estimate lies within ±5 percentage points of the 20% target

`output/interval_characteristics.csv` includes:

- mean and median width of the 90% interval for selected-dose toxicity
- SD and interquartile range of interval width

## Reproducibility notes

Generated simulation outputs are excluded from Git by default because the trial-level `.rds` file can be large. The code, design assumptions, and fixed seeds are version controlled; running the master script regenerates the outputs.

The safety stopping calculation uses the internal `dfcrm` posterior kernel `dfcrm:::crmh` so that the stopping rule matches the empiric Bayesian CRM parameterisation used by `dfcrm 0.2.2.1`. Because this is an internal package function, validation should be repeated if `dfcrm` is upgraded.

## Funding interpretation

The sample size is justified through operating characteristics rather than a conventional hypothesis-testing power calculation. Candidate maximum sample sizes of 12, 15 and 18 are compared with respect to dose-selection performance, patient allocation, DLT burden, excessive-toxicity stopping and posterior precision.

The final sample-size statement should be based on the generated results rather than hard-coded into the repository.
