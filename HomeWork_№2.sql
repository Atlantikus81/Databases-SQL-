-- 1. Создать БД vk, исполнив скрипт _vk_db_creation.sql (в материалах к уроку)

/*
Не совсем понятно применение команды DROP к каждой таблице в отдельности,
если мы её применяем ко всей базе данных целиком. Каждый раз, выполняя скрипт,
мы удаляем всю базу данных вместе со всеми таблицами, а затем воссоздаём её вновь.
Поэтому команду DROP для каждой таблицы я закомментировал.
*/

DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

-- DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамилия', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(120) UNIQUE,
 	password_hash VARCHAR(100), -- 123456 => vzx;clvgkajrpo9udfxvsldkrn24l5456345t
	phone BIGINT UNSIGNED UNIQUE, 
	
    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'юзеры';

-- DROP TABLE IF EXISTS `profiles`;
CREATE TABLE profiles (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
	
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

ALTER TABLE profiles ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE -- (значение по умолчанию)
    ON DELETE RESTRICT; -- (значение по умолчанию)

-- DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
);

-- DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL, -- изменили на составной ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM('requested', 'approved', 'declined', 'unfriended'), # DEFAULT 'requested',
    -- `status` TINYINT(1) UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP, -- можно будет даже не упоминать это поле при обновлении
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)-- ,
    -- CHECK (initiator_user_id <> target_user_id)
);
-- чтобы пользователь сам себе не отправил запрос в друзья
-- ALTER TABLE friend_requests 
-- ADD CHECK(initiator_user_id <> target_user_id);

-- DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED NOT NULL,
	
	INDEX communities_name_idx(name), -- индексу можно давать свое имя (communities_name_idx)
	FOREIGN KEY (admin_user_id) REFERENCES users(id)
);

-- DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
);

-- DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
    name VARCHAR(255), -- записей мало, поэтому в индексе нет необходимости
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

-- DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body TEXT,
    filename VARCHAR(255),
    -- file BLOB,    	
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

-- DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW()

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

/* намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)
*/
);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_fk 
FOREIGN KEY (media_id) REFERENCES vk.media(id);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_fk_1 
FOREIGN KEY (user_id) REFERENCES vk.users(id);

ALTER TABLE vk.profiles 
ADD CONSTRAINT profiles_fk_1 
FOREIGN KEY (photo_id) REFERENCES media(id);

-- 2. Написать скрипт, добавляющий в созданную БД vk 2-3 новые таблицы
-- (с перечнем полей, указанием индексов и внешних ключей) (CREATE TABLE)
-- При выполнении задания пользовался примером решения
-- Таблицы video и audio делал по аналогии с таблицей photo

