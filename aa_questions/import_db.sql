DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO
  users(fname, lname)
VALUES
  ('Ziyan', 'Wang'), ('Alexandra', 'Savramis'), ('David', 'Sorochkin');


-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
DROP TABLE IF EXISTS questions;

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO
  questions(title, body, user_id)
SELECT
  'Ziyan''s Question', 'Who am I?', users.id
FROM
  users
WHERE
  users.fname = 'Ziyan' and users.lname = 'Wang';



INSERT INTO
  questions(title, body, user_id)
SELECT
  'Alexandra''s Question', 'Help explain SQL', users.id
FROM
  users
WHERE
  users.fname = 'Alexandra' and users.lname = 'Savramis';


-- INSERT INTO
--   questions(title, body, user_id)
-- SELECT
--   'David''s Question', 'What is the database?', users.id
-- FROM
--   users
-- WHERE
--   users.fname = 'David' and users.lname = 'Sorochkin';


-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_follows(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE users.fname = 'Ziyan' AND users.lname = 'Wang'),
   (SELECT id FROM questions WHERE title = 'Alexandra''s Question')

   -- ((SELECT id FROM users WHERE users.fname = 'Alexandra' AND users.lname = 'Savramis'),
   --  (SELECT id FROM questions WHERE title = 'Alexandra''s Question')
);

-- INSERT INTO
--   question_follows(user_id, question_id)
-- SELECT
--   ((  SELECT id
--       FROM users
--       WHERE users.fname = 'Alexandra' AND users.lname = 'Savramis'
--     ), (
--       SELECT id
--       FROM questions
--       WHERE title = 'Alexandra''s Question'
--     )
--   );





-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  body TEXT NOT NULL,


  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)

);

INSERT INTO
  replies(user_id, question_id, parent_reply_id, body)
VALUES
  -- (users.id, question.id, replies.id, 'Search google for the answers')
    ((SELECT id FROM users WHERE fname = "Ziyan" AND lname = "Wang"),
    (SELECT id FROM questions WHERE title = 'Ziyan''s Question'),
    NULL,
    "Who am I?"
  );


INSERT INTO
  replies(user_id, question_id, parent_reply_id, body)
VALUES
  -- (users.id, question.id, replies.id, 'Search google for the answers')
  ((SELECT id FROM users WHERE fname = "Alexandra" AND lname = "Savramis"),
  (SELECT id FROM questions WHERE title = 'Ziyan''s Question'),
  (SELECT id FROM replies WHERE body = "Who am I?"),
  "You are human."
  );


-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- --
DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Ziyan" AND lname = "Wang"),
  (SELECT id FROM questions WHERE title = 'Alexandra''s Question')
);
