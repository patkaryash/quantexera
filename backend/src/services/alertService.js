const pool = require("../config/db");

const createZoneViolationAlert = async (workerId) => {
  try {
    await pool.query(
      `INSERT INTO alerts (worker_id, type, message)
       VALUES ($1, $2, $3)`,
      [workerId, "zone_violation", "Worker moved outside assigned zone"]
    );
  } catch (error) {
    console.error("Auto zone alert creation error:", error.message);
  }
};

const createAttendanceViolationAlert = async (workerId) => {
  try {
    await pool.query(
      `INSERT INTO alerts (worker_id, type, message)
       VALUES ($1, $2, $3)`,
      [
        workerId,
        "attendance_violation",
        "Worker attempted attendance outside assigned zone",
      ]
    );
  } catch (error) {
    console.error("Attendance violation alert creation error:", error.message);
  }
};

module.exports = {
  createZoneViolationAlert,
  createAttendanceViolationAlert,
};