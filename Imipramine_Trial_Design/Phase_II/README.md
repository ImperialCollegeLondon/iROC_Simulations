# Bayesian Phase 2 simulation

Reproducible R code for exploring operating characteristics of a two-arm Phase 2 design with a positive, right-skewed endpoint analysed on the log10 scale.

## Quick start in RStudio

1. Open `bayesPhase2Sim.Rproj` in RStudio.
2. In the **Console**, type:

```r
source("scripts/run_simulation.R")
```

and press Enter.

Alternatively, open `run.R` and click **Source**. No non-base R packages are required. The full run uses 20,000 simulations per scenario and may take some time because it evaluates many scenarios and two SD thresholds.

When it finishes, look in the `results/` folder for:

- `operating_characteristics.csv` — sample-size x treatment-effect grid.
- `sd_sensitivity.csv` — sensitivity to uncertainty in the true SD.
- `n40_sd_thresholds.csv` — approximate highest central SD retaining 90% and 80% probability of success for N=40.

From a terminal at the repository root, the equivalent command is:

```bash
Rscript scripts/run_simulation.R
```

## Current design assumptions

The contemporary control mean is 3.875 on the log10 scale. A 50% treatment reduction corresponds to `log10(0.5) = -0.30103`, giving a true treatment mean of approximately 3.57397. The central contemporary SD is 0.285. Across possible future trials, the true SD can vary lognormally around this central value; the default log-SD variability is `sdlog = 0.15`.

Two sources of prior information are retained separately:

| Source | Arm | n | log10 mean | SD | Weight |
|---|---|---:|---:|---:|---:|
| Existing | Control | 6 | 3.90 | 1.50 | 1.00 |
| Existing | Treatment | 6 | 3.45 | 1.50 | 1.00 |
| Initial phase | Control | 6 | 3.90 | 1.50 | 1.00 |
| Initial phase | Treatment | 9 | 3.45 | 1.50 | 1.00 |

The success criterion is `P(mu_T - mu_C < 0 | data) > 0.975`.

## Sample-size and effect scenarios

The main analysis evaluates total sample sizes **N = 36, 38, 40, 42, 44, 46, 48, and 50**, with equal allocation between control and treatment. Each sample size is evaluated at true reductions of **0%, 25%, 30%, 40%, and 50%**.

The 0% scenario is particularly useful for examining the probability of declaring success when there is no true contemporary treatment effect.

## SD variability sensitivity

At a true 50% treatment reduction, the simulation is repeated using:

```r
sdlog = c(0.00, 0.10, 0.15, 0.20, 0.25)
```

These values describe uncertainty/variation in the true population SD across possible trials. They are **not** alternative values of the central SD itself. With `sdlog = 0`, the data-generating SD is fixed at the central value 0.285. Larger values produce progressively wider lognormal variation around 0.285.

## N=40 maximum-SD sensitivity

A second sensitivity analysis asks a different question:

> Assuming N=40, a true 50% treatment reduction, and `sdlog = 0.15`, how large could the **central (median) population SD** be while retaining approximately 90% or 80% probability of trial success?

The script uses a bisection search over the central SD and writes the results to `results/n40_sd_thresholds.csv`.

The reported SD thresholds are **Monte Carlo estimates**, not exact mathematical cut-offs. The search uses the same random-number seed at each candidate SD to reduce simulation noise, a tolerance of 0.001 SD units, and 20,000 simulations per candidate. The output also reports the Monte Carlo SE at the selected boundary. For a final design decision near a threshold, it is sensible to repeat this particular calculation with more simulations.

## Statistical note

This repository implements a fast Bayesian design approximation. Individual contemporary observations are simulated and the residual variance is updated using a weak inverse-chi-square-style prior centred on the specified central SD. The resulting variance estimate is then plugged into Normal posterior calculations for the arm means. Thus, uncertainty in the data-generating SD and sampling variability in the estimated SD are represented, but the final posterior probability does not fully integrate over the posterior distribution of sigma.

For a definitive trial analysis or regulatory/protocol implementation, the operating characteristics should also be validated against a full Bayesian model that jointly samples the arm effect and residual SD.

## Reproducibility and Monte Carlo precision

The default is `n_sim = 20000`, with seed `20260921`. Monte Carlo standard errors are included in the output. At a 90% probability of success, 20,000 simulations give an MCSE of approximately 0.0021, corresponding to about ±0.42 percentage points for an approximate 95% Monte Carlo interval.

## Customising the design

The easiest place to change the scientific assumptions is `R/spec.R`. The existing and initial-phase sources are deliberately kept separate so that actual initial-phase summaries or different borrowing weights can be substituted later without restructuring the simulation.
