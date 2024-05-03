drop table if exists monitor_characteristics;
drop table if exists processor_characteristics;
drop table if exists characteristics_descriptions;
drop table if exists characteristics;
drop table if exists product;
drop table if exists category;

drop table if exists monitor_characteristics;
drop table if exists processor_characteristics;
drop table if exists product;
drop table if exists category;


create table category
(
    id   serial8,
    name varchar not null,
    primary key (id)
);

create table characteristics
(
    id          serial8,
    category_id int8    not null,
    name        varchar not null,
    primary key (id),
    foreign key (category_id) references category (id)
);


create table product
(
    id          serial8,
    category_id int8,
    name        varchar not null,
    primary key (id),
    foreign key (category_id) references category (id)
);

create table characteristics_descriptions
(
    id                 serial8,
    characteristics_id int8,
    product_id         int8,
    description        varchar not null,
    primary key (id),
    foreign key (characteristics_id) references characteristics (id),
    foreign key (product_id) references product (id)
);


insert into category(name)
values ('Процессоры'),
       ('Мониторы');

insert into product(category_id, name)
values (1, 'Intel Core I9 9900'),
       (1, 'AMD Ryzen R7 7700'),
       (2, 'Samsung SU556270'),
       (2, 'AOC Z215S659');


insert into characteristics(category_id, name)
values (1, 'Производитель'),
       (1, 'Количество ядер'),
       (1, 'Сокет'),
       (2, 'Производитель'),
       (2, 'Диагональ'),
       (2, 'Матрица'),
       (2, 'Разрешение');

insert into characteristics_descriptions(characteristics_id, product_id, description)
values (1, 1, 'Intel'),
       (2, 1, '8'),
       (3, 1, '1250'),
       (1, 2, 'AMD'),
       (2, 2, '12'),
       (3, 2, 'AM4'),
       (4, 3, 'Samsung'),
       (5, 3, '27'),
       (6, 3, 'TN'),
       (7, 3, '2560*1440'),
       (4, 4, 'AOS'),
       (5, 4, '21.5'),
       (6, 4, 'AH-IPS'),
       (7, 4, '1920*1080');

select c2.name category, c.name characteristics
from characteristics c
         join category c2 on c2.id = c.category_id
where category_id = 2;

select p.name product, c.name characteristics, cd.description description
from product p
         join characteristics c on p.category_id = c.category_id
         join characteristics_descriptions cd on c.id = cd.characteristics_id and cd.product_id = p.id
where p.id = 2;


-- вывести товары, у которых есть характеристика производитель со значением интел
-- и характеристика со значением ядер 8


select p.name product_name, c.name characteristics1, cd.description description,
       f_t.name characteristics2, f_t.description description
from characteristics_descriptions cd
         join product p on cd.product_id = p.id
         join characteristics c on cd.characteristics_id = c.id
         join (select p.name name1,  c.name, cd.description
               from characteristics_descriptions cd
                        join product p on cd.product_id = p.id
                        join characteristics c on cd.characteristics_id = c.id
               where c.name = 'Количество ядер'
                 and cd.description = '8') f_t
              on name1 = p.name
where c.name = 'Производитель'
  and cd.description = 'Intel';

select c.name, p.name, p.price
from product p
join category c on p.category_id = c.id;

alter table product
add column price int8;

update product
set price = 20000
where id = 1;

update product
set price = 25000
where id = 2;

update product
set price = 15000
where id = 3;

update product
set price = 20000
where id = 4;

update product p
set price = price * (100 + 0) / 100
where p.category_id = (select c.id
                       from category c
                       where c.name = 'Мониторы');
















