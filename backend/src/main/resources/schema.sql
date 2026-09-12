CREATE TABLE IF NOT EXISTS it_user (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(256) NOT NULL,
  password VARCHAR(256) NOT NULL,
  name VARCHAR(256),
  addr VARCHAR(256),
  gender VARCHAR(4) DEFAULT '0',
  head_img VARCHAR(512),
  lon DOUBLE,
  lat DOUBLE,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_it_user_username (username)
);

CREATE TABLE IF NOT EXISTS it_event (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(256),
  intro VARCHAR(1024),
  addr VARCHAR(256),
  head_img VARCHAR(512),
  start_time DATETIME,
  lon DOUBLE,
  lat DOUBLE,
  state INT DEFAULT 1,
  if_delete INT DEFAULT 0,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  update_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_it_event_user_id (user_id),
  CONSTRAINT fk_it_event_user
    FOREIGN KEY (user_id) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS it_event_comment (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  content VARCHAR(1024),
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_it_event_comment_event_id (event_id),
  KEY idx_it_event_comment_user_id (user_id),
  CONSTRAINT fk_it_event_comment_event
    FOREIGN KEY (event_id) REFERENCES it_event (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_it_event_comment_user
    FOREIGN KEY (user_id) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS it_event_member (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_it_event_member (event_id, user_id),
  KEY idx_it_event_member_user_id (user_id),
  CONSTRAINT fk_it_event_member_event
    FOREIGN KEY (event_id) REFERENCES it_event (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_it_event_member_user
    FOREIGN KEY (user_id) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS it_friend (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  friend_id BIGINT UNSIGNED NOT NULL,
  apply INT DEFAULT 2,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_it_friend_direction (user_id, friend_id),
  KEY idx_it_friend_friend_id (friend_id),
  CONSTRAINT fk_it_friend_user
    FOREIGN KEY (user_id) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_it_friend_friend
    FOREIGN KEY (friend_id) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS it_chat (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id_from BIGINT UNSIGNED NOT NULL,
  user_id_to BIGINT UNSIGNED NOT NULL,
  content VARCHAR(10240),
  status_from INT DEFAULT 0,
  status_to INT DEFAULT 0,
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_it_chat_user_from (user_id_from),
  KEY idx_it_chat_user_to (user_id_to),
  CONSTRAINT fk_it_chat_user_from
    FOREIGN KEY (user_id_from) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_it_chat_user_to
    FOREIGN KEY (user_id_to) REFERENCES it_user (id)
    ON DELETE CASCADE ON UPDATE CASCADE
);
