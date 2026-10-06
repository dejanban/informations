-- Učni primeri za ločeno Oracle shemo. Prvi zagon ustvari tabele.
-- Ob ponovnem zagonu CREATE TABLE ne bo uspel, če objekti že obstajajo.
-- Skripta ne briše obstoječih objektov.

-- Za prvi zagon v prazni učni shemi Oracle.
CREATE TABLE ucni_oddelek (
  oddelek_id NUMBER PRIMARY KEY,
  naziv VARCHAR2(80) NOT NULL
);
CREATE TABLE ucni_vloga (
  vloga_id NUMBER PRIMARY KEY,
  oddelek_id NUMBER REFERENCES ucni_oddelek(oddelek_id),
  datum_prejema DATE NOT NULL,
  datum_zakljucka DATE,
  status VARCHAR2(20) NOT NULL,
  znesek NUMBER(12,2)
);
INSERT INTO ucni_oddelek VALUES (10, 'Oddelek A');
INSERT INTO ucni_oddelek VALUES (20, 'Oddelek B');
INSERT INTO ucni_oddelek VALUES (30, 'Oddelek C');
INSERT INTO ucni_vloga VALUES (1,10,DATE '2026-09-01',DATE '2026-09-03','ZAKLJUCENA',100);
INSERT INTO ucni_vloga VALUES (2,10,DATE '2026-09-02',DATE '2026-09-07','ZAKLJUCENA',200);
INSERT INTO ucni_vloga VALUES (3,20,DATE '2026-09-04',NULL,'ODPRTA',50);
INSERT INTO ucni_vloga VALUES (4,20,DATE '2026-08-29',DATE '2026-09-02','ZAKLJUCENA',150);
INSERT INTO ucni_vloga VALUES (5,20,DATE '2026-09-10',DATE '2026-09-11','ZAKLJUCENA',NULL);
COMMIT;

-- A. Mesecni pregled
SELECT o.naziv,
       COUNT(v.vloga_id) AS stevilo,
       NVL(SUM(v.znesek), 0) AS znesek,
       ROUND(AVG(v.datum_zakljucka - v.datum_prejema), 2) AS povp_dni
FROM ucni_oddelek o
LEFT JOIN ucni_vloga v
  ON v.oddelek_id = o.oddelek_id
 AND v.status = 'ZAKLJUCENA'
 AND v.datum_zakljucka >= DATE '2026-09-01'
 AND v.datum_zakljucka < DATE '2026-10-01'
GROUP BY o.naziv
ORDER BY o.naziv;

-- B. Zadnja vloga
SELECT vloga_id, oddelek_id, datum_prejema
FROM (
  SELECT v.*,
         ROW_NUMBER() OVER (
           PARTITION BY oddelek_id
           ORDER BY datum_prejema DESC, vloga_id DESC
         ) AS rn
  FROM ucni_vloga v
)
WHERE rn = 1
ORDER BY oddelek_id;

-- C. Kontrole
SELECT status, COUNT(*) AS stevilo,
       COUNT(znesek) AS znani_zneski,
       SUM(znesek) AS vsota
FROM ucni_vloga
GROUP BY status
ORDER BY status;

SELECT vloga_id
FROM ucni_vloga
WHERE datum_zakljucka < datum_prejema
   OR (status = 'ZAKLJUCENA' AND datum_zakljucka IS NULL);
