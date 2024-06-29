# Functional requirements

## Basic entities:

Basic entities is presented by:
- User
- Project
- Milestone
- Task
- Subtask
- Sprint
- Calendar
- WorkDaysData
- Tags

---

## Entities discription

User has his properties:
- id
- Name
- Role
- ColorCode
- UserName
- Password

Project atributes:
- id
- Name
- Discription
- StartDate
- EndDate
- DeadLine
- DaysFact
- DaysPlan
- SnoozeDays
- Status

Milestone atributes:
- id
- Name
- Discription
- ProjectId
- StartDate
- EndDate
- DeadLine
- DaysFact
- DaysPlan
- SnoozeDays
- Status

Task atributes:
- id
- Tag
- ProjectId
- MileStoneId
- Name
- Discription
- StartDate
- EndDate
- DeadLine
- DaysFact
- DaysPlan
- SnoozeDays

Subtask atribute:
- id
- TaskId
- Name
- StartDate
- EndDate
- DeadLine
- DaysFact
- DaysPlan
- SnoozeDays

Sprint atributes:
- id
- Number
- StartDate
- EndDate
- Tasks list
- WorkDays

Calendar atributes:
- Year
- Month
- Day
- IsWorking

WorkDaysData atributes:
- Year
- Month
- Day
- TaskId
- SubTaskId
- IsCommited

Tags atributes:
- id
- Name
- CollorCode

---

## User scenarios

### Work with user

- Login:
    1. Get authentification token;
    2. Use it for some API cals.
- Rename user name
- Block user
- Create user with a role
- Change user collor
- Reset user password

### Work with task

- Create a project
- Optionaly add a milestones
- Create new task and add some subtasks:
    1. Create a task;
    2. Add a subtasks to task.
- Change task status
- Change subtask status
- Delete a task
- Delete a subtask

---

### Work with Calendar

- Add working days into Calendar
- Change day status for is_working or not_working

---

## List of DB tables

List of DB's tables:
1. Statuses
1. UsersData
1. UsersLogins
1. Projects
1. Milestones
1. Tasks
1. SubTasks
1. Calendar
1. Tags

## Table discriptions

Statuses:
id = 1, status = 'in plan';
id = 2, status = 'in work';
id = 3, status = 'snoozed';
id = 4, status = 'on testing';
id = 5, status = 'fixing';
id = 6, status = 'completed';

---
