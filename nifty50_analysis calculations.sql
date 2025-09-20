------------------------------------------------------------
-- 1. BASIC PERFORMANCE TRENDS
------------------------------------------------------------

-- 1.1 Daily Returns (% change in Close price from previous day)
WITH daily_returns AS (
    SELECT
        Symbol,
        Date,
        Close,
        ( (Close - LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date)) 
          / LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date) ) * 100 AS Daily_Return_Percent
    FROM nifty_50
)
SELECT * FROM daily_returns;

-- 1.2 Monthly average return & volatility (risk)
WITH daily_returns AS (
    SELECT
        Symbol,
        Date,
        ( (Close - LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date)) 
          / LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date) ) * 100 AS Daily_Return_Percent
    FROM nifty_50
)
SELECT
    Symbol,
    DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
    AVG(Daily_Return_Percent) AS Avg_Monthly_Return,
    STDDEV(Daily_Return_Percent) AS Monthly_Volatility
FROM daily_returns
GROUP BY Symbol, YearMonth
ORDER BY Symbol, YearMonth;

-- 1.3 Best/Worst performing stocks (overall)
WITH daily_returns AS (
    SELECT
        Symbol,
        Date,
        ( (Close - LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date)) 
          / LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date) ) * 100 AS Daily_Return_Percent
    FROM nifty_50
)
SELECT
    Symbol,
    AVG(Daily_Return_Percent) AS Avg_Return
FROM daily_returns
GROUP BY Symbol
ORDER BY Avg_Return DESC;
------------------------------------------------------------


------------------------------------------------------------
-- 2. VOLUME & LIQUIDITY INSIGHTS
------------------------------------------------------------

-- 2.1 Which stocks trade the highest volumes (monthly)
SELECT
    Symbol,
    DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
    SUM(Volume) AS Total_Volume
FROM nifty_50
GROUP BY Symbol, YearMonth
ORDER BY Total_Volume DESC;

-- 2.2 Which stocks attract the most money flow (Turnover)
SELECT
    Symbol,
    DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
    SUM(Turnover) AS Total_Turnover
FROM nifty_50
GROUP BY Symbol, YearMonth
ORDER BY Total_Turnover DESC;

-- 2.3 Daily/Monthly average traded volume
SELECT
    Symbol,
    DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
    AVG(Volume) AS Avg_Daily_Volume
FROM nifty_50
GROUP BY Symbol, YearMonth
ORDER BY Avg_Daily_Volume DESC;
------------------------------------------------------------


------------------------------------------------------------
-- 3. VOLATILITY ANALYSIS
------------------------------------------------------------

-- 3.1 Daily High-Low spread % as volatility indicator
SELECT
    Symbol,
    Date,
    ((High - Low) / Low) * 100 AS Daily_Volatility_Percent
FROM nifty_50
ORDER BY Symbol, Date;

-- 3.2 Compare volatility of top 5 stocks (by average volatility)
WITH vol_data AS (
    SELECT
        Symbol,
        ((High - Low) / Low) * 100 AS Daily_Volatility_Percent
    FROM nifty_50
)
SELECT
    Symbol,
    AVG(Daily_Volatility_Percent) AS Avg_Volatility
FROM vol_data
GROUP BY Symbol
ORDER BY Avg_Volatility DESC
limit 5;

------------------------------------------------------------


------------------------------------------------------------
-- 4. STOCK RANKING & COMPARISON
------------------------------------------------------------

-- 4.1 Top 5 gainers and losers each month
WITH monthly_returns AS (
    SELECT
        Symbol,
        DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
        (MAX(Close) - MIN(Close)) / MIN(Close) * 100 AS Monthly_Return_Percent
    FROM nifty_50
    GROUP BY Symbol, YearMonth
)
SELECT *
FROM (
    SELECT 
        Symbol,
        YearMonth,
        Monthly_Return_Percent,
        RANK() OVER (PARTITION BY YearMonth ORDER BY Monthly_Return_Percent DESC) AS Gainer_Rank,
        RANK() OVER (PARTITION BY YearMonth ORDER BY Monthly_Return_Percent ASC) AS Loser_Rank
    FROM monthly_returns
) ranked
WHERE Gainer_Rank <= 5 OR Loser_Rank <= 5
ORDER BY YearMonth, Gainer_Rank, Loser_Rank;
-- best stock---
WITH yearly_returns AS (
    SELECT
        Symbol,
        YEAR(Date) AS Year,
        (MAX(Close) - MIN(Close)) / MIN(Close) * 100 AS Yearly_Return
    FROM nifty_50
    GROUP BY Symbol, Year
)
SELECT *
FROM yearly_returns
WHERE Year = (SELECT MAX(YEAR(Date)) FROM nifty_50)
ORDER BY Yearly_Return DESC
LIMIT 1;

