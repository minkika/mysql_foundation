USE assisthomist;
SET GLOBAL log_bin_trust_function_creators = 1;

# Функция, которая возвращает последнего пользователя, что-то сделавшего в доме
DELIMITER //
CREATE FUNCTION who_is_the_last()
    RETURNS VARCHAR(20)
BEGIN
    DECLARE last_user TEXT;
    DECLARE last_action_id INT;
    SELECT max(id) INTO last_action_id FROM user_logs;
    SELECT u.nickname
    INTO last_user
    FROM user_logs ul
             JOIN users u ON ul.user_id = u.id
    WHERE ul.id = last_action_id;
    RETURN last_user;
END//
DELIMITER ;
SELECT who_is_the_last();

# Проверка
# insert into user_logs (id, user_id, action, gadget) VALUES (999, 2, 1, 1);
# SELECT who_is_the_last();

# Триггер, который проверяет заполнение mac-адреса в таблице users

DELIMITER //
CREATE TRIGGER mac_is_required
    BEFORE INSERT
    ON users
    FOR EACH ROW
BEGIN
    IF new.mac_address IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'MAC address is required';
    END IF;
END//
DELIMITER ;

# Проверка
# INSERT INTO users (id, nickname, mac_address, email, phone)
# VALUES (99, 'del', NULL, NULL, NULL);

# Триггер, который при удалении типа гаджета меняет всем его элементам тип "Другое"

INSERT INTO gadget_types (id, name, icon, units)
VALUES (99, 'Другое', 'other.png', NULL);

DELIMITER //
CREATE TRIGGER change_gadget_type
    BEFORE DELETE
    ON gadget_types
    FOR EACH ROW
BEGIN
    UPDATE gadgets SET type = '99' WHERE type = old.id;
END//
DELIMITER ;

# Проверка
# INSERT INTO gadget_types (id, name, icon, units)
# VALUES (77, 'delete', 'other.png', NULL);
#
# INSERT INTO gadgets (name, room, type)
# VALUES ('del1', 1, 77),
#        ('del2', 1, 77),
#        ('del3', 1, 77),
#        ('del4', 1, 77);
#
# DELETE from gadget_types WHERE id = 77;
#
# SELECT *
# FROM gadgets
# WHERE type = 99;

# Процедура,которая удаляет значения датчиков старше 1 года

DROP PROCEDURE IF EXISTS delete_old;
DELIMITER //
CREATE PROCEDURE delete_old ()
BEGIN
    delete from indications where date_time < (NOW() - INTERVAL 1 YEAR);
END//
DELIMITER ;

# Проверка
# SELECT * from indications where date_time < (NOW() - INTERVAL 1 YEAR);
# call delete_old();
# SELECT * from indications where date_time < (NOW() - INTERVAL 1 YEAR);
# SELECT * from indications where date_time > (NOW() - INTERVAL 1 YEAR);