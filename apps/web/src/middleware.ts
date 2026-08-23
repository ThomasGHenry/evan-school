import { type NextRequest, NextResponse } from 'next/server';

export function middleware(_req: NextRequest): NextResponse {
  return NextResponse.next();
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
