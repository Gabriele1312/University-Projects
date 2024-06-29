-- Create Camping Table
CREATE TABLE Camping (
    campingID NUMBER,
    name VARCHAR(255),
    place VARCHAR(255),
    CONSTRAINT PK_IDcamping PRIMARY KEY (campingID),
    CONSTRAINT UNIQUE_NAME UNIQUE (name)
);

-- Create Users Table
CREATE TABLE Users (
    userID NUMBER,
    username VARCHAR(255),
    password VARCHAR(255),
    email VARCHAR(255),
    name VARCHAR(255),
    surname VARCHAR(255),
    role VARCHAR(255),
    department VARCHAR(255),
    camping NUMBER,
    CONSTRAINT PK_ID PRIMARY KEY (userID),
    CONSTRAINT FK_CAMPING_USERS FOREIGN KEY (camping) REFERENCES Camping (campingID)
);

-- Create Buildings Table
CREATE TABLE Buildings (
    buildingID NUMBER,
    typology VARCHAR(255),
    position VARCHAR(255),
    CONSTRAINT PK_BUILDING_ID PRIMARY KEY (buildingID)
);

-- Create History Table
CREATE TABLE History (
    historyID NUMBER,
    camping VARCHAR(255),
    description VARCHAR(255),
    workDate DATE,
    building NUMBER,
    department VARCHAR(255),
    cost NUMBER,
    CONSTRAINT PK_HISTORY_ID PRIMARY KEY (historyID),
    CONSTRAINT FK_CAMPING_HISTORY FOREIGN KEY (camping) REFERENCES Camping (name),
    CONSTRAINT FK_BUILDING_HISTORY FOREIGN KEY (building) REFERENCES Buildings (buildingID)
);

-- Create Contracts Table
CREATE TABLE Contracts (
    contractID NUMBER,
    camping VARCHAR(255),
    customer NUMBER,
    startDate DATE,
    endDate DATE,
    building NUMBER,
    price NUMBER,
    powerCons NUMBER,
    waterCons NUMBER,
    gasCons NUMBER,    
    CONSTRAINT PK_CONTRACTS_ID PRIMARY KEY (contractID),
    CONSTRAINT FK_BUILDING_CONTRACTS FOREIGN KEY (building) REFERENCES Buildings (buildingID),
    CONSTRAINT FK_CAMPING_CONTRACTS FOREIGN KEY (camping) REFERENCES Camping (name),
    CONSTRAINT FK_CUSTOMER_CONTRACTS FOREIGN KEY (customer) REFERENCES Users (userID)
);


INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (1, 'jdoe', 'Password_password_1', 'jdoe@example.com', 'John', 'Doe', 'Admin', NULL, 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (2, 'asmith', 'Password_password_2', 'asmith@example.com', 'Anna', 'Smith', 'Worker', 'Electrical', 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (3, 'bwhite', 'Password_password_3', 'bwhite@example.com', 'Brian', 'White', 'Leader', 'Electrical', 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (4, 'jparker', 'Password_password_4', 'jparker@example.com', 'Jack', 'Parker', 'Leader', 'Plumber', 2);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (5, 'smiller', 'Password_password_5', 'smiller@example.com', 'Sara', 'Miller', 'Leader', 'Surveillance', 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (6, 'lgreen', 'Password_password_6', 'lgreen@example.com', 'Laura', 'Green', 'Employee', 'Officer', 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (7, 'pblack', 'Password_password_7', 'pblack@example.com', 'Paul', 'Black', 'Employee', 'Maintenance', 2);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (8, 'jking', 'Password_password_8', 'jking@example.com', 'Julia', 'King', 'Customer', NULL, 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (9, 'rjones', 'Password_password_9', 'rjones@example.com', 'Robert', 'Jones', 'Customer', NULL, 2);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (10, 'kharris', 'Password_password_10', 'kharris@example.com', 'Karen', 'Harris', 'Guest', NULL, 1);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (11, 'tthompson', 'Password_password_11', 'tthompson@example.com', 'Tom', 'Thompson', 'Admin', NULL, 2);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (12, 'lwilson', 'Password_password_12', 'lwilson@example.com', 'Laura', 'Wilson', 'Admin', NULL, 3);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (13, 'fbush', 'Password_password_13', 'fbush@example.com', 'Ferdinand', 'Bush', 'Customer', NULL, 3);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (14, 'abuff', 'Password_password_14', 'abuff@example.com', 'Andrew', 'Buffalo', 'Customer', NULL, 4);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (15, 'xcode', 'Password_password_15', 'xcode@example.com', 'Xami', 'Code', 'Employee', 'Maintenance', 4);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (16, 'gstone', 'Password_password_16', 'gstone@example.com', 'Gabriel', 'Stone', 'Admin', NULL, 2);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (17, 'vred', 'Password_password_17', 'vred@example.com', 'Victoria', 'Red', 'Employee', 'Officer', 2);
INSERT INTO Users (userID, username, password, email, name, surname, role, department, camping) VALUES (18, 'ypurple', 'Password_password_18', 'ypurple@example.com', 'Yannik', 'Purple', 'Worker', 'Surveillance', 4);

INSERT INTO Camping (campingID, name, place) VALUES (1, 'Mountain View', 'Rocky Mountains');
INSERT INTO Camping (campingID, name, place) VALUES (2, 'Sunny Beach', 'California Coast');
INSERT INTO Camping (campingID, name, place) VALUES (3, 'Forest Retreat', 'Black Forest');
INSERT INTO Camping (campingID, name, place) VALUES (4, 'Lake Paradise', 'Great Lakes');

INSERT INTO Buildings (buildingID, typology, position) VALUES (1, 'ApartmentA', 'Lake');
INSERT INTO Buildings (buildingID, typology, position) VALUES (2, 'ApartmentB', 'Garden');
INSERT INTO Buildings (buildingID, typology, position) VALUES (3, 'ApartmentC', 'Pool');
INSERT INTO Buildings (buildingID, typology, position) VALUES (4, 'Camper Pitch', 'Garden');
INSERT INTO Buildings (buildingID, typology, position) VALUES (5, 'Camper Pitch', 'Lake');
INSERT INTO Buildings (buildingID, typology, position) VALUES (6, 'Bungalow', 'Pool');
INSERT INTO Buildings (buildingID, typology, position) VALUES (7, 'Bungalow', 'Pool');
INSERT INTO Buildings (buildingID, typology, position) VALUES (8, 'Bungalow', 'Lake');

INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (10, 'Mountain View', 'Replaced electrical wiring', DATE '2023-09-01', 1, 'Electrical', 1200);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (11, 'Mountain View', 'Fixed broken pipes', DATE '2023-09-10', 2, 'Plumber', 800);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (12, 'Sunny Beach', 'Installed new surveillance cameras', DATE '2023-09-20', 2, 'Surveillance', 1500);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (13, 'Sunny Beach', 'Upgraded circuit breakers', DATE '2023-10-01', 4, 'Electrical', 1300);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (14, 'Forest Retreat', 'Repaired water heater', DATE '2023-10-10', 6, 'Plumber', 600);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (15, 'Lake Paradise', 'Serviced alarm system', DATE '2023-10-20', 6, 'Surveillance', 1100);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (16, 'Lake Paradise', 'Installed LED lighting', DATE '2023-11-01', 7, 'Electrical', 1400);
INSERT INTO History (historyID, camping, description, workDate, building, department, cost) VALUES (17, 'Forest Retreat','Cleared clogged drains', DATE '2023-11-10', 8, 'Plumber', 500);

INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (1, 'Mountain View', 8, DATE '2024-01-01', DATE '2024-01-10', 1, 1000, 50, 30, 20);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (2, 'Sunny Beach', 9, DATE '2024-02-01', DATE '2024-02-15', 2, 1200, 60, 40, 30);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (3, 'Forest Retreat', 13, DATE '2021-03-01', DATE'2021-03-10', 3, 800, 40, 20, 10);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (4, 'Lake Paradise', 14, DATE '2024-04-01', DATE '2024-04-20', 6, 1500, 70, 50, 40);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (5, 'Sunny Beach', 14, DATE '2022-05-01', DATE '2022-05-15', 6, 1100, 45, 35, 25);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (6, 'Forest Retreat', 8, DATE '2023-06-01', DATE '2023-06-10', 1, 900, 55, 25, 15);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (7, 'Lake Paradise', 13, DATE '2023-07-01', DATE '2023-07-20', 7, 1400, 65, 45, 35);
INSERT INTO Contracts (contractID, camping, customer, startDate, endDate, building, price, powerCons, waterCons, gasCons) VALUES (8, 'Mountain View', 9, DATE '2020-08-01', DATE '2020-08-15', 2, 1600, 75, 55, 45);
