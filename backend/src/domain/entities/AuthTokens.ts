/**
 * Entité métier AuthTokens - Représente une paire de tokens d'authentification
 */

export interface AuthTokensProps {
  readonly accessToken: string;
  readonly refreshToken: string;
  readonly expiresIn: number; // en secondes
  readonly tokenType: string;
}

export class AuthTokens {
  constructor(private readonly props: AuthTokensProps) {}

  get accessToken(): string {
    return this.props.accessToken;
  }

  get refreshToken(): string {
    return this.props.refreshToken;
  }

  get expiresIn(): number {
    return this.props.expiresIn;
  }

  get tokenType(): string {
    return this.props.tokenType;
  }

  // Méthode pour sérialiser les tokens (pour les réponses API)
  toJSON() {
    return {
      accessToken: this.props.accessToken,
      refreshToken: this.props.refreshToken,
      expiresIn: this.props.expiresIn,
      tokenType: this.props.tokenType
    };
  }

  // Méthode pour créer des tokens à partir d'une paire JWT
  static fromJWT(accessToken: string, refreshToken: string, expiresIn: number = 900): AuthTokens {
    return new AuthTokens({
      accessToken,
      refreshToken,
      expiresIn,
      tokenType: 'Bearer'
    });
  }
}


