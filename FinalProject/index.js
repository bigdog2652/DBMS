// Nick Kraus, John Rogers, Marc Ramsarran-Humphrey
// Database Management Systems
// 12/4/25
// Nodejs Server - Final Project

// Set up express server
const express = require("express");
const app = express();
const port = 3000;

// Set up session handling middleware for login management
const session = require("express-session");
app.use(session({
    secret: "Tis3s4pt60nwn"
}));


// Import database pool
const pool = require('./mysql');

// Start server
app.listen(port, function () {
    console.log("NodeJS app listening on port " + port);
});

// Middleware to parse URL encoded bodies
const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: true }));


const fsp = require("fs").promises; 

async function readAndServe(path, res) {
    try {
        const data = await fsp.readFile(path);
        res.setHeader('Content-Type', 'text/html');
        res.end(data);
    } catch (err) {
        console.error("File Read Error:", err);
        res.status(404).send("<html><body><h1>404 Not Found</h1><p>The file " + path + " could not be served.</p></body></html>");
    }
}

// Function to track login status
function requireLogin(req, res, next) {
    if (!req.session.uid) {
        return res.redirect("/login");
    }
    next(); 
}

// Function to get registered courses for the logged-in user
async function registeredCourses(req) {
    const query = "select section_id, course_code, courses.title, professors.first_name, professors.last_name, meeting_days, start_time, end_time"
            + ", capacity from enrollments join sections on enrollments.section_id = sections.id join courses on sections.course_id = courses.id" 
            + " join professors on sections.professor_id = professors.id where enrollments.student_id = ?";

    const [rows] = await pool.query(query, [req.session.uid]);

    let html = "<html><body><h2>Registered Courses</h2><ul>";
    html += "<table style=\"width:100% ; text-align:center\"><tr><th>Section ID</th><th>Course Code</th><th>Course Title</th><th>Professor</th><th>Meeting Times</th><th>Capacity</th></tr>";
    rows.forEach(row => {
        html += `<tr><td>${row.section_id}</td><td>${row.course_code}</td><td>${row.title}</td><td>${row.first_name} ${row.last_name}</td><td>${row.meeting_days} ${row.start_time} - ${row.end_time}</td><td>${row.capacity}</td></tr>`;
    });
    html += "</table></body></html>";
    return html;
}

// Route handlers
app.get("/login", async (req, res) => {
    // Await the file serving operation
    await readAndServe("./login.htm", res);
});

app.get("/", async (req, res) => {
    // Await the file serving operation
    await readAndServe("./login.htm", res);
});

app.get("/menu", requireLogin, async (req, res) => {
    // Await the file serving operation
    await readAndServe("./menu.html", res);
});

app.get("/search", requireLogin, async (req, res) => {
    // Await the file serving operation
    await readAndServe("./search.html", res);
});

app.get("/register", requireLogin, async (req, res) => {
    // Await the file serving operation
    try {
        let html = await fsp.readFile("./register.html", "utf8");

        html += await registeredCourses(req);

        res.send(html);
    } catch (err) {
        console.error("Register Page Error:", err);
        res.status(500).send("Server error while loading register page");
    }
});

app.get("/drop", requireLogin, async (req, res) => {
    // Await the file serving operation
    try {
        let html = await fsp.readFile("./drop.html", "utf8");

        html += await registeredCourses(req);

        res.send(html);
    } catch (err) {
        console.error("Drop Page Error:", err);
        res.status(500).send("Server error while loading drop page");
    }
});

app.get("/update", requireLogin, async (req, res) => {
    // Await the file serving operation
    try {
        let html = await fsp.readFile("./update.html", "utf8");

        html += await registeredCourses(req);

        res.send(html);
    } catch (err) {
        console.error("Update Page Error:", err);
        res.status(500).send("Server error while loading update page");
    }
});

app.get("/logout", (req, res) => {
    req.session.destroy(() => {
        res.redirect("/login");
    });
});

// Post Functions

app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const [rows] = await pool.query(
      "SELECT * FROM users WHERE email = ? AND password = ?",
      [email, password]
    );

    if (rows.length == 0) {
      return res.send(`
        <script>
            alert("Invalid email or password");
            window.location.href = "/login";
        </script>`);
    }

    // Save session
    req.session.uid = rows[0].id;

    // Redirect
    req.session.save(() => {
      res.redirect("/menu");
    });
  } catch (error) {
    console.error(error);
    return res.status(500).send("Server error");
  }
});

