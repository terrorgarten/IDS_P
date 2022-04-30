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


--##################### SEKCE TVORBY TABULEK PRO 2. ODEVZDÁNÍ  ##########################

CREATE TABLE PRODEJ
(
    ID_prodej      INT DEFAULT NULL PRIMARY KEY, --tento identifikátor se autoinkrementuje přes demonstrační trigger
    Datum          DATE NOT NULL,
    ID_zamestnance INT  NOT NULL
);

CREATE TABLE ZAMESTANEC
(
    ID_zamestnance   INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Jmeno            CHAR(255)                 NOT NULL,
    Prijmeni         CHAR(255)                 NOT NULL,
    Titul            CHAR(255)                 NULL,
    Datum_nastupu    DATE                      NULL,
    Datum_propusteni DATE                      NULL
);

CREATE TABLE OBJEDNAVKA
(
    ID_objednavky    INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Jmeno_dodavatele CHAR(255)                 NOT NULL,
    Datum_obj        DATE                      NULL,
    Datum_doruceni   DATE                      NULL,
    Tvori            INT                       NOT NULL,
    Prevzal          INT                       NULL
);

CREATE TABLE POLOZKA
(
    ID_polozky    INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Pocet_polozka NUMBER(38, 0)             NOT NULL,
    ID_prodej     INT                       NOT NULL,
    ID_baleni     INT                       NOT NULL
);


CREATE TABLE BALENI
(
    ID_baleni      INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Epirace        DATE                      NULL,
    Pocet_baleni   NUMBER(38, 0)             NOT NULL,
    ID_objednavky  INT                       NOT NULL,
    Obchodni_nazev CHAR(255)                 NOT NULL
);

CREATE TABLE LECIVO
(
    Obchodni_nazev CHAR(255) PRIMARY KEY,
    Ucina_latka    CHAR(255)     NOT NULL,
    ID_leciva      INT           NOT NULL UNIQUE,
    Na_predpis     NUMBER(1, 0)  NOT NULL CHECK (Na_predpis in (0, 1)),
    Pocet_v_baleni NUMBER(38, 0) NOT NULL,
    Urceni         CHAR(512)     NULL,
    Cena           NUMBER(38, 0) NOT NULL,
    Doporuceny_vek NUMBER(4, 0)  NULL
);

CREATE TABLE POJISTOVNA
(
    Kod_pojistovny NUMBER(3, 0) PRIMARY KEY,
    Kontakt        CHAR(512) NULL
);

CREATE TABLE PREDPIS
(
    ID_receptu       INT GENERATED AS IDENTITY NOT NULL PRIMARY KEY,
    Vydavajici_lekar CHAR(255)                 NOT NULL,
    Pacient          CHAR(255)                 NOT NULL,
    Typ              NUMBER(1, 0)              NOT NULL CHECK (Typ in (0, 1)),
    --number = 0 --> e recept
    --number = 1 --> papir
    Kod_receptu      NUMBER(38, 0)             NULL UNIQUE,
    Sken_receptu     CHAR(512)                 NULL,

    CONSTRAINT check_erecept_positiv
        CHECK ( Typ = 1 OR Kod_receptu IS NOT NULL),

    CONSTRAINT check_erecept_negativ
        CHECK ( Typ = 0 OR Kod_receptu IS NULL),

    CONSTRAINT check_papir_positive
        CHECK ( Typ = 0 OR Sken_receptu IS NOT NULL),

    CONSTRAINT check_papir_negative
        CHECK ( Typ = 1 OR Sken_receptu IS NULL)

);

CREATE TABLE PRISPIVA
(
    Castku         NUMBER(38, 0) NOT NULL,
    Obchodni_nazev CHAR(255)     NOT NULL,
    Kod_pojistovny NUMBER(3, 0)  NOT NULL
);

CREATE TABLE VYDANA_POLOZKA
(
    Prispevek      NUMBER(38, 0) NOT NULL,
    Kod_pojistovny NUMBER(3, 0)  NULL,
    ID_polozky     INT           NOT NULL,
    ID_receptu     INT           NOT NULL
);

--vazby

