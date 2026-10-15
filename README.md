# OAT Retention: Real-World Evidence Analysis

## Project Overview

This project demonstrates a reproducible analytical workflow for examining the association between missed-dose episodes and 180-day retention among people receiving opioid agonist treatment (OAT).

The project uses a **synthetic cohort of 500 participants** to demonstrate descriptive analysis, logistic regression, standardised predicted retention, bootstrap confidence intervals, and visualisation.

**Important:** The dataset is synthetic. It contains no real patient outcomes and must not be interpreted as clinical evidence.

## Research Question

Is a recorded missed-dose episode associated with 180-day retention in a synthetic OAT cohort, after accounting for selected participant characteristics?

## Objectives

- Describe 180-day retention by missed-dose episode status.
- Estimate the unadjusted difference in retention between the two groups.
- Use logistic regression to adjust for selected covariates.
- Estimate standardised retention under two exposure scenarios.
- Calculate a bootstrap confidence interval for the adjusted retention difference.
- Produce a figure and report documenting the analysis.

## Dataset

The synthetic dataset contains 500 participants.

The primary exposure is a recorded missed-dose episode. The primary outcome is retention at 180 days.

The adjusted model includes:

- Age
- Housing stability
- Mental health condition
- Prior OAT

The data are illustrative and do not represent actual patients or treatment outcomes.

## Methods

### 1. Descriptive analysis

Retention proportions are calculated separately for participants with and without a recorded missed-dose episode.

### 2. Unadjusted analysis

The difference in retention proportions is expressed in percentage points, with a 95% confidence interval calculated using the score-based method.

The difference is defined as:

Retention without a missed-dose episode minus retention with a missed-dose episode.

### 3. Adjusted analysis

A logistic regression model estimates the association between missed-dose episode status and 180-day retention, adjusting for age, housing stability, mental health condition, and prior OAT.

### 4. Standardisation

Predicted retention probabilities are calculated for each participant under two scenarios: everyone assigned no missed-dose episode, and everyone assigned a missed-dose episode. The mean predicted probabilities are compared to estimate the adjusted retention difference.

### 5. Bootstrap uncertainty

A participant-level bootstrap with 2,000 resamples estimates the 95% percentile confidence interval for the adjusted retention difference.

## Illustrative Results

| Measure | Estimate |
|---|---:|
| Retention without a missed-dose episode | 78.66% |
| Retention with a missed-dose episode | 70.43% |
| Unadjusted retention difference | 8.23 percentage points |
| Unadjusted 95% confidence interval | 0.44 to 16.31 |
| Standardised retention without a missed-dose episode | 78.58% |
| Standardised retention with a missed-dose episode | 70.60% |
| Adjusted retention difference | 7.98 percentage points |
| Adjusted bootstrap 95% confidence interval | 0.07 to 16.00 |

These results illustrate the analytical workflow using synthetic data. They do not establish causality or provide evidence about actual OAT patients.

## Project Structure

- `scripts/01_generate_data.R` — generates the synthetic cohort.
- `scripts/02_analysis.R` — performs descriptive, adjusted, and bootstrap analyses and saves the results and figure.
- `data/synthetic_oat_cohort.csv` — generated synthetic dataset.
- `oat_retention_results.csv` — estimates and confidence intervals.
- `oat_retention_comparison.png` — comparison of unadjusted and adjusted retention differences.
- `oat_retention_report.qmd` — Quarto source document.
- `oat_retention_report.html` — rendered HTML report.
- `session_info.txt` — R session and package environment information.

## Reproducibility

The analysis was developed in R using RStudio and Quarto.

To reproduce the analysis:

1. Open the project directory in RStudio.
2. Ensure the required R packages are installed, including `DescTools` and `ggplot2`.
3. Run `scripts/02_analysis.R` from the project directory.
4. Render `oat_retention_report.qmd` in Quarto to generate the HTML report.

The analysis script generates the synthetic dataset by sourcing `scripts/01_generate_data.R`.

## Limitations

- The dataset is synthetic and does not represent real-world patient records.
- The results are illustrative and should not guide clinical decisions.
- The model adjusts only for the covariates specified in the analysis.
- Bootstrap intervals quantify uncertainty within this synthetic analytical exercise; they do not address all possible sources of bias.
- An association in this analysis should not be interpreted as a causal effect.

## Skills Demonstrated

R programming, data cleaning, descriptive statistics, logistic regression, predicted probabilities, standardisation, bootstrap confidence intervals, data visualisation, Quarto reporting, and reproducible research practices.