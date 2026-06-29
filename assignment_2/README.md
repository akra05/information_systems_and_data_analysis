# Assignment 2 – SQL Queries (DQL)

## Task Description

17 SQL queries on a FIFA World Cup database (men's and women's tournaments) using **DuckDB**.

## Database Schema

| Table | Description |
|---|---|
| `Spieler` | Players with position flags (goalkeeper, defender, midfielder, forward) |
| `Spielerauftritte` | Player appearances per match with exact field position |
| `Mannschaften` | Teams with region, gender flags, and team code |
| `Schiedsrichter` | Referees linked to a confederation |
| `Konfoederationen` | Football confederations |
| `Tore` | Goals scored, linked to match, tournament, and player |
| `Spiele` | Matches with group stage flag |
| `Turniere` | Tournaments |

## Queries Overview

| # | Topic | Points |
|---|---|---|
| 1 | Male referees | 1 |
| 2 | Player counts by position (name starts with B), cast to INT128 | 1 |
| 3 | European teams | 1 |
| 4 | Goalkeepers who played tournaments | 1 |
| 5 | Players who played more than 3 positions | 1 |
| 6 | Teams with both men's and women's squad | 1 |
| 7 | Referee count per confederation | 1 |
| 8 | Players with more than 3 match appearances | 1 |
| 9 | Goals scored by defenders | 1 |
| 10 | Players in at least one group stage match | 1 |
| 11 | Average players per position per tournament | 1 |
| 12 | Tournaments with above-average goals scored | 2 |
| 13 | Goals per player per tournament (fewer than 2 tournaments) | 2 |
| 14 | Female players per region | 2 |
| 15 | Players with fewest goals per tournament | 2 |
| 16 | Players who scored in every tournament | 3 |
| 17 | Goals per player per tournament including zero-scorers (CTE + UNION ALL) | 3 |

## Result

All queries passed – **20/20 points**.