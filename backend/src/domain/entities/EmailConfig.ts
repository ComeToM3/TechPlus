interface EmailConfigProps {
  host: string;
  port: number;
  secure: boolean;
  auth: {
    user: string;
    pass: string;
  };
  from: {
    name: string;
    email: string;
  };
  tls?: {
    rejectUnauthorized: boolean;
  };
}

export class EmailConfig {
  private props: EmailConfigProps;

  constructor(props: EmailConfigProps) {
    this.props = props;
  }

  // Getters
  get host(): string { return this.props.host; }
  get port(): number { return this.props.port; }
  get secure(): boolean { return this.props.secure; }
  get auth(): { user: string; pass: string } { return this.props.auth; }
  get from(): { name: string; email: string } { return this.props.from; }
  get tls(): { rejectUnauthorized: boolean } | undefined { return this.props.tls; }

  // Business logic methods
  isConfigured(): boolean {
    return !!(this.props.auth.user && this.props.auth.pass);
  }

  isSecure(): boolean {
    return this.props.secure;
  }

  getConnectionString(): string {
    return `${this.props.auth.user}@${this.props.host}:${this.props.port}`;
  }

  toJSON() {
    return {
      host: this.host,
      port: this.port,
      secure: this.secure,
      auth: this.auth,
      from: this.from,
      tls: this.tls,
    };
  }
}

