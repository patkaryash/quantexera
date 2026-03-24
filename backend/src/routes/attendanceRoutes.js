const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const {
  checkInAttendance,
  getWorkerAttendance,
  getAllAttendance,
} = require("../controllers/attendanceController");

// Worker marks attendance
router.post("/check-in", authMiddleware, roleMiddleware("worker"), checkInAttendance);

// Admin gets all attendance
router.get("/", authMiddleware, roleMiddleware("admin"), getAllAttendance);

// Admin or worker can get one worker's attendance
router.get("/:workerId", authMiddleware, roleMiddleware("admin", "worker"), getWorkerAttendance);

module.exports = router;