ALTER TABLE POLOZKA
    ADD CONSTRAINT POLOZKA_ID_prodejFK FOREIGN KEY (ID_prodej) REFERENCES PRODEJ;


ALTER TABLE PRODEJ
    ADD CONSTRAINT PRODEJ_ID_zamestnanceFK FOREIGN KEY (ID_zamestnance) REFERENCES ZAMESTANEC;


ALTER TABLE OBJEDNAVKA
    ADD CONSTRAINT OBJEDNAVKA_Tvori FOREIGN KEY (Tvori) REFERENCES ZAMESTANEC (ID_zamestnance);


ALTER TABLE OBJEDNAVKA
    ADD CONSTRAINT OBJEDNAVKA_Prevzal FOREIGN KEY (Prevzal) REFERENCES ZAMESTANEC (ID_zamestnance);


ALTER TABLE BALENI
    ADD CONSTRAINT BALENI_ID_objednavky FOREIGN KEY (ID_objednavky) REFERENCES OBJEDNAVKA;

ALTER TABLE POLOZKA
    ADD CONSTRAINT POLOZKA_ID_baleni FOREIGN KEY (ID_baleni) REFERENCES BALENI;


ALTER TABLE BALENI
    ADD CONSTRAINT BALENI_Obchodni_nazev FOREIGN KEY (Obchodni_nazev) REFERENCES LECIVO;

ALTER TABLE PRISPIVA
    ADD CONSTRAINT PRISPIVA_Kod_pojistovny FOREIGN KEY (Kod_pojistovny) REFERENCES POJISTOVNA;

ALTER TABLE PRISPIVA
    ADD CONSTRAINT PRISPIVA_Obchodni_nazev FOREIGN KEY (Obchodni_nazev) REFERENCES LECIVO;

ALTER TABLE VYDANA_POLOZKA
    ADD CONSTRAINT VYDANA_POLOZKA_Kod_pojistovny FOREIGN KEY (Kod_pojistovny) REFERENCES POJISTOVNA;

ALTER TABLE VYDANA_POLOZKA
    ADD CONSTRAINT VYDANA_POLOZKA_ID_polozky FOREIGN KEY (ID_polozky) REFERENCES POLOZKA;

ALTER TABLE VYDANA_POLOZKA
    ADD CONSTRAINT VYDANA_POLOZKA_ID_receptu FOREIGN KEY (ID_receptu) REFERENCES PREDPIS;


ALTER TABLE PRISPIVA
    ADD CONSTRAINT PRISPIVA_FK_PRISPIVA PRIMARY KEY (Obchodni_nazev, Kod_pojistovny);

ALTER TABLE VYDANA_POLOZKA
    ADD CONSTRAINT VYDANA_POLOZKA_POINTER PRIMARY KEY (ID_polozky);


ALTER TABLE BALENI
    ADD CONSTRAINT BALENI_BaleniNezap CHECK (Pocet_baleni > 0);

ALTER TABLE LECIVO
    ADD CONSTRAINT LECIVO_LecivoNezap CHECK (Pocet_v_baleni > 0 AND cena > 0);

ALTER TABLE PRISPIVA
    ADD CONSTRAINT PRISPIVA_PrispivaNezap CHECK (Castku >= 0 );


ALTER TABLE VYDANA_POLOZKA
    ADD CONSTRAINT VydanaPolozkaCheck CHECK (Prispevek >= 0 );


ALTER TABLE POJISTOVNA
    ADD CONSTRAINT KodPojistovnyCheck CHECK (Kod_pojistovny > 99 );


--##################### SEKCE TRIGGERů PRO 4. ODEVZDÁNÍ  ##########################
-- TRIGGER 1: AUTOMATICKÉ GENEROVÁNÍ PRIMÁRNÍHO KLÍČE TABULKY
DROP SEQUENCE "id_prodej_seq"; --pro opětovné spouštění
CREATE SEQUENCE "id_prodej_seq"; --deklerace sekvence

CREATE OR REPLACE TRIGGER "id_inkrement_trig" -- deklerace triggeru
    BEFORE INSERT
    ON PRODEJ --pred vlozenim do prodej
    FOR EACH ROW --kazdy radek
    WHEN (NEW.ID_prodej IS NULL) --kdyz je nový PK NULL