-- добавим таблицу фотоальбомов
-- DROP TABLE IF EXISTS photo_albums;
CREATE TABLE photo_albums (
	id SERIAL,
	name varchar(255),
    user_id BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- добавим таблицу фотографий
-- DROP TABLE IF EXISTS photos;
CREATE TABLE photos (
	id SERIAL,
	album_id BIGINT unsigned,
	media_id BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

-- добавим таблицу видеоальбомов
-- DROP TABLE IF EXISTS video_albums;
CREATE TABLE video_albums (
	id SERIAL,
	name varchar(255),
    user_id BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- добавим таблицу видео
-- DROP TABLE IF EXISTS videos;
CREATE TABLE videos (
	id SERIAL,
	album_id BIGINT unsigned,
	media_id BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_id) REFERENCES video_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

-- добавим таблицу аудиоальбомов
-- DROP TABLE IF EXISTS audio_albums;
CREATE TABLE audio_albums (
	id SERIAL,
	name varchar(255),
    user_id BIGINT UNSIGNED NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- добавим таблицу аудио
-- DROP TABLE IF EXISTS audio;
CREATE TABLE audio (
	id SERIAL,
	album_id BIGINT unsigned,
	media_id BIGINT unsigned NOT NULL,

	FOREIGN KEY (album_id) REFERENCES audio_albums(id),
    FOREIGN KEY (media_id) REFERENCES media(id)
);

-- добавим таблицу городов
-- DROP TABLE IF EXISTS cities;
CREATE TABLE cities (
	id SERIAL,
	`name` varchar(255) NOT NULL
);

-- добавим поле с идентификатором города
ALTER TABLE profiles ADD COLUMN city_id BIGINT UNSIGNED NOT NULL ;

-- сделаем это поле внешним ключом
ALTER TABLE profiles ADD CONSTRAINT fk_profiles_city_id
    FOREIGN KEY (city_id) REFERENCES cities(id);

-- 3. Заполнить 2 таблицы БД vk данными (по 10 записей в каждой таблице) (INSERT)
-- При заполнении исполшьзовался сайт https://filldb.info

INSERT INTO users (firstname, lastname, email, password_hash, phone)
VALUES 
('Laura', 'Blick', 'ayla66@example.com', 'f564af084eff35325aa2f3044b225ed2deb8e69f', 546),
('Rose', 'Runte', 'ullrich.rollin@example.net', '6422000f4314d02e76f538eabdc431fdefac1573', 563),
('Robbie', 'Parker', 'williamson.tillman@example.com', '6964a7be4796447723cc7aaf7f42c0c00188ba9d', 623259),
('Emily', 'Aufderhar', 'hjenkins@example.net', '5985b82e5bb8ad068a4b1dc1f0bb7ba7e553707f', 124754),
('Derek', 'Zieme', 'leonora74@example.org', '5f7c58a0205a9de7d17d1e2761d6478b69036920', 759915),
('Elaina', 'Cassin', 'crist.alec@example.org', '3d52f1533ba71d9d6e597e695961608a4a69dd19', 744404),
('Geovanny', 'Wehner', 'cullen95@example.org', '4739ed397487255b3288f076bd155dfa20e5ef0b', 725753),
('Hadley', 'Hauck', 'elouise.hessel@example.com', '4560bf88052c5e588eb990c11adfd0a8820beb45', 719774),
('Axel', 'Beatty', 'prosacco.joey@example.com', '20a30ce1ab34b38d334b146dca2b1058d5bb43e7', 988733),
('Rebecca', 'Schoen', 'thea89@example.org', '386ee453d3c1c8b7146632b7e402875efab0416f', 176996);

SELECT * FROM users;

INSERT INTO messages VALUES 
('1','2','4', 'Сообщение_1', '2020-10-11 00:00:00'),
('2','3','5', 'Сообщение_2', '2019-03-10 00:00:00'),
('3','5','3', 'Сообщение_3', '2021-07-20 00:00:00'),
('4','6','3', 'Сообщение_4', '2027-03-10 00:00:00'),       -- Из "будущего"
('5','1','4', 'Сообщение_5', '2017-04-24 00:00:00'),
('6','5','2', 'Сообщение_6', '2026-08-14 00:00:00'),       -- Из "будущего"
('7','2','5', 'Сообщение_7', '2027-04-15 00:00:00'),       -- Из "будущего"
('8','4','3', 'Сообщение_8', '2018-12-13 00:00:00'),
('9','3','4', 'Сообщение_9', '2015-12-17 00:00:00'),
('10','6','1', 'Сообщение_10', '2018-10-10 00:00:00');

SELECT * FROM messages;

INSERT INTO cities VALUES
(1, 'Москва'),
(2, 'Самара'),
(3, 'Воронеж'),
(4, 'Казань'),
(5, 'Саратов'),
(6, 'Краснодар'),
(7, 'Омск');

INSERT INTO profiles VALUES
(1, 'Ж', '2000-02-10', NULL, '2012-10-15 00:00:00', 'Москва', '1'),
(2, 'М', '1987-06-19', NULL, '2008-06-20 00:00:00', 'Самара', '2'),
(3, 'М', '2010-11-17', NULL, '2018-11-19 00:00:00', 'Воронеж', '3'),
(4, 'М', '1995-03-28', NULL, '2015-02-21 00:00:00', 'Москва', '1'),
(5, 'Ж', '2012-05-02', NULL, '2009-11-21 00:00:00', 'Казань', '4'),
(6, 'Ж', '2010-10-30', NULL, '2019-04-25 00:00:00', 'Краснодар', '6'),
(7, 'М', '1997-01-10', NULL, '2013-10-02 00:00:00', 'Саратов', '5'),
(8, 'Ж', '2001-11-08', NULL, '2018-01-19 00:00:00', 'Омск', '7'),
(9, 'М', '1990-07-23', NULL, '2011-08-21 00:00:00', 'Москва', '1'),
(10, 'Ж', '1992-03-15', NULL, '2017-11-15 00:00:00', 'Воронеж', '3');

SELECT * FROM profiles;

-- 4.* Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false).
-- При необходимости предварительно добавить такое поле в таблицу profiles со значением по умолчанию = false (или 0)
-- (ALTER TABLE + UPDATE) (timestampdiff(birthday, now()))

-- Данное решение взял из примера

-- добавим флаг is_active 
ALTER TABLE vk.profiles 
ADD COLUMN is_active BIT DEFAULT 1;

-- сделать невовершеннолетних неактивными
UPDATE profiles
SET is_active = 0
WHERE (birthday + INTERVAL 18 YEAR) > NOW();

-- проверим не активных
SELECT *
FROM profiles
WHERE is_active = 0
ORDER BY birthday;

-- проверим активных
SELECT *
FROM profiles
WHERE is_active = 1
ORDER BY birthday;

-- 5.* Написать скрипт, удаляющий сообщения «из будущего» (дата позже сегодняшней) (DELETE)

DELETE FROM messages
WHERE created_at > NOW();

SELECT * FROM messages;
-- Долго не получалось удалить строки,
-- пришлось гуглить и менять настройки Workbench.
