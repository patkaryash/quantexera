const pool = require("../config/db");
const { isPointInPolygon } = require("../services/geofenceService");
const { createZoneViolationAlert } = require("../services/alertService");

// Update worker location
const updateLocation = async (req, res) => {
  try {
    const { workerId, latitude, longitude } = req.body;

    if (!workerId || latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: "workerId, latitude, and longitude are required",
      });
    }

    // Check worker exists and get assigned zone
    const workerResult = await pool.query(
      `SELECT workers.*, zones.polygon
       FROM workers
       LEFT JOIN zones ON workers.assigned_zone_id = zones.id
       WHERE workers.id = $1`,
      [workerId]
    );

    if (workerResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Worker not found",
      });
    }

    const worker = workerResult.rows[0];

    let isInsideZone = null;

    // If worker has zone polygon, check it
    if (worker.polygon && Array.isArray(worker.polygon) && worker.polygon.length > 0) {
      isInsideZone = isPointInPolygon(
        { lat: latitude, lng: longitude },
        worker.polygon
      );
    }

    const result = await pool.query(
      `INSERT INTO locations (worker_id, latitude, longitude, is_inside_zone)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [workerId, latitude, longitude, isInsideZone]
    );

    // Auto-create alert if outside zone
    if (isInsideZone === false) {
      await createZoneViolationAlert(workerId);
    }

    // AUTO-ATTENDANCE: If worker is inside zone, auto-mark attendance for today
    let attendanceMarked = false;
    if (isInsideZone === true) {
      try {
        const existingAttendance = await pool.query(
          `SELECT * FROM attendance WHERE worker_id = $1 AND date = CURRENT_DATE`,
          [workerId]
        );
        if (existingAttendance.rows.length === 0) {
          await pool.query(
            `INSERT INTO attendance (worker_id, check_in_time, status)
             VALUES ($1, CURRENT_TIMESTAMP, 'present')`,
            [workerId]
          );
          attendanceMarked = true;
        }
      } catch (attErr) {
        console.error("Auto-attendance error:", attErr.message);
      }
    }

    return res.status(201).json({
      success: true,
      message: "Location updated successfully",
      location: result.rows[0],
      zoneStatus: isInsideZone,
      attendanceMarked,
    });
  } catch (error) {
    console.error("Update location error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to update location",
    });
  }
};

// Get all latest worker locations
const getAllLocations = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT DISTINCT ON (locations.worker_id)
        locations.id,
        locations.worker_id,
        locations.latitude,
        locations.longitude,
        locations.is_inside_zone,
        locations.timestamp,
        users.name
      FROM locations
      JOIN workers ON locations.worker_id = workers.id
      JOIN users ON workers.user_id = users.id
      ORDER BY locations.worker_id, locations.timestamp DESC
    `);

    return res.status(200).json({
      success: true,
      locations: result.rows,
    });
  } catch (error) {
    console.error("Get all locations error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch locations",
    });
  }
};

// Get location history of one worker
const getWorkerLocations = async (req, res) => {
  try {
    const { workerId } = req.params;

    const result = await pool.query(
      `SELECT * FROM locations
       WHERE worker_id = $1
       ORDER BY timestamp DESC`,
      [workerId]
    );

    return res.status(200).json({
      success: true,
      locations: result.rows,
    });
  } catch (error) {
    console.error("Get worker locations error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch worker locations",
    });
  }
};

module.exports = {
  updateLocation,
  getAllLocations,
  getWorkerLocations,
};