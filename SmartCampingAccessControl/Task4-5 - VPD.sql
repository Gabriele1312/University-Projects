--Context creation
CREATE CONTEXT camping_ctx USING camping_ctx_pkg;

--Package definition
CREATE OR REPLACE EDITIONABLE PACKAGE admin.camping_ctx_pkg IS
  PROCEDURE set_user_data;
END camping_ctx_pkg;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY admin.camping_ctx_pkg IS
  PROCEDURE set_user_data IS
    username_1 VARCHAR(400);
    user_id USERS.userID%TYPE;
    user_role USERS.role%TYPE;
    user_department USERS.department%TYPE;
    camping_id CAMPING.campingID%TYPE;
    
  BEGIN
    -- Ottieni il nome utente dalla sessione
    username_1 := SYS_CONTEXT('USERENV', 'SESSION_USER');
    DBMS_OUTPUT.PUT_LINE('Username: ' || LOWER(username_1));
    
    -- Ottieni id, ruolo e il dipartimento dell'utente loggato
    SELECT USERS.userID, USERS.role, USERS.department, USERS.camping INTO user_id, user_role, user_department, camping_id
    FROM ADMIN.USERS
    WHERE LOWER(USERS.username) = LOWER(username_1);

    DBMS_OUTPUT.PUT_LINE('Valore di user_id: ' || user_id);
    DBMS_OUTPUT.PUT_LINE('Valore di user_role: ' || user_role);
    DBMS_OUTPUT.PUT_LINE('Valore di user_department: ' || user_department);
    DBMS_OUTPUT.PUT_LINE('Valore di camping_id: ' || camping_id);
    
    -- Imposta il contesto con id, ruolo e il dipartimento dell'utente
    DBMS_SESSION.SET_CONTEXT('camping_ctx', 'user_id', user_id);
    DBMS_SESSION.SET_CONTEXT('camping_ctx', 'user_role', user_role);
    DBMS_SESSION.SET_CONTEXT('camping_ctx', 'user_department', user_department);
    DBMS_SESSION.SET_CONTEXT('camping_ctx', 'camping_id', camping_id);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('No data found for user ' || username_1);
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Unexpected error while setting user context.');
  END set_user_data;

END camping_ctx_pkg;
/

CREATE OR REPLACE EDITIONABLE TRIGGER admin.camping_ctx_trig
AFTER LOGON ON DATABASE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Chiamo il trigger');
    admin.camping_ctx_pkg.set_user_data;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected error in logon trigger.');
END camping_ctx_trig;
/

--POLICY 1: The administrator can access and manage only users registered in his camping.
CREATE OR REPLACE FUNCTION admin.admin_user_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_role VARCHAR2(100);
  camping_id NUMERIC;

BEGIN
  --Retrieve role and camping id from the context
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  camping_id := SYS_CONTEXT('camping_ctx', 'camping_id');
  
  IF user_role = 'Admin' THEN predicate := 'users.camping = ' || camping_id;

  END IF;

  RETURN predicate;
END admin_user_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'USERS',
        POLICY_NAME => 'admin_user_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'ADMIN_USER_INFO'
    );
END;
/


--POLICY 3: Officer employees see the list of customers and guests based on the camping they work (without accessing the username and password fields).
--Create view to exclude the password and username
CREATE VIEW employee_customer_list AS 
SELECT userID, email, name, surname, role, camping
FROM ADMIN.Users
WHERE role='Customer' OR role='Guest'

CREATE OR REPLACE FUNCTION admin.employee_user_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_role VARCHAR2(100);
  user_department VARCHAR2(400);
  camping_id NUMERIC;

BEGIN
  -- Retrieve attributes based on context
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  user_department := SYS_CONTEXT('camping_ctx', 'user_department');
  camping_id := SYS_CONTEXT('camping_ctx', 'camping_id');
  
  IF user_role = 'Employee' AND user_department = 'Officer' THEN predicate := 'employee_customer_list.camping = ' || camping_id;

  END IF;

  RETURN predicate;
END employee_user_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'employee_customer_list',
        POLICY_NAME => 'employee_user_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'EMPLOYEE_USER_INFO',
        STATEMENT_TYPES => 'SELECT'
    );
END;
/

--POLICY 5: The maintenance employee manage the list of external workers based on the campsite (without accessing the username and password fields)
--Create view to hide fields
CREATE VIEW employee_workers_list AS
SELECT userID, email, name, surname, role, department, camping
FROM admin.Users
WHERE role = 'Worker' OR role='Leader';


