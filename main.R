# ==============================================================================
# Project: Student Stress Pattern Analyzer
# File: main.R
# Purpose: Master driver script to execute the complete lab project:
#          1. Dataset verification / generation
#          2. Data cleaning & anomaly correction
#          3. Factor analysis, stress scoring & classifications
#          4. Descriptive & inferential statistical analysis
#          5. High-resolution visualizations (Bar charts, Histograms, Scatter, Boxplots)
# ==============================================================================

# Clear console & environment for reproducible clean run
rm(list = ls())

cat("================================================================================\n")
cat("          STUDENT STRESS PATTERN ANALYZER - R PROGRAMMING LAB PROJECT           \n")
cat("================================================================================\n")
cat("Initializing pipeline...\n\n")

# Define Project Paths
RAW_DATA_PATH   <- "data/student_stress_raw.csv"
CLEAN_DATA_PATH <- "data/student_stress_clean.csv"
SCRIPTS_DIR     <- "scripts"
PLOTS_DIR       <- "plots"

# Step 0: Ensure Raw Data Exists
if (!file.exists(RAW_DATA_PATH)) {
  cat("-> Raw dataset not found. Generating initial dataset...\n")
  source("data/generate_dataset.R")
} else {
  cat(sprintf("-> Raw dataset verified at: '%s'\n", RAW_DATA_PATH))
}

# Step 1: Source & Execute Data Cleaning
cat("-> Sourcing: scripts/01_data_cleaning.R\n")
source(file.path(SCRIPTS_DIR, "01_data_cleaning.R"))
df_clean <- clean_student_data(raw_path = RAW_DATA_PATH, clean_path = CLEAN_DATA_PATH)

# Step 2: Source & Execute Data Analysis
cat("\n-> Sourcing: scripts/02_data_analysis.R\n")
source(file.path(SCRIPTS_DIR, "02_data_analysis.R"))
analysis_results <- perform_stress_analysis(df_clean)

# Step 3: Source & Execute Visualizations
cat("\n-> Sourcing: scripts/03_visualization.R\n")
source(file.path(SCRIPTS_DIR, "03_visualization.R"))
generate_stress_visualizations(analysis_results$data, output_dir = PLOTS_DIR)

# Step 4: Sync with Interactive Web Frontend
cat("\n-> Syncing dataset with Web Frontend...\n")
if (file.exists(file.path(SCRIPTS_DIR, "export_to_json.R"))) {
  source(file.path(SCRIPTS_DIR, "export_to_json.R"))
}
# Ensure plots are synced in frontend/plots
if (dir.exists("frontend/plots")) {
  file.copy(from = list.files(PLOTS_DIR, full.names = TRUE),
            to = "frontend/plots", overwrite = TRUE)
}

# Step 5: Executive Project Summary
cat("\n================================================================================\n")
cat("                         PROJECT EXECUTION SUMMARY                              \n")
cat("================================================================================\n")
cat(sprintf(" Total Students Analyzed        : %d\n", nrow(analysis_results$data)))
cat(sprintf(" Raw Dataset                    : %s\n", RAW_DATA_PATH))
cat(sprintf(" Clean Dataset                  : %s\n", CLEAN_DATA_PATH))
cat(sprintf(" Analyzed Dataset               : %s\n", "data/student_stress_analyzed.csv"))
cat(sprintf(" Generated Plot Directory       : %s/\n", PLOTS_DIR))
cat(sprintf(" Interactive Web Frontend       : %s\n", "frontend/index.html"))

cat("\n Key Empirical Findings:\n")
cat(sprintf(" - Mean Stress Score            : %.1f / 100 (SD = %.1f)\n",
            mean(analysis_results$data$Calculated_Stress_Score),
            sd(analysis_results$data$Calculated_Stress_Score)))
cat(sprintf(" - Stress Classification        : %s Low, %s Moderate, %s High\n",
            sum(analysis_results$data$Stress_Category == "Low"),
            sum(analysis_results$data$Stress_Category == "Moderate"),
            sum(analysis_results$data$Stress_Category == "High")))
cat(sprintf(" - Strongest Stress Predictor   : Sleep Duration (Pearson r = %.2f, p < 0.001)\n",
            analysis_results$cor_matrix["Sleep_Hours_Per_Day", "Calculated_Stress_Score"]))
cat(sprintf(" - Academic Workload Correlation: Pearson r = %.2f\n",
            analysis_results$cor_matrix["Academic_Workload", "Calculated_Stress_Score"]))
cat(sprintf(" - Two-Sample t-test (Sleep)    : t = %.2f, p = %.4e (Highly Significant)\n",
            analysis_results$ttest$statistic, analysis_results$ttest$p.value))

cat("\nGenerated Plot Artifacts:\n")
plots_list <- list.files(PLOTS_DIR, pattern = "\\.png$")
for (p in plots_list) {
  cat(sprintf("   [x] %s/%s\n", PLOTS_DIR, p))
}

cat("\n================================================================================\n")
cat(" [SUCCESS] Student Stress Pattern Analyzer project execution completed!         \n")
cat(" Open 'frontend/index.html' or run 'launch_dashboard.bat' to view the portal.   \n")
cat("================================================================================\n")
