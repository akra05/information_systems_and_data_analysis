# Assignment 1 – Database Design & Modification

## Part 1 – TU Berlin Health Insurance Database

### Task Description

Database administration for a fictional health insurance company at TU Berlin.  
Goal: Design a DuckDB database for managing patient and physician data based on a given EER diagram.

![EER Diagram](eer_diagramm.png)

### Implementation

The schema was fully implemented in DuckDB SQL (`schema.sql`).

#### Tables

| Table | Description |
|---|---|
| `Ärzt_in` | Physician directory with LANR, specialty, languages (array), name (struct) |
| `Diagnose` | ICD codes with additional classification and optional description |
| `Gesundheitseinrichtung` | Hospital, private practice, or facility using the **null style** (type discriminator) |
| `angestellt` | m:n relationship physician ↔ facility with salary & hire date |
| `Termin` | Sequentially assigned IDs, unique constraint on (LANR, timestamp) |
| `Patient_in` | Insurance number with structural check (1 letter + 9 digits) |
| `stellt` | Diagnosis issued by a physician – unique on (timestamp, LANR) |
| `hat` | Link between patient ↔ diagnosis ↔ appointment |
| `OP-Saal` | Max 20 operating rooms per hospital, numbered from 0 |
| `OP` | UUID as primary key, duration between 15 min and 9 hours |

#### Notable Design Decisions

- **Generalization `Gesundheitseinrichtung`** in null style: A `Typ` attribute discriminates between `Krankenhaus`, `Privatpraxis`, and `Gesundheitseinrichtung`. A `CHECK` constraint ensures only type-relevant attributes are populated.
- **Complex DuckDB types**: `Name` as `STRUCT`, `Sprachen` as `VARCHAR[]`
- **Sequence `TerminID`** with `MAXVALUE 3000000` for automatic appointment IDs
- **Public holiday constraint** in `angestellt`: Hires on 6 German public holidays are blocked
- **Age limit** in `Ärzt_in`: Reference date 17.05.2024, only physicians younger than 68 years

### Result

All tests passed – **8/8 points**.

---

## Part 2 – Hotel Chain Database

### Task Description

Inspection and extension of an incomplete DuckDB database for a hotel chain.  
Goal: Add missing tables, correct existing data, and normalize the schema.

### Changes Made

#### 1. Salary (Collective Agreement)
- Added new attribute `Gehalt` (UINTEGER) to the `MitarbeiterIn` table
- Values set by department: Security 2000 €, Cleaning 2200 €, Reception 2600 €, Management 3200 €

#### 2. Address Normalization
- New table `Ort` with `OrtID` (UUID), `Straße`, `Hausnummer`, `PLZ` (regex check `^[0-9]{5}$`), `Stadt`
- Removed `Adresse` column from `Hotel`, replaced with `OrtID` (FK)
- Two hotels share an address (HotelID 1002 & 1003 → same UUID) – redundancy correctly eliminated

#### 3. Manager Table
- New table `ManagerIn` with `Letzte_Fortbildung` (nullable), `Nächste_Fortbildung` (NOT NULL), `Bonus`
- CHECK: `Letzte_Fortbildung < Nächste_Fortbildung`
- FK on `MitarbeiterIn(PersID)`
- 6 managers inserted from handwritten list

#### 4. Data Corrections
- Converted `Angestellt_am` from string (`DD.MM.YYYY`) to `DATE`
- Renamed column `Column_5` to `Anz_Zimmer`
- Deleted terminated employee `em300025`

### Result

All tests passed – **7/7 points**.