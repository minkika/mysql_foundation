USE assisthomist;

# Соответствие всех пользователей и их полномочий

CREATE OR REPLACE VIEW authority AS
(
SELECT u.nickname                                   who,
       if(al.action IS NULL, 'Все', a.name)      AS what,
       if(al.gadget_type IS NULL, 'Все', g.name) AS gadget,
       if(al.room IS NULL, 'Все', r.name)        AS `where`
FROM access_levels al
         LEFT JOIN actions a ON al.action = a.id
         LEFT JOIN gadget_types g ON al.gadget_type = g.id
         LEFT JOIN users u ON al.user_id = u.id
         LEFT JOIN rooms r ON al.room = r.id
    );

# Все гаджеты по комнатам

CREATE OR REPLACE VIEW inventarisation AS
(
SELECT r.name room, g.name gadget, gt.name type
FROM gadgets g
         JOIN rooms r on r.id = g.room
         JOIN gadget_types gt ON g.type = gt.id ORDER BY r.name)