app.post("/search", requireLogin, async (req, res) => {
    const keyword = req.body.keyword;

    try {
        let html = await fsp.readFile("./search.html", "utf8");

        // Sends sql query for courses table by name or description
        const query = "select sections.id, courses.course_code, courses.title, professors.first_name, professors.last_name, meeting_days, start_time, end_time"
            + ", capacity from sections join courses on sections.course_id = courses.id" 
            + " join professors on sections.professor_id = professors.id"
            + " where courses.title like ? or course_code like ? or professors.first_name like ? or professors.last_name like ?";
            
        const [rows] = await pool.query(
            query,
            ['%' + keyword + '%', '%' + keyword + '%', '%' + keyword + '%', '%' + keyword + '%']
        );


        if (rows.length === 0) {
            return res.send(`
                <script>
                    alert("No results found for '${keyword}'");
                    window.location.href = "/search";
                </script>`);
        }

        // Builds HTML response for search query results
        html += "<html><body><h2>Related Courses</h2><ul>";
        html += "<table style=\"width:100% ; text-align:center\"><tr><th>Section ID</th><th>Course Code</th><th>Course Title</th><th>Professor</th><th>Meeting Times</th><th>Capacity</th></tr>";
        rows.forEach(row => {
            html += `<tr><td>${row.id}</td><td>${row.course_code}</td><td>${row.title}</td><td>${row.first_name} ${row.last_name}</td><td>${row.meeting_days} ${row.start_time} - ${row.end_time}</td><td>${row.capacity}</td></tr>`;
        });
        html += "</table></body></html>";

        res.send(html);
    } catch (error) {
        console.error("Search Error:", error);
        res.status(500).send("Server error during search");
    }
});

app.post("/register", requireLogin, async (req, res) => {
    const courseID = req.body.course_id;

    try {
        // Checks if course exists
        const [courseCheck] = await pool.query(
            "SELECT * FROM sections WHERE id = ?",
            [courseID]
        );

        if (courseCheck.length === 0) {
            return res.send(`
                <script>
                    alert("Course does not exist.");
                    window.location.href = "/register";
                </script>
            `);
        }

        // Checks if student is at course limit
        const [enrolledRows] = await pool.query(
            "select count(*) from enrollments where student_id = ?",
            [req.session.uid]
        );

        if (enrolledRows[0]['count(*)'] >= 5) {
            return res.send(`
                <script>
                    alert("You have reached the maximum course limit of 5.");
                    window.location.href = "/register";
                </script>
            `);
        }
        
        // Checks if already registered
        const [rows] = await pool.query(
            "select * from enrollments where student_id = ? AND section_id = ?",
            [req.session.uid, courseID]
        );

        if (rows.length > 0) {
            return res.send(`
                <script>
                    alert("You are already registered for this course.");
                    window.location.href = "/register";
                </script>
            `);
        }

        // Registers the user for the course
        await pool.query(
            "INSERT INTO enrollments (student_id, section_id) VALUES (?, ?)",
            [req.session.uid, courseID]
        );

        return res.send(`
            <script>
                alert("Successfully registered for the course!");
                window.location.href = "/register";
            </script>
        `);

    } catch (error) {
        console.error("Registration Error:", error);
        return res.status(500).send("Server error during registration");
    }  
});

app.post("/drop", requireLogin, async (req, res) => {
    const studentId = req.session.uid;
    const section_id = req.body.course_id;

    try {
        //Deletes enrollment from enrollments table
        const [result] = await pool.query(
            "DELETE FROM enrollments WHERE student_id = ? AND section_id = ?",
            [studentId, section_id]
        );

        //Checks if user was registered for the course
        if (result.affectedRows === 0) {
            return res.send("<script>alert('Not registered for this course'); window.location.href='/drop';</script>");
        }

        res.send("<script>alert('Course dropped'); window.location.href='/drop';</script>");

    } catch (err) {
        console.error(err);
        res.status(500).send("Drop error");
    }
});

app.post("/update", requireLogin, async (req, res) => {
    const oldSection_id = req.body.section_idold;
    const newSection_id = req.body.section_idnew;

    try {
        // Checks if old and new section IDs are the same
        if (oldSection_id === newSection_id) {
            return res.send("<script>alert('Old and new Section IDs cannot be the same'); window.location.href='/update';</script>");
        }

        // Checks if the student is enrolled in the new section
        const [enrollmentCheck] = await pool.query(
            "SELECT * FROM enrollments WHERE student_id = ? AND section_id = ?",
            [req.session.uid, newSection_id]
        );
        if (enrollmentCheck.length > 0) {
            return res.send("<script>alert('Already enrolled in the new section'); window.location.href='/update';</script>");
        }

        // Checks if the new section ID exists
        const [newSectionCheck] = await pool.query(
            "SELECT * FROM sections WHERE id = ?",
            [newSection_id]
        );

        if (newSectionCheck.length === 0) {
            return res.send("<script>alert('New Section ID does not exist'); window.location.href='/update';</script>");
        }

        // Updates enrollment in enrollments table
        const [result] = await pool.query(
            "UPDATE enrollments SET section_id = ? WHERE section_id = ? AND student_id = ?",
            [newSection_id, oldSection_id, req.session.uid]
        );

        // Checks if the update affected any rows
        if (result.affectedRows === 0) {
            return res.send("<script>alert('Not previously enrolled in the old section'); window.location.href='/update';</script>");
        } else
            res.send("<script>alert('Course updated'); window.location.href='/update';</script>");

    } catch (err) {
        console.error(err);
        res.status(500).send("Update error");
    }
});

