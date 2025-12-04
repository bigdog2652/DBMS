create database course_registration;
use course_registration;

-- Users table with plain text password
create table users (
  id int auto_increment primary key,
  email varchar(255) not null unique,
  password varchar(255) not null,   -- changed from password_hash
  role enum('student','professor','admin') not null,
  created_at timestamp default current_timestamp
);

create table departments (
  id int auto_increment primary key,
  code varchar(10) not null unique,
  name varchar(100) not null
);

create table professors (
  id int primary key,
  first_name varchar(50) not null,
  last_name varchar(50) not null,
  office varchar(50),
  title varchar(50),
  department_id int not null,
  foreign key (id) references users(id),
  foreign key (department_id) references departments(id)
);

create table students (
  id int primary key,
  first_name varchar(50) not null,
  last_name varchar(50) not null,
  student_number varchar(20) not null unique,
  class_year int,
  status enum('active','inactive') default 'active',
  foreign key (id) references users(id)
);

create table majors (
  id int auto_increment primary key,
  department_id int not null,
  code varchar(10) not null unique,
  name varchar(100) not null,
  foreign key (department_id) references departments(id)
);

create table student_majors (
  id int auto_increment primary key,
  student_id int not null,
  major_id int not null,
  primary_flag boolean default false,
  foreign key (student_id) references students(id),
  foreign key (major_id) references majors(id),
  unique key uniq_student_major (student_id, major_id)
);

create table courses (
  id int auto_increment primary key,
  department_id int not null,
  course_code varchar(20) not null,
  title varchar(200) not null,
  credits decimal(3,1) not null,
  description text,
  foreign key (department_id) references departments(id),
  unique key uniq_course (department_id, course_code)
);

create table prerequisites (
  id int auto_increment primary key,
  course_id int not null,
  prereq_course_id int not null,
  foreign key (course_id) references courses(id),
  foreign key (prereq_course_id) references courses(id),
  unique key uniq_prereq (course_id, prereq_course_id)
);

create table sections (
  id int auto_increment primary key,
  course_id int not null,
  term varchar(10) not null,
  section_code varchar(10) not null,
  professor_id int not null,
  capacity int not null,
  location varchar(100),
  meeting_days set('Mon','Tue','Wed','Thu','Fri') not null,
  start_time time not null,
  end_time time not null,
  foreign key (course_id) references courses(id),
  foreign key (professor_id) references professors(id),
  unique key uniq_section (course_id, term, section_code)
);

create table enrollments (
  id int auto_increment primary key,
  student_id int not null,
  section_id int not null,
  status enum('enrolled','waitlisted','dropped','completed') not null default 'enrolled',
  grade varchar(2),
  enrolled_at timestamp default current_timestamp,
  foreign key (student_id) references students(id),
  foreign key (section_id) references sections(id),
  unique key uniq_enrollment (student_id, section_id)
);


create table transcripts (
  id int auto_increment primary key,
  student_id int not null,
  course_id int not null,
  term varchar(10) not null,
  grade varchar(2) not null,
  credits_awarded decimal(3,1) not null,
  foreign key (student_id) references students(id),
  foreign key (course_id) references courses(id),
  unique key uniq_transcript (student_id, course_id, term)
);

insert into departments (code, name) values ('CS', 'Computer Science');

-- Users
insert into users (email, password, role) values
('alice@student.edu', 'password1', 'student'),
('bob@student.edu', 'password2', 'student'),
('aabdelha@sju.edu', 'password3', 'professor'),
('vvelsju.edu', 'password4', 'professor'),
('ggrevera@sju.edu', 'password5', 'professor'),
('oajaj@sju.edu', 'password6', 'professor'),
('bforoura@sju.edu', 'password7', 'professor'),
('swolfinger@sju.edu', 'password8', 'professor'),
('bjorgage@sju.edu', 'password9', 'professor'),
('wchang@sju.edu', 'password10', 'professor');

