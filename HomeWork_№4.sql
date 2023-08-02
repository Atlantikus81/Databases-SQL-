-- 1. Подсчитать количество групп (сообществ), в которые вступил каждый пользователь.

SELECT id, firstname, lastname, COUNT(*) AS count_communities -- вывели id, чтобы было видно, какие пользователи не попали в выборку
FROM users
JOIN users_communities ON users.id = users_communities.user_id
GROUP BY user_id;
-- order by count_communities desc;

-- 2. Подсчитать количество пользователей в каждом сообществе.

SELECT name, COUNT(*) AS count_users
FROM communities
JOIN users_communities ON communities.id  = users_communities.community_id
GROUP BY name;

-- 3. Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека,
-- который больше всех общался с выбранным пользователем (написал ему сообщений).

SELECT from_user_id, firstname, lastname, COUNT(*) AS max_count_messages
FROM messages
JOIN users ON messages.from_user_id = users.id
WHERE to_user_id = 1
GROUP BY from_user_id
ORDER BY max_count_messages DESC
LIMIT 1;

-- 4. * Подсчитать общее количество лайков, которые получили пользователи младше 18 лет..

SELECT COUNT(*) AS count_likes
FROM likes
JOIN media ON likes.media_id = media.id
JOIN profiles ON media.user_id = profiles.user_id
WHERE TIMESTAMPDIFF(YEAR, birthday, NOW()) < 18;

-- 5. * Определить, кто больше поставил лайков (всего): мужчины или женщины.

SELECT gender, COUNT(*) AS count_likes
FROM likes
JOIN profiles ON likes.user_id = profiles.user_id
GROUP BY gender
ORDER BY count_likes DESC;
