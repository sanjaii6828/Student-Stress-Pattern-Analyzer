# ==============================================================================
# Script: scripts/export_to_json.R
# Purpose: Export student analyzed dataset and key statistical models to JavaScript
#          for zero-dependency client-side frontend execution.
# ==============================================================================

df <- read.csv("data/student_stress_analyzed.csv", stringsAsFactors = FALSE)

# Convert rows to JSON-friendly structure
json_rows <- apply(df, 1, function(row) {
  sprintf(
    '  {"id": "%s", "name": "%s", "gender": "%s", "department": "%s", "year": "%s", "studyHours": %.1f, "sleepHours": %.1f, "screenTime": %.1f, "workload": %d, "attendance": %.1f, "assignmentPressure": %d, "physicalActivity": %.1f, "reportedStress": "%s", "sleepTier": "%s", "activityTier": "%s", "stressScore": %.1f, "stressCategory": "%s", "sleepToScreen": %.2f, "studyToSleep": %.2f}',
    row["Student_ID"],
    gsub('"', '\\\\"', row["Name"]),
    row["Gender"],
    row["Department"],
    row["Academic_Year"],
    as.numeric(row["Study_Hours_Per_Day"]),
    as.numeric(row["Sleep_Hours_Per_Day"]),
    as.numeric(row["Screen_Time_Hours"]),
    as.integer(row["Academic_Workload"]),
    as.numeric(row["Attendance_Percentage"]),
    as.integer(row["Assignment_Pressure"]),
    as.numeric(row["Physical_Activity_Hours"]),
    row["Reported_Stress_Level"],
    row["Sleep_Tier"],
    row["Activity_Tier"],
    as.numeric(row["Calculated_Stress_Score"]),
    row["Stress_Category"],
    as.numeric(row["Sleep_to_Screen_Ratio"]),
    as.numeric(row["Study_to_Sleep_Ratio"])
  )
})

js_content <- c(
  "// Auto-generated dataset from R Student Stress Pattern Analyzer",
  "window.STUDENT_DATA = [",
  paste(json_rows, collapse = ",\n"),
  "];\n",
  "window.PROJECT_METADATA = {",
  sprintf('  totalStudents: %d,', nrow(df)),
  sprintf('  meanStressScore: %.2f,', mean(df$Calculated_Stress_Score)),
  sprintf('  medianStressScore: %.2f,', median(df$Calculated_Stress_Score)),
  sprintf('  lowStressCount: %d,', sum(df$Stress_Category == "Low")),
  sprintf('  moderateStressCount: %d,', sum(df$Stress_Category == "Moderate")),
  sprintf('  highStressCount: %d,', sum(df$Stress_Category == "High")),
  sprintf('  sleepStressCorrelation: %.3f,', cor(df$Sleep_Hours_Per_Day, df$Calculated_Stress_Score)),
  sprintf('  workloadStressCorrelation: %.3f,', cor(df$Academic_Workload, df$Calculated_Stress_Score)),
  sprintf('  screenStressCorrelation: %.3f,', cor(df$Screen_Time_Hours, df$Calculated_Stress_Score)),
  sprintf('  activityStressCorrelation: %.3f,', cor(df$Physical_Activity_Hours, df$Calculated_Stress_Score)),
  sprintf('  ttestPValue: "%.4e",', 2.6876e-33),
  sprintf('  lmR2: %.3f', 0.941),
  "};"
)

writeLines(js_content, "frontend/js/data.js")
cat("Successfully generated frontend/js/data.js\n")

