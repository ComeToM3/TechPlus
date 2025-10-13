/**
 * Helper pour les tests de migration Clean Architecture
 * Fournit des utilitaires communs pour tester la résolution des dépendances
 */

import { Container } from '../../src/infrastructure/container/Container';

export class MigrationTestHelper {
  private container: Container;

  constructor() {
    this.container = Container.getInstance();
  }

  /**
   * Teste la résolution d'un repository
   */
  async testRepository(repositoryName: string): Promise<boolean> {
    try {
      const repository = this.container.resolve(repositoryName);
      expect(repository).toBeDefined();
      expect((repository as any).constructor.name).toContain('Repository');
      return true;
    } catch (error) {
      console.error(`❌ Erreur lors de la résolution du repository ${repositoryName}:`, error);
      return false;
    }
  }

  /**
   * Teste la résolution d'un use case
   */
  async testUseCase(useCaseName: string): Promise<boolean> {
    try {
      const useCase = this.container.resolve(useCaseName);
      expect(useCase).toBeDefined();
      expect((useCase as any).constructor.name).toContain('UseCase');
      return true;
    } catch (error) {
      console.error(`❌ Erreur lors de la résolution du use case ${useCaseName}:`, error);
      return false;
    }
  }

  /**
   * Teste la résolution d'un controller
   */
  async testController(controllerName: string): Promise<boolean> {
    try {
      const controller = this.container.resolve(controllerName);
      expect(controller).toBeDefined();
      expect((controller as any).constructor.name).toContain('Controller');
      return true;
    } catch (error) {
      console.error(`❌ Erreur lors de la résolution du controller ${controllerName}:`, error);
      return false;
    }
  }

  /**
   * Teste la résolution d'un service
   */
  async testService(serviceName: string): Promise<boolean> {
    try {
      const service = this.container.resolve(serviceName);
      expect(service).toBeDefined();
      expect((service as any).constructor.name).toContain('Service');
      return true;
    } catch (error) {
      console.error(`❌ Erreur lors de la résolution du service ${serviceName}:`, error);
      return false;
    }
  }

  /**
   * Teste la résolution de plusieurs composants
   */
  async testMultipleComponents(components: string[]): Promise<{ [key: string]: boolean }> {
    const results: { [key: string]: boolean } = {};
    
    for (const component of components) {
      try {
        const resolved = this.container.resolve(component);
        expect(resolved).toBeDefined();
        results[component] = true;
      } catch (error) {
        console.error(`❌ Erreur lors de la résolution de ${component}:`, error);
        results[component] = false;
      }
    }
    
    return results;
  }

  /**
   * Teste le chargement d'une entité métier
   */
  async testEntity(entityPath: string, entityName: string): Promise<boolean> {
    try {
      const entityModule = await import(entityPath);
      const EntityClass = entityModule[entityName];
      expect(EntityClass).toBeDefined();
      expect(typeof EntityClass).toBe('function');
      return true;
    } catch (error) {
      console.error(`❌ Erreur lors du chargement de l'entité ${entityName}:`, error);
      return false;
    }
  }

  /**
   * Teste la logique métier d'une entité
   */
  async testEntityBusinessLogic(entityPath: string, entityName: string, testData: any): Promise<boolean> {
    try {
      const entityModule = await import(entityPath);
      const EntityClass = entityModule[entityName];
      
      // Test de création d'instance
      const instance = new EntityClass(testData);
      expect(instance).toBeDefined();
      
      // Test des méthodes métier si elles existent
      if (typeof instance.toJSON === 'function') {
        const json = instance.toJSON();
        expect(json).toBeDefined();
      }
      
      return true;
    } catch (error) {
      console.error(`❌ Erreur lors du test de la logique métier de ${entityName}:`, error);
      return false;
    }
  }
}
