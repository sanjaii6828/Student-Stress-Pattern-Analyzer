# ==============================================================================
# File: scripts/03_visualization.R
# Project: Student Stress Pattern Analyzer
# Purpose: Generate high-resolution, publication-grade visualizations using
#          base R graphics: Bar Charts, Histograms, Scatter Plots, and Box Plots.
# ==============================================================================

generate_stress_visualizations <- function(df, output_dir = "plots") {
  
  cat("\n========================================================\n")
  cat(" [STEP 6] GENERATING VISUALIZATION SUITE\n")
  cat("========================================================\n")
  
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Aesthetic Color Palettes
  cat_colors  <- c("Low" = "#2ECC71", "Moderate" = "#F39C12", "High" = "#E74C3C")
  year_colors <- c("#3498DB", "#9B59B6", "#E67E22", "#1ABC9C")
  sleep_colors <- c("#E74C3C", "#F1C40F", "#27AE60")
  
  # ----------------------------------------------------------------------------
  # PLOT 1: Bar Chart - Stress Category Distribution
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 1: Stress Category Bar Chart...\n")
  png(filename = file.path(output_dir, "01_barchart_stress_distribution.png"),
      width = 1200, height = 800, res = 150)
  
  stress_counts <- table(df$Stress_Category)
  stress_pcts   <- round(prop.table(stress_counts) * 100, 1)
  
  par(mar = c(5, 5, 4, 2), bg = "#FAFAFA")
  bp <- barplot(stress_counts,
                col = cat_colors[names(stress_counts)],
                border = "#2C3E50",
                ylim = c(0, max(stress_counts) * 1.35),
                ylab = "Number of Students",
                xlab = "Classified Stress Category",
                main = "Student Stress Distribution (N = 200)",
                sub = "Source: Student Stress Pattern Analyzer Lab Study",
                font.main = 2, cex.main = 1.3, cex.lab = 1.1)
  grid(nx = NA, ny = NULL, col = "#D5D8DC", lty = 2)
  # Re-draw bars over grid without repeating axes
  barplot(stress_counts, col = cat_colors[names(stress_counts)],
          border = "#2C3E50", add = TRUE, axes = FALSE, ann = FALSE)
  
  # Value labels above bars with clean clearance
  labels <- paste0(stress_counts, "\n(", stress_pcts, "%)")
  text(x = bp, y = stress_counts,
       labels = labels, pos = 3, offset = 0.6, cex = 1.05, font = 2, col = "#2C3E50")
  
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 2: Clustered Bar Chart - Mean Stress Score by Department & Academic Year
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 2: Department vs Year Clustered Bar Chart...\n")
  png(filename = file.path(output_dir, "02_barchart_dept_stress.png"),
      width = 1400, height = 850, res = 150)
  
  dept_year_mat <- tapply(df$Calculated_Stress_Score, list(df$Academic_Year, df$Department), mean)
  dept_year_mat <- round(dept_year_mat, 1)
  
  par(mar = c(6, 5, 4, 2), bg = "#FAFAFA")
  bp_dept <- barplot(dept_year_mat,
                     beside = TRUE,
                     col = year_colors,
                     border = "#2C3E50",
                     ylim = c(0, 100),
                     ylab = "Average Stress Score (0 - 100)",
                     xlab = "",
                     main = "Mean Stress Score Across Departments by Academic Year",
                     las = 1, font.main = 2, cex.main = 1.2, cex.lab = 1.05)
  grid(nx = NA, ny = NULL, col = "#D5D8DC", lty = 2)
  barplot(dept_year_mat, beside = TRUE, col = year_colors, border = "#2C3E50",
          add = TRUE, axes = FALSE, ann = FALSE)
  
  legend("topright",
         legend = rownames(dept_year_mat),
         fill = year_colors,
         border = "#2C3E50",
         title = "Academic Year",
         bty = "n", cex = 0.9)
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 3: Histogram - Distribution of Calculated Stress Scores
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 3: Stress Score Distribution Histogram...\n")
  png(filename = file.path(output_dir, "03_histogram_stress_scores.png"),
      width = 1200, height = 800, res = 150)
  
  par(mar = c(5, 5, 4, 2), bg = "#FAFAFA")
  h <- hist(df$Calculated_Stress_Score,
            breaks = seq(0, 100, by = 5),
            col = "#85C1E9",
            border = "#2980B9",
            prob = TRUE,
            xlab = "Calculated Composite Stress Score (0 - 100)",
            ylab = "Density",
            main = "Distribution of Composite Stress Scores with Normal Density Fit",
            font.main = 2, cex.main = 1.2, cex.lab = 1.1)
  grid(col = "#D5D8DC", lty = 2)
  # Re-draw histogram over grid without duplicate axes
  hist(df$Calculated_Stress_Score, breaks = seq(0, 100, by = 5),
       col = "#85C1E9", border = "#2980B9", prob = TRUE, add = TRUE, axes = FALSE, ann = FALSE)
  
  # Theoretical Normal Density Curve
  x_seq <- seq(0, 100, length.out = 200)
  y_norm <- dnorm(x_seq, mean = mean(df$Calculated_Stress_Score), sd = sd(df$Calculated_Stress_Score))
  lines(x_seq, y_norm, col = "#C0392B", lwd = 2.5)
  
  # Kernel Density Estimate
  lines(density(df$Calculated_Stress_Score), col = "#27AE60", lwd = 2.5, lty = 2)
  
  # Mean and Median indicators
  abline(v = mean(df$Calculated_Stress_Score), col = "#922B21", lwd = 2, lty = 3)
  abline(v = median(df$Calculated_Stress_Score), col = "#1F618D", lwd = 2, lty = 4)
  
  legend("topright",
         legend = c("Fitted Normal Curve", "Kernel Density",
                    sprintf("Mean = %.1f", mean(df$Calculated_Stress_Score)),
                    sprintf("Median = %.1f", median(df$Calculated_Stress_Score))),
         col = c("#C0392B", "#27AE60", "#922B21", "#1F618D"),
         lwd = c(2.5, 2.5, 2, 2),
         lty = c(1, 2, 3, 4),
         bty = "n", cex = 0.95)
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 4: Dual Histogram - Sleep Hours vs Study Hours
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 4: Comparative Sleep vs Study Histograms...\n")
  png(filename = file.path(output_dir, "04_histogram_sleep_vs_study.png"),
      width = 1400, height = 750, res = 150)
  
  par(mfrow = c(1, 2), mar = c(5, 4.5, 4, 2), bg = "#FAFAFA")
  
  # Sleep Histogram
  hist(df$Sleep_Hours_Per_Day,
       breaks = seq(2, 11, by = 0.5),
       col = "#AED6F1", border = "#2471A3",
       xlab = "Sleep Hours per Day", ylab = "Number of Students",
       main = "Distribution of Sleep Hours",
       font.main = 2, cex.main = 1.1)
  abline(v = mean(df$Sleep_Hours_Per_Day), col = "#C0392B", lwd = 2, lty = 2)
  abline(v = 7.0, col = "#27AE60", lwd = 2, lty = 3)
  legend("topright",
         legend = c(sprintf("Mean = %.1fh", mean(df$Sleep_Hours_Per_Day)), "Recommended (7h)"),
         col = c("#C0392B", "#27AE60"), lty = c(2, 3), lwd = 2, bty = "n", cex = 0.9)
  box(col = "#BDC3C7")
  
  # Study Histogram
  hist(df$Study_Hours_Per_Day,
       breaks = seq(0, 12, by = 0.5),
       col = "#FAD7A0", border = "#D35400",
       xlab = "Study Hours per Day", ylab = "Number of Students",
       main = "Distribution of Study Hours",
       font.main = 2, cex.main = 1.1)
  abline(v = mean(df$Study_Hours_Per_Day), col = "#C0392B", lwd = 2, lty = 2)
  legend("topright",
         legend = sprintf("Mean = %.1fh", mean(df$Study_Hours_Per_Day)),
         col = "#C0392B", lty = 2, lwd = 2, bty = "n", cex = 0.9)
  box(col = "#BDC3C7")
  
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 5: Scatter Plot - Sleep Hours vs Stress Score (with Linear Fit)
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 5: Sleep Hours vs Stress Score Scatter Plot...\n")
  png(filename = file.path(output_dir, "05_scatterplot_sleep_vs_stress.png"),
      width = 1200, height = 800, res = 150)
  
  par(mar = c(5, 5, 4, 2), bg = "#FAFAFA")
  
  pt_colors <- cat_colors[as.character(df$Stress_Category)]
  
  plot(df$Sleep_Hours_Per_Day, df$Calculated_Stress_Score,
       col = pt_colors,
       pch = 19, cex = 1.2,
       xlab = "Sleep Hours per Day",
       ylab = "Calculated Stress Score (0 - 100)",
       main = "Correlation Between Sleep Duration and Stress Score",
       font.main = 2, cex.main = 1.3, cex.lab = 1.1)
  grid(col = "#D5D8DC", lty = 2)
  
  # Re-plot points with subtle dark border for clarity
  points(df$Sleep_Hours_Per_Day, df$Calculated_Stress_Score,
         col = "#2C3E50", pch = 1, cex = 1.2)
  
  # Fit linear regression line
  fit_sleep <- lm(Calculated_Stress_Score ~ Sleep_Hours_Per_Day, data = df)
  abline(fit_sleep, col = "#8E44AD", lwd = 3)
  
  # Pearson correlation
  r_sleep <- cor(df$Sleep_Hours_Per_Day, df$Calculated_Stress_Score)
  legend_text <- c(
    sprintf("Linear Fit: y = %.1f + (%.1f)x", coef(fit_sleep)[1], coef(fit_sleep)[2]),
    sprintf("Pearson r = %.2f (p < 0.001)", r_sleep),
    "Low Stress", "Moderate Stress", "High Stress"
  )
  legend("topright",
         legend = legend_text,
         col = c("#8E44AD", "transparent", cat_colors["Low"], cat_colors["Moderate"], cat_colors["High"]),
         lty = c(1, NA, NA, NA, NA),
         pch = c(NA, NA, 19, 19, 19),
         lwd = c(3, NA, NA, NA, NA),
         bg = "white", box.col = "#BDC3C7", cex = 0.95)
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 6: Scatter Plot - Screen Time vs Stress Score (by Physical Activity)
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 6: Screen Time vs Stress Score Scatter Plot...\n")
  png(filename = file.path(output_dir, "06_scatterplot_screen_vs_stress.png"),
      width = 1200, height = 800, res = 150)
  
  par(mar = c(5, 5, 4, 2), bg = "#FAFAFA")
  
  act_colors <- c("Sedentary (<1h)" = "#E74C3C", "Moderate (1-2h)" = "#F39C12", "Active (>2h)" = "#27AE60")
  pt_act_col <- act_colors[as.character(df$Activity_Tier)]
  
  plot(df$Screen_Time_Hours, df$Calculated_Stress_Score,
       col = pt_act_col,
       pch = 19, cex = 1.2,
       xlab = "Daily Screen Time (Hours)",
       ylab = "Calculated Stress Score (0 - 100)",
       main = "Screen Time vs. Stress Score Moderated by Physical Activity",
       font.main = 2, cex.main = 1.3, cex.lab = 1.1)
  grid(col = "#D5D8DC", lty = 2)
  points(df$Screen_Time_Hours, df$Calculated_Stress_Score, col = "#2C3E50", pch = 1, cex = 1.2)
  
  fit_screen <- lm(Calculated_Stress_Score ~ Screen_Time_Hours, data = df)
  abline(fit_screen, col = "#2980B9", lwd = 2.5, lty = 1)
  
  r_screen <- cor(df$Screen_Time_Hours, df$Calculated_Stress_Score)
  legend("topleft",
         legend = c(sprintf("Linear Trend (r = %.2f)", r_screen),
                    "Sedentary (<1h Activity)",
                    "Moderate (1-2h Activity)",
                    "Active (>2h Activity)"),
         col = c("#2980B9", act_colors["Sedentary (<1h)"], act_colors["Moderate (1-2h)"], act_colors["Active (>2h)"]),
         lty = c(1, NA, NA, NA),
         pch = c(NA, 19, 19, 19),
         lwd = c(2.5, NA, NA, NA),
         bg = "white", box.col = "#BDC3C7", cex = 0.95)
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 7: Box Plot - Stress Score Distribution across Academic Years
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 7: Academic Year Stress Score Box Plot...\n")
  png(filename = file.path(output_dir, "07_boxplot_stress_by_academic_year.png"),
      width = 1200, height = 800, res = 150)
  
  par(mar = c(5, 5, 4, 2), bg = "#FAFAFA")
  bx_year <- boxplot(Calculated_Stress_Score ~ Academic_Year, data = df,
                     col = c("#D4E6F1", "#D2B4DE", "#EDBB99", "#A2D9CE"),
                     border = "#2C3E50",
                     notch = FALSE,
                     ylab = "Calculated Stress Score (0 - 100)",
                     xlab = "Academic Year",
                     main = "Stress Score Progression Across Academic Years",
                     font.main = 2, cex.main = 1.3, cex.lab = 1.1)
  grid(nx = NA, ny = NULL, col = "#D5D8DC", lty = 2)
  boxplot(Calculated_Stress_Score ~ Academic_Year, data = df,
          col = c("#D4E6F1", "#D2B4DE", "#EDBB99", "#A2D9CE"),
          border = "#2C3E50", notch = FALSE, add = TRUE, axes = FALSE, ann = FALSE)
  
  # Overlay diamond points for group means
  means_year <- tapply(df$Calculated_Stress_Score, df$Academic_Year, mean)
  points(1:4, means_year, pch = 18, col = "#C0392B", cex = 2.0)
  
  legend("topleft",
         legend = c("Group Median (IQR Box)", "Group Mean"),
         col = c("#2C3E50", "#C0392B"),
         pch = c(NA, 18),
         lty = c(1, NA),
         lwd = c(2, NA),
         pt.cex = c(NA, 1.8),
         bg = "white", box.col = "#BDC3C7", cex = 0.95)
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 8: Box Plot - Stress Score by Sleep Tier
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 8: Sleep Tier Stress Score Box Plot...\n")
  png(filename = file.path(output_dir, "08_boxplot_stress_by_sleep_tier.png"),
      width = 1200, height = 800, res = 150)
  
  par(mar = c(5, 5, 4, 2), bg = "#FAFAFA")
  bx_sleep <- boxplot(Calculated_Stress_Score ~ Sleep_Tier, data = df,
                      col = c("#FADBD8", "#FCF3CF", "#D5F5E3"),
                      border = "#2C3E50",
                      notch = FALSE,
                      ylab = "Calculated Stress Score (0 - 100)",
                      xlab = "Sleep Duration Category",
                      main = "Impact of Sleep Deprivation on Student Stress Score",
                      font.main = 2, cex.main = 1.3, cex.lab = 1.1)
  grid(nx = NA, ny = NULL, col = "#D5D8DC", lty = 2)
  boxplot(Calculated_Stress_Score ~ Sleep_Tier, data = df,
          col = c("#FADBD8", "#FCF3CF", "#D5F5E3"),
          border = "#2C3E50", notch = FALSE, add = TRUE, axes = FALSE, ann = FALSE)
  
  means_sleep <- tapply(df$Calculated_Stress_Score, df$Sleep_Tier, mean)
  points(1:3, means_sleep, pch = 18, col = "#8E44AD", cex = 2.0)
  
  legend("topright",
         legend = c("Group Median", "Group Mean"),
         col = c("#2C3E50", "#8E44AD"),
         pch = c(NA, 18),
         lty = c(1, NA),
         lwd = c(2, NA),
         pt.cex = c(NA, 1.8),
         bg = "white", box.col = "#BDC3C7", cex = 0.95)
  box(col = "#BDC3C7")
  dev.off()
  
  # ----------------------------------------------------------------------------
  # PLOT 9: Comprehensive 2x2 Master Analytics Dashboard
  # ----------------------------------------------------------------------------
  cat("-> Generating Plot 9: Comprehensive 2x2 Analytics Dashboard...\n")
  png(filename = file.path(output_dir, "09_stress_analytics_dashboard.png"),
      width = 1600, height = 1200, res = 150)
  
  par(mfrow = c(2, 2), mar = c(4.5, 4.5, 3.5, 1.5), oma = c(0, 0, 3, 0), bg = "#FAFAFA")
  
  # Panel A: Bar Chart
  bp_dash <- barplot(stress_counts, col = cat_colors[names(stress_counts)], border = "#2C3E50",
                     ylim = c(0, max(stress_counts) * 1.35), ylab = "Count", xlab = "Stress Category",
                     main = "A) Classification Breakdown", font.main = 2)
  grid(nx = NA, ny = NULL, col = "#D5D8DC", lty = 2)
  barplot(stress_counts, col = cat_colors[names(stress_counts)], border = "#2C3E50",
          add = TRUE, axes = FALSE, ann = FALSE)
  text(x = bp_dash, y = stress_counts,
       labels = paste0(stress_counts, " (", stress_pcts, "%)"), pos = 3, offset = 0.5, font = 2)
  box(col = "#BDC3C7")
  
  # Panel B: Histogram
  hist(df$Calculated_Stress_Score, breaks = seq(0, 100, by = 5), col = "#85C1E9", border = "#2980B9",
       prob = TRUE, xlab = "Stress Score (0-100)", ylab = "Density", main = "B) Stress Score Distribution",
       font.main = 2)
  grid(col = "#D5D8DC", lty = 2)
  hist(df$Calculated_Stress_Score, breaks = seq(0, 100, by = 5), col = "#85C1E9", border = "#2980B9",
       prob = TRUE, add = TRUE, axes = FALSE, ann = FALSE)
  lines(x_seq, y_norm, col = "#C0392B", lwd = 2)
  abline(v = mean(df$Calculated_Stress_Score), col = "#922B21", lwd = 2, lty = 2)
  box(col = "#BDC3C7")
  
  # Panel C: Scatter Plot
  plot(df$Sleep_Hours_Per_Day, df$Calculated_Stress_Score, col = pt_colors, pch = 19, cex = 1.1,
       xlab = "Sleep Hours", ylab = "Stress Score", main = "C) Sleep Duration vs Stress Score", font.main = 2)
  grid(col = "#D5D8DC", lty = 2)
  abline(fit_sleep, col = "#8E44AD", lwd = 2.5)
  legend("topright", legend = sprintf("r = %.2f", r_sleep), text.font = 2, bty = "n")
  box(col = "#BDC3C7")
  
  # Panel D: Box Plot
  boxplot(Calculated_Stress_Score ~ Academic_Year, data = df,
          col = c("#D4E6F1", "#D2B4DE", "#EDBB99", "#A2D9CE"), border = "#2C3E50", notch = FALSE,
          xlab = "Academic Year", ylab = "Stress Score", main = "D) Stress Distribution Across Years", font.main = 2)
  grid(nx = NA, ny = NULL, col = "#D5D8DC", lty = 2)
  boxplot(Calculated_Stress_Score ~ Academic_Year, data = df,
          col = c("#D4E6F1", "#D2B4DE", "#EDBB99", "#A2D9CE"), border = "#2C3E50", notch = FALSE,
          add = TRUE, axes = FALSE, ann = FALSE)
  points(1:4, means_year, pch = 18, col = "#C0392B", cex = 1.8)
  box(col = "#BDC3C7")
  
  mtext("STUDENT STRESS PATTERN ANALYZER - MULTI-DIMENSIONAL DASHBOARD",
        outer = TRUE, cex = 1.4, font = 2, col = "#1A5276")
  
  dev.off()
  
  cat(sprintf("-> All 9 visualization plots successfully generated in folder: '%s/'\n", output_dir))
}
