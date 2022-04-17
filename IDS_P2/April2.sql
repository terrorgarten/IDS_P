
--DROP TABLES;

DROP TABLE PRODEJ CASCADE CONSTRAINTS;

DROP TABLE ZAMESTANEC CASCADE CONSTRAINTS;

DROP TABLE OBJEDNAVKA CASCADE CONSTRAINTS;

DROP TABLE POLOZKA CASCADE CONSTRAINTS;

DROP TABLE BALENI CASCADE CONSTRAINTS;

DROP TABLE LECIVO CASCADE CONSTRAINTS;

DROP TABLE POJISTOVNA CASCADE CONSTRAINTS;

DROP TABLE PREDPIS CASCADE CONSTRAINTS;

DROP TABLE PRISPIVA CASCADE CONSTRAINTS;

DROP TABLE VYDANA_POLOZKA;

---DROP TABLE E_RECEPT;

---DROP TABLE PAPIROVY;




--CREATE TABLE PRODEJ 

CREATE TABLE PRODEJ 
(
    ID_prodej INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Datum DATE NOT NULL,
    ID_zamestnance INT NOT NULL
);

CREATE TABLE ZAMESTANEC
(
    ID_zamestnance INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Jmeno CHAR(255) NOT NULL,
    Prijmeni CHAR(255) NOT NULL,
    Titul  CHAR(255) NULL,
    Datum_nastupu DATE NULL,
    Datum_propusteni DATE NULL 
);

CREATE TABLE OBJEDNAVKA
(
    ID_objednavky INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Jmeno_dodavatele CHAR(255) NOT NULL,
    Datum_obj DATE NULL,
    Datum_doruceni DATE NULL,
    Tvori INT NOT NULL,
    Prevzal INT NULL
);

CREATE TABLE POLOZKA 
(
    ID_polozky INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Pocet_polozka NUMBER(38,0) NOT NULL,
    ID_prodej INT NOT NULL,
    ID_baleni INT NOT NULL
);


CREATE TABLE BALENI
(
    ID_baleni INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Epirace DATE NULL,
    Pocet_baleni NUMBER(38,0) NOT NULL,
    ID_objednavky INT NOT NULL,
    Obchodni_nazev CHAR(255) NOT NULL
);

CREATE TABLE LECIVO
(
    Obchodni_nazev CHAR(255) PRIMARY KEY,
    Ucina_latka CHAR(255) NOT NULL,
    ID_leciva INT NOT NULL UNIQUE,
    Na_predpis NUMBER(1,0) NOT NULL CHECK(Na_predpis in (0, 1)),
    Pocet_v_baleni NUMBER(38,0) NOT NULL,
    Urceni CHAR(512) NULL,
    Cena NUMBER(38,0) NOT NULL,
    Doporuceny_vek NUMBER(4,0) NULL
);

CREATE TABLE POJISTOVNA
(
    Kod_pojistovny NUMBER(3,0) PRIMARY KEY,
    Kontakt CHAR(512) NULL
);

CREATE TABLE PREDPIS
(
    ID_receptu INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Vydavajici_lekar CHAR(255) NOT NULL,
    Pacient CHAR(255) NOT NULL,
    Typ NUMBER(1,0) NOT NULL CHECK(Typ in (0, 1)),
    --number = 0 --> e recept
    --number = 1 --> papir
    Kod_receptu NUMBER(38,0) NULL UNIQUE,
    Sken_receptu CHAR(512) NULL,

    CONSTRAINT check_erecept_positiv 
    CHECK( Typ = 1 OR Kod_receptu IS NOT NULL), 

    CONSTRAINT check_erecept_negativ
    CHECK( Typ = 0 OR Kod_receptu IS NULL),
    
    CONSTRAINT check_papir_positive
    CHECK( Typ = 0 OR Sken_receptu IS NOT NULL),
    
    CONSTRAINT check_papir_negative
    CHECK( Typ = 1 OR Sken_receptu IS NULL)
    --CHECK( Typ == 0 OR Kod_receptu IS NOT NULL )
);