BEGIN
    :NEW.ID_prodej := "id_prodej_seq".nextval; --vygeneruj dalsi hodnotu pro z teto sekvence pro ID_prodej
END;
/

-- TRIGGER 2: Hlida vysi prispevku pojistovny na lecivo, jenz je limitovana samotnou cenou leciva
CREATE OR REPLACE TRIGGER "prevyseni_prispevku"
    BEFORE INSERT OR UPDATE OF Obchodni_nazev, Castku
    ON PRISPIVA
    FOR EACH ROW
DECLARE
    limit NUMBER;
BEGIN
    --Zisk dat
    SELECT Cena
    INTO limit
    FROM LECIVO
    WHERE LECIVO.Obchodni_nazev = :NEW.Obchodni_nazev;
    --Kontrola
    IF (limit < :NEW.Castku)
    THEN
        RAISE_APPLICATION_ERROR(-20201, 'Příspěvek nemůže být vyšší než cena léčiva', FALSE);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20202, 'Trigger pro převýšení příspěvku zachytil nevalidní insert');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Trigger pro převýšení příspěvku zachytil nespecifikovanou vyjímku.');
END;
/
--DEMONSTRAČNÍ INSERT, JENŽ SELŽE S CHYBOU -20001, KTEROU GENERUJE TRIGGER preteceni_prispevku
/*INSERT INTO POJISTOVNA
(
    Kod_pojistovny,
    Kontakt
)
VALUES
(
    235,
    'Sikovna pojistka'
);
INSERT INTO PRISPIVA
(

    Castku,
    Obchodni_nazev,
    Kod_pojistovny
)
VALUES
(
    6000, --ZDE TRIGGEREM VYHODI VYJIMKU - V DATABAZI MA TENTO LEK CENU 1999
    (select Obchodni_nazev from LECIVO where (Obchodni_nazev = 'Osino')),
    (select Kod_pojistovny from POJISTOVNA where (KONTAKT = 'Sikovna pojistka'))

);*/


--##################### SEKCE VKLÁDÁNÍ SAMPLE DAT PRO 2. ODEVZDÁNÍ  ##########################

INSERT INTO ZAMESTANEC
(Jmeno,
 Prijmeni,
 Datum_nastupu)
VALUES ('Jan',
        'Dvorak',
        DATE '2022-12-11');

INSERT INTO PRODEJ
(Datum,
 ID_zamestnance)
VALUES (DATE '2022-12-12',
        (select ID_zamestnance from ZAMESTANEC where (Jmeno = 'Jan' AND Prijmeni = 'Dvorak')));


INSERT INTO LECIVO
(Obchodni_nazev,
 Ucina_latka,
 ID_leciva,
 Na_predpis,
 Pocet_v_baleni,
 Cena)
VALUES ('Osino',
        'Cukr',
        12,
        0,
        200,
        1999);

INSERT INTO LECIVO
(Obchodni_nazev,
 Ucina_latka,
 ID_leciva,
 Na_predpis,
 Pocet_v_baleni,
 Cena)
VALUES ('Ospen',
        'Acelpyrin',
        80,
        1,
        20,
        500);


INSERT INTO OBJEDNAVKA
(Jmeno_dodavatele,
 Tvori,
 Datum_obj)
VALUES ('Leky s.r.o.',
        (select ID_zamestnance from ZAMESTANEC where (Jmeno = 'Jan' AND Prijmeni = 'Dvorak')),
        '10-DEC-22');


INSERT INTO BALENI
(Pocet_baleni,
 ID_objednavky,
 Obchodni_nazev)
VALUES (5,
        (select ID_objednavky from OBJEDNAVKA where (JMENO_DODAVATELE = 'Leky s.r.o.')),
        (select Obchodni_nazev from LECIVO where (Obchodni_nazev = 'Osino')));

INSERT INTO POJISTOVNA
(Kod_pojistovny,
 Kontakt)
VALUES (233,
        'NaseZdravi s.r.o.');

INSERT INTO PREDPIS
(Vydavajici_lekar,
 Pacient,
 Typ,
    --number = 0 --> e recept
    --number = 1 --> papir
 Kod_receptu)
