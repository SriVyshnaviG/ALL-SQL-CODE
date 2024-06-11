select * from Parks_and_Recreation.employee_demographics
where first_name LIKE 'a___%' AND age >18 AND gender != 'Female' AND birth_date > '1985-01-01';
# Matches first names that start with 'a' followed by exactly three more characters.