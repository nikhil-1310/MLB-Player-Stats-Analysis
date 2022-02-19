-- Open db Group5
use ITOM6265_F21_Group5;

-- First step was creating tabla RawData with SQL Server Import Wizard
-- Next, we created our tables out of RawData

-- Table that contains MLB Players
SELECT DISTINCT Player, Team INTO MLB_Players
FROM RawData;

-- Table that contains MLB games information
SELECT DISTINCT Date, Team, Opponent, Result INTO MLB_Game
FROM RawData;

-- Table that contains performance indicators by each player per team
SELECT ID, Date, Team, PA, AB, R, H, _2B, _3B, HR, RBI, BB, SO, SB INTO PerformanceIndicators
FROM RawData;

-- Table that contains information of players per MLB Team
SELECT MLB_Players.Team, COUNT(ID) AS TotalPlayers INTO MLB_Team3
FROM MLB_Players, MLB_Team2
WHERE MLB_Players.Team = MLB_Team2.Team
GROUP BY MLB_Players.Team;

-- Test queries for R code/Shiny app
-- Query to show performance indicators per player by choosing team
SELECT MLB_Players.Player, SUM(PerformanceIndicators.R) AS Runs,
                    SUM(PerformanceIndicators.H) AS Hits,
                    SUM(PerformanceIndicators.AB) AS AtBats,
                    SUM(PerformanceIndicators.SO) AS Strikeouts
                    FROM PerformanceIndicators, MLB_Players
                    WHERE PerformanceIndicators.ID=MLB_Players.ID
                    and MLB_Players.Team LIKE '%ARI%'
                    GROUP BY MLB_Players.Player;

-- Query to show game scores by selected team
SELECT * 
FROM MLB_Game 
WHERE Team LIKE '%ARI%';

-- Query to insert new game score
INSERT INTO MLB_Game VALUES
					('2021-11-05','ARI','CHC','W 5-0');

-- Query to update game scores
UPDATE MLB_Game SET Result='L 0-2'
WHERE Date LIKE '%2021-11-05%' AND Team LIKE '%ARI%';

-- Query to remove game scores
DELETE FROM MLB_Game 
WHERE Date LIKE '%2020-11-05%' and Team like '%ARI%';

-- Queries for graphs showing total players and total wins per team in 2015-2021
-- 1st
SELECT *
FROM MLB_Team3;

-- 2nd
SELECT MLB_Team3.Team, COUNT(MLB_Game.Team) AS Wins 
FROM MLB_Team3, MLB_Game
WHERE MLB_Game.Team=MLB_Team3.Team AND MLB_Game.Result LIKE '%W%'
GROUP BY MLB_Team3.Team;
