const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const {
  updateLocation,
  getAllLocations,
  getWorkerLocations,
} = require("../controllers/locationController");

// Worker updates own location
router.post("/", authMiddleware, roleMiddleware("worker"), updateLocation);

// Admin gets all latest locations
router.get("/", authMiddleware, roleMiddleware("admin"), getAllLocations);

// Admin or worker can get one worker's locations
router.get("/:workerId", authMiddleware, roleMiddleware("admin", "worker"), getWorkerLocations);

module.exports = router;