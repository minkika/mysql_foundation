USE assisthomist;

# Пользователь, который больше всего включал свет во всем доме

SELECT count(*), u.nickname
FROM users u
         JOIN user_logs ul ON u.id = ul.user_id AND action = 1 AND gadget IN
                                                                   (SELECT id FROM gadgets WHERE type = 19)
GROUP BY u.nickname
ORDER BY count(*) DESC
LIMIT 1;

# Типы гаджетов по частоте использования

SELECT count(*) `uses`, gt.name `gadget type`
FROM gadget_types gt
         JOIN gadgets g
         JOIN user_logs ul
              ON gt.id = g.type AND g.id = ul.gadget
GROUP BY gt.name
ORDER BY count(*) DESC;

# Действие, которое чаще всего производилось по ночам

SELECT a.name
FROM actions a
         JOIN user_logs ul ON a.id = ul.action AND hour(ul.date_time) NOT BETWEEN 6 AND 23
GROUP BY ul.action
ORDER BY count(*) DESC
LIMIT 1 -- Кто-то по ночам логи подтирает



