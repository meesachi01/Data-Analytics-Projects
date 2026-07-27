#  10-Year Coronary Heart Disease (CHD) Risk Prediction

## Overview

This project develops a machine learning model to predict the **10-year risk of Coronary Heart Disease (CHD)** using patient data from the Framingham Heart Study. The objective is to support early disease detection by identifying individuals at higher risk, enabling timely preventive healthcare interventions.

## Business Value

Predictive analytics can assist healthcare providers by:

- Identifying patients at elevated risk of coronary heart disease
- Supporting early intervention and preventive care
- Improving clinical decision-making
- Reducing healthcare costs through proactive treatment
- Prioritizing patients for additional screening and monitoring

## Skills Demonstrated

- Python
- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn
- Imbalanced-learn (SMOTE)
- Exploratory Data Analysis (EDA)
- Feature Engineering
- Machine Learning
- Logistic Regression
- Model Evaluation
- Classification

## Project Workflow

The project includes:

- Data cleaning and preprocessing
- Missing value treatment
- Duplicate and outlier detection
- Exploratory data analysis (EDA)
- Feature engineering
- Handling class imbalance using SMOTE
- Logistic Regression model development
- Threshold optimization
- Model evaluation using multiple performance metrics

## Model Performance

| Metric | Training | Test |
|--------|---------:|------:|
| Accuracy | 0.679 | 0.641 |
| Precision | 0.679 | 0.248 |
| Recall | 0.680 | 0.631 |
| F1 Score | 0.679 | 0.356 |
| ROC-AUC | 0.749 | 0.643 |

## Key Insights

- **Age** was the strongest predictor of coronary heart disease risk.
- Daily cigarette consumption and biological sex were among the most influential risk factors.
- Multicollinearity between systolic and diastolic blood pressure was addressed by creating a **Pulse Pressure** feature.
- Class imbalance was handled using **SMOTE** after the train-test split to prevent data leakage.
- The model prioritizes **Recall**, ensuring that high-risk patients are less likely to be missed.

## Project Files

- **CHD Prediction.ipynb** – Complete Python notebook containing the analysis and machine learning workflow
- **CHD Prediction.pdf** – Project report with methodology, results, and visualizations
- **README.md** – Project documentation

## Getting Started

Clone or download this repository and open **CHD Prediction.ipynb** in Jupyter Notebook or Visual Studio Code to explore the complete analysis. For a concise overview of the methodology, model performance, and key findings, refer to the accompanying PDF report.
