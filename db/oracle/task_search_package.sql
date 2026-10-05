-- Oracle PL/SQL package for task search
-- This is a reference artifact — it does not run locally against H2.
-- It mirrors the logic used by the Spring Data repository and is
-- representative of the kind of Oracle PL/SQL found in production.

CREATE OR REPLACE PACKAGE task_search_pkg AS

    TYPE task_record IS RECORD (
        id          NUMBER,
        title       VARCHAR2(255),
        description VARCHAR2(1000),
        status      VARCHAR2(20),
        priority    VARCHAR2(10),
        assignee    VARCHAR2(100),
        created_at  TIMESTAMP
    );

    TYPE task_cursor IS REF CURSOR RETURN task_record;

    PROCEDURE search_tasks(
        p_search_term IN  VARCHAR2 DEFAULT NULL,
        p_status      IN  VARCHAR2 DEFAULT NULL,
        p_page        IN  NUMBER   DEFAULT 1,
        p_page_size   IN  NUMBER   DEFAULT 10,
        p_results     OUT task_cursor,
        p_total_count OUT NUMBER
    );

END task_search_pkg;
/

CREATE OR REPLACE PACKAGE BODY task_search_pkg AS

    PROCEDURE search_tasks(
        p_search_term IN  VARCHAR2 DEFAULT NULL,
        p_status      IN  VARCHAR2 DEFAULT NULL,
        p_page        IN  NUMBER   DEFAULT 1,
        p_page_size   IN  NUMBER   DEFAULT 10,
        p_results     OUT task_cursor,
        p_total_count OUT NUMBER
    ) IS
        v_term   VARCHAR2(1000);
        v_offset NUMBER;
    BEGIN
        -- cap length to 100 chars and escape LIKE wildcards ('!' is the escape char)
        v_term   := '%' ||
                    REPLACE(REPLACE(REPLACE(LOWER(SUBSTR(NVL(p_search_term, ''), 1, 100)),
                            '!', '!!'), '%', '!%'), '_', '!_') || '%';
        v_offset := (GREATEST(NVL(p_page, 1), 1) - 1) * NVL(p_page_size, 10);

        -- Total count for pagination metadata
        SELECT COUNT(*)
          INTO p_total_count
          FROM tasks
         WHERE archived = 0
           AND (LOWER(title) LIKE v_term ESCAPE '!' OR LOWER(description) LIKE v_term ESCAPE '!')
           AND (p_status IS NULL OR status = p_status);

        -- Paginated results using OFFSET/FETCH (Oracle 12c+)
        OPEN p_results FOR
            SELECT id, title, description, status, priority, assignee, created_at
              FROM tasks
             WHERE archived = 0
               AND (LOWER(title) LIKE v_term ESCAPE '!' OR LOWER(description) LIKE v_term ESCAPE '!')
               AND (p_status IS NULL OR status = p_status)
             ORDER BY created_at DESC, id DESC
            OFFSET v_offset ROWS FETCH NEXT NVL(p_page_size, 10) ROWS ONLY;

    END search_tasks;

END task_search_pkg;
/
