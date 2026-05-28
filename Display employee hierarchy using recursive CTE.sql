with recursive data_hierarchy as
(
select
employee_id, employee_name, manager_id, 1 as level from employee 
where manager_id is null
union all
select 
w.employee_id, w.employee_name, w.manager_id, w.level+1
from employee w join data_hierarchy as eh 
on e.manager_id = eh.employee_id
)
select * from data_hierarchy
