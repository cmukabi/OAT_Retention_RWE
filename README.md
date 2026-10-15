# OAT Retention RWE: Reproducible Analysis in R

**A synthetic real-world evidence (RWE) portfolio project demonstrating statistical analysis, adjusted retention estimates, bootstrap confidence intervals, and reproducible reporting in R.**

[View the GitHub repository](https://github.com/cmukabi/OAT_Retention_RWE)

## Project Overview

This project demonstrates how a reproducible analytical workflow can examine the association between missed-dose episodes and 180-day retention in a synthetic opioid agonist treatment (OAT) cohort.

The project uses simulated data for 500 participants to demonstrate cohort analysis, descriptive statistics, logistic regression, standardised predicted probabilities, bootstrap uncertainty estimation, data visualisation, and reporting with Quarto.

**Important:** All data and numerical findings are synthetic and generated for learning and portfolio development. They are not real patient outcomes, clinical evidence, or estimates of actual service performance.

## Research Question

Among participants in a synthetic OAT cohort, is a recorded missed-dose episode associated with retention at 180 days after adjustment for selected baseline characteristics?

## Objectives

- Describe 180-day retention by missed-dose episode status.
- Estimate the unadjusted difference in retention between groups and its 95% confidence interval.
- Fit an adjusted logistic regression model.
- Estimate standardised retention probabilities under two hypothetical exposure scenarios.
- Use participant-level bootstrap resampling to estimate uncertainty in the adjusted retention difference.
- Produce a reproducible analysis report and visualisation.

## Dataset

The cohort contains 500 synthetic participants and includes:

- Age
- Housing stability
- Mental health condition
- Prior OAT
- Missed-dose episode indicator
- Maximum consecutive missed doses
- Intervention and re-induction assessment indicators
- Retention at 180 days

The adjusted model includes age, housing stability, mental health condition, and prior OAT.

The dataset is illustrative. Its simulated relationships and outcome patterns should not be assumed to reflect actual clinical populations.

## Methods

### 1. Descriptive analysis

Calculate retention proportions for participants with and without a recorded missed-dose episode.

### 2. Unadjusted analysis

Estimate the difference in retention proportions, defined as:

**Retention without a missed-dose episode minus retention with a missed-dose episode.**

Report the difference in percentage points with a 95% confidence interval.

### 3. Adjusted logistic regression

Model 180-day retention using missed-dose episode status and the prespecified covariates.

### 4. Standardisation

Calculate predicted retention probabilities for each participant under two hypothetical scenarios: no missed-dose episode for everyone and a missed-dose episode for everyone. Average these probabilities and compare the resulting estimates.

These standardised estimates are model-based contrasts; they should not be interpreted as causal effects.

### 5. Bootstrap uncertainty

Use 2,000 participant-level bootstrap resamples to estimate a percentile-based 95% confidence interval for the adjusted retention difference.

## Illustrative Results

| Measure | Estimate |
|---|---:|
| Participants | 500 |
| Retention without a missed-dose episode | 78.66% |
| Retention with a missed-dose episode | 70.43% |
| Unadjusted difference | 8.23 percentage points |
| Unadjusted 95% confidence interval | 0.44 to 16.31 percentage points |
| Standardised retention without a missed-dose episode | 78.58% |
| Standardised retention with a missed-dose episode | 70.60% |
| Adjusted difference | 7.98 percentage points |
| Adjusted bootstrap 95% confidence interval | 0.07 to 16.00 percentage points |

### Interpretation

Within this simulated cohort, retention was lower among participants with a recorded missed-dose episode. The adjusted model produced a similar estimated difference after accounting for the selected covariates.

These findings demonstrate statistical methods and interpretation using simulated data. They do not establish causality or describe actual treatment outcomes.

## Project Files

| File | Purpose |
|---|---|
| `data/synthetic_oat_cohort.csv` | Synthetic cohort dataset |
| `scripts/01_generate_data.R` | Generates the synthetic cohort |
| `scripts/02_analysis.R` | Performs analysis and generates outputs |
| `oat_retention_results.csv` | Analysis estimates and confidence intervals |
| `oat_retention_adjusted_retention.csv` | Standardised retention estimates |
| `oat_retention_comparison.png` | Visual comparison of retention estimates |
| `oat_retention_report.qmd` | Quarto report source |
| `oat_retention_report.html` | Rendered analysis report |
| `session_info.txt` | R session and package information |

## Visualisation

The project includes a comparison figure showing the unadjusted and adjusted retention differences.

![OAT retention analysis comparison](oat_retention_comparison.png)

## Reproducibility

The project was developed using R, RStudio, and Quarto.

To reproduce the analysis:

1. Clone or download the repository.
2. Open `OAT_Retention_RWE.Rproj` in RStudio.
3. Install the required R packages if they are not already installed, including `DescTools` and `ggplot2`.
4. Run `scripts/02_analysis.R` from the project directory.
5. Render `oat_retention_report.qmd` using Quarto.

The analysis script sources the data-generation script and regenerates the synthetic cohort and analysis outputs.

## Limitations

- The dataset is entirely synthetic.
- The outcome is a binary retention indicator rather than a dated time-to-event outcome.
- The analysis does not establish the temporal ordering of treatment engagement events.
- The adjusted model includes only the specified covariates.
- Bootstrap intervals quantify uncertainty within this simulated exercise and do not account for every potential source of bias.
- Associations should not be interpreted as causal effects.
- The analysis is for methodological demonstration and should not guide clinical decisions.

## Skills Demonstrated

**R programming · Data quality checks · Descriptive statistics · Logistic regression · Predicted probabilities · Standardisation · Bootstrap confidence intervals · Data visualisation · Quarto reporting · Reproducible research · Statistical interpretation**

## Future Development

Potential extensions include more detailed cohort-quality checks, sensitivity analyses using alternative retention definitions, and a dated event-history dataset to demonstrate appropriate time-to-event methods.

Any extension should preserve clear outcome definitions, appropriate handling of censoring, and explicit separation of synthetic assumptions from real-world evidence.

---

*Portfolio project for demonstrating reproducible analytical methods using synthetic data.*