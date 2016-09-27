DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  subject_question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,
  body TEXT,
  parent_reply_id INTEGER,

  FOREIGN KEY (subject_question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS likes;

CREATE TABLE likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Mickey', 'Loreti'),
  ('Luke', 'Wassink'),
  ('Tim', 'Johnson');


INSERT INTO
  questions (title, body, author_id)
VALUES
  ('Test Question', 'This is the question I''m asking', (SELECT id FROM users WHERE lname = 'Johnson')),
  ('Other Question', 'Different question asked', (SELECT id FROM users WHERE lname = 'Loreti'));

INSERT INTO
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Test Question'), (SELECT id FROM users WHERE lname = 'Wassink'));


INSERT INTO
  replies (subject_question_id, author_id, body, parent_reply_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Test Question'), (SELECT id FROM users WHERE lname = 'Loreti'), 'Reply to your question', NULL);

INSERT INTO
  replies (subject_question_id, author_id, body, parent_reply_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Test Question'), (SELECT id FROM users WHERE lname = 'Johnson'), 'Reply to your reply', (SELECT id FROM replies WHERE body = 'Reply to your question'));


INSERT INTO
  likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE lname = 'Loreti'), (SELECT id FROM questions WHERE title = 'Test Question'));
