# Student Stress Pattern Analyzer
**A Comprehensive R Programming Laboratory Project**

---

## 📌 Project Overview
The **Student Stress Pattern Analyzer** is a moderate-level R Programming laboratory project designed to explore, quantify, and visualize academic stress patterns among higher education students. Using pure R (without reliance on external package dependencies), this project demonstrates end-to-end data science workflows:
1. **Dataset Generation & Handling**: Synthetic yet empirically calibrated cohort dataset of 200 student records.
2. **Data Cleaning & Preprocessing**: Whitespace normalization, outlier remediation, and median imputation of missing data.
3. **Data-Frame Operations & Factor Manipulations**: Nominal and ordinal factors, ratio feature engineering, subsetting, sorting, and aggregations.
4. **Stress Score Algorithm**: A normalized multi-criteria composite index calculating continuous stress scores (0 to 100).
5. **Categorical Classification**: Quantile-benchmarked classification into **Low**, **Moderate**, and **High** stress tiers.
6. **Frequency Tables & Contingency Analysis**: 1-way and 2-way cross-tabulations, marginal probabilities, and Pearson Chi-Square tests of independence.
7. **Inferential & Descriptive Statistics**: Summary statistics (Mean, Median, SD, IQR), Pearson correlation matrix, independent two-sample t-tests, One-Way ANOVA, and multiple linear regression.
8. **High-Resolution Visualizations**: Publication-grade Bar Charts, Histograms with density overlays, Scatter Plots with linear regressions, and Box Plots with IQR and mean markers.

---

## 📁 Project Structure

```text
project/
├── data/
│   ├── generate_dataset.R         # R script to synthesize raw student data
│   ├── student_stress_raw.csv     # Raw dataset with intentional anomalies
│   ├── student_stress_clean.csv   # Preprocessed and cleaned dataset
│   └── student_stress_analyzed.csv# Final enriched dataset with stress scores & tiers
├── scripts/
│   ├── 01_data_cleaning.R         # Modular data cleaning & imputation script
│   ├── 02_data_analysis.R         # Factor handling, scoring, tables, and statistics
│   ├── 03_visualization.R         # Base R publication-grade visualization suite
│   └── export_to_json.R           # Syncs R dataset with web frontend
├── frontend/                      # Interactive Web Analytics Portal
│   ├── index.html                 # Single-Page Application dashboard
│   ├── css/
│   │   └── styles.css             # Responsive modern styling with container queries
│   ├── js/
│   │   ├── data.js                # Auto-generated dataset from R pipeline
│   │   └── app.js                 # Chart.js visualizer, simulator & table controller
│   └── plots/                     # Mirrored high-res R plots for web gallery
├── plots/                         # High-resolution native R plots
├── launch_dashboard.bat           # 1-Click Windows dashboard launcher
├── launch_dashboard.ps1           # PowerShell dashboard launcher
├── main.R                         # Master driver script executing the full pipeline
└── README.md                      # Comprehensive laboratory documentation
```

---

## 📊 Dataset Schema

| Column Name | Type | Description |
| :--- | :--- | :--- |
| `Student_ID` | Character | Unique student identifier (e.g., `STU1001`) |
| `Name` | Character | Student Full Name |
| `Gender` | Factor (Nominal) | `Male`, `Female`, `Non-Binary` |
| `Department` | Factor (Nominal) | `Computer Science`, `Electronics`, `Mechanical`, `Civil`, `Biotechnology` |
| `Academic_Year` | Factor (Ordered) | `Year 1 < Year 2 < Year 3 < Year 4` |
| `Study_Hours_Per_Day` | Numeric (Hours) | Daily study duration (1.5 – 10.0 hrs) |
| `Sleep_Hours_Per_Day` | Numeric (Hours) | Daily sleep duration (3.5 – 9.5 hrs) |
| `Screen_Time_Hours` | Numeric (Hours) | Total screen exposure (2.0 – 12.0 hrs) |
| `Academic_Workload` | Integer (1 to 5) | Perceived academic load (1 = Very Low, 5 = Very High) |
| `Attendance_Percentage` | Numeric (%) | Semester class attendance rate (0% – 100%) |
| `Assignment_Pressure` | Integer (1 to 5) | Assignment deadline pressure rating |
| `Physical_Activity_Hours` | Numeric (Hours) | Daily physical exercise duration (0 – 3.5 hrs) |
| `Reported_Stress_Level` | Factor (Ordered) | Baseline self-reported survey level (`Low`, `Moderate`, `High`) |
| `Calculated_Stress_Score` | Numeric (0–100) | Multi-criteria composite stress score |
| `Stress_Category` | Factor (Ordered) | Model classification (`Low < Moderate < High`) |
| `Sleep_to_Screen_Ratio` | Numeric | Ratio of sleep hours to screen time hours |
| `Study_to_Sleep_Ratio` | Numeric | Ratio of study hours to sleep hours |

