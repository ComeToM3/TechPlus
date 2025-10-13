import { Router } from 'express';
import { TableControllerNew } from '../controllers/tableControllerNew';
import { Container } from '../infrastructure/container/Container';

const router = Router();

// Récupérer le controller depuis le container DI
const tableController = Container.getInstance().getTableController();

/**
 * @route GET /api/admin/tables
 * @description Get all tables for the restaurant
 * @access Admin only
 */
router.get('/', (req, res) => {
  tableController.getTables(req, res);
});

/**
 * @route GET /api/admin/tables/:id
 * @description Get a specific table by ID
 * @access Admin only
 */
router.get('/:id', (req, res) => {
  tableController.getTableById(req, res);
});

/**
 * @route POST /api/admin/tables
 * @description Create a new table
 * @access Admin only
 */
router.post('/', (req, res) => {
  tableController.createTable(req, res);
});

/**
 * @route PUT /api/admin/tables/:id
 * @description Update a table
 * @access Admin only
 */
router.put('/:id', (req, res) => {
  tableController.updateTable(req, res);
});

/**
 * @route DELETE /api/admin/tables/:id
 * @description Delete a table
 * @access Admin only
 */
router.delete('/:id', (req, res) => {
  tableController.deleteTable(req, res);
});

/**
 * @route GET /api/admin/tables/statistics
 * @description Get table statistics
 * @access Admin only
 */
router.get('/statistics', (req, res) => {
  tableController.getTableStatistics(req, res);
});

/**
 * @route GET /api/admin/tables/metadata
 * @description Get tables metadata only (without reservations)
 * @access Admin only
 */
router.get('/metadata', (req, res) => {
  tableController.getTableMetadata(req, res);
});

/**
 * @route PATCH /api/admin/tables/batch
 * @description Batch update multiple tables
 * @access Admin only
 */
router.patch('/batch', (req, res) => {
  tableController.batchUpdateTables(req, res);
});

export default router;
