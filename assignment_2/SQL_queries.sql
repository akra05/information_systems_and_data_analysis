-- ============================================================
-- Assignment 2 – SQL Queries (DQL)
-- FIFA World Cup Database (Men's & Women's)
-- Result: 20/20 points
-- ============================================================


-- Query 1 (1pt)
-- Male referees
-- Output: Schiedsrichter_ID (↓), Familienname, Vorname
SELECT Schiedsrichter_ID, Familienname, Vorname 
FROM Schiedsrichter
WHERE Weiblich = 0
ORDER BY Schiedsrichter_ID DESC
LIMIT 10;


-- Query 2 (1pt)
-- Count of goalkeepers, defenders, midfielders and forwards
-- whose first family name starts with B, cast to INT128
SELECT 
    CAST(COUNT(CASE WHEN Torhueter = 1 AND Familienname LIKE 'B%' THEN 1 END) AS INT128) AS "Anzahl Torhueter",
    CAST(COUNT(CASE WHEN Verteidiger = 1 AND Familienname LIKE 'B%' THEN 1 END) AS INT128) AS "Anzahl Verteidiger",
    CAST(COUNT(CASE WHEN Mittelfeldspieler = 1 AND Familienname LIKE 'B%' THEN 1 END) AS INT128) AS "Anzahl Mittelfeldspieler",
    CAST(COUNT(CASE WHEN Stuermer = 1 AND Familienname LIKE 'B%' THEN 1 END) AS INT128) AS "Anzahl Stuermer"
FROM Spieler;


-- Query 3 (1pt)
-- European teams
-- Output: Mannschafts_ID (↓), Mannschaftsname, Mannschaftscode
SELECT Mannschafts_ID, Mannschaftsname, Mannschaftscode
FROM Mannschaften
WHERE Regionname = 'Europe'
ORDER BY Mannschafts_ID DESC
LIMIT 10;


-- Query 4 (1pt)
-- Goalkeepers who played in at least one tournament
-- Output: Turnieranzahl (↓), Spieler_ID (↓), Familienname, Vorname
SELECT Turnieranzahl, Spieler_ID, Familienname, Vorname
FROM Spieler
WHERE Torhueter = 1 AND Turnieranzahl IS NOT NULL
ORDER BY Turnieranzahl DESC, Spieler_ID DESC
LIMIT 10;


-- Query 5 (1pt)
-- Players who played more than 3 positions, cast count to INT64
-- Output: Spieler_ID (↓), Familienname, Vorname, positions_played (↑)
SELECT Spieler_ID, Familienname, Vorname,
       CAST(4 AS INT64) AS positions_played
FROM Spieler
WHERE Torhueter = 1 AND Verteidiger = 1 AND Mittelfeldspieler = 1 AND Stuermer = 1
LIMIT 10;


-- Query 6 (1pt)
-- Teams with both a men's and a women's squad
-- Output: Mannschafts_ID (↑), Mannschaftsname, Mannschaftscode
SELECT Mannschafts_ID, Mannschaftsname, Mannschaftscode
FROM Mannschaften
WHERE Herrenmannschaft = 1 AND Damenmannschaft = 1
ORDER BY Mannschafts_ID ASC
LIMIT 10;


-- Query 7 (1pt)
-- Number of referees per confederation
-- Output: Konfoederationsname (↓), Anzahl an Schiedsrichter
SELECT Konfoederationsname,
       COUNT(Schiedsrichter.Schiedsrichter_ID) AS "Anzahl an Schiedsrichter"
FROM Konfoederationen
JOIN Schiedsrichter ON Konfoederationen.Konfoederations_ID = Schiedsrichter.Konfoederations_ID
GROUP BY Konfoederationsname
ORDER BY Konfoederationsname DESC;


-- Query 8 (1pt)
-- Players with more than 3 match appearances
-- Output: Spieler_ID (↓), Familienname, Vorname, Auftritte (↑)
SELECT Spieler.Spieler_ID, Familienname, Vorname,
       COUNT(Spielerauftritte.Spieler_ID) AS Auftritte
FROM Spieler
JOIN Spielerauftritte ON Spieler.Spieler_ID = Spielerauftritte.Spieler_ID
GROUP BY Spieler.Spieler_ID, Familienname, Vorname
HAVING COUNT(Spielerauftritte.Spieler_ID) > 3
ORDER BY Spieler.Spieler_ID DESC, COUNT(Spielerauftritte.Spieler_ID) ASC
LIMIT 10;


-- Query 9 (1pt)
-- Goals scored by defenders
-- Output: Spieler_ID (↓), Familienname, Vorname, scored_Tore (↓)
SELECT Spieler.Spieler_ID, Familienname, Vorname,
       COUNT(Tore.Spieler_ID) AS scored_Tore
FROM Spieler
JOIN Tore ON Spieler.Spieler_ID = Tore.Spieler_ID
WHERE Verteidiger = 1
GROUP BY Spieler.Spieler_ID, Familienname, Vorname
ORDER BY Spieler.Spieler_ID DESC, scored_Tore DESC
LIMIT 10;


-- Query 10 (1pt)
-- Players who appeared in at least one group stage match, no duplicates
-- Output: Spieler_ID (↓), Familienname, Vorname
SELECT DISTINCT Spieler.Spieler_ID, Familienname, Vorname
FROM Spieler
JOIN Spielerauftritte ON Spieler.Spieler_ID = Spielerauftritte.Spieler_ID
JOIN Spiele ON Spielerauftritte.Spiel_ID = Spiele.Spiel_ID
WHERE Spiele.Gruppenphase = 1
ORDER BY Spieler.Spieler_ID DESC
LIMIT 10;


