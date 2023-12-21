if not exists (select * 
from productpostformula 
where formula_id = 650369)
begin
insert into productpostformula values (650004, '2023-11-09 12:50:58.558', 500002,650369,1,null,2941,600) 
end

if not exists (select * 
from productpostformula 
where formula_id = 650370)
begin
insert into productpostformula values (650005, '2023-11-09 12:50:58.558', 500002,650370,1,null,2941,600) 
end
