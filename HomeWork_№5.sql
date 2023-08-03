-- 1. Создайте представление с произвольным SELECT-запросом из прошлых уроков [CREATE VIEW]
-- В качестве основы взят пятый запрос из четвёртого ДЗ

CREATE VIEW gender_count_likes AS
SELECT gender, COUNT(*) AS count_likes
FROM likes
JOIN profiles ON likes.user_id = profiles.user_id
GROUP BY gender
ORDER BY count_likes DESC;

-- 2. Выведите данные, используя написанное представление [SELECT]

SELECT * FROM gender_count_likes;

-- 3. Удалите представление [DROP VIEW]

DROP VIEW gender_count_likes;

-- 4. * Сколько новостей (записей в таблице media) у каждого пользователя?
-- Вывести поля: news_count (количество новостей), user_id (номер пользователя), user_email (email пользователя).
-- Попробовать решить с помощью CTE или с помощью обычного JOIN.

WITH table_cte AS
(
SELECT COUNT(*) AS news_count, user_id
FROM media
GROUP BY user_id
)
SELECT news_count, user_id, email AS user_email
FROM table_cte
JOIN users ON table_cte.user_id = users.id;
