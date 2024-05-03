drop table if exists product_discounts;
drop table if exists category_discounts;
drop table if exists discounts;
drop table if exists product;
drop table if exists category;

create table category
(
    id   serial8,
    name varchar not null,
    primary key (id)
);

create table product
(
    id          serial8,
    category_id int8,
    name        varchar not null,
    price       int8    not null,
    primary key (id),
    foreign key (category_id) references category (id)
);

create table discounts
(
    id       serial8,
    discount int8 not null,
    primary key (id)
);

create table product_discounts
(
    id          serial8,
    product_id  int8 default null,
    discount_id int8 not null,
    primary key (id),
    foreign key (product_id) references product (id),
    foreign key (discount_id) references discounts (id)
);

create table category_discounts
(
    id          serial8,
    category_id int8 default null,
    discount_id int8 not null,
    primary key (id),
    foreign key (category_id) references category (id),
    foreign key (discount_id) references discounts (id)
);

insert into category(name)
values ('Smartphone'),
       ('Car'),
       ('Book');

insert into product(category_id, name, price)
values (1, 'iPhone 12 Pro', 1000),
       (2, 'Kia Rio', 10000),
       (1, 'Samsung Galaxy S5', 1200),
       (3, 'Alice in Wonderland', 15),
       (3, 'Billy Milligan', 16),
       (2, 'Toyota Corolla', 1200);

insert into discounts(discount)
values (2),
       (10),
       (5),
       (15),
       (20),
       (50);

insert into category_discounts(category_id, discount_id)
values (1, 2),
       (2, 3),
       (1, 1),
       (3, 6);

insert into product_discounts(product_id, discount_id)
values (1, 4),
       (3, 2),
       (4, 5),
       (6, 1);

select p.*, sum(d.discount) final_discount, (100 - sum(d.discount)) / 100 * p.price final_price
from product p
         join category c on c.id = p.category_id
         join category_discounts cd on cd.category_id = c.id
         join discounts d on d.id = cd.discount_id
group by p.id, c.id;

select c.*, sum(d.discount) total_discount
from category c
         join category_discounts cd on c.id = cd.category_id
         join discounts d on d.id = cd.discount_id
group by c.id
order by total_discount desc;

delete
from product_discounts
where product_id = 4;
delete
from product
where category_id = 3;

select c.name, coalesce(avg(p.price), 0)
from category c
         left join product p on c.id = p.category_id
group by c.id;



select cd.category_id, coalesce(sum(d1.discount), 0) category_discount
from category_discounts cd
         join discounts d1 on cd.discount_id = d1.id
group by cd.category_id
order by cd.category_id; -- 1 variant

select pd.product_id, coalesce(sum(d.discount), 0) product_discount
from product_discounts pd
         join discounts d on pd.discount_id = d.id
group by pd.product_id
order by pd.product_id; -- 1 variant

select p.id, p.name, coalesce(sum(d.discount), 0) product_discount
from product p
         left join product_discounts pd on p.id = pd.product_id
         left join discounts d on pd.discount_id = d.id
group by p.id, p.name, pd.product_id
order by p.id; -- 2 variant

select p.id, p.name, coalesce(sum(d.discount), 0) category_discount
from product p
         left join category_discounts cd on p.category_id = cd.category_id
         left join discounts d on cd.discount_id = d.id
group by p.id, p.name, cd.category_id
order by p.id; -- 2 variant


select p.name,
       category_discount,
       product_discount,
       category_discount + product_discount total_discount
from product p
         join (select p.id, p.name, coalesce(sum(d.discount), 0) category_discount
               from product p
                        left join category_discounts cd on p.category_id = cd.category_id
                        left join discounts d on cd.discount_id = d.id
               group by p.id, p.name, cd.category_id
               order by p.id) c_t on p.name = c_t.category_discount
         join(select p.id, p.name, coalesce(sum(d.discount), 0) product_discount
              from product p
                       left join product_discounts pd on p.id = pd.product_id
                       left join discounts d on pd.discount_id = d.id
              group by p.id, p.name, pd.product_id
              order by p.id) p_t on p.name = p_t.name; -- 2 variant


select p.name,
       coalesce(category_discount, 0)                                 category_discount,
       coalesce(product_discount, 0)                                  product_discount,
       coalesce(category_discount, 0) + coalesce(product_discount, 0) total_discount,
       p.price                                                        initial_price,
       p.price * (100 - coalesce(category_discount, 0) - coalesce(product_discount, 0)) / 100
                                                                      price_with_discount
from product p
         left join (select cd.category_id, coalesce(sum(d1.discount), 0) category_discount
                    from category_discounts cd
                             left join discounts d1 on cd.discount_id = d1.id
                    group by cd.category_id
                    order by cd.category_id) c_t on p.category_id = c_t.category_id
         left join(select pd.product_id, coalesce(sum(d.discount), 0) product_discount
                   from product_discounts pd
                            left join discounts d on pd.discount_id = d.id
                   group by pd.product_id
                   order by pd.product_id) p_t on p.id = p_t.product_id; -- 1 variant


select *
from (select p.name,
             coalesce(category_discount, 0)                                 category_discount,
             coalesce(product_discount, 0)                                  product_discount,
             coalesce(category_discount, 0) + coalesce(product_discount, 0) total_discount,
             p.price                                                        initial_price,
             p.price * (100 - coalesce(category_discount, 0) - coalesce(product_discount, 0)) / 100
                                                                            price_with_discount
      from product p
               left join (select cd.category_id, coalesce(sum(d1.discount), 0) category_discount
                          from category_discounts cd
                                   left join discounts d1 on cd.discount_id = d1.id
                          group by cd.category_id
                          order by cd.category_id) c_t on p.category_id = c_t.category_id
               left join(select pd.product_id, coalesce(sum(d.discount), 0) product_discount
                         from product_discounts pd
                                  left join discounts d on pd.discount_id = d.id
                         group by pd.product_id
                         order by pd.product_id) p_t on p.id = p_t.product_id) t_t -- 1 variant)
where t_t.total_discount = (select max(total_discount)
                            from (select coalesce(category_discount, 0) + coalesce(product_discount, 0) total_discount
                                  from product p
                                           left join (select cd.category_id,
                                                             coalesce(sum(d1.discount), 0) category_discount
                                                      from category_discounts cd
                                                               left join discounts d1 on cd.discount_id = d1.id
                                                      group by cd.category_id
                                                      order by cd.category_id) c_t on p.category_id = c_t.category_id
                                           left join(select pd.product_id, coalesce(sum(d.discount), 0) product_discount
                                                     from product_discounts pd
                                                              left join discounts d on pd.discount_id = d.id
                                                     group by pd.product_id
                                                     order by pd.product_id) p_t on p.id = p_t.product_id) t_t1);






