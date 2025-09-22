declare module 'express-sanitizer' {
  import { Request, Response, NextFunction } from 'express';

  interface SanitizerOptions {
    allowedTags?: string[];
    allowedAttributes?: { [key: string]: string[] };
    allowedSchemes?: string[];
    allowedSchemesByTag?: { [key: string]: string[] };
  }

  function expressSanitizer(
    options?: SanitizerOptions
  ): (req: Request, res: Response, next: NextFunction) => void;

  export = expressSanitizer;
}
