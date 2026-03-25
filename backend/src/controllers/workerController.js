const pool = require("../config/db");

// Get all workers
const getAllWorkers = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        workers.id,
        workers.phone,
        workers.assigned_zone_id,
        workers.duty_status,
        users.name,
        users.email,
        zones.name AS zone_name
      FROM workers
      JOIN users ON workers.user_id = users.id
      LEFT JOIN zones ON workers.assigned_zone_id = zones.id
      ORDER BY workers.id ASC
    `);

    return res.status(200).json({
      success: true,
      workers: result.rows,
    });
  } catch (error) {
    console.error("Get all workers error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch workers",
    });
  }
};

// Get worker by ID
const getWorkerById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `
      SELECT 
        workers.id,
        workers.phone,
        workers.assigned_zone_id,
        workers.duty_status,
        users.name,
        users.email,
        zones.name AS zone_name
      FROM workers
      JOIN users ON workers.user_id = users.id
      LEFT JOIN zones ON workers.assigned_zone_id = zones.id
      WHERE workers.id = $1
      `,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Worker not found",
      });
    }

    return res.status(200).json({
      success: true,
      worker: result.rows[0],
    });
  } catch (error) {
    console.error("Get worker by ID error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch worker",
    });
  }
};

// Start duty
const startDuty = async (req, res) => {
  try {
    const { workerId } = req.body;

    if (!workerId) {
      return res.status(400).json({
        success: false,
        message: "workerId is required",
      });
    }

    const result = await pool.query(
      `UPDATE workers
       SET duty_status = 'active'
       WHERE id = $1
       RETURNING *`,
      [workerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Worker not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Duty started successfully",
      worker: result.rows[0],
    });
  } catch (error) {
    console.error("Start duty error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to start duty",
    });
  }
};

// Stop duty
const stopDuty = async (req, res) => {
  try {
    const { workerId } = req.body;

    if (!workerId) {
      return res.status(400).json({
        success: false,
        message: "workerId is required",
      });
    }

    const result = await pool.query(
      `UPDATE workers
       SET duty_status = 'inactive'
       WHERE id = $1
       RETURNING *`,
      [workerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Worker not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Duty stopped successfully",
      worker: result.rows[0],
    });
  } catch (error) {
    console.error("Stop duty error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to stop duty",
    });
  }
};

// Assign worker to zone (admin)
const assignZone = async (req, res) => {
  try {
    const { id } = req.params;
    const { zoneId } = req.body;

    const result = await pool.query(
      `UPDATE workers SET assigned_zone_id = $1 WHERE id = $2 RETURNING *`,
      [zoneId, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Worker not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Worker assigned to zone successfully",
      worker: result.rows[0],
    });
  } catch (error) {
    console.error("Assign zone error:", error.message);
    return res.status(500).json({ success: false, message: "Failed to assign zone" });
  }
};

module.exports = {
  getAllWorkers,
  getWorkerById,
  startDuty,
  stopDuty,
  assignZone,
};