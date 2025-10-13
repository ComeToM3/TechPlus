/**
 * Interface Repository pour l'entité User
 * Définit les contrats d'accès aux données sans dépendance à l'implémentation
 */

import { User } from '../entities/User';

export interface CreateUserData {
  email: string;
  password?: string;
  name?: string;
  phone?: string;
  avatar?: string;
  role?: string;
  isActive?: boolean;
}

export interface UpdateUserData {
  name?: string;
  phone?: string;
  avatar?: string;
  password?: string;
  isActive?: boolean;
  lastLoginAt?: Date;
}

export interface UserRepository {
  /**
   * Trouve un utilisateur par son email
   */
  findByEmail(email: string): Promise<User | null>;

  /**
   * Trouve un utilisateur par son ID
   */
  findById(id: string): Promise<User | null>;

  /**
   * Crée un nouvel utilisateur
   */
  create(userData: CreateUserData): Promise<User>;

  /**
   * Met à jour un utilisateur existant
   */
  update(id: string, userData: UpdateUserData): Promise<User>;

  /**
   * Supprime un utilisateur
   */
  delete(id: string): Promise<void>;

  /**
   * Vérifie si un utilisateur existe par email
   */
  existsByEmail(email: string): Promise<boolean>;

  /**
   * Trouve un utilisateur par email avec son mot de passe (pour l'authentification)
   */
  findByEmailWithPassword(email: string): Promise<{ user: User; password: string } | null>;

  /**
   * Met à jour la dernière connexion d'un utilisateur
   */
  updateLastLogin(id: string): Promise<void>;
}


