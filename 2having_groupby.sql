select gender, AVG(age) 
from employee_demographics
GROUP BY gender
HAVING AVG(age)>30;

select occupation, AVG(salary) 
from employee_salary
where occupation LIKE '%manager%'#row level #aggregation will give error
GROUP BY occupation
HAVING AVG(salary)>75000;#aggregate function level after group by runs


