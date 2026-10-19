
# ============================================================
# OAT Retention RWE Portfolio
# File: 02_analysis.R
# Purpose: Descriptive, adjusted and bootstrap analysis
# ============================================================

# 1. Project setup --------------------------------------------
# Run this script from the OAT_Retention_RWE RStudio project.

# Generate the synthetic dataset
source(
  file.path("scripts", "01_generate_data.R")
)

# Confirm that the expected dataset exists
stopifnot(exists("oat_data"))
stopifnot(nrow(oat_data) == 500)

# Required package
if (!requireNamespace("DescTools", quietly = TRUE)) {
  stop("Install DescTools first: install.packages('DescTools')")
}

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("Install ggplot2 first: install.packages('ggplot2')")
}

library(ggplot2)

# 2. Descriptive analysis -------------------------------------

retention_table <- with(
  oat_data,
  table(missed_dose_episode, retained_180d)
)

print(retention_table)

print(
  round(
    prop.table(retention_table, margin = 1) * 100,
    2
  )
)

#

# 3. Unadjusted retention difference -------------------------

# Use participants with non-missing exposure and outcome
unadjusted_data <- oat_data[
  complete.cases(
    oat_data[, c("missed_dose_episode", "retained_180d")]
  ),
]

# Count participants without a missed-dose episode
no_episode_data <- unadjusted_data[
  unadjusted_data$missed_dose_episode == FALSE,
]

# Count participants with a missed-dose episode
episode_data <- unadjusted_data[
  unadjusted_data$missed_dose_episode == TRUE,
]

# Calculate retention counts and denominators
retained_no_episode <- sum(no_episode_data$retained_180d)
n_no_episode <- nrow(no_episode_data)

retained_episode <- sum(episode_data$retained_180d)
n_episode <- nrow(episode_data)

# Calculate retention percentages
retention_no_episode <- 100 * retained_no_episode / n_no_episode
retention_episode <- 100 * retained_episode / n_episode

cat(
  "No missed-dose episode:",
  round(retention_no_episode, 2), "% (",
  retained_no_episode, "/", n_no_episode, ")\n"
)

cat(
  "Missed-dose episode:",
  round(retention_episode, 2), "% (",
  retained_episode, "/", n_episode, ")\n"
)

# Calculate the score-based confidence interval
ci_result <- DescTools::BinomDiffCI(
  x1 = retained_no_episode,
  n1 = n_no_episode,
  x2 = retained_episode,
  n2 = n_episode,
  method = "score",
  conf.level = 0.95
)

print(ci_result)

# Express estimates in percentage points
unadjusted_RD <- 100 * ci_result[1, "est"]
unadjusted_lower <- 100 * ci_result[1, "lwr.ci"]
unadjusted_upper <- 100 * ci_result[1, "upr.ci"]

cat(
  "Retention difference:",
  round(unadjusted_RD, 2),
  "percentage points\n"
)

cat(
  "95% CI:",
  round(unadjusted_lower, 2), "to",
  round(unadjusted_upper, 2),
  "percentage points\n"
)



# 4. Prepare analysis data ------------------------------------

analysis_data <- oat_data[
  ,
  c(
    "retained_180d",
    "missed_dose_episode",
    "age",
    "housing_stable",
    "mental_health_condition",
    "prior_oat"
  )
]

categorical_vars <- c(
  "housing_stable",
  "mental_health_condition",
  "prior_oat"
)

analysis_data[categorical_vars] <- lapply(
  analysis_data[categorical_vars],
  factor
)

analysis_data <- analysis_data[
  complete.cases(analysis_data),
]

cat("Analysis sample size:", nrow(analysis_data), "\n")

# 5. Adjusted logistic regression -----------------------------

adjusted_model <- glm(
  retained_180d ~ missed_dose_episode +
    age +
    housing_stable +
    mental_health_condition +
    prior_oat,
  data = analysis_data,
  family = binomial(link = "logit")
)

print(summary(adjusted_model))

or_ci <- exp(
  cbind(
    Estimate = coef(adjusted_model),
    confint(adjusted_model)
  )
)

print(round(or_ci, 3))

# 6. Standardised retention estimates -------------------------

data_no_episode <- analysis_data
data_episode <- analysis_data

data_no_episode$missed_dose_episode <- FALSE
data_episode$missed_dose_episode <- TRUE

pred_no_episode <- predict(
  adjusted_model,
  newdata = data_no_episode,
  type = "response"
)

pred_episode <- predict(
  adjusted_model,
  newdata = data_episode,
  type = "response"
)