---

## 🧮 Mathematical Model: Composite Stress Score

The continuous composite stress score is computed via a multi-criteria normalized model:

$$\text{Composite Stress Score} = \min\Big(100, \max\Big(0, \, w_w W + w_p P + w_d D + w_s S + w_a A_{\text{risk}} - w_b B_{\text{act}}\Big)\Big)$$

Where each factor is normalized to a $[0, 100]$ scale:
1. **Academic Workload ($W$)** (Weight $w_w = 0.25$): $\frac{\text{Academic\_Workload} - 1}{4} \times 100$
2. **Assignment Pressure ($P$)** (Weight $w_p = 0.25$): $\frac{\text{Assignment\_Pressure} - 1}{4} \times 100$
3. **Sleep Deficit ($D$)** (Weight $w_d = 0.25$): $\max\left(0, \frac{8.5 - \text{Sleep\_Hours}}{5.0}\right) \times 100$
4. **Screen Time ($S$)** (Weight $w_s = 0.15$): $\min\left(100, \frac{\text{Screen\_Time\_Hours}}{12.0} \times 100\right)$
5. **Attendance Risk ($A_{\text{risk}}$)** (Weight $w_a = 0.10$): $\max\left(0, \frac{85.0 - \text{Attendance}}{30.0}\right) \times 100$
6. **Physical Activity Buffer ($B_{\text{act}}$)** (Reduction weight $w_b = -0.15$): $\min\left(100, \frac{\text{Physical\_Activity\_Hours}}{3.0} \times 100\right)$

### Classification Cutoffs:
- **Low Stress**: $\text{Score} < 42.0$
- **Moderate Stress**: $42.0 \le \text{Score} < 68.0$
- **High Stress**: $\text{Score} \ge 68.0$

---

## 🔬 Statistical Analysis Highlights

### 1. Descriptive Statistics ($N = 200$)
- **Calculated Stress Score**: Mean = $45.79$, Median = $47.50$, $\text{SD} = 21.71$, $\text{IQR} = 33.60$, Min = $5.0$, Max = $92.9$
- **Sleep Hours**: Mean = $5.59$ hrs, Median = $5.40$ hrs, $\text{SD} = 1.33$ hrs
- **Study Hours**: Mean = $5.42$ hrs, Median = $5.55$ hrs, $\text{SD} = 1.75$ hrs
- **Screen Time**: Mean = $8.26$ hrs, Median = $8.20$ hrs, $\text{SD} = 1.67$ hrs

### 2. Pearson Correlation Coefficients with Stress Score
- **Academic Workload**: $r = +0.940$ (Very strong positive driver)
- **Sleep Duration**: $r = -0.879$ (Very strong protective factor)
- **Assignment Pressure**: $r = +0.858$ (Strong positive driver)
- **Study Hours**: $r = +0.764$ (Moderate-strong positive correlation)
- **Screen Time**: $r = +0.545$ (Moderate positive correlation)
- **Physical Activity**: $r = -0.504$ (Moderate protective buffer)
- **Attendance**: $r = -0.454$ (Inverse correlation)

### 3. Hypothesis Testing (Independent Two-Sample t-test)
- **Null Hypothesis ($H_0$)**: There is no significant difference in stress score between students sleeping $<6$ hrs and students sleeping $\ge 6$ hrs.
- **Alternative Hypothesis ($H_1$)**: Students with short sleep ($<6$ hrs) have higher stress scores.
- **Results**:
  - Group 1 (Sleep $<6$ hrs, $n = 125$): Mean Stress = $58.14$
  - Group 2 (Sleep $\ge 6$ hrs, $n = 75$): Mean Stress = $25.19$
  - Welch Two Sample t-statistic = $15.344$, $df = 156.27$, $p = 2.69 \times 10^{-33}$ ($p < 0.001$).
- **Decision**: Reject $H_0$. Sleep deprivation is a statistically significant contributor to higher student stress.

### 4. Classification Breakdown & Model Concordance
- **Low Stress**: $82$ students ($41.0\%$)
- **Moderate Stress**: $84$ students ($42.0\%$)
- **High Stress**: $34$ students ($17.0\%$)
- **Self-Reported vs Algorithmic Agreement**: $71.0\%$ overall concordance.

