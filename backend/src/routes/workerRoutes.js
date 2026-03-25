const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const {
  getAllWorkers,
  getWorkerById,
  startDuty,
  stopDuty,
  assignZone,
} = require("../controllers/workerController");

// Admin can see all workers
router.get("/", authMiddleware, roleMiddleware("admin"), getAllWorkers);

// Admin and worker can see one worker
router.get("/:id", authMiddleware, roleMiddleware("admin", "worker"), getWorkerById);

// Admin assigns worker to a zone
router.put("/:id/assign-zone", authMiddleware, roleMiddleware("admin"), assignZone);

// Worker starts/stops duty
router.put("/start-duty", authMiddleware, roleMiddleware("worker"), startDuty);
router.put("/stop-duty", authMiddleware, roleMiddleware("worker"), stopDuty);

module.exports = router;