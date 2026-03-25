const express = require("express");
const router = express.Router();
const pool = require("../config/db");
const authMiddleware = require("../middleware/authMiddleware");

// Get all zones with their polygon data
router.get("/", authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT z.id, z.name, z.polygon,
        (SELECT COUNT(*) FROM workers WHERE assigned_zone_id = z.id) as worker_count
      FROM zones z
      ORDER BY z.id ASC
    `);

    return res.status(200).json({
      success: true,
      zones: result.rows,
    });
  } catch (error) {
    console.error("Get zones error:", error.message);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch zones",
    });
  }
});

module.exports = router;
