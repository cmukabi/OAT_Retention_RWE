# ============================================================
# Project: OAT Retention RWE
# Script: 01_generate_data.R
# Purpose: Generate a synthetic methadone cohort
# ============================================================

set.seed(20261013)

n <- 500

# Generate baseline characteristics
oat_data <- data.frame(
  patient_id = 1:n,
  age = pmax(18, pmin(75, round(rnorm(n, 38, 10)))),
  
  housing_stable = sample(
    c("Yes", "No"), n, replace = TRUE,
    prob = c(0.65, 0.35)
  ),
  
  mental_health_condition = sample(
    c("Yes", "No"), n, replace = TRUE,
    prob = c(0.40, 0.60)
  ),
  
  prior_oat = sample(
    c("Yes", "No"), n, replace = TRUE,
    prob = c(0.45, 0.55)
  )
)

# All patients initiate methadone with DOT
oat_data$treatment <- "Methadone"
oat_data$initial_dosing <- "DOT"

# Simulate whether a patient has a missed-dose episode
oat_data$missed_dose_episode <- rbinom(n, 1, 0.35) == 1

# Illustrative maximum consecutive missed doses
oat_data$max_consecutive_missed <- ifelse(
  oat_data$missed_dose_episode,
  sample(1:7, n, replace = TRUE),
  0
)

# Record event categories using the supplied study rules
oat_data$intervention_flag <-
  oat_data$max_consecutive_missed >= 3

oat_data$reinduction_assessment_flag <-
  oat_data$max_consecutive_missed >= 5

# Simulate six-month retention for demonstration.
# These probabilities are illustrative, not clinical estimates.
retention_probability <- plogis(
  1.2 +
    0.35 * (oat_data$housing_stable == "Yes") -
    0.30 * (oat_data$mental_health_condition == "Yes") -
    0.25 * (oat_data$prior_oat == "Yes") -
    0.20 * oat_data$missed_dose_episode
)

oat_data$retained_180d <- rbinom(
  n, size = 1, prob = retention_probability
) == 1

# Inspect cohort
head(oat_data)
nrow(oat_data)

# Summarise the synthetic cohort
table(oat_data$retained_180d)
table(oat_data$intervention_flag)
table(oat_data$reinduction_assessment_flag)

# Save data
write.csv(
  oat_data,
  "data/synthetic_oat_cohort.csv",
  row.names = FALSE
)

nrow(oat_data)
table(oat_data$retained_180d)
table(oat_data$intervention_flag)
table(oat_data$reinduction_assessment_flag)

# check unique IDs
sum(duplicated(oat_data$patient_id))


# check missing values by variable

colSums(is.na((oat_data)))


# Check age range 

range(oat_data$age)



#Check treatment and initial dosing 
table(oat_data$treatment)
table(oat_data$initial_dosing)



# Check intervention threshold: 3 or more missed doses
sum(
  oat_data$intervention_flag !=
    (oat_data$max_consecutive_missed >= 3)
)

# Check re-induction assessment threshold: 5 or more missed doses
sum(
  oat_data$reinduction_assessment_flag !=
    (oat_data$max_consecutive_missed >= 5)
)

# Retention by missed-dose episode
retention_by_missed_dose <- aggregate(
  retained_180d ~ missed_dose_episode,
  data = oat_data,
  FUN = mean
)

retention_by_missed_dose


table(oat_data$missed_dose_episode)
#Retention counts by missed-dose history
table(
  oat_data$missed_dose_episode,
  oat_data$retained_180d
  
)

# Missed-dose episode by 180-day retention
retention_table <- with(
  oat_data,
  table(missed_dose_episode, retained_180d)
)

retention_table

# Row percentages
round(
  prop.table(retention_table, margin = 1) * 100,
  1
)
#===============================================================================
