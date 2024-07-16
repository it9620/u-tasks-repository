DROP SCHEMA IF EXISTS u_tasks_repository CASCADE;

CREATE SCHEMA IF NOT EXISTS u_tasks_repository;

CREATE TYPE u_tasks_repository.status AS ENUM ('in_plane', 'in_work', 'snoozed', 'on_testing', 'fixing', 'done');

CREATE TYPE u_tasks_repository.role AS ENUM ('admin', 'user');

-- Users tables
CREATE TABLE IF NOT EXISTS u_tasks_repository.users_data (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    color VARCHAR(7) CHECK (color ~ '^#[0-9A-Fa-f]{6}$') DEFAULT '#334FFF'
);

CREATE TABLE IF NOT EXISTS u_tasks_repository.users_logins (
    id UUID PRIMARY KEY,
    user_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(128) NOT NULL,
    role u_tasks_repository.role DEFAULT 'user'
);

-- Tasks tables

-- Create the projects table
CREATE TABLE IF NOT EXISTS u_tasks_repository.projects (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    begin_date DATE,
    end_date DATE,
    deadline DATE,
    days_count_fact DOUBLE PRECISION CHECK(days_count_fact >= 0),
    days_count_plan DOUBLE PRECISION CHECK(days_count_plan >= 0),
    snoozed_days_count DOUBLE PRECISION CHECK(snoozed_days_count >= 0),
    status u_tasks_repository.status DEFAULT 'in_plane'
);

-- Create the milestones table
CREATE TABLE IF NOT EXISTS u_tasks_repository.milestones (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    project_id UUID REFERENCES u_tasks_repository.projects(id),
    begin_date DATE,
    end_date DATE,
    deadline DATE,
    days_count_fact DOUBLE PRECISION CHECK(days_count_fact >= 0),
    days_count_plan DOUBLE PRECISION CHECK(days_count_plan >= 0),
    snoozed_days_count DOUBLE PRECISION CHECK(snoozed_days_count >= 0),
    status u_tasks_repository.status DEFAULT 'in_plane'
);

-- Create the tasks table
CREATE TABLE IF NOT EXISTS u_tasks_repository.tasks (
    id UUID PRIMARY KEY,
    tag VARCHAR(255),
    project_id UUID REFERENCES u_tasks_repository.projects(id),
    milestone_id UUID REFERENCES u_tasks_repository.milestones(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    begin_date DATE,
    end_date DATE,
    deadline DATE,
    days_count_fact DOUBLE PRECISION CHECK(days_count_fact >= 0),
    days_count_plan DOUBLE PRECISION CHECK(days_count_plan >= 0),
    snoozed_days_count DOUBLE PRECISION CHECK(snoozed_days_count >= 0),
    status u_tasks_repository.status DEFAULT 'in_plane'
);

-- Create the subtasks table
CREATE TABLE IF NOT EXISTS u_tasks_repository.subtasks (
    id UUID PRIMARY KEY,
    task_id UUID REFERENCES u_tasks_repository.tasks(id),
    name VARCHAR(255) NOT NULL,
    begin_date DATE,
    end_date DATE,
    deadline DATE,
    days_count_fact DOUBLE PRECISION CHECK(days_count_fact >= 0),
    days_count_plan DOUBLE PRECISION CHECK(days_count_plan >= 0),
    snoozed_days_count DOUBLE PRECISION CHECK(snoozed_days_count >= 0),
    status u_tasks_repository.status DEFAULT 'in_plane'
);

-- Tags table
CREATE TABLE IF NOT EXISTS u_tasks_repository.tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    color VARCHAR(7) CHECK (color ~ '^#[0-9A-Fa-f]{6}$') DEFAULT '#FF1515'
);

-- Junction table for tasks and tags
CREATE TABLE IF NOT EXISTS u_tasks_repository.task_tags (
    task_id UUID REFERENCES u_tasks_repository.tasks(id),
    tag_id INTEGER REFERENCES u_tasks_repository.tags(id),
    PRIMARY KEY (task_id, tag_id)
);

--- End of Tasks tables

--- Calendar table
CREATE TABLE IF NOT EXISTS u_tasks_repository.calendar (
    date DATE NOT NULL PRIMARY KEY,
    is_workday BOOLEAN DEFAULT TRUE
);

--- Workdays table - it's like junction table for users, tasks, and subtasks
CREATE TABLE IF NOT EXISTS u_tasks_repository.workdays (
    id SERIAL PRIMARY KEY,
    date DATE REFERENCES u_tasks_repository.calendar(date),
    user_id UUID REFERENCES u_tasks_repository.users_data(id),
    task_id UUID REFERENCES u_tasks_repository.tasks(id),
    subtask_id UUID REFERENCES u_tasks_repository.subtasks(id),
    work_time DOUBLE PRECISION CHECK(work_time >= 0) -- in days
);

--- Sprints_list table
CREATE TABLE IF NOT EXISTS u_tasks_repository.sprints_list (
    id UUID PRIMARY KEY,
    number INTEGER NOT NULL,
    begin_date DATE NOT NULL,
    end_date DATE NOT NULL
);

--- Sprint_content table
CREATE TABLE IF NOT EXISTS u_tasks_repository.sprints_tasks (
    id UUID PRIMARY KEY,
    sprint_id UUID REFERENCES u_tasks_repository.sprints_list(id),
    begin_date DATE NOT NULL,
    end_date DATE NOT NULL,
    task_id UUID REFERENCES u_tasks_repository.tasks(id) NOT NULL,
    subtask_id UUID REFERENCES u_tasks_repository.subtasks(id),
    user_id UUID REFERENCES u_tasks_repository.users_data(id),
    is_fact BOOLEAN DEFAULT FALSE
);
