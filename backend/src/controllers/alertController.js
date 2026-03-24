const pool = require("../config/db");

// Create alert
const createAlert = async (req, res) => {
  try {
    const { workerId, type, message } = req.body;

    if (!workerId || !type || !message) {
      return res.status(400).json({
        success: false,
        message: "workerId, type, and message are required",
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

    const result = await pool.query(
      `INSERT INTO alerts (worker_id, type, message)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [workerId, type, message]
    );

    return res.status(201).json({
      success: true,
      message: "Alert created successfully",
      alert: result.rows[0],
    });
  } catch (error) {
    console.error("Create alert error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to create alert",
    });
  }
};

// Get all alerts
const getAllAlerts = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        alerts.id,
        alerts.worker_id,
        alerts.type,
        alerts.message,
        alerts.created_at,
        users.name
      FROM alerts
      JOIN workers ON alerts.worker_id = workers.id
      JOIN users ON workers.user_id = users.id
      ORDER BY alerts.created_at DESC
    `);

    return res.status(200).json({
      success: true,
      alerts: result.rows,
    });
  } catch (error) {
    console.error("Get all alerts error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch alerts",
    });
  }
};

// Get alerts by worker
const getWorkerAlerts = async (req, res) => {
  try {
    const { workerId } = req.params;

    const result = await pool.query(
      `SELECT * FROM alerts
       WHERE worker_id = $1
       ORDER BY created_at DESC`,
      [workerId]
    );

    return res.status(200).json({
      success: true,
      alerts: result.rows,
    });
  } catch (error) {
    console.error("Get worker alerts error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch worker alerts",
    });
  }
};

module.exports = {
  createAlert,
  getAllAlerts,
  getWorkerAlerts,
};