USE SCHEMA FINANCIAL_ANALYTICS.FRAUD_DETECTION;

CREATE OR REPLACE FUNCTION SCORE_TRANSACTION(
    AMT FLOAT,
    AMT_1HR FLOAT,
    COUNT_24HR FLOAT,
    HOUR_INT INT,
    NEW_MERCH_COUNT FLOAT,
    AMT_Z_SCORE FLOAT,
    CNP_RATIO FLOAT
)
RETURNS FLOAT
LANGUAGE PYTHON
RUNTIME_VERSION = 3.9
-- *** FIX: Updated joblib and pandas to supported, stable versions ***
PACKAGES = ('scikit-learn==1.3.0', 'joblib==1.2.0', 'pandas==1.5.3')
IMPORTS = ('@ML_MODELS_INTERNAL/models/isolation_forest_model_v1.joblib.gz') 
HANDLER = 'predict_anomaly'
AS
$$
import sys
import os
import joblib
import pandas as pd

MODEL_FILE = os.path.join(sys._xoptions['snowflake_import_directory'], 'isolation_forest_model_v1.joblib.gz')
MODEL = joblib.load(MODEL_FILE)

def predict_anomaly(amt, amt_1hr, count_24hr, hour_int, new_merch_count, amt_z_score, cnp_ratio):
    
    input_data = pd.DataFrame([[amt, amt_1hr, count_24hr, hour_int, new_merch_count, amt_z_score, cnp_ratio]],
                              columns=[
                                  'AMOUNT', 'AMT_1HR_ACCT', 'COUNT_24HR_ACCT', 'HOUR_OF_DAY',
                                  'NEW_MERCHANT_COUNT_7D', 'AMT_Z_SCORE_30D', 'CARD_PRESENT_RATIO_7D'
                              ])
    
    score = MODEL.decision_function(input_data)[0]
    return float(score)
$$;