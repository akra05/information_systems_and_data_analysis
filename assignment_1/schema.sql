CREATE TABLE Ärzt_in (
    LANR CHAR(9) NOT NULL CHECK(LENGTH(LANR)=9) ,
    Fachgebiet VARCHAR  NOT NULL,  
    Name STRUCT(Titel VARCHAR, Vorname VARCHAR, Nachname VARCHAR) NOT NULL,  
    Sprachen VARCHAR[] NOT NULL,  
    Geburtsdatum DATE NOT NULL,
    Primary Key(LANR),
    
    CHECK (Geburtsdatum > '1956-05-17')
);
CREATE TABLE Diagnose (
    ICD CHAR(3) NOT NULL CHECK(LENGTH(ICD)=3),
    Zusatzinformation CHAR(1) NOT NULL,
    CHECK (Zusatzinformation IN ('G','V','A','L','R','B') ),
    Beschreibung VARCHAR,
    Primary Key(ICD)
);
CREATE TABLE Gesundheitseinrichtung(
    SteuerID CHAR(11) NOT NULL CHECK(SteuerID SIMILAR TO 'DE[0-9]{9}'),
    Name VARCHAR NOT NULL,
    Adresse VARCHAR NOT NULL,
    Bundesland CHAR(5) NOT NULL CHECK(Bundesland IN('DE-BW', 'DE-BY', 'DE-BE', 'DE-BB', 'DE-HB', 'DE-HH', 'DE-HE', 'DE-MV', 'DE-NI', 'DE-NW', 'DE-RP', 'DE-SL', 'DE-SN', 'DE-ST', 'DE-SH', 'DE-TH')),
    Umsatz DECIMAL(15,2) NOT NULL CHECK(Umsatz <= 9999999999999.99),
    Betten USMALLINT CHECK(Betten <= 1500),
    Bettenauslastung FLOAT CHECK(Bettenauslastung BETWEEN 0 AND 1),
    ist_Universitätsklinikum BOOLEAN,
    ist_privatisiert BOOLEAN,
    Fachrichtung VARCHAR,
    Zahlungsart VARCHAR CHECK(Zahlungsart IN ('Versichert', 'Selbstzahler')),
    Typ VARCHAR NOT NULL CHECK(Typ IN('Krankenhaus','Privatpraxis', 'Gesundheitseinrichtung')),
    CHECK (
      (Typ = 'Krankenhaus' AND Betten IS NOT NULL AND Bettenauslastung IS NOT NULL AND ist_Universitätsklinikum IS NOT NULL AND ist_privatisiert IS NOT NULL AND Fachrichtung IS NULL AND Zahlungsart IS NULL) 
      OR
      (Typ = 'Privatpraxis' AND Betten IS NULL AND Bettenauslastung IS NULL AND ist_Universitätsklinikum IS NULL AND ist_privatisiert IS NULL AND Fachrichtung IS NOT NULL AND Zahlungsart IS NOT NULL) 
      OR
      (Typ = 'Gesundheitseinrichtung' AND Betten IS NULL AND Bettenauslastung IS NULL AND ist_Universitätsklinikum IS NULL AND ist_privatisiert IS NULL AND Fachrichtung IS NULL AND Zahlungsart IS NULL)
    ),
    PRIMARY KEY(Name,SteuerID)
);
CREATE TABLE angestellt (
    Einstellungsdatum DATE NOT NULL,
    Gehalt DECIMAL(7,2) NOT NULL CHECK(Gehalt >= 5288.32 AND Gehalt <= 11019.20),
    SteuerID CHAR(11) NOT NULL,
    Name VARCHAR NOT NULL,
    LANR CHAR(9) NOT NULL CHECK(LENGTH(LANR) = 9),
    PRIMARY KEY (LANR,SteuerID,Name),
    FOREIGN KEY (LANR) REFERENCES Ärzt_in,
    FOREIGN KEY (Name,SteuerID) REFERENCES Gesundheitseinrichtung(Name,SteuerID),
    CHECK (
        NOT (
            (MONTH(Einstellungsdatum) = 1 AND DAY(Einstellungsdatum) = 1) OR
            (MONTH(Einstellungsdatum) = 3 AND DAY(Einstellungsdatum) = 8) OR
            (MONTH(Einstellungsdatum) = 5 AND DAY(Einstellungsdatum) = 1) OR
            (MONTH(Einstellungsdatum) = 10 AND DAY(Einstellungsdatum) = 3) OR
            (MONTH(Einstellungsdatum) = 12 AND DAY(Einstellungsdatum) = 25) OR
            (MONTH(Einstellungsdatum) = 12 AND DAY(Einstellungsdatum) = 26)
        )
    )
);
CREATE SEQUENCE TerminID MAXVALUE 3000000;
CREATE TABLE Termin(
    ID UINTEGER DEFAULT NEXTVAL('TerminID'),
    LANR CHAR(9) NOT NULL,
    Zeitpunkt TIMESTAMP NOT NULL,
    Zusatzgebühren DECIMAL(5,2) DEFAULT 0 NOT NULL CHECK(Zusatzgebühren>=0 AND Zusatzgebühren<=500),
    ist_Neupatient_in BOOLEAN NOT NULL,
    FOREIGN KEY (LANR) REFERENCES Ärzt_in(LANR), 
    PRIMARY KEY (ID),
    UNIQUE(LANR,Zeitpunkt)
);
CREATE TABLE Patient_in(
    Versichertennummer CHAR(10) CHECK(LENGTH(Versichertennummer)=10),
    Name STRUCT(Titel VARCHAR, Vorname VARCHAR, Nachname VARCHAR) NOT NULL,
    Geburtsdatum DATE NOT NULL,
    Beschäftigung VARCHAR,
    Geschlecht CHAR(1) CHECK(LENGTH(Geschlecht)=1 OR Geschlecht = NULL),
    CHECK (Geschlecht IN ('d','w','m') ),
    PRIMARY KEY (Versichertennummer),
    CHECK (
        SUBSTRING(Versichertennummer FROM 1 FOR 1) BETWEEN 'A' AND 'Z' AND
        SUBSTRING(Versichertennummer FROM 2 FOR 9) BETWEEN '0' AND '9'
    )
);
CREATE TABLE stellt (
    LANR CHAR(9) NOT NULL,
    ICD CHAR(3) NOT NULL,
    Zeitpunkt TIMESTAMP NOT NULL,
    FOREIGN KEY (LANR) REFERENCES Ärzt_in(LANR),
    FOREIGN KEY (ICD) REFERENCES Diagnose(ICD),
    PRIMARY KEY (ICD, LANR),
    UNIQUE (Zeitpunkt,LANR)
);
CREATE TABLE hat (
    Versichertennummer CHAR(10) NOT NULL,
    ICD CHAR(3),
    ID UINTEGER,
    FOREIGN KEY (ID) REFERENCES Termin(ID),
    FOREIGN KEY (Versichertennummer) REFERENCES Patient_in(Versichertennummer),
    FOREIGN KEY (ICD) REFERENCES Diagnose(ICD),
    PRIMARY KEY (ICD, ID)
);
CREATE TABLE "OP-Saal" (
    Raumnummer UTINYINT NOT NULL CHECK(Raumnummer<=20),
    Name VARCHAR NOT NULL,
    SteuerID CHAR(11) NOT NULL,
    FOREIGN KEY (Name,SteuerID) REFERENCES Gesundheitseinrichtung(Name,SteuerID),
    PRIMARY KEY (Raumnummer, Name,SteuerID)
);
CREATE TABLE OP(
    Nummer UUID NOT NULL,
    Dringlichkeit VARCHAR NOT NULL CHECK(Dringlichkeit IN('Notoperation', 'dringliche Operation', 'frühelektive Operation','elektive Operation' )),
    ist_Vollnarkose BOOLEAN NOT NULL,
    Versichertennummer CHAR(10),
    Datum DATE NOT NULL,
    Startzeit TIME NOT NULL,
    Endzeit TIME NOT NULL,
    Raumnummer UTINYINT NOT NULL,
    SteuerID CHAR(11) NOT NULL,
    Name VARCHAR NOT NULL,
    CHECK (Endzeit > (Startzeit + INTERVAL '15' MINUTES) AND Endzeit <= (Startzeit + INTERVAL '9' HOUR)),
    FOREIGN KEY (Raumnummer,Name,SteuerID) REFERENCES "OP-Saal"(Raumnummer,Name,SteuerID),
    FOREIGN KEY (Versichertennummer) REFERENCES Patient_in(Versichertennummer),
    PRIMARY KEY(Nummer)
);