import { ClerkProvider } from '@clerk/nextjs';
import type { ReactNode } from 'react';

export const metadata = {
  title: "Evan's Meditation School",
  description: 'Live meditation courses with Evan.',
};

function wrapWithClerk(children: ReactNode): ReactNode {
  const publishableKey = process.env['NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY'];
  if (!publishableKey) return children;
  return <ClerkProvider publishableKey={publishableKey}>{children}</ClerkProvider>;
}

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{wrapWithClerk(children)}</body>
    </html>
  );
}
