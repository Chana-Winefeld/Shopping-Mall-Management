CREATE DATABASE ShoppingMall;
GO


USE ShoppingMall;
GO

CREATE TABLE StoreTypes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(50) NOT NULL
);

INSERT INTO StoreTypes (Name) VALUES ('Food'), ('General'), ('Clothing'),('toys');

CREATE TABLE Owners (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(100) NOT NULL,
    Tz VARCHAR(20) NOT NULL,
	Address VARCHAR(20), 
    PhoneNumber VARCHAR(20),
	Email_Address VARCHAR(255)
	
);
INSERT INTO Owners (FullName, Tz,Address,PhoneNumber,Email_Address) VALUES 
('David Cohen', '123456789','Jerusalem','0548478897','8644616@gmail.com'), 
('Ronit Levi', '987654321','Eilat','0546589009','hjg5545@gmail.com'), 
('Moshe Israeli', '456789123','Beitar','058484458','s656265@gmail.com'),
('Yael Peretz', '223344556','Hifa','052121548','a53446@gmail.com'),
('Avi Ben-David', '998877665','Arad','054151879','chaniv6487@gmail.com'),
('Tamar Gal', '112233445','Jerusalem','0541879658','TG454@gmail.com'),
('Yossi Shalom', '334455667','Bnei Brak','052658792','y78555@gmail.com'),
('Maya Katz', '556677889','Netivot','025804565','maya@gmail.com'),
('Sara Katzen', '329396881','Beitar','0548504567','s0548504567@gmail.com'),
('Chani Winfeld', '215862749','Tel Tzion','0504103800','965563@gmail.com'),
('Rachel Mizrachi', '889900112','Jerusalem','057958859','iuhkh@gmail.com'),
('Dan Green', '990011223','Eilat','025558787','hghj5@gmail.com'),
('Yonatan Azulay', '100200300','Ashdod','023456789','y300@gmail.com'),
('Shira Tal', '200300400','Ofakim','054879568','ggu@gmail.com'),
('Elad Nissim', '300400500','Beit Shemsh','0589546235','elad@gmail.com'),
('Nitzan Oren', '400500600','Sderot','0537615488','utgjj@gmail.com'),
('Galit Shitrit', '500600700','Ashkelon','0256879585','fg@gmail.com'),
('Omer Sasson', '600700800',null,'05697554564','gujhj@gmail.com'),
('Alon Hadad', '700800900',null,'02542365554','yugji@gmail.com'),
('Michal Arbel', '800900100','Beit Hilkiya','025698732','tgdcjh@gmail.com'),
('Rafi Menashe', '900100200','Jericho','0845623358','rafi200@gmail.com');

CREATE TABLE PlaceTypes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(50) NOT NULL,
 
);
INSERT INTO PlaceTypes (Name) VALUES ('Parking'), ('Store'), ('Synagogue'),('Bathroom');


CREATE TABLE Spaces (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FloorNumber INT NOT NULL,
    NumberInFloor INT NOT NULL,
    SizeInMeters DECIMAL(10,2) NOT NULL,
    Occipital_Area bit,
	Front_Window bit
);

INSERT INTO Spaces (FloorNumber, NumberInFloor, SizeInMeters,Occipital_Area,Front_Window) 
VALUES 
(1, 101,5 , 50.00,0),
(2, 202,5 , 40.00,1),
(0, 1,6 , 200.00,0);

CREATE TABLE SpacesRental (
    Id INT PRIMARY KEY IDENTITY(1,1),
	Id_PlaceTypes INT REFERENCES PlaceTypes(Id),
	Id_Spaces INT REFERENCES Spaces(Id),
	Id_StoreTypes INT REFERENCES StoreTypes(Id),
	Id_Owners INT REFERENCES Owners(Id),
    RentalStartDate DATE NOT NULL,
    RentalEndDate DATE NOT NULL,
	Store_Name VARCHAR (15),
	Description VARCHAR (30),
	Store_Phone VARCHAR(20)

);

INSERT INTO SpacesRental (Id_PlaceTypes, Id_Spaces, Id_StoreTypes, Id_Owners, RentalStartDate, RentalEndDate, Store_Name, Description, Store_Phone) 
VALUES 
(1, 1, 1, 1, '2023-01-01', '2025-01-01', 'Mango', 'חנות בגדים', '087653214');


CREATE TABLE Settings (
    PricePerMeter DECIMAL(10,2) NOT NULL,
	--הנחה לעורפי 
	BackShop BIT,
	--תוספת לחלון לקדמי
	FrontWindow BIT
);

INSERT INTO Settings (PricePerMeter) VALUES (150.00)