adjusted_retention <- data.frame(
  scenario = c(
    "No missed-dose episode",
    "Missed-dose episode"
  ),
  retention_percent = 100 * c(
    mean(pred_no_episode),
    mean(pred_episode)
  )
)

print(adjusted_retention)

# Save standardised retention estimates for Quarto

write.csv(
  adjusted_retention,
  file = "oat_retention_adjusted_retention.csv",
  row.names = FALSE
)

cat("Standardised retention estimates saved.\n")

adjusted_RD <- 100 * (
  mean(pred_no_episode) -
    mean(pred_episode)
)

cat(
  "Adjusted retention difference:",
  round(adjusted_RD, 2),
  "percentage points\n"
)

# 7. Bootstrap confidence interval ----------------------------

set.seed(20261014)

B <- 2000
n <- nrow(analysis_data)

bootstrap_RD <- rep(NA_real_, B)

for (b in seq_len(B)) {
  
  boot_indices <- sample.int(
    n,
    size = n,
    replace = TRUE
  )
  
  boot_data <- analysis_data[boot_indices, ]
  
  boot_model <- tryCatch(
    glm(
      retained_180d ~ missed_dose_episode +
        age +
        housing_stable +
        mental_health_condition +
        prior_oat,
      data = boot_data,
      family = binomial(link = "logit")
    ),
    error = function(e) NULL
  )
  
  if (
    is.null(boot_model) ||
    !boot_model$converged ||
    any(!is.finite(coef(boot_model)))
  ) {
    next
  }
  
  boot_no <- boot_data
  boot_yes <- boot_data
  
  boot_no$missed_dose_episode <- FALSE
  boot_yes$missed_dose_episode <- TRUE
  
  p_no <- tryCatch(
    predict(boot_model, newdata = boot_no,
            type = "response"),
    error = function(e) NULL
  )
  
  p_yes <- tryCatch(
    predict(boot_model, newdata = boot_yes,
            type = "response"),
    error = function(e) NULL
  )
  
  if (is.null(p_no) || is.null(p_yes)) next
  
  if (
    any(!is.finite(p_no)) ||
    any(!is.finite(p_yes))
  ) {
    next
  }
  
  bootstrap_RD[b] <- 100 * (
    mean(p_no) - mean(p_yes)
  )
}

valid_RD <- bootstrap_RD[is.finite(bootstrap_RD)]

cat(
  "Successful bootstrap replicates:",
  length(valid_RD), "of", B, "\n"
)

if (length(valid_RD) < 0.95 * B) {
  warning(
    "Investigate bootstrap failures before reporting the CI."
  )
}

bootstrap_CI <- quantile(
  valid_RD,
  probs = c(0.025, 0.975),
  names = TRUE
)

print(bootstrap_CI)

# 8. Comparison figure ----------------------------------------


comparison <- data.frame(
  analysis = factor(
    c("Unadjusted", "Adjusted"),
    levels = c("Adjusted", "Unadjusted")
  ),
  estimate = c(unadjusted_RD, adjusted_RD),
  lower = c(unadjusted_lower, as.numeric(bootstrap_CI[1])),
  upper = c(unadjusted_upper, as.numeric(bootstrap_CI[2]))
)

comparison$label <- sprintf(
  "%.2f (%.2f to %.2f)",
  comparison$estimate,
  comparison$lower,
  comparison$upper
)

retention_plot <- ggplot(
  comparison,
  aes(x = estimate, y = analysis)
) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  geom_segment(
    aes(
      x = lower, xend = upper,
      y = analysis, yend = analysis
    )
  ) +
  geom_point(size = 3) +
  geom_text(
    aes(label = label),
    nudge_y = 0.20,
    size = 3.5
  ) +
  labs(
    title = "Difference in 180-day OAT retention",
    subtitle = paste(
      "No missed-dose episode minus",
      "missed-dose episode"
    ),
    x = "Retention difference (percentage points)",
    y = NULL,
    caption = paste(
      "Unadjusted: score-based CI.",
      "Adjusted: percentile bootstrap CI."
    )
  ) +
  theme_minimal(base_size = 12)

print(retention_plot)

ggsave(
  filename = "oat_retention_comparison.png",
  plot = retention_plot,
  width = 9,
  height = 5,
  dpi = 300
)


# 9. Save results and environment -----------------------------

write.csv(
  comparison,
  "oat_retention_results.csv",
  row.names = FALSE
)

writeLines(
  capture.output(sessionInfo()),
  "session_info.txt"
)

cat("\nAnalysis completed.\n")
cat("Project directory:", getwd(), "\n")




