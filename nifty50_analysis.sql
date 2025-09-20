create database nifty_analysis;
use nifty_analysis;
CREATE TABLE nifty_50 (
  Date DATE,
  Symbol VARCHAR(50),
  Series VARCHAR(10),
  Prev_Close DECIMAL(12,2),
  Open DECIMAL(12,2),
  High DECIMAL(12,2),
  Low DECIMAL(12,2),
  Last DECIMAL(12,2),
  Close DECIMAL(12,2),
  VWAP DECIMAL(14,4),
  Volume BIGINT,
  Turnover DECIMAL(25,2)
);
select * from nifty_50;
-- Remove rows with missing essential values---
DELETE FROM nifty_50
WHERE Date IS NULL
   OR Symbol IS NULL
   OR series IS NULL
   or  Prev_Close is null
   or Open is null
   or High is null
   or Low is null
   or Last is null
   or Close is null
   or VWAP is null
   or Volume is null
   or Turnover is null;
SET SQL_SAFE_UPDATES = 0;   
ALTER TABLE nifty_50 DROP COLUMN id;

ALTER TABLE nifty_50 
ADD id INT primary key auto_increment FIRST;

SELECT *
FROM nifty_50
ORDER BY row_id;

SELECT *
FROM nifty_50
ORDER BY Symbol;
select * from nifty_50;
SELECT COUNT(*) AS TotalRows
FROM nifty_50;

SELECT Symbol, COUNT(*) AS RowCount
FROM nifty_50
GROUP BY Symbol
ORDER BY Symbol;










