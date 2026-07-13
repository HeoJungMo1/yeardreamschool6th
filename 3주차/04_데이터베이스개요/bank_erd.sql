
CREATE TABLE Account
(
  account_id         NOT NULL,
  Name       VARCHAR NOT NULL,
  ID         INTEGER NOT NULL,
  ID         INTEGER NOT NULL,
  PRIMARY KEY (account_id)
);

CREATE TABLE customer
(
  ID             INTEGER NOT NULL,
  Name           VARCHAR NOT NULL DEFAULT 홍길동,
  Acoount_Number VARCHAR NOT NULL,
  PIN            INTEGER NOT NULL,
  PRIMARY KEY (ID)
);

ALTER TABLE Account
  ADD CONSTRAINT FK_customer_TO_Account
    FOREIGN KEY (ID)
    REFERENCES customer (ID);
