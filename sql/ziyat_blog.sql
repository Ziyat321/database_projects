drop table if exists commentaries;
drop table if exists articles;
drop table if exists category;
drop table if exists users;

create table users
(
    id         serial8,
    login      varchar not null,
    first_name varchar not null,
    last_name  varchar not null,
    primary key (id)
);

create table category
(
    id   serial8,
    name varchar not null,
    primary key (id)
);

create table articles
(
    id          serial8,
    category_id int8,
    users_id    int8,
    status      varchar not null,
    title       varchar not null,
    content     text    not null,
    primary key (id),
    foreign key (category_id) references category (id),
    foreign key (users_id) references users (id)
);

create table commentaries
(
    id          serial8,
    users_id    int8,
    articles_id int8,
    commentary  text not null,
    primary key (id),
    foreign key (users_id) references users (id),
    foreign key (articles_id) references articles (id)
);


insert into users (login, first_name, last_name)
values ('tree12', 'mark', 'twen'),
       ('bill_21', 'bill', 'gates');

insert into category(name)
values ('roman'),
       ('scientific');

insert into articles(category_id, users_id, status, title, content)
values (1, 1, 'published', 'adventures of pinoccio', 'once upon a time...'),
       (1, 1, 'not published', 'peter pen', 'in a country named...'),
       (2, 2, 'published', 'future of ai', 'when we first incorporated...'),
       (1, 2, 'not published', 'my memoires', 'i want to thank...');

insert into commentaries(users_id, articles_id, commentary)
values (1, 1, 'i was excited by...'),
       (1, 2, 'not decided when to publish yet.'),
       (2, 3, 'good job.'),
       (2, 4, '100%');

select u.first_name, u.last_name, count(a.id) articles_number
from users u
         join articles a on u.id = a.users_id
where a.status = 'published'
group by u.id;

select a.id,
       c.name,
       concat(u.first_name, ' ', u.last_name) author,
       a.title,
       a.status,
       count(c2.id)                           commentaries_number
from articles a
         join users u on a.users_id = u.id
         join category c on c.id = a.category_id
         join commentaries c2 on a.id = c2.articles_id
group by a.id, c.name, author;