VALUES ('Dr. Zavor',
        'Jan Novak',
        0,
        1234567890);

INSERT INTO PRISPIVA
(Castku,
 Obchodni_nazev,
 Kod_pojistovny)
VALUES (5,
        (select Obchodni_nazev from LECIVO where (Obchodni_nazev = 'Osino')),
        (select Kod_pojistovny from POJISTOVNA where (KONTAKT = 'NaseZdravi s.r.o.')));

INSERT INTO POLOZKA
(Pocet_polozka,
 ID_prodej,
 ID_baleni)
VALUES (5,
        (select ID_prodej from PRODEJ where (DATUM = DATE '2022-12-12')),
        (select ID_baleni from BALENI where (OBCHODNI_NAZEV = 'Osino')));


INSERT INTO VYDANA_POLOZKA
(Prispevek,
 Kod_pojistovny,
 ID_polozky,
 ID_receptu)
VALUES (5,
        (select Kod_pojistovny from POJISTOVNA where (KONTAKT = 'NaseZdravi s.r.o.')),
        (select ID_polozky from POLOZKA where (Pocet_polozka = 5)),
        (select ID_receptu from PREDPIS where (Vydavajici_lekar = 'Dr. Zavor')));

--##################### SEKCE DOTAZŮ SELECT PRO 3. ODEVZDÁNÍ  ##########################


--S1:
--Celkové tržy za den a počet jednotlivých prodejů (Zde 12. 12. 2022) - k prodejním stastikám
--  SPLŇUJE:
--  jeden z dotazů využívající klauzuli group by, zde s více agregačními funkcemi
SELECT datum,
       SUM(prodejni_castka)   as trzba_celkem,
       SUM(primy_prodej)      as prima_trzba,
       SUM(platba_pojistovny) as trzba_od_pojistoven,
       COUNT(*)               as pocet_prodeju
FROM (SELECT datum,
             id_prodej,
             pocet_polozka * cena                             as prodejni_castka,
             pocet_polozka * cena - prispevek * pocet_polozka as primy_prodej,
             prispevek * pocet_polozka                        as platba_pojistovny
      FROM POLOZKA
               NATURAL JOIN BALENI
               NATURAL JOIN LECIVO
               NATURAL JOIN PRODEJ
               NATURAL JOIN VYDANA_POLOZKA
      WHERE datum = '12-DEC-22')
GROUP BY datum;

--S2:
--Objednávky na cestě, které obsahují léčivo (zde 'Osino') - pokud nemáme na skladě léky a potřebujeme vědět, zda jsou objednané
--  SPLŇUJE:
--  jeden dotaz obsahující predikát EXISTS
--  spojeni dvou tabulek
SELECT Id_objednavky as Objednavka_cislo, Datum_obj as Objednano_dne, Prijmeni as Objednal
FROM OBJEDNAVKA O
         NATURAL JOIN ZAMESTANEC
WHERE O.Datum_obj IS NOT NULL
  AND O.Datum_doruceni IS NULL
  AND EXISTS
    (
        SELECT *
        FROM BALENI
        WHERE ID_OBJEDNAVKY = O.ID_OBJEDNAVKY
          AND OBCHODNI_NAZEV = 'Osino'
    );


--S3
--Které pojišťovny přispívají na léčivo a kolik (zde Osino) - pro určení
--  SPLŇUJE:
--  jeden ze dvou dotazů využívajících spojení dvou tabulek
SELECT DISTINCT Kod_pojistovny as pojistovna, Castku as prispiva
FROM LECIVO
         NATURAL JOIN PRISPIVA
WHERE Obchodni_nazev = 'Osino'
ORDER BY prispiva;



--S4
--Jaká je průměrná částka příspěvku pojišťovny na léčiva - pro statistiky příspěvků pojišťoven
--  SPLŇUJE:
--  jedna z klauzulí group by s agregační funkcí
--  spojeni dvou tabulek
SELECT Obchodni_nazev as lecivo, AVG(Castku) as prumerny_prispevek
FROM LECIVO
         NATURAL JOIN PRISPIVA
GROUP BY Obchodni_nazev;



