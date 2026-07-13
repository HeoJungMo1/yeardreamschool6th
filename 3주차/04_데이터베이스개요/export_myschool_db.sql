
CREATE TABLE course
(
  수강  NULL    
);

CREATE TABLE department
(
  dept_id VARCHAR(10) NULL    ,
  --      VARCHAR(50) NOT NULL,
  --      VARCHAR(50) NULL     DEFAULT 미정,
  PRIMARY KEY (dept_id)
);

CREATE TABLE enrollment
(
  참조관계에  NULL    
);

CREATE TABLE professor
(
  prof_id   VARCHAR(10) NULL    ,
  name      VARCHAR(20) NOT NULL,
  email     VARCHAR(50) NOT NULL UNIQUE,
  dept_id   VARCHAR(10) NULL    ,
  hire_year INT         NULL    ,
  PRIMARY KEY (prof_id),
  FOREIGN KEY (dept_id) REFERENCES department (dept_id)
);

CREATE TABLE student
(
  student_id   VARCHAR(10) NULL    ,
  name         VARCHAR(20) NOT NULL,
  email        VARCHAR(50) NULL     UNIQUE,
  birth_year   INT         NULL    ,
  dept_id      VARCHAR(10) NULL    ,
  grade        INT         NULL    ,
  tuition_paid VARCHAR(1)  NULL     DEFAULT N,
  PRIMARY KEY (student_id),
  FOREIGN KEY (dept_id) REFERENCES department (dept_id)
);
