USE transactions;

-- ----------------------------------------------------------
-- Creació de la taula credit_card
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS credit_card(
	id VARCHAR(15) PRIMARY KEY,
    iban VARCHAR(50),
    pan VARCHAR(25),
    pin VARCHAR(4),
    cvv INT,
    expiring_date VARCHAR(25)
);

-- ----------------------------------------------------------
-- Relació amb la taula transaction
-- ----------------------------------------------------------
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- ----------------------------------------------------------
-- La targeta de crèdit CcU-2938 ha de mostrar com a número de compte: TR323456312213576817699999
-- ----------------------------------------------------------
UPDATE credit_card
SET iban='TR323456312213576817699999'
WHERE id='CcU-2938';

SELECT *
FROM credit_card
WHERE id='CcU-2938';

-- ----------------------------------------------------------
-- En la taula "transaction" ingressa una nova transacció amb nova informació:
-- ----------------------------------------------------------
INSERT INTO credit_card(id)
VALUES('CcU-9999');

INSERT INTO company(id)
VALUES('b-9999');

INSERT INTO transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

-- ----------------------------------------------------------
-- Eliminar la columna "pan" de la taula credit_card
-- ----------------------------------------------------------
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;

-- ----------------------------------------------------------
-- Nivell 2: Elimina de la taula transaction el registre amb ID 000447FE-B650-4DCF-85DE-C7ED0EE1CAAD.
-- ----------------------------------------------------------
DELETE
FROM transaction
WHERE id='000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

-- ----------------------------------------------------------
-- Crea una vista amb: Nom de la companyia, telèfon, país, mitjana de compra per companyia.
-- ----------------------------------------------------------
CREATE VIEW VistaMarketing AS 
SELECT c.company_name, c.phone, c.country, ROUND(AVG(t.amount), 2) AS avg_purchase
FROM transaction t
JOIN company c ON t.company_id=c.id
WHERE declined=0
GROUP BY c.id, c.company_name;

-- ----------------------------------------------------------
-- Ordena la vista amb les dades de major a menor mitjana de compra.
-- ----------------------------------------------------------
SELECT * 
FROM VistaMarketing
ORDER BY avg_purchase DESC;

-- ----------------------------------------------------------
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
-- ----------------------------------------------------------
SELECT * 
FROM VistaMarketing
WHERE country='Germany';

-- ----------------------------------------------------------
-- Nivell 3: Deixar els comandos executats per a obtenir el següent diagrama
-- ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)
);
-- Carreguem les dades de la taula user
-- Canviem el nom la taula
RENAME TABLE user TO data_user;
-- Canviem el tipus de parametre id
ALTER TABLE data_user
MODIFY COLUMN id INT;
-- Afegim el id 9999(anteriorment el vam afegir manualment a la taula transaction)
INSERT INTO data_user(id)
VALUES ('9999');
-- Establim la relació entre la taula pare (User) i filla (Transaction)
ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_data_user
FOREIGN KEY (user_id) REFERENCES data_user(id);
-- Eliminem la variable website de company
ALTER TABLE company
DROP COLUMN website;

SELECT *
FROM company;
-- Afegim variable fecha_actual
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE DEFAULT (CURDATE());

SELECT *
FROM credit_card;
-- Canviem el límit de caracters
ALTER TABLE transaction
MODIFY COLUMN credit_card_id VARCHAR(20);

ALTER TABLE credit_card
MODIFY COLUMN id VARCHAR(20);
-- Canviem el nom de la variable email a presonal_email
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

-- ----------------------------------------------------------
-- L'empresa també us demana crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ----------------------------------------------------------
CREATE VIEW InformeTecnico AS
SELECT t.id AS transaction_id, u.name AS user_name, u.surname AS user_surname, cc.iban, c.company_name
FROM transaction t
JOIN data_user u ON t.user_id=u.id
JOIN credit_card cc ON t.credit_card_id=cc.id
JOIN company c ON t.company_id=c.id;

-- ----------------------------------------------------------
-- Mostra els resultats de la vista i ordena'ls de forma descendent en funció de la variable ID de transacció.
-- ----------------------------------------------------------
SELECT *
FROM InformeTecnico
ORDER BY transaction_id DESC;