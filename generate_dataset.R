# ==============================================================================
# Script: generate_dataset.R
# Project: Student Stress Pattern Analyzer
# Purpose: Generate realistic raw student dataset with intentional minor anomalies
#          for demonstrating data cleaning in R.
# ==============================================================================

set.seed(42) # For reproducibility

n_students <- 200

# Student IDs and Demographics
student_ids <- sprintf("STU%04d", 1001:(1000 + n_students))

first_names <- c("Aarav", "Aditi", "Ananya", "Arjun", "Deepak", "Diya", "Ishaan",
                 "Kavya", "Manish", "Neha", "Pooja", "Rahul", "Riya", "Rohan",
                 "Sneha", "Siddharth", "Tanvi", "Varun", "Vidya", "Yash",
                 "Alex", "Chris", "Jordan", "Morgan", "Sam", "Taylor")
last_names <- c("Sharma", "Verma", "Patel", "Iyer", "Rao", "Nair", "Reddy",
                "Gupta", "Mehta", "Singh", "Kumar", "Chopra", "Das", "Joshi",
                "Kapoor", "Bhat", "Deshmukh", "Menon", "Pillai", "Bose")

names <- paste(sample(first_names, n_students, replace = TRUE),
               sample(last_names, n_students, replace = TRUE))

genders_pool <- c("Male", "Female", "Female", "Male", "Non-Binary")
genders <- sample(genders_pool, n_students, replace = TRUE)

departments_pool <- c("Computer Science", "Electronics", "Mechanical", "Civil", "Biotechnology")
departments <- sample(departments_pool, n_students, replace = TRUE, prob = c(0.35, 0.25, 0.15, 0.10, 0.15))

academic_years_pool <- c("Year 1", "Year 2", "Year 3", "Year 4")
academic_years <- sample(academic_years_pool, n_students, replace = TRUE, prob = c(0.28, 0.27, 0.25, 0.20))

# Core Metrics with realistic inter-variable correlations
# Academic Workload (1 to 5 scale)
academic_workload <- sample(1:5, n_students, replace = TRUE, prob = c(0.10, 0.20, 0.35, 0.25, 0.10))

# Assignment Pressure (correlated with workload)
assignment_pressure <- pmax(1, pmin(5, round(academic_workload + rnorm(n_students, mean = 0, sd = 0.8))))

# Study Hours per Day (positively correlated with workload: 2 to 9 hours)
study_hours <- round(pmax(1.5, pmin(10.0, 2.0 + 1.1 * academic_workload + rnorm(n_students, 0, 1.2))), 1)

# Sleep Hours per Day (negatively correlated with workload and study hours: 3.5 to 9 hours)
sleep_hours <- round(pmax(3.5, pmin(9.5, 9.0 - 0.7 * academic_workload - 0.25 * study_hours + rnorm(n_students, 0, 0.7))), 1)

# Screen Time Hours (study hours + leisure, 3 to 11.5 hours)
screen_time <- round(pmax(2.0, pmin(12.0, 3.5 + 0.6 * study_hours + rnorm(n_students, 1.5, 1.3))), 1)

# Attendance Percentage (generally 60% to 98%, slightly lower with high workload)
attendance <- round(pmax(55.0, pmin(99.0, 92.0 - 2.5 * academic_workload + rnorm(n_students, 0, 6.0))), 1)

# Physical Activity Hours (0 to 3.5 hours per day, tends to be lower when workload is high)
physical_activity <- round(pmax(0.0, pmin(3.5, 2.2 - 0.3 * academic_workload + rnorm(n_students, 0, 0.6))), 1)

# Baseline Reported Stress Level (Initial self-reported category)
# Probability of High stress increases with workload and assignment pressure
latent_stress <- 0.35 * academic_workload + 0.35 * assignment_pressure + 0.2 * (8 - sleep_hours) - 0.2 * physical_activity + rnorm(n_students, 0, 0.5)
reported_stress <- ifelse(latent_stress < 2.0, "Low",
                   ifelse(latent_stress < 3.3, "Moderate", "High"))

# Assemble raw data frame
df_raw <- data.frame(
  Student_ID = student_ids,
  Name = names,
  Gender = genders,
  Department = departments,
  Academic_Year = academic_years,
  Study_Hours_Per_Day = study_hours,
  Sleep_Hours_Per_Day = sleep_hours,
  Screen_Time_Hours = screen_time,
  Academic_Workload = academic_workload,
  Attendance_Percentage = attendance,
  Assignment_Pressure = assignment_pressure,
  Physical_Activity_Hours = physical_activity,
  Reported_Stress_Level = reported_stress,
  stringsAsFactors = FALSE
)

# Introduce realistic minor anomalies for data cleaning demonstrations:
# 1. Trailing or leading whitespace in some Gender values
df_raw$Gender[c(12, 45, 88, 142)] <- paste0("  ", df_raw$Gender[c(12, 45, 88, 142)], " ")

# 2. A few missing values (NAs) in Physical_Activity_Hours and Screen_Time_Hours
df_raw$Physical_Activity_Hours[c(18, 56, 112, 175)] <- NA
df_raw$Screen_Time_Hours[c(34, 99, 150)] <- NA

# 3. An out-of-range attendance anomaly (e.g. 108.5% due to data entry typo)
df_raw$Attendance_Percentage[27] <- 108.5

# 4. A negative sleep hours entry typo (-1.0 instead of 7.0)
df_raw$Sleep_Hours_Per_Day[73] <- -1.0

# Write to CSV
output_path <- "data/student_stress_raw.csv"
write.csv(df_raw, file = output_path, row.names = FALSE)
cat(sprintf("Successfully generated raw dataset: %s with %d rows and %d columns.\n",
            output_path, nrow(df_raw), ncol(df_raw)))

