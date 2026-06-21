# Heart Disease Prediction Dashboard

![R](https://img.shields.io/badge/R-276DC3?style=flat&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-30A9DE?style=flat&logo=shiny)
![Plotly](https://img.shields.io/badge/Plotly-3F4B88?style=flat&logo=plotly)
![Random Forest](https://img.shields.io/badge/ML-Random%20Forest-orange)

## Overview

This repository contains a heart disease prediction dashboard built in R using Shiny. The application trains and compares two machine learning models—Logistic Regression and Random Forest—on a heart disease dataset. It provides an interactive UI for making predictions, visualizing feature distributions, and comparing model performance.

## Problem Statement

Cardiovascular disease is a leading cause of mortality worldwide. Early detection of heart disease based on clinical measurements can help healthcare providers identify at-risk patients and recommend preventive treatment plans.

## Solution

This project delivers an interactive Shiny application that:
- trains machine learning models on a heart disease dataset,
- performs feature selection using Recursive Feature Elimination (RFE),
- allows users to input patient health parameters,
- predicts heart disease risk with two model options,
- visualizes model performance and clinical feature distributions.

## Features

- ✅ Interactive Shiny dashboard with multiple tabs
- ✅ Prediction using Logistic Regression and Random Forest
- ✅ Recursive Feature Elimination to select top features
- ✅ Training/testing split and model evaluation
- ✅ Confusion matrix-based metrics (accuracy, precision, recall, F1)
- ✅ ROC curve and AUC comparison
- ✅ Plotly-powered visualizations for exploration
- ✅ Feature importance charts for both models
- ✅ Real-time patient input interface
- ✅ Distribution and correlation analytics

## Tech Stack

| Category | Technology |
|---|---|
| Frontend | Shiny, shinydashboard, Plotly |
| Backend | R, caret, randomForest |
| Database | CSV dataset (`heart.csv`) |
| Languages | R |
| Frameworks | Shiny, tidyverse |
| Tools | RStudio, Git, R packages: e1071, pROC, DT, corrplot, reshape2 |

## System Architecture

The application follows a single-script Shiny architecture with a combined UI and server workflow:
1. Load the CSV dataset.
2. Convert the target variable into a factor for classification.
3. Perform Recursive Feature Elimination (RFE) to select the top 10 predictive features.
4. Split the selected dataset into training and test sets.
5. Train two models: Logistic Regression and Random Forest.
6. Evaluate each model using test set predictions.
7. Launch the Shiny dashboard, where the UI renders input controls, plots, and tables.
8. User inputs are processed reactively by the server to generate predictions and visualizations.

## Project Structure

```text
heart diseases/
├── .git/                            # Git repository metadata
├── App_NamanMittal_500121068+BhavishyaKatariya_500118956.R   # Main Shiny application and model script
├── heart.csv                        # Heart disease dataset
├── Heart_Disease_Prediction_Model_Help_File_NamanMittal_500121068+BhavishyaKatariya_500118956.docx  # Support documentation
├── Heart_Disease_Prediction_Report_NamanMittal_500121068+BhavishyaKatariya_500118956.pdf            # Project report
└── README.md                        # Project overview and instructions
```

## Database Design

This project uses a single CSV dataset rather than a relational database. The dataset schema includes the following fields:

| Column | Description |
|---|---|
| `age` | Patient age in years |
| `sex` | Sex (1 = male, 0 = female) |
| `cp` | Chest pain type (0–3) |
| `trestbps` | Resting blood pressure (mm Hg) |
| `chol` | Serum cholesterol (mg/dl) |
| `fbs` | Fasting blood sugar > 120 mg/dl (1 = true; 0 = false) |
| `restecg` | Resting electrocardiographic results (0–2) |
| `thalach` | Maximum heart rate achieved |
| `exang` | Exercise-induced angina (1 = yes; 0 = no) |
| `oldpeak` | ST depression induced by exercise relative to rest |
| `slope` | Slope of peak exercise ST segment (0–2) |
| `ca` | Number of major vessels colored by fluoroscopy (0–3) |
| `thal` | Thalassemia status (1 = normal, 2 = fixed defect, 3 = reversible defect) |
| `target` | Heart disease presence (1 = disease, 0 = no disease) |

Relationships:
- Single flat table with all observations and target labels.
- No relational foreign keys or separate entities are defined.

## API Endpoints

This repository does not expose REST APIs. It is a local Shiny dashboard application with the following interactive sections:

| Component | Route / Tab | Description |
|---|---|---|
| Prediction | `Prediction` tab | Enter patient parameters and generate a heart disease prediction using the selected model. |
| Visualizations | `Visualizations` tab | Explore target distribution, correlation heatmap, and numeric feature comparisons. |
| Model Comparison | `Model Comparison` tab | Compare model metrics and ROC curves for Logistic Regression vs Random Forest. |

> Note: There are no external HTTP endpoints defined in the current codebase.

## Installation & Setup

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/heart-disease-prediction.git
cd "heart diseases"
```

### 2. Install R and required packages

Install R from [https://cran.r-project.org/](https://cran.r-project.org/) and then install required packages in R or RStudio:

```r
install.packages(c(
  "caret",
  "e1071",
  "tidyverse",
  "shiny",
  "pROC",
  "shinythemes",
  "randomForest",
  "plotly",
  "DT",
  "shinydashboard",
  "corrplot",
  "reshape2"
))
```

### 3. Prepare the dataset

- Ensure `heart.csv` is available in the project root.
- Update the dataset path in `App_NamanMittal_500121068+BhavishyaKatariya_500118956.R` if needed.

Current path in code:

```r
heart <- read.csv("C:\\Users\\naman\\Downloads\\heart.csv")
```

For portability, change this to:

```r
heart <- read.csv("heart.csv")
```

### 4. Run the project

Open the R script in RStudio and click **Run App**, or run the application manually:

```r
library(shiny)
runApp("App_NamanMittal_500121068+BhavishyaKatariya_500118956.R")
```

## Usage Guide

1. Open the Shiny application in your browser.
2. Select the `Prediction` tab.
3. Enter patient health parameter values:
   - Chest pain type
   - Sex
   - Thalassemia
   - Scan results and exercise data
   - Blood pressure, cholesterol, age, and more
4. Choose either **Logistic Regression** or **Random Forest**.
5. Click **Predict**.
6. Review the prediction result and probability score.
7. Switch to `Visualizations` to explore:
   - disease distribution,
   - feature correlation,
   - numeric comparisons by disease label.
8. Use `Model Comparison` to inspect:
   - performance table,
   - ROC curves,
   - grouped metric bar charts.

## Screenshots

Add visual assets to illustrate the dashboard and core flows:

- `screenshots/prediction-tab.png` — prediction form and results
- `screenshots/visualizations-tab.png` — distribution and correlation plots
- `screenshots/model-comparison-tab.png` — ROC curve and metrics comparison

> Replace these placeholders with actual screenshots once the app is running.

## Security Features

- Input controls use Shiny UI validation and type constraints.
- Numeric fields enforce reasonable bounds for clinical parameters.
- Current implementation does not include authentication or session management.

> Security improvements are recommended for production deployment.

## Challenges Faced

- Building a responsive Shiny dashboard with multiple visualization types.
- Selecting the most relevant features using RFE for better prediction quality.
- Comparing classification models with meaningful metrics and ROC analysis.
- Ensuring the app remains user-friendly while handling numerical medical data.
- Working around an absolute dataset path in the original script for portability.

## Future Enhancements

1. Convert dataset loading to a relative path or configurable data source.
2. Add user authentication and role-based access control.
3. Build a REST API layer for model prediction and analytics.
4. Enable dataset upload and dynamic retraining from the UI.
5. Add explainable AI features like SHAP or LIME for predictions.
6. Include additional algorithms such as XGBoost and SVM.
7. Deploy the dashboard to a cloud platform (e.g. ShinyApps.io, DigitalOcean, AWS).
8. Implement audit logging and usage tracking.
9. Add responsive mobile-friendly dashboard layout.
10. Enhance validation with stricter input sanitization and session handling.
11. Expand the dataset and support additional heart disease cohorts.
12. Add export options for reports and model summaries.

## Contributing

Contributions are welcome!

1. Fork the repository.
2. Create a new branch: `git checkout -b feature/your-feature`.
3. Commit your changes: `git commit -m "Add some feature"`.
4. Push to the branch: `git push origin feature/your-feature`.
5. Open a pull request.

Please include a clear description of your changes and any testing details.

## License

This project is available under the MIT License. See `LICENSE` for details.

## Author

- Name: _Your Name_
- GitHub: [your-username](https://github.com/your-username)
- LinkedIn: [your-linkedin](https://www.linkedin.com/in/your-linkedin)
- Email: your.email@example.com

## Acknowledgements

- R and RStudio
- Shiny and shinydashboard
- caret for model training and feature selection
- randomForest for ensemble prediction
- plotly for interactive charts
- DT for table rendering
- pROC for ROC and AUC evaluation
- tidyverse for data manipulation
