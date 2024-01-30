
CREATE TABLE student (
    sid SERIAL PRIMARY KEY,
    sname VARCHAR(255),
    sex CHAR(1),
    age INTEGER,
    year INTEGER,
    gpa NUMERIC
);

CREATE TABLE dept (
    dname VARCHAR(255) PRIMARY KEY,
    numphds INTEGER
);

CREATE TABLE prof (
    pname VARCHAR(255),
    dname VARCHAR(255) REFERENCES dept(dname),
    PRIMARY KEY (pname, dname)
);

CREATE TABLE course (
    cno VARCHAR(255),
    dname VARCHAR(255) REFERENCES dept(dname),
    cname VARCHAR(255),
    PRIMARY KEY (cno, dname)
);

CREATE TABLE major (
    dname VARCHAR(255) REFERENCES dept(dname),
    sid INTEGER REFERENCES student(sid),
    PRIMARY KEY (dname, sid)
);

CREATE TABLE section (
    dname VARCHAR(255) REFERENCES dept(dname),
    cno VARCHAR(255),
    sectno INTEGER,
    pname VARCHAR(255),
    PRIMARY KEY (dname, cno, sectno, pname)
);

CREATE TABLE enroll (
    sid INTEGER REFERENCES student(sid),
    dname VARCHAR(255) REFERENCES dept(dname),
    cno VARCHAR(255),
    sectno INTEGER,
    grade VARCHAR(2),
    PRIMARY KEY (sid, dname, cno, sectno)
);