--S5
--Jaké volně dostupné léčiva se prodaly během daného dne a kolik balení to bylo, seřazeno od nejprodávanějšího - pro statistiky volně prodejných receptů
--  SPLŇUJE:
--  Použití IN a vnořený select
--  Spojení tří tabulek
SELECT Obchodni_nazev as volne_dostupne_lecivo, SUM(Pocet_polozka) as pocet_prodanych_baleni
FROM POLOZKA
         NATURAL JOIN BALENI
         NATURAL JOIN PRODEJ
WHERE datum = '12-DEC-22'
  and Obchodni_nazev IN (SELECT Obchodni_nazev
                         FROM LECIVO
                         WHERE Na_predpis = 0)
GROUP BY Obchodni_nazev
ORDER BY pocet_prodanych_baleni;


--S6 Jak statisticky závisí typ receptu s příspěvkem pro jednotlivé typy receptu u každé pojišťovny
--  SPLŇUJE:
--  Klauzule group by s agregační funkcí
--  Spojení dvou tabulek
SELECT AVG(prispevek) as prumer,
       MAX(prispevek) as maxim,
       MIN(prispevek) as minim,
       typ            as typ_receptu,
       kod_pojistovny as pojistovna
FROM VYDANA_POLOZKA
         NATURAL JOIN PREDPIS
GROUP BY typ, kod_pojistovny;


--S7 Odkud bylo objednáno specifické balení léků? Pro reklamace, stížnosti apod.
--  SPLŇUJE:
--  Spojení tří tabulek
SELECT Id_baleni as Identifikator_kusu, Obchodni_nazev as lecivo, Jmeno_dodavatele
FROM Baleni
         NATURAL JOIN Objednavka
         NATURAL JOIN Lecivo
WHERE Id_baleni = 1;

SELECT *
FROM POJISTOVNA;
SELECT *
FROM PRISPIVA;
SELECT CENA
from LECIVO;


-- ################################### EXPLAIN PLAN + INDEX PRO 4. ODEVZDÁNÍ ##################################

--pro opětovné spuštění
DROP INDEX index_datum_sort;


EXPLAIN PLAN FOR
SELECT datum,
       SUM(prodejni_castka)   as trzba_celkem,
       SUM(primy_prodej)      as prima_trzba,
       SUM(platba_pojistovny) as trzba_od_pojistoven,
       COUNT(*)               as pocet_prodeju
FROM (SELECT datum,
             id_prodej,
             pocet_polozka * cena                             as prodejni_castka,
             pocet_polozka * cena - prispevek * pocet_polozka as primy_prodej,
             prispevek * pocet_polozka                        as platba_pojistovny
      FROM POLOZKA
               NATURAL JOIN BALENI
               NATURAL JOIN LECIVO
               NATURAL JOIN PRODEJ
               NATURAL JOIN VYDANA_POLOZKA
      WHERE datum = '12-DEC-22')
GROUP BY datum
ORDER BY datum;


SELECT *
FROM TABLE (dbms_xplan.display);

CREATE UNIQUE INDEX index_datum_sort on PRODEJ (Datum);



EXPLAIN PLAN FOR
SELECT datum,
       SUM(prodejni_castka)   as trzba_celkem,
       SUM(primy_prodej)      as prima_trzba,
       SUM(platba_pojistovny) as trzba_od_pojistoven,
       COUNT(*)               as pocet_prodeju
FROM (SELECT datum,
             id_prodej,
             pocet_polozka * cena                             as prodejni_castka,
             pocet_polozka * cena - prispevek * pocet_polozka as primy_prodej,
             prispevek * pocet_polozka                        as platba_pojistovny
      FROM POLOZKA
               NATURAL JOIN BALENI
               NATURAL JOIN LECIVO
               NATURAL JOIN PRODEJ
               NATURAL JOIN VYDANA_POLOZKA
      WHERE datum = '12-DEC-22')
GROUP BY datum
ORDER BY Datum;

SELECT *
FROM TABLE (dbms_xplan.display);


--############################ PRIDANI PRAV DRUHEMU CLENOVI TYMU PRO ODEVZDANI 4 ############################

