CREATE DATABASE Toysgroup;

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);
    
    
CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(100)
);


CREATE TABLE Country (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(100),
    RegionID INT,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY,
    ProductID INT,
    CountryID INT,
    Quantity INT,
    SalesDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (CountryID) REFERENCES Country(CountryID)
);

INSERT INTO Category (CategoryID, CategoryName) VALUES (1, 'Lego');
INSERT INTO Category (CategoryID, CategoryName) VALUES (2, 'Barbie');

INSERT INTO Product (ProductID, ProductName, CategoryID) VALUES (1, 'Lego-100', 1);
INSERT INTO Product (ProductID, ProductName, CategoryID) VALUES (2, 'Lego-200', 1);
INSERT INTO Product (ProductID, ProductName, CategoryID) VALUES (3, 'Barbie Fashionista', 2);
INSERT INTO Product (ProductID, ProductName, CategoryID) VALUES (4, 'Barbie Dreamhouse', 2);

INSERT INTO Region (RegionID, RegionName) VALUES (1, 'WestEurope');
INSERT INTO Region (RegionID, RegionName) VALUES (2, 'SouthEurope');

INSERT INTO Country (CountryID, CountryName, RegionID) VALUES (1, 'France', 1);
INSERT INTO Country (CountryID, CountryName, RegionID) VALUES (2, 'Germany', 1);
INSERT INTO Country (CountryID, CountryName, RegionID) VALUES (3, 'Italy', 2);
INSERT INTO Country (CountryID, CountryName, RegionID) VALUES (4, 'Greece', 2);

INSERT INTO Sales (SalesID, ProductID, CountryID, Quantity, SalesDate) VALUES (1, 1, 1, 10, '2024-01-01');
INSERT INTO Sales (SalesID, ProductID, CountryID, Quantity, SalesDate) VALUES (2, 2, 2, 5, '2024-01-02');
INSERT INTO Sales (SalesID, ProductID, CountryID, Quantity, SalesDate) VALUES (3, 1, 3, 7, '2024-01-03');
INSERT INTO Sales (SalesID, ProductID, CountryID, Quantity, SalesDate) VALUES (4, 2, 4, 8, '2024-01-04');
INSERT INTO Sales (SalesID, ProductID, CountryID, Quantity, SalesDate) VALUES (5, 3, 1, 12, '2024-01-05');

/*	Verificare che i campi definiti come PK siano univoci. In altre parole, scrivi una query per determinare
l’univocità dei valori di ciascuna PK (una query per tabella implementata).*/

SELECT CategoryID, COUNT(*) 
FROM Category 
GROUP BY CategoryID;

SELECT ProductID, COUNT(*) 
FROM Product 
GROUP BY ProductID;

SELECT RegionID, COUNT(*) 
FROM Region 
GROUP BY RegionID;

SELECT CountryID, COUNT(*) 
FROM Country 
GROUP BY CountryID; 

SELECT SalesID, COUNT(*) 
FROM Sales 
GROUP BY SalesID;

/*2)	Esporre l’elenco delle transazioni indicando nel result set il codice documento, 
la data, il nome del prodotto, la categoria del prodotto, il nome dello stato,
 il nome della regione di vendita e un campo booleano valorizzato in base alla condizione che siano passati più di 180 giorni 
dalla data vendita o meno (>180 -> True, <= 180 -> False */

SELECT 
    s.SalesID AS CodiceDocumento,
    s.SalesDate AS Data,
    p.ProductName AS NomeProdotto,
    c.CategoryName AS CategoriaProdotto,
    co.CountryName AS NomeStato,
    r.RegionName AS NomeRegione,
    CASE 
        WHEN DATEDIFF(CURRENT_DATE(), s.SalesDate) > 180 THEN 'Vero'
        ELSE 'Falso'
    END AS Più_di_180_Giorni
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
JOIN 
    Category c ON p.CategoryID = c.CategoryID
JOIN 
    Country co ON s.CountryID = co.CountryID
JOIN 
    Region r ON co.RegionID = r.RegionID;


/* 3)	Esporre l’elenco dei prodotti che hanno venduto, in totale, 
una quantità maggiore della media delle vendite realizzate nell’ultimo anno censito. 
(ogni valore della condizione deve risultare da una query e non deve essere inserito a mano).
Nel result set devono comparire solo il codice prodotto e il totale venduto. */

SELECT s.ProductID as CODICE_PRODOTTO, SUM(s.Quantity) AS VALORE_VENDUTO
FROM Sales s
WHERE YEAR(s.SalesDate) = (SELECT MAX(YEAR(SalesDate)) FROM Sales)
GROUP BY s.ProductID
HAVING SUM(s.Quantity) > (
    SELECT AVG(TotalQuantity) AS AverageSales
    FROM (
        SELECT SUM(s.Quantity) AS TotalQuantity
        FROM Sales s
        WHERE YEAR(s.SalesDate) = (SELECT MAX(YEAR(SalesDate)) FROM Sales)
        GROUP BY s.ProductID
    ) AS Subquery
);



        

/* 4)	Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno.*/

SELECT 
    p.ProductName, 
    YEAR(s.SalesDate) AS Anno, 
    SUM(s.Quantity) AS QuantitàTotale
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
GROUP BY 
    p.ProductName, 
    YEAR(s.SalesDate);
    
    

/*5)	Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente.*/

SELECT 
    c.CountryName, 
    YEAR(s.SalesDate) AS Anno, 
    SUM(s.Quantity) AS FatturatoTotale
FROM 
    Sales s
JOIN 
    Country c ON s.CountryID = c.CountryID
GROUP BY 
    c.CountryName, 
    YEAR(s.SalesDate)
ORDER BY 
    Anno, 
    FatturatoTotale DESC;


/*6)	Rispondere alla seguente domanda: qual è la categoria di articoli maggiormente richiesta dal mercato?*/

SELECT 
    c.CategoryName, 
    SUM(s.Quantity) AS TotalQuantity
FROM 
    Sales s
JOIN 
    Product p ON s.ProductID = p.ProductID
JOIN 
    Category c ON p.CategoryID = c.CategoryID
GROUP BY 
    c.CategoryName
ORDER BY 
    TotalQuantity DESC
LIMIT 1;

/*7)	Rispondere alla seguente domanda: quali sono i prodotti invenduti? Proponi due approcci risolutivi differenti.*/

-- approcio 1
SELECT p.ProductID, p.ProductName
FROM Product p
LEFT JOIN Sales s ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL;

-- approccio 2
SELECT p.ProductID, p.ProductName
FROM Product p
WHERE NOT EXISTS (
    SELECT 1 
    FROM Sales s 
    WHERE p.ProductID = s.ProductID
);

/*	Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle informazioni
utili (codice prodotto, nome prodotto, nome categoria)
*/

CREATE VIEW ProductView AS
SELECT 
    p.ProductID AS CodiceProdotto, 
    p.ProductName AS NomeProdotto, 
    c.CategoryName AS NomeCategoria
FROM 
    Product p
JOIN 
    Category c ON p.CategoryID = c.CategoryID;
    
    /*	9. Creare una vista per le informazioni geografiche*/
    
 CREATE VIEW GeographyView AS
SELECT 
    co.CountryID AS CodicePaese, 
    co.CountryName AS NomePaese, 
    r.RegionID AS CodiceRegione, 
    r.RegionName AS NomeRegione
FROM 
    Country co
JOIN 
    Region r ON co.RegionID = r.RegionID;   