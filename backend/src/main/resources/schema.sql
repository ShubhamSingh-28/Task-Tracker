CREATE TABLE IF NOT EXISTS tasks (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(255)  NOT NULL,
    description VARCHAR(1000),
    status      VARCHAR(20)   NOT NULL,
    priority    VARCHAR(10)   DEFAULT 'MEDIUM',
    archived    BOOLEAN       DEFAULT FALSE,
    assignee    VARCHAR(100),
    created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_tasks_status CHECK (status IN ('OPEN', 'IN_PROGRESS', 'DONE'))
);

CREATE INDEX IF NOT EXISTS idx_tasks_archived_status_created
    ON tasks (archived, status, created_at);