-- Students
insert into students (id, first_name, last_name, student_number, class_year)
select id, 'Alice', 'Nguyen', 'S1001', 2026 from users where email='alice@student.edu';

insert into students (id, first_name, last_name, student_number, class_year)
select id, 'Bob', 'Lee', 'S1002', 2025 from users where email='bob@student.edu';

-- Professors
insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Ameen Abdel', 'Hai', 'CS-120', 'Professor',
 (select id from departments where code='CS')
from users where email='aabdelha@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Vetri', 'Vel', 'CS-201', 'Professor',
 (select id from departments where code='CS')
from users where email='vvelsju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'George', 'Grevera', 'CS-281', 'Professor',
 (select id from departments where code='CS')
from users where email='ggrevera@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Ola', 'Ajaj', 'CS-310', 'Professor',
 (select id from departments where code='CS')
from users where email='oajaj@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Babak', 'Foroura', 'CS-351', 'Professor',
 (select id from departments where code='CS')
from users where email='bforoura@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Stacy', 'Wolfinger', 'CS-370', 'Professor',
 (select id from departments where code='CS')
from users where email='swolfinger@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Brian', 'Jorgage', 'CS-315', 'Professor',
 (select id from departments where code='CS')
from users where email='bjorgage@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Wei', 'Chang', 'CS-364', 'Professor',
 (select id from departments where code='CS')
from users where email='wchang@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Stacy', 'Wolfinger', 'CS-340', 'Professor',
 (select id from departments where code='CS')
from users where email='swolfinger@sju.edu';


-- Majors
insert into majors (department_id, code, name)
values ((select id from departments where code='CS'), 'CS', 'B.S. Computer Science');

-- Student Majors
insert into student_majors (student_id, major_id, primary_flag)
values (
 (select id from students where student_number='S1001'),
 (select id from majors where code='CS'), true
);

-- Courses
insert into courses (department_id, course_code, title, credits)
values 
 ((select id from departments where code='CS'), 'CS120', 'Computer Science', 3.0),
 ((select id from departments where code='CS'), 'CS201', 'Data Structures', 3.0),
 ((select id from departments where code='CS'), 'CS281', 'Design & Analysis Algorithms', 3.0),
 ((select id from departments where code='CS'), 'CS310', 'Operating Systems', 3.0),
 ((select id from departments where code='CS'), 'CS351', 'Database Mangament Systems', 3.0),
 ((select id from departments where code='CS'), 'CS370', 'Cybersecurity: Core Domains', 3.0),
 ((select id from departments where code='CS'), 'CS315', 'Software Engineering', 3.0),
 ((select id from departments where code='CS'), 'CS330', 'Generative AI', 3.0),
 ((select id from departments where code='CS'), 'CS364', 'Network Forensics', 3.0),
 ((select id from departments where code='CS'), 'CS340', 'Intro to Cybercrime', 3.0);