-- stock the wrost---
WITH yearly_returns AS (
    SELECT
        Symbol,
        YEAR(Date) AS Year,
        (MAX(Close) - MIN(Close)) / MIN(Close) * 100 AS Yearly_Return
    FROM nifty_50
    GROUP BY Symbol, Year
)
SELECT *
FROM yearly_returns
WHERE Year = (SELECT MAX(YEAR(Date)) FROM nifty_50)
ORDER BY Yearly_Return ASC
LIMIT 1;

------------------------------------------------------------


------------------------------------------------------------
-- 5. TIME-BASED INSIGHTS
------------------------------------------------------------

-- 5.1 Best performing year/month for each stock
WITH monthly_returns AS (
    SELECT
        Symbol,
        DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
        (MAX(Close) - MIN(Close)) / MIN(Close) * 100 AS Monthly_Return
    FROM nifty_50
    GROUP BY Symbol, YearMonth
)
SELECT *
FROM (
    SELECT
        Symbol,
        YearMonth,
        Monthly_Return,
        RANK() OVER (PARTITION BY Symbol ORDER BY Monthly_Return DESC) AS Best_Month_Rank
    FROM monthly_returns
) ranked
WHERE Best_Month_Rank = 1;

-- 5.2 Seasonal trends (average return by month number across years)
WITH monthly_returns AS (
    SELECT
        Symbol,
        MONTH(Date) AS Month_No,
        (MAX(Close) - MIN(Close)) / MIN(Close) * 100 AS Monthly_Return
    FROM nifty_50
    GROUP BY Symbol, YEAR(Date), MONTH(Date)
)
SELECT
    Symbol,
    Month_No,
    AVG(Monthly_Return) AS Avg_Seasonal_Return
FROM monthly_returns
GROUP BY Symbol, Month_No
ORDER BY Symbol, Month_No;
------------------------------------------------------------






WITH daily_returns AS (
    SELECT
        Symbol,
        Date,
        ( (Close - LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date)) 
          / LAG(Close) OVER (PARTITION BY Symbol ORDER BY Date) ) * 100 AS Daily_Return_Percent,
        Volume,
        Turnover,
        ((High - Low) / Low) * 100 AS Daily_Volatility_Percent
    FROM nifty_50
),
monthly_stats AS (
    SELECT
        Symbol,
        DATE_FORMAT(Date, '%Y-%m') AS YearMonth,
        AVG(Daily_Return_Percent) AS Avg_Monthly_Return,
        AVG(Volume) AS Avg_Monthly_Volume,
        AVG(Turnover) AS Avg_Monthly_Turnover,
        AVG(Daily_Volatility_Percent) AS Avg_Monthly_Volatility
    FROM daily_returns
    GROUP BY Symbol, YearMonth
)
SELECT
    Symbol,
    YearMonth,
    ROUND(Avg_Monthly_Return,2) AS Avg_Return,
    ROUND(Avg_Monthly_Volume,0) AS Avg_Volume,
    ROUND(Avg_Monthly_Turnover,2) AS Avg_Turnover,
    ROUND(Avg_Monthly_Volatility,2) AS Avg_Volatility
FROM monthly_stats
WHERE Avg_Monthly_Return > 0        -- positive returns
  AND Avg_Monthly_Volume > (SELECT AVG(Volume) FROM nifty_50)  -- higher than avg liquidity
  AND Avg_Monthly_Turnover > (SELECT AVG(Turnover) FROM nifty_50) 
  AND Avg_Monthly_Volatility < (SELECT AVG(((High - Low)/Low)*100) FROM nifty_50) -- lower than avg risk
ORDER BY Avg_Return DESC, Avg_Volume DESC, Avg_Turnover DESC
limit 10;