-- Query 11 (1pt)
-- Average number of players per exact field position per tournament
-- Output: Positionscode (↑), Average
SELECT Positionscode,
       COUNT(Spieler_ID) / turnier_zahl AS Average
FROM Spielerauftritte
CROSS JOIN (
    SELECT COUNT(DISTINCT Turnier_ID) AS turnier_zahl
    FROM Spielerauftritte
)
GROUP BY Positionscode, turnier_zahl
ORDER BY Positionscode ASC
LIMIT 10;


-- Query 12 (2pt)
-- Tournaments with above-average goals scored (at least 1 goal)
-- Output: Turnier_ID (↓), Tore_scored
SELECT Turnier_ID, COUNT(*) AS Tore_scored
FROM Tore
CROSS JOIN (
    SELECT AVG(Tore_pro_Turnier) AS Average
    FROM (
        SELECT Turnier_ID, COUNT(*) AS Tore_pro_Turnier
        FROM Tore
        GROUP BY Turnier_ID
    ) AS Tore_pro_Turnier
) AS Durchschnitt_Tore
GROUP BY Turnier_ID, Average
HAVING COUNT(*) > Durchschnitt_Tore.Average
ORDER BY Turnier_ID DESC
LIMIT 10;


-- Query 13 (2pt)
-- Goals per player per tournament for players in fewer than 2 tournaments
-- Output: Spieler_ID (↓), Turniername (↑), Familienname, Vorname, scored_Tore (↑)
SELECT Spieler.Spieler_ID, Turniername, Familienname, Vorname,
       COUNT(Tore.*) AS scored_Tore
FROM Spieler
JOIN Tore ON Spieler.Spieler_ID = Tore.Spieler_ID
JOIN Turniere ON Tore.Turnier_ID = Turniere.Turnier_ID
WHERE Turnieranzahl < 2
GROUP BY Spieler.Spieler_ID, Familienname, Vorname, Turniername
ORDER BY Spieler.Spieler_ID DESC
LIMIT 10;


-- Query 14 (2pt)
-- Number of female players per region
-- Output: Regionname (↑), Anzahl
SELECT Regionname, COUNT(Spieler.Spieler_ID) AS Anzahl
FROM Spieler
JOIN Spielerauftritte ON Spieler.Spieler_ID = Spielerauftritte.Spieler_ID
JOIN Mannschaften ON Spielerauftritte.Mannschafts_ID = Mannschaften.Mannschafts_ID
WHERE Spieler.Weiblich = 1
GROUP BY Regionname
ORDER BY Regionname ASC
LIMIT 10;


-- Query 15 (2pt)
-- Players with the fewest goals per tournament (min. 1 goal, per tournament separately)
-- Output: Turnier_ID (↓), Spieler_ID (↓), scored_Tore
SELECT Turnier_ID, Spieler_ID, COUNT(*) AS scored_Tore
FROM Tore
GROUP BY Spieler_ID, Turnier_ID
HAVING COUNT(*) = (
    SELECT MIN(scored_Tore)
    FROM (
        SELECT Turnier_ID, Spieler_ID, COUNT(*) AS scored_Tore
        FROM Tore
        GROUP BY Turnier_ID, Spieler_ID
        HAVING COUNT(*) >= 1
    ) AS Min_Tore
)
ORDER BY Turnier_ID DESC, Spieler_ID DESC
LIMIT 10;


-- Query 16 (3pt)
-- Players who scored in every tournament (both men's and women's)
-- Output: Spieler_ID (↑), Familienname (↑), Vorname (↑)
WITH TotalTurniere AS (
    SELECT COUNT(DISTINCT Turnier_ID) AS total_turniere
    FROM Tore
),
SpielerTurniere AS (
    SELECT Spieler_ID, COUNT(DISTINCT Turnier_ID) AS turnier_tore
    FROM Tore
    GROUP BY Spieler_ID
)
SELECT Spieler.Spieler_ID, Spieler.Familienname, Spieler.Vorname
FROM Spieler
JOIN SpielerTurniere ON Spieler.Spieler_ID = SpielerTurniere.Spieler_ID
JOIN TotalTurniere ON SpielerTurniere.turnier_tore = TotalTurniere.total_turniere
ORDER BY Spieler.Spieler_ID ASC, Spieler.Familienname ASC, Spieler.Vorname ASC
LIMIT 10;


-- Query 17 (3pt)
-- Goals per player per tournament including zero-scorers
-- Uses CTE + UNION ALL: one branch for players with no goals, one for players with goals
-- Output: scored_Tore (↑), Spieler_ID (↓), Turnier_ID (↑)
WITH Keine_Tore AS (
    SELECT DISTINCT
        Spielerauftritte.Spieler_ID,
        Spielerauftritte.Turnier_ID,
        CAST(0 AS INT64) AS scored_Tore
    FROM Spielerauftritte
    LEFT JOIN Tore
        ON Spielerauftritte.Spieler_ID = Tore.Spieler_ID
        AND Spielerauftritte.Turnier_ID = Tore.Turnier_ID
    WHERE Tore.Spieler_ID IS NULL
),
Mit_Toren AS (
    SELECT DISTINCT
        Tore.Spieler_ID,
        Tore.Turnier_ID,
        CAST(COUNT(Tore.*) AS INT64) AS scored_Tore
    FROM Tore
    GROUP BY Tore.Spieler_ID, Tore.Turnier_ID
)
SELECT CAST(scored_Tore AS INT64) AS scored_Tore, Spieler_ID, Turnier_ID
FROM (
    SELECT Spieler_ID, Turnier_ID, scored_Tore FROM Keine_Tore
    UNION ALL
    SELECT Spieler_ID, Turnier_ID, scored_Tore FROM Mit_Toren
) AS combined
ORDER BY scored_Tore ASC, Spieler_ID DESC, Turnier_ID ASC
LIMIT 10;