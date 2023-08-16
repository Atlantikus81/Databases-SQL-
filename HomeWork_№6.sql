-- 1. Написать функцию, которая удаляет всю информацию об указанном пользователе из БД vk.
-- Пользователь задается по id. Удалить нужно все сообщения, лайки, медиа записи, профиль и запись из таблицы users.
-- Функция должна возвращать номер пользователя.

-- Создание функции:
DROP FUNCTION IF EXISTS delete_user;
DELIMITER //
CREATE FUNCTION delete_user(del_user_id BIGINT) RETURNS BIGINT READS SQL DATA
BEGIN
DELETE FROM messages WHERE messages.from_user_id = del_user_id;
DELETE FROM likes WHERE likes.user_id = del_user_id;
DELETE FROM media WHERE media.user_id = del_user_id;
-- DELETE FROM users_communities WHERE users_communities.user_id = del_user_id;
-- DELETE FROM friend_requests WHERE friend_requests.initiator_user_id = del_user_id;
DELETE FROM profiles WHERE profiles.user_id = del_user_id;
DELETE FROM users WHERE users.id = del_user_id;
RETURN del_user_id;
END //
DELIMITER ;

-- Вызов функции:
SELECT delete_user(1);

SELECT * FROM messages;
SELECT * FROM likes;
SELECT * FROM media;
SELECT * FROM profiles;
SELECT * FROM users;

-- 2. Предыдущую задачу решить с помощью процедуры и обернуть используемые команды в транзакцию внутри процедуры.

-- Создание процедуры:
DROP PROCEDURE IF EXISTS delete_user;
DELIMITER //
CREATE PROCEDURE delete_user (del_user_id BIGINT)
BEGIN
START TRANSACTION;
DELETE FROM messages WHERE messages.from_user_id = del_user_id;
DELETE FROM likes WHERE likes.user_id = del_user_id;
DELETE FROM media WHERE media.user_id = del_user_id;
-- DELETE FROM users_communities WHERE users_communities.user_id = del_user_id;
-- DELETE FROM friend_requests WHERE friend_requests.initiator_user_id = del_user_id;
DELETE FROM profiles WHERE profiles.user_id = del_user_id;
DELETE FROM users WHERE users.id = del_user_id;
COMMIT;
END //
DELIMITER ;

-- Вызов процедуры:
CALL delete_user (1);

SELECT * FROM messages;
SELECT * FROM likes;
SELECT * FROM media;
SELECT * FROM profiles;
SELECT * FROM users;

-- 3. * Написать триггер, который проверяет новое появляющееся сообщество.
-- Длина названия сообщества (поле name) должна быть не менее 5 символов.
-- Если требование не выполнено, то выбрасывать исключение с пояснением.

DROP TRIGGER IF EXISTS check_community_name;
DELIMITER //
CREATE TRIGGER check_community_name BEFORE INSERT ON communities FOR EACH ROW
BEGIN
IF CHAR_LENGTH(NEW.name) < 5 THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ошибка! Название сообщества должно содержать не менее 5 символов!';
END IF;
END //
DELIMITER ;

INSERT INTO communities VALUES (20, 'aaaa');
