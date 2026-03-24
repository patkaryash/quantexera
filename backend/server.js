require("dotenv").config();

const http = require("http");
const app = require("./app");
const pool = require("./src/config/db");

const PORT = process.env.PORT || 5000;

const server = http.createServer(app);

async function startServer() {
  try {
    await pool.query("SELECT NOW()");
    console.log("Database connection test successful");

    server.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Server startup failed:", error.message);
    process.exit(1);
  }
}

startServer();