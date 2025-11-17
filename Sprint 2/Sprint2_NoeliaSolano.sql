USE transactions;
-- ----------------------------------------------------------
-- Nivell 1
-- Exercici 2: Utilitzant JOIN realitzaràs les següents consultes; llistat dels països que estan generant vendes
-- ----------------------------------------------------------
SELECT DISTINCT c.country
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

-- ----------------------------------------------------------
-- Des de quants països es generen les vendes.
-- ----------------------------------------------------------
SELECT COUNT(DISTINCT c.country) AS NumberOfCountries
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0;

-- ----------------------------------------------------------
-- Identifica la companyia amb la mitjana més gran de vendes
-- ----------------------------------------------------------
SELECT 
    c.company_name, 
    ROUND(AVG(t.amount), 2) AS AverageSales
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.company_name
ORDER BY AverageSales DESC
LIMIT 1;

-- ----------------------------------------------------------
-- Exercici 3: Utilitzant només subconsultes (sense utilitzar JOIN), mostra totes les transaccions realitzades per empreses d'Alemanya
-- ----------------------------------------------------------
SELECT *
FROM transaction t
WHERE t.declined = 0
	AND EXISTS(
		SELECT 1
		FROM company c
		WHERE c.id = t.company_id
			AND c.country = 'Germany'
		);

-- ----------------------------------------------------------
-- Llista les empreses amb transaccions superiors a la mitjana
-- ----------------------------------------------------------
SELECT c.company_name
FROM company c
WHERE EXISTS(
	SELECT 1
	FROM transaction t
	WHERE t.company_id = c.id
		AND t.declined = 0
		AND t.amount > (
			SELECT AVG(t2.amount)
			FROM transaction t2
			WHERE t2.declined = 0
		)
);

-- ----------------------------------------------------------
-- Llista d'empreses sense transaccions registrades
-- ----------------------------------------------------------
SELECT c.company_name
FROM company c
WHERE NOT EXISTS(
    SELECT 1
    FROM transaction t
    WHERE t.company_id = c.id
		AND t.declined = 0
);

-- ----------------------------------------------------------
-- Nivell 2:
-- Els 5 dies amb més ingressos. Mostra la data de cada transacció juntament amb el total de les vendes.
-- ----------------------------------------------------------
SELECT 
    ROUND(SUM(t.amount), 2) AS TotalSales, 
    DATE(t.timestamp) AS Date
FROM transaction t
WHERE t.declined = 0
GROUP BY Date
ORDER BY TotalSales DESC
LIMIT 5;

-- ----------------------------------------------------------
-- Mitjana de vendes per país
-- ----------------------------------------------------------
SELECT 
    c.country, ROUND(AVG(t.amount), 2) AS AverageSales
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.country
ORDER BY AverageSales DESC;

-- ----------------------------------------------------------
-- Llista de transaccions d'empreses del mateix país que "Non Institute". Mostra el llistat aplicant JOIN i subconsultes.
-- ----------------------------------------------------------
SELECT t.*
FROM transaction t
JOIN company c ON c.id = t.company_id
WHERE t.declined = 0
	AND c.country = (
		SELECT c2.country
        FROM company c2
        WHERE c2.company_name = 'Non Institute'
		);

-- ----------------------------------------------------------
-- Mostra el llistat aplicant solament subconsultes.
-- ----------------------------------------------------------
SELECT t.*
FROM transaction t
WHERE t.declined = 0
	AND EXISTS(
        SELECT 1
        FROM company c
        WHERE c.id = t.company_id
			AND c.country = (
                SELECT c2.country
                FROM company c2
                WHERE c2.company_name = 'Non Institute'
		)
);

-- ----------------------------------------------------------
-- Nivell 3
-- Exercici 1: Dades d'empreses amb transaccions entre 350 i 400€ en dates '2015-04-29', '2018-07-20', '2024-03-13'
-- ----------------------------------------------------------
SELECT 
    c.company_name, 
    c.phone, 
    c.country, 
    DATE(t.timestamp) AS date, 
    t.amount
FROM transaction t
JOIN company c
ON t.company_id = c.id
WHERE t.amount BETWEEN 350 AND 400
	AND t.declined = 0
	AND DATE(t.timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY t.amount DESC;
-- ----------------------------------------------------------
-- Exercici 2: Classificació de les empreses segons si tenen més o menys de 400 transaccions
-- ----------------------------------------------------------
SELECT 
    c.id,
    c.company_name,
    COUNT(t.id) AS num_transactions,
    CASE
        WHEN COUNT(t.id) > 400 THEN 'Over400'
        WHEN COUNT(t.id) < 400 THEN 'Under400'
        ELSE 'Exactly400'
    END AS category_transaction
FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY c.id, c.company_name;
