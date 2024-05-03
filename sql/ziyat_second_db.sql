drop table if exists users;
drop table if exists user_data;



create table user_data
(
    id              serial8,
    document_number varchar not null,
    f_name          varchar not null,
    l_name          varchar not null,
    birthdate       date    not null,
    primary key (id)
);

create table users
(
    id           serial8,
    user_data_id int8    not null,
    login        varchar not null,
    password     varchar not null,
    primary key (id),
    unique (user_data_id),
    foreign key (user_data_id) references user_data (id)
);



insert into user_data(document_number, f_name, l_name, birthdate)
values ('US7722315643', 'Bill', 'Gates', '1972-02-12'),
       ('UK1212870600', 'Mark', 'Miller', '1980-03-03');

insert into users(user_data_id, login, password)
values (2, 'mark.m', 'Mark#M123'),
       (1, 'bill.g', 'Bill#$Gates');

select u.id, u.login, ud.f_name, ud.l_name
from users u
         join user_data ud on u.user_data_id = ud.id;

drop table if exists orders_products;
drop table if exists orders;
drop table if exists products;
drop table if exists category;
drop table if exists discounts;


create table category
(
    id   serial8,
    name varchar not null,
    unique (name),
    primary key (id)
);

create table products
(
    id          serial8,
    category_id int8    not null,
    name        varchar not null,
    price       int4    not null,
    primary key (id),
    foreign key (category_id) references category (id)
);

create table discounts
(
    id       serial8,
    discount int8,
    primary key (id)
);

create table orders
(
    id           serial8,
    discounts_id int8,
    status       varchar   not null,
    date_time    timestamp not null,
    primary key (id),
    foreign key (discounts_id) references discounts (id)
);



create table orders_products
(
    id              serial8,
    orders_id       int8,
    products_id     int8,
    primary key (id),
    products_number int8 not null,
    foreign key (orders_id) references orders (id),
    foreign key (products_id) references products (id)
);

insert into category(name)
values ('Cars'),
       ('Furniture');

insert into products(category_id, name, price)
values (1, 'Toyota Camry 5', 200000),
       (1, 'Lexus ES250', 250000),
       (1, 'Nissan Juke', 150000),
       (2, 'Table', 10000),
       (2, 'Chair', 5000),
       (2, 'Armchair', 7000);

select c.id, c.name, p.name, p.price
from category c
         join products p on c.id = p.category_id
group by c.id, p.id
order by p.price desc;

select c.id, c.name, round(avg(p.price)) average_price, count(p.id) products_number
from category c
         join products p on c.id = p.category_id
group by c.id
order by average_price desc;

insert into discounts (discount)
values (10),
       (5);

insert into orders(discounts_id, status, date_time)
values (1, 'Оформлено', '2024-02-23 15:00'),
       (2, 'Доставлено', '2024-02-15 12:00');

insert into orders (status, date_time)
values ('Отправлено', '2024-01-05 14:30');

insert into orders_products(orders_id, products_id, products_number)
values (1, 2, 1),
       (1, 3, 2),
       (1, 5, 5),
       (2, 2, 1),
       (3, 1, 2);

select o.id,
       o.status,
       o.date_time,
       sum(op.products_number)                                                   products_number,
       sum(p.price * op.products_number) * (100 - coalesce(d.discount, 0)) / 100 order_cost
from orders o
         left join discounts d on d.id = o.discounts_id
         join orders_products op on o.id = op.orders_id
         join products p on p.id = op.products_id
group by o.id, d.discount
order by o.id;

-- название категорий, товары которых покупались чаще
select t_t.products_id, sum(t_t.products_number) bought_number
from (select op.products_id, op.products_number
      from orders_products op) t_t
group by t_t.products_id
order by t_t.products_id;


select max(bought_number) bought_number_max
from (select t_t.products_id, sum(t_t.products_number) bought_number
      from (select op.products_id, op.products_number
            from orders_products op) t_t
      group by t_t.products_id
      order by t_t.products_id) t_t1;


select c.name category, bought_number
from (select t_t.products_id, sum(t_t.products_number) bought_number
      from (select op.products_id, op.products_number
            from orders_products op) t_t
      group by t_t.products_id
      order by t_t.products_id) t_t1
         join products p on t_t1.products_id = p.id
         join category c on c.id = p.category_id
where bought_number = (select max(bought_number) bought_number_max
                       from (select t_t.products_id, sum(t_t.products_number) bought_number
                             from (select op.products_id, op.products_number
                                   from orders_products op) t_t
                             group by t_t.products_id
                             order by t_t.products_id) t_t2);

select op.products_id, sum(op.products_number) bought_number
from orders_products op
group by op.products_id;

select max(bought_number) bought_number_max
from (select op.products_id, sum(op.products_number) bought_number
      from orders_products op
      group by op.products_id) t_t;

select c.name category, bought_number
from (select op.products_id, sum(op.products_number) bought_number
      from orders_products op
      group by op.products_id) t_t
         join products p on products_id = p.id
         join category c on c.id = p.category_id
where bought_number = (select max(bought_number) bought_number_max
                       from (select op.products_id, sum(op.products_number) bought_number
                             from orders_products op
                             group by op.products_id) t_t);



select c.id, c.name, sum(op.products_number) bought_number
from orders_products op
         join products p on products_id = p.id
         join category c on c.id = p.category_id
group by c.id
order by c.id;


select max(bought_number) max_bought_number
from (select c.id, c.name, sum(op.products_number) bought_number
      from orders_products op
               join products p on products_id = p.id
               join category c on c.id = p.category_id
      group by c.id
      order by c.id) t_t;


select c.name category, sum(op.products_number) bought_number
from orders_products op
         join products p on products_id = p.id
         join category c on c.id = p.category_id
group by c.id
having sum(op.products_number) = (select max(bought_number) max_bought_number
                                  from (select c.id, c.name, sum(op.products_number) bought_number
                                        from orders_products op
                                                 join products p on products_id = p.id
                                                 join category c on c.id = p.category_id
                                        group by c.id
                                        order by c.id) t_t)
order by c.id;
