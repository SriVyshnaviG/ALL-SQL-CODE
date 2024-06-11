create view adults
AS
select * from employee_demographics
where age>18;

describe adults;

create or replace view adults (ID, age) 
AS
select employee_id,age from employee_demographics
where age >=18;

create or replace view employee_vw (department, occupation, avg_salary)
as
select pd.department_name, es.occupation,avg(es.salary)
from employee_salary es JOIN parks_departments pd
on es.dept_id = pd.department_id
-- where age > 30
group by department_id, occupation;
-- with check option CONSTRAINT emp_vw_chk; it is not available in mysql -helps with DML later on

select * from employee_vw;
create or replace view employee_vw (department, occupation, avg_salary)
as
select pd.department_name, es.occupation,avg(es.salary)
from employee_salary es JOIN parks_departments pd
on es.dept_id = pd.department_id
-- where age > 30
group by department_id, occupation;
-- with read only; it is not available in mysql - doesn't allow DML

DROP view employee_vw;
