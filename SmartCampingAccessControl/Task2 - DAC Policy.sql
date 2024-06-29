--USER CREATION
--Admin of Mountain View camping
CREATE USER jdoe IDENTIFIED BY Password_password_1;
GRANT CREATE SESSION TO jdoe;

--Admin of Sunny Beach camping
CREATE USER gstone IDENTIFIED BY Password_password_16;
GRANT CREATE SESSION TO gstone;

--Officer employee of Mountain View camping
CREATE USER lgreen IDENTIFIED BY Password_password_6;
GRANT CREATE SESSION TO lgreen;

--Officer employee of Sunny Beach camping
CREATE USER vred IDENTIFIED BY Password_password_17;
GRANT CREATE SESSION TO vred;

--Maintenance Employee of Sunny Beach camping
CREATE USER pblack IDENTIFIED BY Password_password_7;
GRANT CREATE SESSION TO pblack;

--Maintenance employee of Lake Paradise camping
CREATE USER xcode IDENTIFIED BY Password_password_15;
GRANT CREATE SESSION TO xcode;

--Electrical leader
CREATE USER bwhite IDENTIFIED BY Password_password_3;
GRANT CREATE SESSION TO bwhite;

--Plumber leader
CREATE USER jparker IDENTIFIED BY Password_password_4;
GRANT CREATE SESSION TO jparker;

--Electrical worker
CREATE USER asmith IDENTIFIED BY Password_password_2;
GRANT CREATE SESSION TO asmith;

--Customer
CREATE USER rjones IDENTIFIED BY Password_password_9;
GRANT CREATE SESSION TO rjones;

--Guest
CREATE USER kharries IDENTIFIED BY Password_password_10;
GRANT CREATE SESSION TO kharries;

--DAC POLICY IMPLEMENTATION

--POLICY 1-2: The administrator of the camping has the privileges needed in order to see all the information to manage the people,contracts and works in his camping.
--user list
CREATE VIEW mountain_view_user_list AS 
SELECT userID, username, password, email, name, surname, role, department, camping
FROM ADMIN.Users 
WHERE camping = 1;

CREATE VIEW sunny_beach_user_list AS 
SELECT userID, username, password, email, name, surname, role, department, camping
FROM ADMIN.Users 
WHERE camping = 2;

CREATE VIEW forest_retreat_user_list AS 
SELECT userID, username, password, email, name, surname, role, department, camping
FROM ADMIN.Users 
WHERE camping = 3;
 
CREATE VIEW lake_paradise_user_list AS 
SELECT userID, username, password, email, name, surname, role, department, camping
FROM ADMIN.Users 
WHERE camping = 4;

--contracts list
CREATE VIEW mountain_view_contracts_baselist AS 
SELECT contractID, camping, customer, startDate, endDate, building, price, powercons, watercons, gascons
FROM ADMIN.Contracts
WHERE camping = 'Mountain View';

CREATE VIEW sunny_beach_contracts_list AS 
SELECT contractID, camping, customer, startDate, endDate, building, price, powercons, watercons, gascons
FROM ADMIN.Contracts
WHERE camping = 'Sunny Beach';

CREATE VIEW forest_retreat_contracts_list AS 
SELECT contractID, camping, customer, startDate, endDate, building, price, powercons, watercons, gascons
FROM ADMIN.Contracts
WHERE camping = 'Forest Retreat';
 
CREATE VIEW lake_paradise_contracts_list AS 
SELECT contractID, camping, customer, startDate, endDate, building, price, powercons, watercons, gascons
FROM ADMIN.Contracts
WHERE camping = 'Lake Paradise';


--history list
CREATE VIEW mountain_view_history_list AS 
SELECT historyID, camping, description, workdate, building, department, cost
FROM ADMIN.History
WHERE camping = 'Mountain View';

CREATE VIEW sunny_beach_history_list AS 
SELECT historyID, camping, description, workdate, building, department, cost
FROM ADMIN.History
WHERE camping = 'Sunny Beach';

CREATE VIEW forest_retreat_history_list AS 
SELECT historyID, camping, description, workdate, building, department, cost
FROM ADMIN.History
WHERE camping = 'Forest Retreat';
 
CREATE VIEW lake_paradise_history_list AS 
SELECT historyID, camping, description, workdate, building, department, cost
FROM ADMIN.History
WHERE camping = 'Lake Paradise';

