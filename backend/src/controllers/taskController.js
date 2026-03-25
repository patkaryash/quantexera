const pool = require("../config/db");

// Create task
const createTask = async (req, res) => {
  try {
    const { title, description, latitude, longitude } = req.body;

    if (!title || latitude === undefined || longitude === undefined) {
      return res.status(400).json({
        success: false,
        message: "title, latitude, and longitude are required",
      });
    }

    const result = await pool.query(
      `INSERT INTO tasks (title, description, latitude, longitude)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [title, description || null, latitude, longitude]
    );

    return res.status(201).json({
      success: true,
      message: "Task created successfully",
      task: result.rows[0],
    });
  } catch (error) {
    console.error("Create task error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to create task",
    });
  }
};

// Get all tasks
const getAllTasks = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        tasks.*,
        users.name AS worker_name
      FROM tasks
      LEFT JOIN workers ON tasks.assigned_worker_id = workers.id
      LEFT JOIN users ON workers.user_id = users.id
      ORDER BY tasks.created_at DESC
    `);

    return res.status(200).json({
      success: true,
      tasks: result.rows,
    });
  } catch (error) {
    console.error("Get all tasks error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch tasks",
    });
  }
};

// Assign task to worker
const assignTask = async (req, res) => {
  try {
    const { id } = req.params;
    const { workerId } = req.body;

    if (!workerId) {
      return res.status(400).json({
        success: false,
        message: "workerId is required",
      });
    }

    // check worker exists
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
      `UPDATE tasks
       SET assigned_worker_id = $1, status = 'assigned'
       WHERE id = $2
       RETURNING *`,
      [workerId, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Task not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Task assigned successfully",
      task: result.rows[0],
    });
  } catch (error) {
    console.error("Assign task error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to assign task",
    });
  }
};

// Mark task complete
const completeTask = async (req, res) => {
  try {
    const { id } = req.params;

    // Get the worker id from the authenticated user
    let workerId = null;
    if (req.user && req.user.id) {
      const workerResult = await pool.query(
        "SELECT id FROM workers WHERE user_id = $1",
        [req.user.id]
      );
      if (workerResult.rows.length > 0) {
        workerId = workerResult.rows[0].id;
      }
    }

    const result = await pool.query(
      `UPDATE tasks
       SET status = 'completed', assigned_worker_id = COALESCE($2, assigned_worker_id)
       WHERE id = $1
       RETURNING *`,
      [id, workerId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Task not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Task marked as completed",
      task: result.rows[0],
    });
  } catch (error) {
    console.error("Complete task error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to complete task",
    });
  }
};

module.exports = {
  createTask,
  getAllTasks,
  assignTask,
  completeTask,
};