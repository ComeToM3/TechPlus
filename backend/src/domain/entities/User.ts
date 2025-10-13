import { UserRole } from '@prisma/client';

interface UserProps {
  id: string;
  email: string;
  password?: string;
  name?: string;
  phone?: string;
  avatar?: string;
  role: UserRole;
  isActive: boolean;
  lastLoginAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export class User {
  private props: UserProps;

  constructor(props: UserProps) {
    this.props = props;
  }

  get id(): string { return this.props.id; }
  get email(): string { return this.props.email; }
  get password(): string | undefined { return this.props.password; }
  get name(): string | undefined { return this.props.name; }
  get phone(): string | undefined { return this.props.phone; }
  get avatar(): string | undefined { return this.props.avatar; }
  get role(): UserRole { return this.props.role; }
  get isActive(): boolean { return this.props.isActive; }
  get lastLoginAt(): Date | undefined { return this.props.lastLoginAt; }
  get createdAt(): Date { return this.props.createdAt; }
  get updatedAt(): Date { return this.props.updatedAt; }

  // Factory method to create User from Prisma model
  static fromPrisma(prismaUser: any): User {
    return new User({
      id: prismaUser.id,
      email: prismaUser.email,
      password: prismaUser.password,
      name: prismaUser.name,
      phone: prismaUser.phone,
      avatar: prismaUser.avatar,
      role: prismaUser.role,
      isActive: prismaUser.isActive,
      lastLoginAt: prismaUser.lastLoginAt,
      createdAt: prismaUser.createdAt,
      updatedAt: prismaUser.updatedAt,
    });
  }

  toJSON() {
    return {
      id: this.id,
      email: this.email,
      name: this.name,
      phone: this.phone,
      avatar: this.avatar,
      role: this.role,
      isActive: this.isActive,
      lastLoginAt: this.lastLoginAt,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}


