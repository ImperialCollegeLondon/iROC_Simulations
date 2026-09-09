# Imipramine Clinical Trial Design Simulations

This repository contains reproducible statistical simulation work supporting the proposed imipramine clinical trial programme.

## Analyses

### Phase I – Bayesian CRM dose finding

The Phase I analysis evaluates a two-dose Bayesian Continual Reassessment Method (CRM) design, including dose selection, toxicity, early stopping, sample-size operating characteristics and posterior precision.

See [`Phase_I_CRM/README.md`](Phase_I_CRM/README.md).

### Phase II – study design simulations

The Phase II directory is reserved for the second-stage design and simulation work. It has its own independent README, scripts, outputs, tables and figures.

See [`Phase_II/README.md`](Phase_II/README.md).

## Repository structure

```text
Imipramine_Trial_Design/
├── README.md
├── .gitignore
├── Phase_I_CRM/
│   ├── README.md
│   ├── Run_CRM_Design.R
│   ├── R/
│   ├── output/
│   ├── tables/
│   ├── figures/
│   └── reports/
└── Phase_II/
    ├── README.md
    ├── Run_PhaseII_Design.R
    ├── R/
    ├── output/
    ├── tables/
    ├── figures/
    └── reports/
```

## Reproducibility

Each phase is intended to be self-contained. Open the relevant phase directory in RStudio and run its master script. This keeps the two analyses independent while allowing them to live in a single GitHub repository.
