USE inotes_db;
SELECT t.id, t.name, COUNT(n.id) AS note_count
FROM note_type AS t LEFT JOIN notes AS n ON n.type_id=t.id
GROUP BY t.id, t.name ORDER BY t.id;
SELECT n.id, n.title, n.content, t.name AS type_name
FROM notes AS n JOIN note_type AS t ON n.type_id=t.id
ORDER BY n.id DESC;
