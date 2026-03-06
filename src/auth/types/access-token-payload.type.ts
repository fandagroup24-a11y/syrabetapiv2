export type AccessTokenPayload = {
  sub: string;
  sid: string;
  typ: 'access';
  iat?: number;
  exp?: number;
};
