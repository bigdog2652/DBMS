const mysql = require('mysql2/promise');

// Database connection configuration
const dbConfig = {
    host: "localhost",
    user: "root",
    password: "toor", 
    database: "course_registration",
    waitForConnections: true, 
    connectionLimit: 10,
    queueLimit: 0
};

const pool = mysql.createPool(dbConfig);
pool.getConnection()
    .then(connection => {
        console.log("Database Pool: Successfully connected to MySQL");
        connection.release(); 
    })
    .catch(err => {
        console.error("Database Pool Error:", err.message);
    });

module.exports = pool;