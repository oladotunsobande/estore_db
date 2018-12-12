-- ---------------------------------------
-- JEMIMAH ADMIN USER
-- ---------------------------------------
CREATE USER `jmm_sys`@`%` IDENTIFIED BY 'jemimah_manager';

GRANT 
ALL PRIVILEGES 
ON jemimah.* TO 'jmm_sys'@'%';

FLUSH PRIVILEGES;

-- ---------------------------------------
-- JEMIMAH APPLICATION USER
-- ---------------------------------------
CREATE USER `jmm_usr`@`%` IDENTIFIED BY 'jemimah_app';

GRANT
SELECT, UPDATE, INSERT, DELETE, EXECUTE
ON jemimah.* TO 'jmm_sys'@'%';

FLUSH PRIVILEGES;