---

## 📈 Generated Visualizations

All visualizations are generated using pure base R graphics, styled with crisp color schemes, annotations, and clean axes:

1. **`01_barchart_stress_distribution.png`**: Bar chart showing student counts and percentages across Low, Moderate, and High stress tiers.
2. **`02_barchart_dept_stress.png`**: Clustered bar chart comparing average stress scores across departments partitioned by academic years.
3. **`03_histogram_stress_scores.png`**: Histogram of continuous stress scores with overlaid theoretical normal curve and empirical kernel density.
4. **`04_histogram_sleep_vs_study.png`**: Dual-panel comparative histograms for daily sleep hours versus study hours with mean markers.
5. **`05_scatterplot_sleep_vs_stress.png`**: Scatter plot showing the strong negative relationship between sleep hours and stress score with linear regression fit ($y = 125.9 - 14.3x$, $r = -0.88$).
6. **`06_scatterplot_screen_vs_stress.png`**: Scatter plot of screen time versus stress score, moderated and colored by physical activity level.
7. **`07_boxplot_stress_by_academic_year.png`**: Box plot showing stress progression across Academic Years (Year 1 to Year 4) with IQR boxes and group mean diamonds.
8. **`08_boxplot_stress_by_sleep_tier.png`**: Box plot highlighting dramatic reductions in stress scores as sleep transitions from Short ($<6$h) to Normal ($6-7.5$h) to Optimal ($>7.5$h).
9. **`09_stress_analytics_dashboard.png`**: 2x2 multi-panel master dashboard synthesizing the core four plot types into a single executive chart.

---

## 🌐 Interactive Web Frontend Dashboard

The project includes a web dashboard built with HTML5, modern CSS3, and JavaScript:

### Features:
1. **Dynamic KPI Metrics & Instant Filters**:
   - Filter all visualizations and student records simultaneously by **Department**, **Academic Year**, **Stress Category**, **Gender**, or live search.
2. **Interactive Chart.js Visualizations**:
   - Doughnut distribution chart with percentage tooltips.
   - Departmental mean stress score bar chart.
   - Real-time scatter plot of Sleep Hours vs Stress Score.
   - Academic Year progression comparison.
3. **Live "What-If" Stress Simulator**:
   - Interactive sliders for Workload, Assignment Pressure, Sleep, Screen Time, Study Hours, Attendance, and Physical Activity.
   - Evaluates continuous scores ($0-100$) dynamically with instantaneous color-coded feedback and personalized recommendations.
4. **Responsive Student Data Explorer (Modern Web Standards)**:
   - Sticky header table with container queries and column sorting.
   - Live search by student name or ID.
   - Client-side pagination and one-click filtered CSV export.
5. **R Plot Inspection Gallery**:
   - Integrated gallery of all 9 high-resolution base R figures with a fullscreen Lightbox modal.

### How to Launch the Web Frontend:
- **Option 1**: Double-click [`launch_dashboard.bat`](file:///c:/Users/DELL/OneDrive/project/launch_dashboard.bat) from Windows Explorer.
- **Option 2**: Run via PowerShell:
  ```powershell
  .\launch_dashboard.ps1
  ```
- **Option 3**: Directly open [`frontend/index.html`](file:///c:/Users/DELL/OneDrive/project/frontend/index.html) in Chrome, Edge, Firefox, or any modern web browser (zero local web server required; works with standard `file:///` protocol).

---

## 🚀 How to Run the Project

### Method 1: Using Command Line (Rscript)
Ensure R is installed on your system. Run:

```bash
Rscript main.R
```

*Note on Windows if `Rscript` is not in your system `PATH`:*
```powershell
& "C:\Program Files\R\R-4.6.1\bin\Rscript.exe" main.R
```

### Method 2: Inside RStudio or R GUI
1. Open RStudio or R GUI.
2. Set your working directory to the project root:
   ```r
   setwd("c:/Users/DELL/OneDrive/project")
   ```
3. Run the master script:
   ```r
   source("main.R")
   ```

---

## 🛠️ Requirements & Dependencies
- **R Version**: R 4.0 or later (tested on R 4.6.1).
- **External Packages**: **None!** (Built entirely on core base R packages: `base`, `stats`, `graphics`, `grDevices`, and `utils`). Guaranteed to run on any computer or university lab terminal without internet or package installation permissions.

