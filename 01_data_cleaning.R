# ==============================================================================
# File: scripts/01_data_cleaning.R
# Project: Student Stress Pattern Analyzer
# Purpose: Data cleaning, anomaly remediation, missing value imputation,
#          and initial factor conversions.
# ==============================================================================

clean_student_data <- function(raw_path = "data/student_stress_raw.csv",
                               clean_path = "data/student_stress_clean.csv") {
  
  cat("\n========================================================\n")
  cat(" [STEP 1] DATA IMPORT & CLEANING PIPELINE\n")
  cat("========================================================\n")
  
  if (!file.exists(raw_path)) {
    stop(paste("Raw data file not found at:", raw_path))
  }
  
  # 1. Read raw CSV dataset
  cat(sprintf("-> Loading raw dataset from: '%s'...\n", raw_path))
  df <- read.csv(raw_path, stringsAsFactors = FALSE)
  
  cat(sprintf("   Initial Dimensions: %d Rows, %d Columns\n", nrow(df), ncol(df)))
  
  # 2. Inspect Missing Values
  na_counts <- colSums(is.na(df))
  cat("\n-> Missing Values Detected per Column:\n")
  print(na_counts[na_counts > 0])
  
  # 3. String Trimming and Categorical Standardization
  cat("\n-> Cleaning categorical text fields (stripping whitespace)...\n")
  char_cols <- sapply(df, is.character)
  for (col in names(df)[char_cols]) {
    df[[col]] <- trimws(df[[col]])
  }
  
  # 4. Outlier & Anomaly Detection and Remediation
  cat("-> Checking and correcting numerical range anomalies...\n")
  
  # (a) Attendance Percentage: Must be between 0% and 100%
  invalid_att <- which(df$Attendance_Percentage < 0 | df$Attendance_Percentage > 100)
  if (length(invalid_att) > 0) {
    cat(sprintf("   * Found %d invalid Attendance values. Capping to [0, 100] range.\n", length(invalid_att)))
    for (idx in invalid_att) {
      cat(sprintf("     - Row %d: Original = %.1f%% -> Corrected = %.1f%%\n",
                  idx, df$Attendance_Percentage[idx], pmin(100, pmax(0, df$Attendance_Percentage[idx]))))
      df$Attendance_Percentage[idx] <- pmin(100, pmax(0, df$Attendance_Percentage[idx]))
    }
  }
  
  # (b) Sleep Hours: Must be positive (> 0 and <= 24)
  invalid_sleep <- which(df$Sleep_Hours_Per_Day <= 0 | df$Sleep_Hours_Per_Day > 24)
  if (length(invalid_sleep) > 0) {
    med_sleep <- median(df$Sleep_Hours_Per_Day[df$Sleep_Hours_Per_Day > 0 & df$Sleep_Hours_Per_Day <= 24], na.rm = TRUE)
    cat(sprintf("   * Found %d invalid Sleep values. Imputing with median (%.1f hrs).\n", length(invalid_sleep), med_sleep))
    for (idx in invalid_sleep) {
      cat(sprintf("     - Row %d: Original = %.1f hrs -> Imputed = %.1f hrs\n",
                  idx, df$Sleep_Hours_Per_Day[idx], med_sleep))
      df$Sleep_Hours_Per_Day[idx] <- med_sleep
    }
  }
  
  # 5. Missing Value Imputation (Median Imputation for Continuous Metrics)
  cat("\n-> Performing missing value imputation...\n")
  num_cols_with_na <- names(df)[sapply(df, is.numeric) & (colSums(is.na(df)) > 0)]
  
  for (col in num_cols_with_na) {
    n_na <- sum(is.na(df[[col]]))
    col_median <- round(median(df[[col]], na.rm = TRUE), 1)
    df[[col]][is.na(df[[col]])] <- col_median
    cat(sprintf("   * Imputed %d missing values in '%s' with median value: %.1f\n", n_na, col, col_median))
  }
  
  # 6. Verify Complete Cases Post-Cleaning
  remaining_na <- sum(is.na(df))
  cat(sprintf("\n-> Data cleaning verification: Total remaining NAs = %d\n", remaining_na))
  
  # 7. Write Clean Dataset
  write.csv(df, file = clean_path, row.names = FALSE)
  cat(sprintf("-> Cleaned dataset saved to: '%s'\n", clean_path))
  
  return(df)
}