CREATE OR REPLACE FUNCTION admin.employee_workers_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_role VARCHAR2(100);
  user_department VARCHAR2(400);
  camping_id NUMERIC;

BEGIN
  --Retrieve role, department and campingID of the connected user
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  user_department := SYS_CONTEXT('camping_ctx', 'user_department');
  camping_id := SYS_CONTEXT('camping_ctx', 'camping_id');
  
  IF user_role = 'Employee' AND user_department = 'Maintenance' THEN predicate := 'employee_workers_list.camping = ' || camping_id;

  END IF;

  RETURN predicate;
END employee_workers_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'employee_workers_list',
        POLICY_NAME => 'employee_workers_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'EMPLOYEE_WORKERS_INFO'
    );
END;
/


--POLICY 2-6-7: Admins and Maintenance employees access the history of jobs done based on the camping where they work or manage, leaders access jobs done based on their job
CREATE OR REPLACE FUNCTION admin.maintenance_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_role VARCHAR2(100);
  user_department VARCHAR2(400);
  user_id NUMERIC;
BEGIN
   --Retrieve role,departmente and userID from the application context
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  user_department := SYS_CONTEXT('camping_ctx', 'user_department');
  user_id := SYS_CONTEXT('camping_ctx', 'user_id');
  
  --Predicate to filter the results
  IF user_role = 'Admin' OR (user_role = 'Employee' AND user_department = 'Maintenance') THEN predicate := 'history.camping IN (SELECT c.name FROM Users u JOIN Camping c ON u.camping = c.campingID WHERE u.userID = ' || user_id || ')';
   
  ELSIF user_role = 'Leader' THEN predicate := 'history.department = ''' || user_department || ''''; -- Filtro basato sul dipartimento

  END IF;

  RETURN predicate;
END maintenance_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'HISTORY',
        POLICY_NAME => 'maintenance_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'MAINTENANCE_INFO'
    );
END;
/

--Policy 8: workers can access based on department only to see and enter description and date of work performed
CREATE VIEW worker_maintenance AS
SELECT historyID, description, building, workdate, department FROM ADMIN.History;

CREATE OR REPLACE FUNCTION admin.worker_maintenance_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_role VARCHAR2(100);
  user_department VARCHAR2(400);
BEGIN
  --Role and department from context
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  user_department := SYS_CONTEXT('camping_ctx', 'user_department');
  
  IF user_role = 'Worker' THEN predicate := 'worker_maintenance.department = ''' || user_department || ''''; -- Filtro basato sul dipartimento
  
  END IF;

  RETURN predicate;
END worker_maintenance_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'worker_maintenance',
        POLICY_NAME => 'worker_maintenance_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'WORKER_MAINTENANCE_INFO'
    );
END;
/


--POLICY 9: Customers only access their rentals (current and historical).
CREATE OR REPLACE FUNCTION admin.customer_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_id NUMERIC;
  user_role VARCHAR2(100);
  user_department VARCHAR2(400);
BEGIN
  -- Ottieni il ruolo, ID dal contesto dell'applicazione
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  user_id := SYS_CONTEXT('camping_ctx', 'user_id');
  user_department := SYS_CONTEXT('camping_ctx','user_department');

  IF user_role = 'Admin' THEN predicate := '1=1'; 

  ELSIF user_role = 'Employee' AND user_department = 'Officer' THEN predicate := '1=1';
   
  ELSE predicate := 'contracts.customer = ''' || user_id || ''''; -- Filtro basato sull affito specifico di ogni utente

  END IF;

  RETURN predicate;
END customer_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'CONTRACTS',
        POLICY_NAME => 'customer_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'CUSTOMER_INFO',
        STATEMENT_TYPES => 'SELECT'
    );
END;
/


--POLICY 2-4: Admin and officer employee can only access the rents of own camping
CREATE OR REPLACE FUNCTION admin.camping_customer_info (schema_var VARCHAR2, table_var VARCHAR2)
RETURN VARCHAR2 IS
  predicate VARCHAR2(4000);
  user_id NUMERIC;
  user_role VARCHAR2(100);
  user_department VARCHAR2(400);
BEGIN
  user_id := SYS_CONTEXT('camping_ctx', 'user_id');
  user_role := SYS_CONTEXT('camping_ctx', 'user_role');
  user_department := SYS_CONTEXT('camping_ctx','user_department');

  IF user_role = 'Admin' OR (user_role = 'Employee' AND user_department = 'Officer') THEN predicate := 'contracts.camping IN (SELECT c.name FROM Users u JOIN Camping c ON u.camping = c.campingID WHERE u.userID = ' || user_id || ')'; -- accede solo ai customer relativi ai campeggi che amministra
  END IF;

  RETURN predicate;
END camping_customer_info;
/

BEGIN
    SYS.DBMS_RLS.ADD_POLICY(
        OBJECT_SCHEMA => 'ADMIN',
        OBJECT_NAME => 'CONTRACTS',
        POLICY_NAME => 'camping_customer_info_policy',
        FUNCTION_SCHEMA => 'ADMIN',
        POLICY_FUNCTION => 'CAMPING_CUSTOMER_INFO'
    );
END;
/

-- NEW POLICIES
-- Users should only see contracts that started before the current date
CREATE OR REPLACE FUNCTION contracts_data_policy (
  schema_var IN VARCHAR2,
  table_var IN VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
  RETURN 'startDate < SYSDATE';
END;
/

BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'ADMIN',
    object_name     => 'CONTRACTS',
    policy_name     => 'contracts_data_policy',
    function_schema => 'ADMIN',
    policy_function => 'CONTRACTS_DATA',
  );
END;
/

-- Users can only access records in the History table for the past 5 years
CREATE OR REPLACE FUNCTION history_date_policy (
  schema_name IN VARCHAR2,
  table_name IN VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
  RETURN 'workDate >= ADD_MONTHS(SYSDATE, -60)';
END;
/

BEGIN
  DBMS_RLS.ADD_POLICY(
    object_schema   => 'ADMIN', 
    object_name     => 'HISTORY', 
    policy_name     => 'history_date_policy',
    function_schema => 'ADMIN',
    policy_function => 'HISTORY_DATE',
  );
END;
/

--Controllo
-- Verifica contesto
SELECT * FROM sys.DBA_CONTEXT WHERE NAMESPACE = 'CAMPING_CTX';

-- Verifica package
SELECT * FROM all_objects WHERE object_name = 'CAMPING_CTX_PKG';

-- Verifica trigger
SELECT * FROM all_triggers WHERE trigger_name = 'CAMPING_CTX_TRIG';

-- Verifica policy
SELECT * FROM DBA_POLICIES WHERE object_name = 'CONTRACTS' AND policy_name = 'camping_customer_info_policy';

--Privilegi per funzionamento policy 1
GRANT SELECT,INSERT,UPDATE,DELETE ON USERS TO jdoe;
GRANT SELECT,INSERT,UPDATE,DELETE ON USERS TO gstone;

--Privilegi per funzionamento policy 3
GRANT SELECT ON employee_customer_list TO lgreen;
GRANT SELECT ON employee_customer_list TO vred;

--Privilegi per funzionamento policy 5
GRANT select, insert, update, delete ON employee_workers_list TO pblack;
GRANT select, insert, update, delete ON employee_workers_list TO xcode;

-- Privilegi per accedere allo storico e vedere se funzionano policy 2-6-7
--Admin
GRANT SELECT,INSERT,DELETE,UPDATE ON HISTORY TO jdoe;
GRANT SELECT,INSERT,UPDATE,DELETE ON HISTORY TO gstone;
--Maintenance employees
GRANT SELECT ON HISTORY TO xcode; 
GRANT SELECT ON HISTORY TO pblack; 
GRANT EXECUTE ON ADMIN.CAMPING_CTX_PKG TO pblack; -- questo per simulare il log on
--Workers/leaders
GRANT SELECT, INSERT, UPDATE ON HISTORY TO jparker;

--Privilegi per policy 8
GRANT SELECT, INSERT, UPDATE ON worker_maintenance TO asmith;
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'ASMITH';
GRANT EXECUTE ON ADMIN.CAMPING_CTX_PKG TO asmith; -- questo per simulare il log on

--Privilegi per controllare se funziona policy 9
--Customer
GRANT SELECT ON CONTRACTS TO rjones;
SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = 'RJONES';
GRANT EXECUTE ON ADMIN.CAMPING_CTX_PKG TO rjones;

--Privilegi per controllare se funziona policy 2-4
--Admin
GRANT SELECT,INSERT,UPDATE,DELETE ON CONTRACTS TO gstone;
GRANT SELECT,INSERT,UPDATE,DELETE ON CONTRACTS TO jdoe;
--Officer Employee
GRANT SELECT ON CONTRACTS TO lgreen;
GRANT SELECT ON CONTRACTS TO vred;

--Con utente loggato, simula log on per vedere se salva attributi con contesto 
SET SERVEROUTPUT ON;
EXEC ADMIN.CAMPING_CTX_PKG.set_user_data;
