
-- 1. Print the names of professors who work in departments that have fewer than 50 PhD students.
WITH PhdCounts AS (
    SELECT dname, COUNT(*) AS num_phds
    FROM major
    WHERE sid IN (SELECT sid FROM student WHERE year = 4)
    GROUP BY dname
)

SELECT pname
FROM prof
WHERE dname IN (SELECT dname FROM PhdCounts WHERE num_phds < 50);

-- 2. Print the names of the students with the lowest GPA.
SELECT sname
FROM student
WHERE gpa = (SELECT MIN(gpa) FROM student);

-- 3. For each Computer Sciences class, print the class number, section number, and the average GPA of the students enrolled in the class section.
/*
WITH ClassAvgGPA AS (
    SELECT cno, sectno, AVG(gpa) AS avg_gpa
    FROM enroll
    JOIN course ON enroll.cno = course.cno
    JOIN student ON enroll.sid = student.sid
    WHERE course.dname = 'Computer Sciences'
    GROUP BY cno, sectno
)

SELECT cno, sectno, avg_gpa
FROM ClassAvgGPA;
*/
WITH ClassAvgGPA AS (
    SELECT course.cno, section.sectno, AVG(student.gpa) AS avg_gpa
    FROM enroll
    JOIN course ON enroll.cno = course.cno
    JOIN section ON enroll.cno = section.cno AND enroll.sectno = section.sectno
    JOIN student ON enroll.sid = student.sid
    WHERE course.dname = 'Computer Sciences'
    GROUP BY course.cno, section.sectno
)

SELECT cno, sectno, avg_gpa
FROM ClassAvgGPA;

-- 4. Print the names and section numbers of all sections with more than six students enrolled in them.
WITH SectionEnrollment AS (
    SELECT cno, sectno, COUNT(*) AS num_students
    FROM enroll
    GROUP BY cno, sectno
)

SELECT c.cname, e.sectno
FROM SectionEnrollment e
JOIN course c ON e.cno = c.cno
WHERE num_students > 6;

-- 5. Print the name(s) and sid(s) of the student(s) enrolled in the most sections.
WITH SectionEnrollmentCount AS (
    SELECT sid, COUNT(*) AS num_sections
    FROM enroll
    GROUP BY sid
    ORDER BY num_sections DESC
    LIMIT 1
)

SELECT student.sname, enroll.sid
FROM SectionEnrollmentCount
JOIN enroll ON SectionEnrollmentCount.sid = enroll.sid
JOIN student ON enroll.sid = student.sid;

-- 6. Print the names of departments that have one or more majors who are under 18 years old.
SELECT DISTINCT d.dname
FROM major m
JOIN student s ON m.sid = s.sid
JOIN dept d ON m.dname = d.dname
WHERE s.age < 18;

-- 7. Print the names and majors of students who are taking one of the College Geometry courses.
SELECT s.sname, m.dname
FROM enroll e
JOIN student s ON e.sid = s.sid
JOIN major m ON e.sid = m.sid
JOIN course c ON e.cno = c.cno
WHERE c.cname LIKE 'College Geometry%';

-- 8. For those departments that have no major taking a College Geometry course, print the department name and the number of PhD students in the department.
WITH NoGeometryMajors AS (
    SELECT d.dname
    FROM dept d
    WHERE NOT EXISTS (
        SELECT 1
        FROM major m
        JOIN course c ON m.sid = c.cno
        WHERE d.dname = m.dname AND c.cname LIKE 'College Geometry%'
    )
)

SELECT n.dname, COUNT(*) AS num_phds
FROM NoGeometryMajors n
JOIN major m ON n.dname = m.dname
WHERE m.sid IN (SELECT sid FROM student WHERE year = 4)
GROUP BY n.dname;

-- 9. Print the names of students who are taking both a Computer Sciences course and a Mathematics course.
SELECT s.sname
FROM enroll e1
JOIN enroll e2 ON e1.sid = e2.sid
JOIN student s ON e1.sid = s.sid
JOIN course c1 ON e1.cno = c1.cno
JOIN course c2 ON e2.cno = c2.cno
WHERE c1.dname = 'Computer Sciences' AND c2.dname = 'Mathematics';

-- 10. Print the age difference between the oldest and the youngest Computer Sciences major.
SELECT MAX(age) - MIN(age) AS age_difference
FROM major m
JOIN student s ON m.sid = s.sid
WHERE m.dname = 'Computer Sciences';

-- 11. For each department that has one or more majors with a GPA under 1.0, print the name of the department and the average GPA of its majors.
WITH LowGPAMajors AS (
    SELECT dname
    FROM major
    WHERE sid IN (SELECT sid FROM student WHERE gpa < 1.0)
    GROUP BY dname
)

SELECT d.dname, AVG(s.gpa) AS avg_gpa
FROM LowGPAMajors l
JOIN major m ON l.dname = m.dname
JOIN student s ON m.sid = s.sid
JOIN dept d ON m.dname = d.dname
GROUP BY d.dname;

-- 12. Print the ids, names, and GPAs of the students who are currently taking all the Civil Engineering courses.
WITH CivilEngineeringCourses AS (
    SELECT cno
    FROM course
    WHERE dname = 'Civil Engineering'
)

SELECT s.sid, s.sname, s.gpa
FROM student s
WHERE NOT EXISTS (
    SELECT cno
    FROM CivilEngineeringCourses
    EXCEPT
    SELECT cno
    FROM enroll e
    WHERE s.sid = e.sid
);
