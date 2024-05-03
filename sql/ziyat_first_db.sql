drop table if exists humans;

create table humans
(
    id serial8,
  first_name varchar not null,
  birthdate date not null,
  position varchar default 'Unemployed' not null,
  income int4 default 0 not null,
  primary key (id)
);

insert into humans(first_name, birthdate, position, income)
values ('Mark', '1992-02-07', 'Developer', 2600),
       ('Jordan', '1999-05-12', 'Designer', 1900);

insert into humans(first_name, birthdate, position, income)
values ('Jeff', '1979-07-17', 'Manager', 3400),
       ('Nick', '1995-12-12', 'Designer', 2300);

insert into humans(first_name, birthdate)
values ('John', '2002-09-19'),
       ('Bill', '1984-05-01');

update humans
set position = 'Developer',
    income = 3200
where id = 4;

update humans
set income = 1.1 * income
where position = 'Developer';

delete
from humans
where position = 'Unemployed';

select *
from humans
where position != 'Unemployed';

select *
from humans
where birthdate >= '1990-01-01' and birthdate < '2000-01-01';

select *
from humans
where position = 'Developer' or position = 'Designer';

select *
from humans
where position = 'Developer' and income < 3000
   or position = 'Designer' and income < 2000;

select *
from humans
where first_name like 'J%';

select count(id) employed
from humans
where position != 'Unemployed';

select position, avg(income) average_income, count(id)
from humans
where position != 'Unemployed'
group by position
order by avg(income) desc;