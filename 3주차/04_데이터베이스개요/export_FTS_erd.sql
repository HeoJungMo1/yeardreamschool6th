
CREATE TABLE Match
(
  MatchDate DATETIME NOT NULL,
  Stadium   VARCHAR  NOT NULL,
  Opponent  VARCHAR  NOT NULL,
  Own_Score INT      NOT NULL,
  Opp_Score INT      NOT NULL,
                     NOT NULL,
  PRIMARY KEY ()
);

CREATE TABLE Match_Player
(
  MatchID  INT     NOT NULL,
  PlayerID INT     NOT NULL,
  Score    VARCHAR NOT NULL,
                   NOT NULL,
                   NOT NULL,
                   NOT NULL
);

CREATE TABLE Player
(
  ID           INT     NOT NULL,
  Name         VARCHAR NOT NULL,
  Age          INT     NOT NULL,
  Season_Score INT     NOT NULL,
                       NOT NULL,
  PRIMARY KEY ()
);

ALTER TABLE Match_Player
  ADD CONSTRAINT FK_Match_TO_Match_Player
    FOREIGN KEY ()
    REFERENCES Match ();

ALTER TABLE Match_Player
  ADD CONSTRAINT FK_Player_TO_Match_Player
    FOREIGN KEY ()
    REFERENCES Player ();
