CREATE TABLE סוגי_מקומות (
    קוד INT PRIMARY KEY IDENTITY(1,1),
    שם NVARCHAR(50) NOT NULL
);

INSERT INTO סוגי_מקומות (שם) VALUES (N'חניון'), (N'חנות'), (N'בית כנסת');

CREATE TABLE סוגי_חנויות (
    קוד INT PRIMARY KEY IDENTITY(1,1),
    שם NVARCHAR(50) NOT NULL
);

INSERT INTO סוגי_חנויות (שם) VALUES (N'אוכל'), (N'מזון'), (N'הלבשה');

CREATE TABLE בעלי_מקום (
    קוד INT PRIMARY KEY IDENTITY(1,1),
    פרטים_אישיים NVARCHAR(MAX) NOT NULL
);

INSERT INTO בעלי_מקום (פרטים_אישיים) VALUES (N'דוד כהן, ת"ז 123456789'), (N'רונית לוי, ת"ז 987654321'), (N'משה ישראלי, ת"ז 456789123');

CREATE TABLE שטח (
    קוד INT PRIMARY KEY IDENTITY(1,1),
    מספר_קומה INT NOT NULL,
    מספר_בתוך_קומה INT NOT NULL,
    קוד_סוג_מקום INT NOT NULL,
    קוד_סוג_חנות INT NULL,
    שטח_במטרים DECIMAL(10,2) NOT NULL,
    קוד_בעל_מקום INT NOT NULL,
    תאריך_תחילת_השכרה DATE NOT NULL,
    תאריך_סיום_השכרה DATE NULL,
    חזית BIT NOT NULL,
    FOREIGN KEY (קוד_סוג_מקום) REFERENCES סוגי_מקומות(קוד),
    FOREIGN KEY (קוד_סוג_חנות) REFERENCES סוגי_חנויות(קוד),
    FOREIGN KEY (קוד_בעל_מקום) REFERENCES בעלי_מקום(קוד)
);

INSERT INTO שטח (מספר_קומה, מספר_בתוך_קומה, קוד_סוג_מקום, קוד_סוג_חנות, שטח_במטרים, קוד_בעל_מקום, תאריך_תחילת_השכרה, תאריך_סיום_השכרה, חזית) 
VALUES 
(1, 101, 2, 1, 50.00, 1, '2023-01-01', '2025-01-01', 1),
(2, 202, 2, 2, 40.00, 2, '2022-06-01', '2024-06-01', 0),
(0, 1, 1, NULL, 200.00, 3, '2021-12-01', NULL, 1);

CREATE TABLE הגדרות (
    מחיר_למטר DECIMAL(10,2) NOT NULL
);

INSERT INTO הגדרות (מחיר_למטר) VALUES (150.00);