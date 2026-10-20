# China City Carbon Emissions 1997–2023: Code

This repository contains code accompanying the article “City-level CO₂ emission inventories in China over 1997–2023”. When using this code, please cite:

Xu, J., Cai, S., Shan, Y., Guan, Y., Li, R., Zhang, H., Liu, M., Bi, J., Oldfield, J., Li, Y., Zhou, Y. & Guan, D. City-level CO₂ emission inventories in China over 1997–2023. *Nature Sustainability* (2026).


## Contents

| File | Description |

| `01_IPCC_Inventory_Construction.R` | Simplified calculation functions for energy-related emissions, cement process emissions and inventory totals. |
| `02_Monte_Carlo_uncertainty.m` | Monte Carlo uncertainty analysis of energy-related CO₂ emissions, excluding cement process emissions. |
| `03_LOF_anomaly_detection.py` | Screening of sectoral emission records using Local Outlier Factor (LOF). |
| `04_Random_forest_tuning_and_interval_prediction.R` | Random forest hyperparameter tuning and prediction interval estimation. |
| `05_Emission_correction_and_point_prediction.R` | Correction of high-uncertainty emission records and prediction of missing emissions. |
| `06_Kmeans_city_classification.R` | Two-stage K-means classification using GDP shares and sectoral employment shares. |


## Software and packages

- **R 4.3.0**: Inventory calculation and city classification use built-in R functions. Random forest scripts use `dplyr`, `mlr3`, `mlr3tuning`, `mlr3learners`, `paradox`, `ranger` and `RFpredInterval`.
- **Python 3.9.13**: LOF anomaly detection uses `numpy`, `pandas`, `pyod` and `scikit-learn`.
- **MATLAB R2026a**: Monte Carlo simulations require Statistics and Machine Learning Toolbox.
