const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const {
  createAlert,
  getAllAlerts,
  getWorkerAlerts,
} = require("../controllers/alertController");

// Admin creates and sees alerts
router.post("/", authMiddleware, roleMiddleware("admin"), createAlert);
router.get("/", authMiddleware, roleMiddleware("admin"), getAllAlerts);

// Admin or worker can get worker alerts
router.get("/:workerId", authMiddleware, roleMiddleware("admin", "worker"), getWorkerAlerts);

module.exports = router;