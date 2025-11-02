-- Context: Ensure we are working in the correct schema
USE SCHEMA FINANCIAL_ANALYTICS.FRAUD_DETECTION;

CREATE OR REPLACE VIEW V_MODEL_FEATURES AS
WITH FirstMerchantUse AS (
    -- CONCEPT: Track first-time usage to identify rapid merchant acquisition (a fraud sign)
    SELECT
        ACCOUNT_ID,
        MERCHANTNAME,
        MIN(TRANSACTION_TS) AS FIRST_USE_TS
    FROM
        RAW_TRANSACTIONS
    GROUP BY 1, 2
),
RollingStats AS (
    -- CONCEPT: Calculate the customer's normal behavior using window functions
    SELECT
        t.*,
        -- Rolling 30-Day Mean and StdDev (for Z-Score)
        AVG(t.AMOUNT) OVER (
            PARTITION BY t.ACCOUNT_ID ORDER BY t.TRANSACTION_TS
            RANGE BETWEEN INTERVAL '30 DAY' PRECEDING AND CURRENT ROW
        ) AS MEAN_AMT_30D,
        STDDEV(t.AMOUNT) OVER (
            PARTITION BY t.ACCOUNT_ID ORDER BY t.TRANSACTION_TS
            RANGE BETWEEN INTERVAL '30 DAY' PRECEDING AND CURRENT ROW
        ) AS STDDEV_AMT_30D,

        -- Rolling 7-Day Counts (for Card-Present Ratio)
        COUNT(t.ACCOUNT_ID) OVER (
            PARTITION BY t.ACCOUNT_ID ORDER BY t.TRANSACTION_TS
            RANGE BETWEEN INTERVAL '7 DAY' PRECEDING AND CURRENT ROW
        ) AS TOTAL_COUNT_7D,
        -- Count Card-Not-Present (online) transactions
        COUNT(CASE WHEN t.CARD_PRESENT = FALSE THEN 1 END) OVER (
            PARTITION BY t.ACCOUNT_ID ORDER BY t.TRANSACTION_TS
            RANGE BETWEEN INTERVAL '7 DAY' PRECEDING AND CURRENT ROW
        ) AS CNP_COUNT_7D
    FROM
        RAW_TRANSACTIONS t
)
SELECT
    rs.ACCOUNT_ID,
    rs.TRANSACTION_TS,
    rs.AMOUNT, -- Raw Amount (Feature 1)
    
    -- Feature 2: Temporal (Hour of Day) - Fraud often occurs outside normal hours
    HOUR(rs.TRANSACTION_TS) AS HOUR_OF_DAY,

    -- Feature 3: Velocity (Total Amount in Last 1 Hour) - Measures sudden, high-value spending spikes
    SUM(rs.AMOUNT) OVER (
        PARTITION BY rs.ACCOUNT_ID ORDER BY rs.TRANSACTION_TS
        RANGE BETWEEN INTERVAL '1 HOUR' PRECEDING AND CURRENT ROW
    ) AS AMT_1HR_ACCT,

    -- Feature 4: Frequency (Count in Last 24 Hours) - Measures rapid, small transaction attempts
    COUNT(rs.ACCOUNT_ID) OVER (
        PARTITION BY rs.ACCOUNT_ID ORDER BY rs.TRANSACTION_TS
        RANGE BETWEEN INTERVAL '24 HOUR' PRECEDING AND CURRENT ROW
    ) AS COUNT_24HR_ACCT,

    -- Feature 5: Behavioral Shift (New Merchant Count 7D) - How many NEW merchants used recently
    SUM(CASE WHEN rs.TRANSACTION_TS = fmu.FIRST_USE_TS THEN 1 ELSE 0 END) OVER (
        PARTITION BY rs.ACCOUNT_ID ORDER BY rs.TRANSACTION_TS
        RANGE BETWEEN INTERVAL '7 DAY' PRECEDING AND CURRENT ROW
    ) AS NEW_MERCHANT_COUNT_7D,

    -- Feature 6: Deviation (30-Day Spending Z-Score) - How unusual the amount is relative to the customer's history
    (rs.AMOUNT - rs.MEAN_AMT_30D) / NULLIF(rs.STDDEV_AMT_30D, 0) AS AMT_Z_SCORE_30D,

    -- Feature 7: Methodology Change (Card-Not-Present Ratio 7D) - Shift from physical card use to online
    rs.CNP_COUNT_7D / NULLIF(rs.TOTAL_COUNT_7D, 0) AS CARD_PRESENT_RATIO_7D

FROM
    RollingStats rs
JOIN
    FirstMerchantUse fmu 
    ON rs.ACCOUNT_ID = fmu.ACCOUNT_ID AND rs.MERCHANTNAME = fmu.MERCHANTNAME;