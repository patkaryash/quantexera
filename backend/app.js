const express = require("express");
const cors = require("cors");

const authRoutes = require("./src/routes/authRoutes");
const workerRoutes = require("./src/routes/workerRoutes");
const locationRoutes = require("./src/routes/locationRoutes");
const taskRoutes = require("./src/routes/taskRoutes");
const attendanceRoutes = require("./src/routes/attendanceRoutes");
const alertRoutes = require("./src/routes/alertRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    success: true,
    message: "Municipal Workforce Management Backend Running",
  });
});

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Backend is healthy",
    timestamp: new Date().toISOString(),
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/workers", workerRoutes);
app.use("/api/locations", locationRoutes);
app.use("/api/tasks", taskRoutes);
app.use("/api/attendance", attendanceRoutes);
app.use("/api/alerts", alertRoutes);

module.exports = app;