# ==============================================================================
# File: scripts/02_data_analysis.R
# Project: Student Stress Pattern Analyzer
# Purpose: Data-frame operations, factor manipulations, stress score calculation,
#          classification, frequency tables, and inferential statistical testing.
# ==============================================================================

# Helper function to compute descriptive statistics table
compute_descriptive_stats <- function(df, num_cols) {
  stats_list <- lapply(num_cols, function(col) {
    x <- df[[col]]
    c(
      Variable = col,
      Mean     = sprintf("%.2f", mean(x, na.rm = TRUE)),
      Median   = sprintf("%.2f", median(x, na.rm = TRUE)),
      SD       = sprintf("%.2f", sd(x, na.rm = TRUE)),
      Variance = sprintf("%.2f", var(x, na.rm = TRUE)),
      IQR      = sprintf("%.2f", IQR(x, na.rm = TRUE)),
      Min      = sprintf("%.2f", min(x, na.rm = TRUE)),
      Max      = sprintf("%.2f", max(x, na.rm = TRUE))
    )
  })
  stats_df <- as.data.frame(do.call(rbind, stats_list), stringsAsFactors = FALSE)
  return(stats_df)
}

perform_stress_analysis <- function(df) {
  
  cat("\n========================================================\n")
  cat(" [STEP 2] FACTOR CONVERSIONS & DATA-FRAME OPERATIONS\n")
  cat("========================================================\n")
  
  # ----------------------------------------------------------------------------
  # 1. Factor Operations
  # ----------------------------------------------------------------------------
  cat("-> Converting categorical variables to R Factors...\n")
  
  # Nominal Factors
  df$Gender     <- factor(df$Gender)
  df$Department <- factor(df$Department)
  
  # Ordinal Factors (Ordered Factors)
  df$Reported_Stress_Level <- factor(df$Reported_Stress_Level,
                                     levels = c("Low", "Moderate", "High"),
                                     ordered = TRUE)
  
  df$Academic_Year <- factor(df$Academic_Year,
                             levels = c("Year 1", "Year 2", "Year 3", "Year 4"),
                             ordered = TRUE)
  
  # Categorize Sleep Hours into discrete factor tiers
  df$Sleep_Tier <- factor(
    ifelse(df$Sleep_Hours_Per_Day < 6.0, "Short Sleep (<6h)",
    ifelse(df$Sleep_Hours_Per_Day <= 7.5, "Normal Sleep (6-7.5h)", "Optimal Sleep (>7.5h)")),
    levels = c("Short Sleep (<6h)", "Normal Sleep (6-7.5h)", "Optimal Sleep (>7.5h)"),
    ordered = TRUE
  )
  
  # Categorize Physical Activity
  df$Activity_Tier <- factor(
    ifelse(df$Physical_Activity_Hours < 1.0, "Sedentary (<1h)",
    ifelse(df$Physical_Activity_Hours <= 2.0, "Moderate (1-2h)", "Active (>2h)")),
    levels = c("Sedentary (<1h)", "Moderate (1-2h)", "Active (>2h)"),
    ordered = TRUE
  )
  
  cat("   * Gender levels:", paste(levels(df$Gender), collapse = ", "), "\n")
  cat("   * Department levels:", paste(levels(df$Department), collapse = ", "), "\n")
  cat("   * Academic_Year levels (ordered):", paste(levels(df$Academic_Year), collapse = " < "), "\n")
  cat("   * Sleep_Tier levels (ordered):", paste(levels(df$Sleep_Tier), collapse = " < "), "\n")
  
  # ----------------------------------------------------------------------------
  # 2. Stress-Score Calculation (Composite Model)
  # ----------------------------------------------------------------------------
  cat("\n========================================================\n")
  cat(" [STEP 3] STRESS-SCORE COMPUTATION & CLASSIFICATION\n")
  cat("========================================================\n")
  cat("-> Calculating normalized Multi-Criteria Composite Stress Score (0 - 100 scale)...\n")
  
  # Component normalization (0 to 100 scale)
  workload_norm   <- ((df$Academic_Workload - 1) / 4) * 100
  pressure_norm   <- ((df$Assignment_Pressure - 1) / 4) * 100
  screen_norm     <- pmin(100, (df$Screen_Time_Hours / 12) * 100)
  sleep_def_norm  <- pmax(0, (8.5 - df$Sleep_Hours_Per_Day) / 5.0) * 100
  att_risk_norm   <- pmax(0, (85.0 - df$Attendance_Percentage) / 30.0) * 100
  activity_buffer <- pmin(100, (df$Physical_Activity_Hours / 3.0) * 100)
  
  # Multi-criteria weighted aggregation:
  # Workload: 25%, Assignment Pressure: 25%, Sleep Deficit: 25%, Screen: 15%, Attendance Risk: 10%
  # Minus Physical Activity buffer: -15%
  raw_score <- (0.25 * workload_norm) +
               (0.25 * pressure_norm) +
               (0.25 * sleep_def_norm) +
               (0.15 * screen_norm) +
               (0.10 * att_risk_norm) -
               (0.15 * activity_buffer)
  
  # Scale and clamp strictly between 0 and 100
  df$Calculated_Stress_Score <- round(pmax(5.0, pmin(98.5, raw_score)), 1)
  
  # Classify into Stress Categories
  df$Stress_Category <- cut(
    df$Calculated_Stress_Score,
    breaks = c(-Inf, 42.0, 68.0, Inf),
    labels = c("Low", "Moderate", "High"),
    right = FALSE
  )
  df$Stress_Category <- factor(df$Stress_Category, levels = c("Low", "Moderate", "High"), ordered = TRUE)
  
  # ----------------------------------------------------------------------------
  # 3. Data-Frame Feature Engineering & Subsetting
  # ----------------------------------------------------------------------------
  cat("-> Engineering derived behavioral ratios in data frame...\n")
  df$Sleep_to_Screen_Ratio <- round(df$Sleep_Hours_Per_Day / pmax(df$Screen_Time_Hours, 0.5), 2)
  df$Study_to_Sleep_Ratio  <- round(df$Study_Hours_Per_Day / pmax(df$Sleep_Hours_Per_Day, 0.5), 2)
  
  # Subsetting examples
  high_risk_students <- df[df$Calculated_Stress_Score >= 75 & df$Sleep_Hours_Per_Day < 6.0, ]
  cat(sprintf("   * High-Risk Subgroup (Stress >= 75 & Sleep < 6h): %d students identified.\n",
              nrow(high_risk_students)))
  
  # Sorting & Ranking example
  sorted_by_stress <- df[order(-df$Calculated_Stress_Score), ]
  cat("\n-> Top 5 Students with Highest Calculated Stress Score:\n")
  print(head(sorted_by_stress[, c("Student_ID", "Name", "Department", "Academic_Year",
                                  "Academic_Workload", "Sleep_Hours_Per_Day",
                                  "Calculated_Stress_Score", "Stress_Category")], 5),
        row.names = FALSE)
  
  # ----------------------------------------------------------------------------
  # 4. Aggregations (Data-Frame Operations)
  # ----------------------------------------------------------------------------
  cat("\n-> Department-wise Aggregations:\n")
  dept_summary <- aggregate(
    cbind(Calculated_Stress_Score, Study_Hours_Per_Day, Sleep_Hours_Per_Day, Screen_Time_Hours) ~ Department,
    data = df,
    FUN = function(x) round(mean(x), 2)
  )
  names(dept_summary) <- c("Department", "Mean_Stress_Score", "Mean_Study_Hours", "Mean_Sleep_Hours", "Mean_Screen_Time")
  print(dept_summary, row.names = FALSE)
  
  cat("\n-> Academic Year Aggregations:\n")
  year_summary <- aggregate(
    cbind(Calculated_Stress_Score, Academic_Workload, Attendance_Percentage) ~ Academic_Year,
    data = df,
    FUN = function(x) round(mean(x), 2)
  )
  names(year_summary) <- c("Academic_Year", "Mean_Stress_Score", "Mean_Workload", "Mean_Attendance")
  print(year_summary, row.names = FALSE)
  
  # ----------------------------------------------------------------------------
  # 5. Frequency Tables & Cross-Tabulations
  # ----------------------------------------------------------------------------
  cat("\n========================================================\n")
  cat(" [STEP 4] FREQUENCY TABLES & CONTINGENCY ANALYSIS\n")
  cat("========================================================\n")
  
  # 1-way Frequency Table
  cat("-> 1-Way Frequency Table: Stress Categories:\n")
  stress_freq <- table(df$Stress_Category)
  stress_prop <- round(prop.table(stress_freq) * 100, 1)
  freq_table <- data.frame(
    Category = names(stress_freq),
    Count = as.numeric(stress_freq),
    Percentage = paste0(stress_prop, "%")
  )
  print(freq_table, row.names = FALSE)
  
  # 2-way Contingency Table: Department vs Stress Category
  cat("\n-> 2-Way Contingency Table: Department vs Stress Category (Counts):\n")
  dept_stress_tbl <- table(Department = df$Department, Stress_Category = df$Stress_Category)
  print(dept_stress_tbl)
  
  cat("\n-> Row Percentages (%% of Department falling into each Stress tier):\n")
  dept_prop_tbl <- round(prop.table(dept_stress_tbl, margin = 1) * 100, 1)
  print(dept_prop_tbl)
  
  # 2-way Contingency Table: Academic Year vs Stress Category
  cat("\n-> 2-Way Contingency Table: Academic Year vs Stress Category (Counts):\n")
  year_stress_tbl <- table(Academic_Year = df$Academic_Year, Stress_Category = df$Stress_Category)
  print(year_stress_tbl)
  
  # Chi-Square Test of Independence
  cat("\n-> Chi-Square Test of Independence (Academic Year vs Stress Category):\n")
  chisq_res <- suppressWarnings(chisq.test(year_stress_tbl))
  cat(sprintf("   * X-squared = %.3f, df = %d, p-value = %.4f\n",
              chisq_res$statistic, chisq_res$parameter, chisq_res$p.value))
  if (chisq_res$p.value < 0.05) {
    cat("   * Interpretation: Statistically significant association between Academic Year and Stress Category (p < 0.05).\n")
  } else {
    cat("   * Interpretation: No statistically significant association detected between Academic Year and Stress Category (p >= 0.05).\n")
  }
  
  # Model Concordance Table (Reported vs Calculated Stress)
  cat("\n-> Self-Reported vs Algorithmic Calculated Stress Category Concordance:\n")
  concordance_tbl <- table(Reported = df$Reported_Stress_Level, Calculated = df$Stress_Category)
  print(concordance_tbl)
  concordance_rate <- round(sum(diag(concordance_tbl)) / sum(concordance_tbl) * 100, 1)
  cat(sprintf("   * Overall Agreement Rate: %.1f%%\n", concordance_rate))
  
  # ----------------------------------------------------------------------------
  # 6. Statistical Analysis
  # ----------------------------------------------------------------------------
  cat("\n========================================================\n")
  cat(" [STEP 5] DESCRIPTIVE & INFERENTIAL STATISTICAL ANALYSIS\n")
  cat("========================================================\n")
  
  # Descriptive Statistics Table
  cat("-> Descriptive Statistics for Continuous Variables:\n")
  analysis_cols <- c("Study_Hours_Per_Day", "Sleep_Hours_Per_Day", "Screen_Time_Hours",
                     "Academic_Workload", "Attendance_Percentage", "Assignment_Pressure",
                     "Physical_Activity_Hours", "Calculated_Stress_Score")
  desc_stats <- compute_descriptive_stats(df, analysis_cols)
  print(desc_stats, row.names = FALSE)
  
  # Correlation Matrix
  cat("\n-> Pearson Correlation Matrix with Calculated Stress Score:\n")
  cor_matrix <- round(cor(df[, analysis_cols]), 3)
  stress_correlations <- data.frame(
    Variable = rownames(cor_matrix),
    Correlation_with_Stress = cor_matrix[, "Calculated_Stress_Score"]
  )
  stress_correlations <- stress_correlations[order(-abs(stress_correlations$Correlation_with_Stress)), ]
  print(stress_correlations, row.names = FALSE)
  
  # Two-Sample t-test: Low Sleep (<6 hrs) vs Adequate Sleep (>=6 hrs)
  cat("\n-> Independent Two-Sample t-test:\n")
  cat("   Hypothesis: Students with short sleep (<6h) experience higher stress scores than students with adequate sleep (>=6h).\n")
  sleep_group1 <- df$Calculated_Stress_Score[df$Sleep_Hours_Per_Day < 6.0]
  sleep_group2 <- df$Calculated_Stress_Score[df$Sleep_Hours_Per_Day >= 6.0]
  
  ttest_res <- t.test(sleep_group1, sleep_group2, alternative = "greater")
  cat(sprintf("   * Group 1 (Sleep < 6h, n=%d) Mean Stress: %.2f\n", length(sleep_group1), mean(sleep_group1)))
  cat(sprintf("   * Group 2 (Sleep >= 6h, n=%d) Mean Stress: %.2f\n", length(sleep_group2), mean(sleep_group2)))
  cat(sprintf("   * t-statistic: %.3f, df: %.2f, p-value: %.4e\n",
              ttest_res$statistic, ttest_res$parameter, ttest_res$p.value))
  if (ttest_res$p.value < 0.001) {
    cat("   * Conclusion: Statistically significant (p < 0.001). Sleep deprivation strongly elevates student stress.\n")
  }
  
  # One-Way ANOVA: Stress Score across Academic Years
  cat("\n-> One-Way Analysis of Variance (ANOVA): Stress across Academic Years:\n")
  anova_model <- aov(Calculated_Stress_Score ~ Academic_Year, data = df)
  anova_summary <- summary(anova_model)
  print(anova_summary)
  
  # Multiple Linear Regression Model
  cat("\n-> Multiple Linear Regression Model Summary (Predicting Stress Score):\n")
  lm_model <- lm(Calculated_Stress_Score ~ Sleep_Hours_Per_Day + Academic_Workload +
                   Screen_Time_Hours + Physical_Activity_Hours + Attendance_Percentage,
                 data = df)
  print(summary(lm_model)$coefficients)
  cat(sprintf("   * Multiple R-squared: %.3f, Adjusted R-squared: %.3f\n",
              summary(lm_model)$r.squared, summary(lm_model)$adj.r.squared))
  
  # Export Analyzed Dataset
  analyzed_path <- "data/student_stress_analyzed.csv"
  write.csv(df, file = analyzed_path, row.names = FALSE)
  cat(sprintf("\n-> Enriched dataset with calculated scores saved to: '%s'\n", analyzed_path))
  
  return(list(
    data = df,
    desc_stats = desc_stats,
    dept_summary = dept_summary,
    year_summary = year_summary,
    freq_table = freq_table,
    contingency_dept = dept_stress_tbl,
    contingency_year = year_stress_tbl,
    cor_matrix = cor_matrix,
    ttest = ttest_res,
    anova = anova_model,
    lm_model = lm_model
  ))
}