-- Prerequisites
insert into prerequisites (course_id, prereq_course_id)
values
 -- CS201 requires CS120
 ((select id from courses where course_code='CS201' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS120' and department_id=(select id from departments where code='CS'))),

 -- CS281 requires CS201
 ((select id from courses where course_code='CS281' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS201' and department_id=(select id from departments where code='CS'))),

 -- CS310 requires CS281
 ((select id from courses where course_code='CS310' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS281' and department_id=(select id from departments where code='CS'))),

 -- CS351 requires CS201
 ((select id from courses where course_code='CS351' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS201' and department_id=(select id from departments where code='CS'))),

 -- CS315 requires CS201
 ((select id from courses where course_code='CS315' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS201' and department_id=(select id from departments where code='CS'))),

 -- CS370 requires CS201
 ((select id from courses where course_code='CS370' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS201' and department_id=(select id from departments where code='CS'))),

 -- CS330 requires CS281
 ((select id from courses where course_code='CS330' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS281' and department_id=(select id from departments where code='CS'))),

 -- CS364 requires CS370
 ((select id from courses where course_code='CS364' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS370' and department_id=(select id from departments where code='CS'))),

 -- CS364 also requires CS310
 ((select id from courses where course_code='CS364' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS310' and department_id=(select id from departments where code='CS'))),

 -- CS340 requires CS370
 ((select id from courses where course_code='CS340' and department_id=(select id from departments where code='CS')),
  (select id from courses where course_code='CS370' and department_id=(select id from departments where code='CS')));


-- Sections
insert into sections (course_id, term, section_code, professor_id, capacity, location, meeting_days, start_time, end_time)
values
 -- CS120 Computer Science - Prof. Abdel Hai
 ((select id from courses where course_code='CS120' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='aabdelha@sju.edu')), 
  30, 'Hall A', 'Mon,Wed,Fri', '09:00', '09:50'),

 -- CS201 Data Structures - Prof. Vetri Vel
 ((select id from courses where course_code='CS201' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='vvelsju.edu')), 
  25, 'Hall B', 'Tue,Thu', '10:00', '11:15'),

 -- CS281 Design & Analysis Algorithms - Prof. George Grevera
 ((select id from courses where course_code='CS281' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='ggrevera@sju.edu')), 
  25, 'Hall C', 'Mon,Wed', '11:00', '12:15'),

 -- CS310 Operating Systems - Prof. Ola Ajaj
 ((select id from courses where course_code='CS310' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='oajaj@sju.edu')), 
  20, 'Hall D', 'Tue,Thu', '13:00', '14:15'),

 -- CS351 Database Management Systems - Prof. Babak Foroura
 ((select id from courses where course_code='CS351' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='bforoura@sju.edu')), 
  20, 'Hall E', 'Mon,Wed', '14:00', '15:15'),

 -- CS370 Cybersecurity: Core Domains - Prof. Stacy Wolfinger
 ((select id from courses where course_code='CS370' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='swolfinger@sju.edu')), 
  20, 'Hall F', 'Tue,Thu', '15:00', '16:15'),

 -- CS315 Software Engineering - Prof. Brian Jorgage
 ((select id from courses where course_code='CS315' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='bjorgage@sju.edu')), 
  25, 'Hall G', 'Mon,Wed', '16:00', '17:15'),

 -- CS330 Generative AI - Prof. (assign to Wolfinger for AI)
 ((select id from courses where course_code='CS330' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='swolfinger@sju.edu')), 
  25, 'Hall H', 'Tue,Thu', '09:00', '10:15'),

 -- CS364 Network Forensics - Prof. Wei Chang
 ((select id from courses where course_code='CS364' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='wchang@sju.edu')), 
  20, 'Hall I', 'Mon,Wed', '10:00', '11:15'),

 -- CS340 Intro to Cybercrime - Prof. Stacy Wolfinger
 ((select id from courses where course_code='CS340' and department_id=(select id from departments where code='CS')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='swolfinger@sju.edu')), 
  20, 'Hall J', 'Tue,Thu', '11:30', '12:45');
  
-- Add Philosophy Department
insert into departments (code, name) values ('PHIL', 'Philosophy');

-- Users (Professors in Philosophy)
insert into users (email, password, role) values
('jdoe@sju.edu', 'password11', 'professor'),
('asmith@sju.edu', 'password12', 'professor'),
('mjohnson@sju.edu', 'password13', 'professor'),
('rwhite@sju.edu', 'password14', 'professor');

-- Professors
insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'John', 'Doe', 'PHIL-101', 'Professor',
 (select id from departments where code='PHIL')
from users where email='jdoe@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Anna', 'Smith', 'PHIL-202', 'Professor',
 (select id from departments where code='PHIL')
from users where email='asmith@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Mary', 'Johnson', 'PHIL-303', 'Professor',
 (select id from departments where code='PHIL')
from users where email='mjohnson@sju.edu';

insert into professors (id, first_name, last_name, office, title, department_id)
select id, 'Robert', 'White', 'PHIL-404', 'Professor',
 (select id from departments where code='PHIL')
from users where email='rwhite@sju.edu';

-- Courses
insert into courses (department_id, course_code, title, credits)
values
 ((select id from departments where code='PHIL'), 'PHIL101', 'Introduction to Philosophy', 3.0),
 ((select id from departments where code='PHIL'), 'PHIL201', 'Ethics', 3.0),
 ((select id from departments where code='PHIL'), 'PHIL301', 'Metaphysics', 3.0),
 ((select id from departments where code='PHIL'), 'PHIL310', 'Philosophy of Law', 3.0),
 ((select id from departments where code='PHIL'), 'PHIL320', 'Philosophy of Mind', 3.0),
 ((select id from departments where code='PHIL'), 'PHIL330', 'Political Philosophy', 3.0);

-- Prerequisites
insert into prerequisites (course_id, prereq_course_id)
values
 -- Ethics requires Intro to Philosophy
 ((select id from courses where course_code='PHIL201' and department_id=(select id from departments where code='PHIL')),
  (select id from courses where course_code='PHIL101' and department_id=(select id from departments where code='PHIL'))),

 -- Metaphysics requires Intro to Philosophy
 ((select id from courses where course_code='PHIL301' and department_id=(select id from departments where code='PHIL')),
  (select id from courses where course_code='PHIL101' and department_id=(select id from departments where code='PHIL'))),

 -- Philosophy of Law requires Ethics
 ((select id from courses where course_code='PHIL310' and department_id=(select id from departments where code='PHIL')),
  (select id from courses where course_code='PHIL201' and department_id=(select id from departments where code='PHIL'))),

 -- Philosophy of Mind requires Metaphysics
 ((select id from courses where course_code='PHIL320' and department_id=(select id from departments where code='PHIL')),
  (select id from courses where course_code='PHIL301' and department_id=(select id from departments where code='PHIL'))),

 -- Political Philosophy requires Ethics
 ((select id from courses where course_code='PHIL330' and department_id=(select id from departments where code='PHIL')),
  (select id from courses where course_code='PHIL201' and department_id=(select id from departments where code='PHIL')));

-- Sections
insert into sections (course_id, term, section_code, professor_id, capacity, location, meeting_days, start_time, end_time)
values

 -- PHIL101 Intro to Philosophy - Prof. John Doe
 ((select id from courses where course_code='PHIL101' and department_id=(select id from departments where code='PHIL')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='jdoe@sju.edu')),
  40, 'Philosophy Hall A', 'Mon,Wed,Fri', '09:00', '09:50'),

 -- PHIL201 Ethics - Prof. Anna Smith
 ((select id from courses where course_code='PHIL201' and department_id=(select id from departments where code='PHIL')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='asmith@sju.edu')),
  35, 'Philosophy Hall B', 'Tue,Thu', '10:00', '11:15'),

 -- PHIL301 Metaphysics - Prof. Mary Johnson
 ((select id from courses where course_code='PHIL301' and department_id=(select id from departments where code='PHIL')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='mjohnson@sju.edu')),
  30, 'Philosophy Hall C', 'Mon,Wed', '11:00', '12:15'),

 -- PHIL310 Philosophy of Law - Prof. Robert White
 ((select id from courses where course_code='PHIL310' and department_id=(select id from departments where code='PHIL')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='rwhite@sju.edu')),
  25, 'Philosophy Hall D', 'Tue,Thu', '13:00', '14:15'),

 -- PHIL320 Philosophy of Mind - Prof. Mary Johnson
 ((select id from courses where course_code='PHIL320' and department_id=(select id from departments where code='PHIL')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='mjohnson@sju.edu')),
  25, 'Philosophy Hall E', 'Mon,Wed', '14:00', '15:15'),

 -- PHIL330 Political Philosophy - Prof. Anna Smith
 ((select id from courses where course_code='PHIL330' and department_id=(select id from departments where code='PHIL')),
  '2025FA', '001', (select id from professors where id=(select id from users where email='asmith@sju.edu')),
  25, 'Philosophy Hall F', 'Tue,Thu', '15:00', '16:15');
  
  select * from departments;