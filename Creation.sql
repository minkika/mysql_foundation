DROP DATABASE IF EXISTS assisthomist;
CREATE DATABASE assisthomist;
USE assisthomist;

DROP TABLE IF EXISTS users;
CREATE TABLE users
(
    id          TINYINT UNSIGNED   NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY, -- SERIAL слишком большой
    nickname    VARCHAR(20) UNIQUE NOT NULL,
    mac_address CHAR(17) UNIQUE,                                               -- Проверка на отсутствие адреса реализована триггером; CHAR выбран, т.к. все данные одной длины, и не потребуется дополнительное место на хранение VARCHAR
    email       VARCHAR(60),                                                   -- Может быть null, т.к. есть технический пользователь
    phone       BIGINT UNIQUE                                                  -- т.к. решение локальное, можно не использовать коды регионов
# Индексировать пользователей не имеет смысла - таблица небольшая, индекс будет затормаживать работу
);

DROP TABLE IF EXISTS actions;
CREATE TABLE actions -- как атрибут для полномочий
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30)
);

DROP TABLE IF EXISTS rooms;
CREATE TABLE rooms -- атрибут полномочий + размещение гаджетов
(
    id   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY, -- комнат не будет больше 127
    name VARCHAR(30)
);

DROP TABLE IF EXISTS gadget_types;
CREATE TABLE gadget_types
(
    id    TINYINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
    name  VARCHAR(30)      NOT NULL,
    icon  VARCHAR(20),
    units VARCHAR(10)
);

# Сначала тут была описана функционально-ролевая модель доступа по RBAC, но впоследствии стало понятно,
# что она заставляет нас содержать трехмерную матрицу вместо двухмерной, а в таких масштабах это не целесообразно,
# поэтому я переписала таблицу под модель ABAC. Настройка и проверка полномочий занимает мало времени и данные "легче"
DROP TABLE IF EXISTS access_levels;
CREATE TABLE access_levels
(
    id          SERIAL PRIMARY KEY,
    user_id     TINYINT UNSIGNED NOT NULL,
    action      BIGINT UNSIGNED,  -- пустое значение = все
    room        TINYINT UNSIGNED, -- пустое значение = все
    gadget_type TINYINT UNSIGNED, -- пустое значение = все
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (action) REFERENCES actions (id),
    FOREIGN KEY (room) REFERENCES rooms (id),
    FOREIGN KEY (gadget_type) REFERENCES gadget_types (id) ON DELETE CASCADE
);

DROP TABLE IF EXISTS gadgets;
CREATE TABLE gadgets
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30),
    room TINYINT UNSIGNED NOT NULL,
    type TINYINT UNSIGNED NOT NULL,
    FOREIGN KEY (type) REFERENCES gadget_types (id)
);

DROP TABLE IF EXISTS user_logs;
CREATE TABLE user_logs
(
    id        SERIAL PRIMARY KEY,
    user_id   TINYINT UNSIGNED NOT NULL,
    action    BIGINT UNSIGNED  NOT NULL,
    gadget    BIGINT UNSIGNED  NOT NULL,
    date_time TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (action) REFERENCES actions (id),
    INDEX user_logs_idx (user_id, gadget)

);

DROP TABLE IF EXISTS indications;
CREATE TABLE indications
(
    id        SERIAL PRIMARY KEY,
    gadget_id BIGINT UNSIGNED NOT NULL,
    date_time TIMESTAMP DEFAULT now(),
    value     FLOAT,
    FOREIGN KEY (gadget_id) REFERENCES gadgets (id),
    INDEX gadget_state_idx (gadget_id)
);

DROP TABLE IF EXISTS sensor_states;
CREATE TABLE sensor_states
(
    id        SERIAL PRIMARY KEY,
    gadget_id BIGINT UNSIGNED NOT NULL,
    date_time TIMESTAMP DEFAULT now(),
    state     ENUM ('on', 'off'),
    FOREIGN KEY (gadget_id) REFERENCES gadgets (id),
    INDEX gadget_state (gadget_id)

);

DROP TABLE IF EXISTS text_messages; -- Допустим, мы будем рассылать сообщения в случае каких-то ситуаций
CREATE TABLE text_messages
(
    id           SERIAL PRIMARY KEY,
    code         BIGINT UNSIGNED NOT NULL,
    text_message TEXT
);