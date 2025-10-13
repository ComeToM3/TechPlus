import { Request, Response } from 'express';
import { GetTablesUseCase } from '../domain/use-cases/table/GetTablesUseCase';
import { GetTableByIdUseCase } from '../domain/use-cases/table/GetTableByIdUseCase';
import { CreateTableUseCase } from '../domain/use-cases/table/CreateTableUseCase';
import { UpdateTableUseCase } from '../domain/use-cases/table/UpdateTableUseCase';
import { DeleteTableUseCase } from '../domain/use-cases/table/DeleteTableUseCase';
import { GetTableStatisticsUseCase } from '../domain/use-cases/table/GetTableStatisticsUseCase';
import { GetTableMetadataUseCase } from '../domain/use-cases/table/GetTableMetadataUseCase';
import { BatchUpdateTablesUseCase } from '../domain/use-cases/table/BatchUpdateTablesUseCase';
import logger from '../utils/logger';

export class TableControllerNew {
  constructor(
    private getTablesUseCase: GetTablesUseCase,
    private getTableByIdUseCase: GetTableByIdUseCase,
    private createTableUseCase: CreateTableUseCase,
    private updateTableUseCase: UpdateTableUseCase,
    private deleteTableUseCase: DeleteTableUseCase,
    private getTableStatisticsUseCase: GetTableStatisticsUseCase,
    private getTableMetadataUseCase: GetTableMetadataUseCase,
    private batchUpdateTablesUseCase: BatchUpdateTablesUseCase
  ) {}

  async getTables(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      // Pour l'instant, on utilise le premier restaurant
      // TODO: Récupérer le restaurantId depuis l'utilisateur ou les paramètres
      const restaurantId = 'default-restaurant-id'; // À remplacer par la logique réelle

      const result = await this.getTablesUseCase.execute({
        restaurantId,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Tables retrieved', {
        userId: user.id,
        restaurantId,
        tableCount: result.data?.length,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get tables', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get tables',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getTableById(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { id } = req.params;

      const result = await this.getTableByIdUseCase.execute({
        tableId: id!,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Table retrieved', {
        userId: user.id,
        tableId: id,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get table', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get table',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async createTable(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { number, capacity, position, status } = req.body;

      // Pour l'instant, on utilise le premier restaurant
      // TODO: Récupérer le restaurantId depuis l'utilisateur ou les paramètres
      const restaurantId = 'default-restaurant-id'; // À remplacer par la logique réelle

      const result = await this.createTableUseCase.execute({
        number,
        capacity,
        position,
        status,
        restaurantId,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Table created', {
        userId: user.id,
        restaurantId,
        tableId: result.data?.id,
        tableNumber: result.data?.number,
        ip: req.ip,
      });

      res.status(201).json({
        success: true,
        data: result.data,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to create table', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to create table',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async updateTable(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { id } = req.params;
      const { number, capacity, position, isActive } = req.body;

      const result = await this.updateTableUseCase.execute({
        tableId: id!,
        number,
        capacity,
        position,
        isActive,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Table updated', {
        userId: user.id,
        tableId: id,
        tableNumber: result.data?.number,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to update table', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to update table',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async deleteTable(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { id } = req.params;

      const result = await this.deleteTableUseCase.execute({
        tableId: id!,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Table deleted', {
        userId: user.id,
        tableId: id,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      logger.error('Failed to delete table', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to delete table',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getTableStatistics(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      // Pour l'instant, on utilise le premier restaurant
      // TODO: Récupérer le restaurantId depuis l'utilisateur ou les paramètres
      const restaurantId = 'default-restaurant-id'; // À remplacer par la logique réelle

      const result = await this.getTableStatisticsUseCase.execute({
        restaurantId,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Table statistics retrieved', {
        userId: user.id,
        restaurantId,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get table statistics', {
        error: error instanceof Error ? error.message : 'Unknown error',
        stack: error instanceof Error ? error.stack : undefined,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get table statistics',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async getTableMetadata(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      // Pour l'instant, on utilise le premier restaurant
      // TODO: Récupérer le restaurantId depuis l'utilisateur ou les paramètres
      const restaurantId = 'default-restaurant-id'; // À remplacer par la logique réelle

      const result = await this.getTableMetadataUseCase.execute({
        restaurantId,
      });

      if (!result.success) {
        res.status(404).json({
          success: false,
          message: result.message,
        });
        return;
      }

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to get table metadata', {
        error: error instanceof Error ? error.message : 'Unknown error',
        ip: req.ip,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to get table metadata',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }

  async batchUpdateTables(req: Request, res: Response): Promise<void> {
    try {
      const user = (req as any).user;
      if (!user || (user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN')) {
        res.status(403).json({
          success: false,
          message: 'Access denied. Admin privileges required.',
        });
        return;
      }

      const { updates } = req.body;

      const result = await this.batchUpdateTablesUseCase.execute({
        updates,
      });

      if (!result.success) {
        res.status(400).json({
          success: false,
          message: result.message,
        });
        return;
      }

      logger.info('Tables batch updated', {
        userId: user.id,
        successful: result.data?.successful,
        failed: result.data?.failed,
        total: result.data?.total,
        ip: req.ip,
      });

      res.status(200).json({
        success: true,
        data: result.data,
      });
    } catch (error) {
      logger.error('Failed to batch update tables', {
        error: error instanceof Error ? error.message : 'Unknown error',
        ip: req.ip,
      });

      res.status(500).json({
        success: false,
        message: 'Failed to batch update tables',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  }
}
