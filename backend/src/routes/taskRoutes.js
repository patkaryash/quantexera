const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const roleMiddleware = require("../middleware/roleMiddleware");

const {
  createTask,
  getAllTasks,
  assignTask,
  completeTask,
} = require("../controllers/taskController");

// Admin creates, views, assigns tasks
router.post("/", authMiddleware, roleMiddleware("admin"), createTask);
router.get("/", authMiddleware, roleMiddleware("admin", "worker"), getAllTasks);
router.put("/:id/assign", authMiddleware, roleMiddleware("admin"), assignTask);

// Worker/admin can mark complete
router.put("/:id/complete", authMiddleware, roleMiddleware("admin", "worker"), completeTask);

module.exports = router;