GRANT select,insert,update,delete ON mountain_view_user_list TO jdoe WITH GRANT OPTION;
GRANT select,insert,update,delete ON mountain_view_contracts_list TO jdoe WITH GRANT OPTION;
GRANT select,insert,update,delete ON mountain_view_history_list TO jdoe WITH GRANT OPTION;
GRANT select,insert,update,delete ON buildings TO jdoe WITH GRANT OPTION;

GRANT select,insert, update,delete ON sunny_beach_user_list TO gstone WITH GRANT OPTION;
GRANT select,insert, update,delete ON sunny_beach_contracts_list TO gstone WITH GRANT OPTION;
GRANT select,insert, update,delete ON sunny_beach_history_list TO gstone WITH GRANT OPTION;
GRANT select,insert,update,delete ON buildings TO gstone WITH GRANT OPTION;

--POLICY 3: The officer employee can only see the list of customer / guest of own camping except the credential (username and password).
CREATE VIEW MV_employee_customer_list AS 
SELECT userID, email, name, surname, role, camping
FROM ADMIN.mountain_view_user_list
WHERE role='Customer' OR role='Guest';

CREATE VIEW SB_employee_customer_list AS 
SELECT userID, email, name, surname, role, camping
FROM ADMIN.sunny_beach_user_list
WHERE role='Customer' OR role='Guest';

CREATE VIEW FR_employee_customer_list AS 
SELECT userID, email, name, surname, role, camping
FROM ADMIN.forest_retreat_user_list
WHERE role='Customer' OR role='Guest';

CREATE VIEW LP_employee_customer_list AS 
SELECT userID, email, name, surname, role, camping
FROM ADMIN.lake_paradise_user_list
WHERE role='Customer' OR role='Guest';

GRANT select ON MV_employee_customer_list TO lgreen;
GRANT select ON SB_employee_customer_list TO vred;

--POLICY 4: The officer employee can manage the list of contracts, in order to handle the rents of the camping where they work.
GRANT select,insert,update,delete ON mountain_view_contracts_list TO lgreen;
GRANT select,insert,update,delete ON sunny_beach_contracts_list TO vred;

--POLICY 5: The maintenance employee can manage the list of workers and leader of each department
CREATE VIEW MV_employee_worker_list AS 
SELECT userID, email, name, surname, role, department, camping
FROM ADMIN.mountain_view_user_list
WHERE role='Leader' OR role='Worker';

CREATE VIEW SB_employee_worker_list AS 
SELECT userID, email, name, surname, role, department, camping
FROM ADMIN.sunny_beach_user_list
WHERE role='Leader' OR role='Worker';

CREATE VIEW FR_employee_worker_list AS 
SELECT userID, email, name, surname, role, department, camping
FROM ADMIN.forest_retreat_user_list
WHERE role='Leader' OR role='Worker';

CREATE VIEW LP_employee_worker_list AS 
SELECT userID, email, name, surname, role, department, camping
FROM ADMIN.lake_paradise_user_list
WHERE role='Leader' OR role='Worker';

GRANT select,insert,update,delete ON SB_employee_worker_list TO pblack;
GRANT select,insert,update,delete ON LP_employee_worker_list TO xcode;

--POLICY 6: The maintenance employee can access the history table of own camping in order to manage the maintenance operations
GRANT select,insert,update,delete ON sunny_beach_history_list TO pblack;
GRANT select,insert,update,delete ON lake_paradise_history_list TO xcode;

--POLICY 7: Leader can see and modify specific maintenance done by worker of its own department
CREATE VIEW electric_maintenance AS
SELECT * FROM ADMIN.History 
WHERE department='Electrical';

CREATE VIEW plumber_maintenance AS
SELECT * FROM ADMIN.History 
WHERE department='Plumber';

CREATE VIEW security_maintenance AS
SELECT * FROM ADMIN.History 
WHERE department='Surveillance';

GRANT select, insert, update ON electric_maintenance TO bwhite;
GRANT select, insert, update ON plumber_maintenance TO jparker;

--POLICY 8: Workers, based on department, can only see and modify not sensible information of the work (i.e price)
CREATE VIEW worker_electric_maintenance AS
SELECT historyID, camping, description, workDate, building FROM ADMIN.electric_maintenance;

CREATE VIEW worker_plumber_maintenance AS
SELECT historyID, camping, description, workDate, building FROM ADMIN.plumber_maintenance;

CREATE VIEW worker_security_maintenance AS
SELECT historyID, camping, description, workDate, building FROM ADMIN.security_maintenance;

GRANT select, insert, update ON worker_electric_maintenance TO asmith;

--POLICY 9: The customer can see the entire information about its contract in all campsites

--POLICY 10: The guest, which is the other component of the family who rent the building, can access only the typology of building and its price


