-- ============================================================
-- Assignment 1.2 – Hotel Chain Database: Inspection & Modification
-- ============================================================

-- Inspect existing tables
SELECT * FROM Hotel;

-- ============================================================
-- Add salary column and populate based on collective agreement
-- ============================================================
ALTER TABLE MitarbeiterIn ADD COLUMN Gehalt UINTEGER;

UPDATE MitarbeiterIn
SET Gehalt = CASE   
    WHEN Abteilung = 'Sicherheit' THEN 2000
    WHEN Abteilung = 'Reinigung'  THEN 2200
    WHEN Abteilung = 'Rezeption'  THEN 2600
    WHEN Abteilung = 'Management' THEN 3200
    ELSE Gehalt 
END;

-- ============================================================
-- Create location table and normalize addresses
-- ============================================================
CREATE TABLE Ort(
    OrtID UUID PRIMARY KEY NOT NULL,
    Straße VARCHAR NOT NULL,
    Hausnummer VARCHAR NOT NULL,
    PLZ CHAR(5) CHECK (PLZ ~ '^[0-9]{5}$') NOT NULL,
    Stadt VARCHAR NOT NULL
);

-- ============================================================
-- Create ManagerIn table (separated from general employee table)
-- ============================================================
CREATE TABLE ManagerIn (
    PersID VARCHAR PRIMARY KEY CHECK (PersID ~ '^em3[0-9]{5}$') NOT NULL,
    Letzte_Fortbildung DATE,
    Nächste_Fortbildung DATE NOT NULL,
    Bonus DECIMAL(8,2) CHECK (Bonus >= 0 AND Bonus <= 100000) NOT NULL,
    CHECK (Letzte_Fortbildung < Nächste_Fortbildung),
    FOREIGN KEY (PersID) REFERENCES MitarbeiterIn(PersID)
);

-- ============================================================
-- Fix date format in MitarbeiterIn (DD.MM.YYYY → DATE)
-- ============================================================
ALTER TABLE MitarbeiterIn
    ALTER Angestellt_am SET DATA TYPE DATE
    USING CAST((SUBSTR(Angestellt_am, 7, 4) || '-' || SUBSTR(Angestellt_am, 4, 2) || '-' || SUBSTR(Angestellt_am, 1, 2)) AS DATE);

-- ============================================================
-- Insert manager records (from handwritten list)
-- ============================================================
INSERT INTO ManagerIn VALUES('em300003', '2023-10-21', '2024-06-12', 936.50);
INSERT INTO ManagerIn VALUES('em300004', '2024-01-13', '2024-09-02', 0);
INSERT INTO ManagerIn VALUES('em300011', '2023-11-14', '2024-06-12', 1500);
INSERT INTO ManagerIn VALUES('em300013', '2024-01-13', '2024-09-02', 345.78);
INSERT INTO ManagerIn VALUES('em300016', '2023-11-14', '2024-07-27', 0);
INSERT INTO ManagerIn VALUES('em300021', '2024-01-13', '2024-07-27', 0);

-- Remove terminated employee (T.T. per todo list)
DELETE FROM MitarbeiterIn WHERE PersID = 'em300025';

-- ============================================================
-- Fix column name in Hotel table
-- ============================================================
ALTER TABLE Hotel RENAME Column_5 TO 'Anz_Zimmer';

-- ============================================================
-- Insert locations and migrate Hotel table to use OrtID
-- ============================================================
INSERT INTO Ort VALUES ('32253edd-9354-4807-9a9f-4d77ac4924b4', 'Albrechtstraße',    '5',   '10117', 'Berlin');
INSERT INTO Ort VALUES ('f9430ecb-6ab9-4b0a-a9f1-1bf278884162', 'Müllerstraße',      '151a', '13353', 'Berlin');
INSERT INTO Ort VALUES ('0db9f3b9-86c9-4b2e-af42-5ed36fed6683', 'Bjoernsonstraße',   '10',  '10439', 'Berlin');
INSERT INTO Ort VALUES ('013acbae-186a-4d98-aeb1-50e6c838317d', 'Willy-Brandt-Platz', '3',  '81829', 'München');
INSERT INTO Ort VALUES ('f7094127-6463-4e21-9165-6eb3a8c15a62', 'Albrechtstraße',    '13',  '80636', 'München');

ALTER TABLE Hotel DROP COLUMN Adresse;
ALTER TABLE Hotel ADD COLUMN OrtID UUID;

-- Two hotels share the same address (HotelID 1002 & 1003)
UPDATE Hotel SET OrtID = '32253edd-9354-4807-9a9f-4d77ac4924b4' WHERE HotelID = 1001;
UPDATE Hotel SET OrtID = 'f9430ecb-6ab9-4b0a-a9f1-1bf278884162' WHERE HotelID = 1002;
UPDATE Hotel SET OrtID = 'f9430ecb-6ab9-4b0a-a9f1-1bf278884162' WHERE HotelID = 1003;
UPDATE Hotel SET OrtID = '0db9f3b9-86c9-4b2e-af42-5ed36fed6683' WHERE HotelID = 1004;
UPDATE Hotel SET OrtID = '013acbae-186a-4d98-aeb1-50e6c838317d' WHERE HotelID = 1005;
UPDATE Hotel SET OrtID = 'f7094127-6463-4e21-9165-6eb3a8c15a62' WHERE HotelID = 1006;