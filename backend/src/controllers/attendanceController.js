const pool = require("../config/db");
const { createAttendanceViolationAlert } = require("../services/alertService");

// Worker check-in with zone validation
const checkInAttendance = async (req, res) => {
  try {
    const { workerId, status } = req.body;

    if (!workerId) {
      return res.status(400).json({
        success: false,
        message: "workerId is required",
      });
    }

    // Check worker exists
    const workerCheck = await pool.query(
      "SELECT * FROM workers WHERE id = $1",
      [workerId]
    );

    if (workerCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Worker not found",
      });
    }

    // Check latest location
    const latestLocationResult = await pool.query(
      `SELECT * FROM locations
       WHERE worker_id = $1
       ORDER BY timestamp DESC
       LIMIT 1`,
      [workerId]
    );

    if (latestLocationResult.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: "No location found. Worker must send location before attendance",
      });
    }

    const latestLocation = latestLocationResult.rows[0];

    if (latestLocation.is_inside_zone !== true) {
      await createAttendanceViolationAlert(workerId);

      return res.status(400).json({
        success: false,
        message: "Attendance not allowed outside assigned zone",
        latestLocation,
      });
    }

    // Prevent duplicate attendance for same date
    const existingAttendance = await pool.query(
      `SELECT * FROM attendance
       WHERE worker_id = $1 AND date = CURRENT_DATE`,
      [workerId]
    );

    if (existingAttendance.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: "Attendance already marked for today",
      });
    }

    const result = await pool.query(
      `INSERT INTO attendance (worker_id, check_in_time, status)
       VALUES ($1, CURRENT_TIMESTAMP, $2)
       RETURNING *`,
      [workerId, status || "present"]
    );

    return res.status(201).json({
      success: true,
      message: "Attendance marked successfully",
      attendance: result.rows[0],
    });
  } catch (error) {
    console.error("Check-in attendance error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to mark attendance",
    });
  }
};

// Get attendance history of one worker
const getWorkerAttendance = async (req, res) => {
  try {
    const { workerId } = req.params;

    const result = await pool.query(
      `SELECT * FROM attendance
       WHERE worker_id = $1
       ORDER BY date DESC, check_in_time DESC`,
      [workerId]
    );

    return res.status(200).json({
      success: true,
      attendance: result.rows,
    });
  } catch (error) {
    console.error("Get worker attendance error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch attendance",
    });
  }
};

// Get all attendance records
const getAllAttendance = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        attendance.id,
        attendance.worker_id,
        attendance.date,
        attendance.check_in_time,
        attendance.status,
        users.name
      FROM attendance
      JOIN workers ON attendance.worker_id = workers.id
      JOIN users ON workers.user_id = users.id
      ORDER BY attendance.date DESC, attendance.check_in_time DESC
    `);

    return res.status(200).json({
      success: true,
      attendance: result.rows,
    });
  } catch (error) {
    console.error("Get all attendance error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch attendance records",
    });
  }
};

module.exports = {
  checkInAttendance,
  getWorkerAttendance,
  getAllAttendance,
};