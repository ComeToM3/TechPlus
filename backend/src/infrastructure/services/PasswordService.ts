/**
 * Service d'infrastructure pour la gestion des mots de passe
 */

import { hash, compare } from 'bcryptjs';
import { PasswordService as IPasswordService } from '../../domain/use-cases/auth/RegisterUserUseCase';

export class PasswordService implements IPasswordService {
  async hash(password: string): Promise<string> {
    return await hash(password, 12);
  }

  async compare(password: string, hashedPassword: string): Promise<boolean> {
    return await compare(password, hashedPassword);
  }
}