--Prava pro Jana Rybku (xrybka05) na vsechny tabulky databaze
GRANT ALL ON BALENI TO XRYBKA05;
GRANT ALL ON LECIVO TO XRYBKA05;
GRANT ALL ON OBJEDNAVKA TO XRYBKA05;
GRANT ALL ON POJISTOVNA TO XRYBKA05;
GRANT ALL ON POLOZKA TO XRYBKA05;
GRANT ALL ON PREDPIS TO XRYBKA05;
GRANT ALL ON PRISPIVA TO XRYBKA05;
GRANT ALL ON PRODEJ TO XRYBKA05;
GRANT ALL ON VYDANA_POLOZKA TO XRYBKA05;
GRANT ALL ON ZAMESTANEC to XRYBKA05;
--TODO doplnit execute právo pro sekvence

--Prava pro Matěje Konopíka (xkonop03) na vsechny tabulky databaze
GRANT ALL ON BALENI TO XKONOP03;
GRANT ALL ON LECIVO TO XKONOP03;
GRANT ALL ON OBJEDNAVKA TO XKONOP03;
GRANT ALL ON POJISTOVNA TO XKONOP03;
GRANT ALL ON POLOZKA TO XKONOP03;
GRANT ALL ON PREDPIS TO XKONOP03;
GRANT ALL ON PRISPIVA TO XKONOP03;
GRANT ALL ON PRODEJ TO XKONOP03;
GRANT ALL ON VYDANA_POLOZKA TO XKONOP03;
GRANT ALL ON ZAMESTANEC to XKONOP03;
--TODO doplnit execute právo pro sekvence


--############################ PRIDANI MATERIALIZOVANEHO POHLEDU + DEMONSTRACE PRO ODEVZDANI 4 ############################
--vymazani pro opakovany beh
DROP MATERIALIZED VIEW materialized_view_baleni;
DROP MATERIALIZED VIEW LOG ON BALENI;

--tvorba materializovaneho pohledu
CREATE MATERIALIZED VIEW LOG ON XKONOP03.BALENI WITH PRIMARY KEY, ROWID;
CREATE MATERIALIZED VIEW materialized_view_baleni
    REFRESH FAST ON COMMIT
AS --TYPO
SELECT Obchodni_nazev, Pocet_baleni, Epirace, ID_BALENI
FROM XKONOP03.BALENI;

GRANT ALL ON materialized_view_baleni TO XRYBKA05;


--priklad pouziti materializovaneho pohledu (pocet baleni na sklade)
SELECT Obchodni_nazev, Pocet_baleni
FROM materialized_view_baleni;

--Nyni vlozeni do tabulky pro demonstraci
INSERT INTO BALENI
(Pocet_baleni,
 ID_objednavky,
 Obchodni_nazev)
VALUES (20,
        (select ID_objednavky from OBJEDNAVKA where (JMENO_DODAVATELE = 'Leky s.r.o.')),
        (select Obchodni_nazev from LECIVO where (Obchodni_nazev = 'Ospen')));
--DELETE FROM BALENI WHERE Obchodni_nazev = 'Ospen';

--výběr z material view po přidání (není aktualizovaný)
SELECT Obchodni_nazev, Pocet_baleni
FROM materialized_view_baleni;

--pro porovnání výběr přímo z tabulky, jenž aktualizovana je
SELECT Obchodni_nazev, Pocet_baleni
FROM BALENI;


--commit dle nastavení mat. pohledu aktualizuje data
COMMIT;
-- nyní jsou v lokálním mat. pohledu jiz data aktualizovane
SELECT Obchodni_nazev, Pocet_baleni
FROM materialized_view_baleni;


--odstranění demonstrační položky
DELETE
FROM BALENI
WHERE Obchodni_nazev = 'Ospen';
--opět stejný výpis z mat. pohledu pred aktualizací
SELECT Obchodni_nazev, Pocet_baleni
FROM materialized_view_baleni;

--v tabulce jiz neni tato polozka
SELECT Obchodni_nazev, Pocet_baleni
FROM BALENI;

--commit dle nastavení mat. pohledu aktualizuje data
COMMIT;
-- nyní jsou v lokálním mat. pohledu jiz data opet aktualizovane
SELECT Obchodni_nazev, Pocet_baleni
FROM materialized_view_baleni;



