--##################### SEKCE DOTAZŮ SELECT PRO 3. ODEVZDÁNÍ  ##########################


--S1:
--Celkové tržy za den a počet jednotlivých prodejů (Zde 12. 12. 2022) - k prodejním stastikám
--  SPLŇUJE:
--  jeden z dotazů využívající klauzuli group by, zde s více agregačními funkcemi
SELECT datum, SUM(prodejni_castka) as trzba_celkem, SUM(primy_prodej) as prima_trzba, SUM(platba_pojistovny) as trzba_od_pojistoven, COUNT(*) as pocet_prodeju
FROM
    (
    SELECT datum, id_prodej, pocet_polozka*cena as prodejni_castka, pocet_polozka*cena-prispevek*pocet_polozka as primy_prodej, prispevek*pocet_polozka as platba_pojistovny
    FROM POLOZKA NATURAL JOIN BALENI NATURAL JOIN LECIVO NATURAL JOIN PRODEJ NATURAL JOIN VYDANA_POLOZKA
    WHERE datum = '12-DEC-22'
    )
GROUP BY datum;

--S2:
--Objednávky na cestě, které obsahují léčivo (zde 'Osino') - pokud nemáme na skladě léky a potřebujeme vědět, zda jsou objednané
--  SPLŇUJE:
--  jeden dotaz obsahující predikát EXISTS
--  spojeni dvou tabulek
SELECT Id_objednavky as Objednavka_cislo, Datum_obj as Objednano_dne, Prijmeni as Objednal
FROM OBJEDNAVKA O NATURAL JOIN ZAMESTANEC
WHERE O.Datum_obj IS NOT NULL AND O.Datum_doruceni IS NULL AND EXISTS
    (
        SELECT *
        FROM BALENI
        WHERE ID_OBJEDNAVKY = O.ID_OBJEDNAVKY AND OBCHODNI_NAZEV = 'Osino'
    );


--S3
--Které pojišťovny přispívají na léčivo a kolik (zde Osino) - pro určení
--  SPLŇUJE:
--  jeden ze dvou dotazů využívajících spojení dvou tabulek
SELECT DISTINCT Kod_pojistovny as pojistovna, Castku as prispiva
FROM LECIVO NATURAL JOIN PRISPIVA
WHERE Obchodni_nazev = 'Osino'
ORDER BY prispiva;



--S4
--Jaká je průměrná částka příspěvku pojišťovny na léčiva - pro statistiky příspěvků pojišťoven
--  SPLŇUJE:
--  jedna z klauzulí group by s agregační funkcí
--  spojeni dvou tabulek
SELECT Obchodni_nazev as lecivo, AVG(Castku) as prumerny_prispevek
FROM LECIVO NATURAL JOIN PRISPIVA
GROUP BY Obchodni_nazev;



--S5
--Jaké volně dostupné léčiva se prodaly během daného dne a kolik balení to bylo, seřazeno od nejprodávanějšího - pro statistiky volně prodejných receptů
--  SPLŇUJE:
--  Použití IN a vnořený select
--  Spojení tří tabulek
SELECT Obchodni_nazev as volne_dostupne_lecivo, SUM(Pocet_polozka) as pocet_prodanych_baleni
FROM POLOZKA NATURAL JOIN BALENI NATURAL JOIN PRODEJ
WHERE datum = '12-DEC-22' and Obchodni_nazev IN(
    SELECT Obchodni_nazev
    FROM LECIVO
    WHERE Na_predpis = 0
)
GROUP BY Obchodni_nazev
ORDER BY pocet_prodanych_baleni;


--S6 Jak statisticky závisí typ receptu s příspěvkem pro jednotlivé typy receptu u každé pojišťovny
--  SPLŇUJE:
--  Klauzule group by s agregační funkcí
--  Spojení dvou tabulek
SELECT AVG(prispevek) as prumer, MAX(prispevek) as maxim, MIN(prispevek) as minim, typ as typ_receptu, kod_pojistovny as pojistovna
FROM VYDANA_POLOZKA NATURAL JOIN PREDPIS
GROUP BY typ, kod_pojistovny;


--S7 Odkud bylo objednáno specifické balení léků? Pro reklamace, stížnosti apod.
--  SPLŇUJE:
--  Spojení tří tabulek
SELECT Id_baleni as Identifikator_kusu, Obchodni_nazev as lecivo, Jmeno_dodavatele
FROM Baleni NATURAL JOIN Objednavka NATURAL JOIN Lecivo
WHERE Id_baleni = 1;

SELECT * FROM POJISTOVNA;
SELECT * FROM PRISPIVA;
SELECT CENA from LECIVO;