CREATE TABLE PRISPIVA
(
    --ID_prispiva INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Castku NUMBER(38,0) NOT NULL,
    Obchodni_nazev CHAR(255) NOT NULL,
    Kod_pojistovny NUMBER(3,0) NOT NULL 
);

CREATE TABLE VYDANA_POLOZKA
(
    Prispevek NUMBER(38,0) NOT NULL,
    Kod_pojistovny NUMBER(3,0) NULL,
    ID_polozky INT NOT NULL,
    ID_receptu INT NOT NULL
);

--vazby

ALTER TABLE POLOZKA
ADD CONSTRAINT ID_prodej FOREIGN KEY (ID_prodej) REFERENCES PRODEJ;
-- chyby integritni omezeni ze prodej ma alespon jednu


ALTER TABLE PRODEJ
ADD CONSTRAINT ID_zamestnance FOREIGN KEY (ID_zamestnance) REFERENCES ZAMESTANEC;


ALTER TABLE OBJEDNAVKA
ADD CONSTRAINT Tvori FOREIGN KEY (Tvori) REFERENCES ZAMESTANEC(ID_zamestnance);


ALTER TABLE OBJEDNAVKA
ADD CONSTRAINT Prevzal FOREIGN KEY (Prevzal) REFERENCES ZAMESTANEC(ID_zamestnance);
-- chybi omezeni ze v objednavce je alespon jedna

ALTER TABLE BALENI
ADD CONSTRAINT ID_objednavky FOREIGN KEY (ID_objednavky) REFERENCES OBJEDNAVKA;

ALTER TABLE POLOZKA
ADD CONSTRAINT ID_baleni FOREIGN KEY (ID_baleni) REFERENCES BALENI;


ALTER TABLE BALENI
ADD CONSTRAINT Obchodni_nazev FOREIGN KEY (Obchodni_nazev) REFERENCES LECIVO;

ALTER TABLE PRISPIVA
ADD CONSTRAINT Kod_pojistovny FOREIGN KEY (Kod_pojistovny) REFERENCES POJISTOVNA;

ALTER TABLE PRISPIVA
ADD CONSTRAINT Obchodni_nazev2 FOREIGN KEY (Obchodni_nazev) REFERENCES LECIVO;
  
ALTER TABLE VYDANA_POLOZKA
ADD CONSTRAINT Kod_pojistovny2 FOREIGN KEY (Kod_pojistovny) REFERENCES POJISTOVNA;
 
ALTER TABLE VYDANA_POLOZKA
ADD CONSTRAINT ID_polozky FOREIGN KEY (ID_polozky) REFERENCES POLOZKA;

ALTER TABLE VYDANA_POLOZKA
ADD CONSTRAINT ID_receptu FOREIGN KEY (ID_receptu) REFERENCES PREDPIS;
-- chybi omezeni ze v receptu je alespon jedna

ALTER TABLE PRISPIVA
ADD CONSTRAINT FK_PRISPIVA PRIMARY KEY (Obchodni_nazev, Kod_pojistovny);

ALTER TABLE VYDANA_POLOZKA
ADD CONSTRAINT POINTER PRIMARY KEY (ID_polozky) ;


ALTER TABLE BALENI
ADD CONSTRAINT BaleniNezap CHECK (Pocet_baleni > 0);

ALTER TABLE LECIVO
ADD CONSTRAINT LecivoNezap CHECK (Pocet_v_baleni > 0 AND cena > 0);

ALTER TABLE PRISPIVA
ADD CONSTRAINT PrispivaNezap CHECK (Castku >= 0 );


ALTER TABLE VYDANA_POLOZKA
ADD CONSTRAINT VydanaPolozkaCheck CHECK (Prispevek >= 0 );


ALTER TABLE POJISTOVNA
ADD CONSTRAINT KodPojistovnyCheck CHECK (Kod_pojistovny > 99 );




--intgritni omezeni - zkontrolovat + 3 vyvorit(komenty)
--
--kontrolu spravnosti 
-- alespon jednoho atributu --BOhuzel ne kod pojistovny je nejspis 3 mistne cislo v desitkove soustave kontrolovat velikost cisel
--Zvzit jestli doplnit primarni klice do tabulek ve kterych nejsou

--predelat nazvy constrains


