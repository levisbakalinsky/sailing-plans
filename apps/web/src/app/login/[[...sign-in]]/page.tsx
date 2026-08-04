import { SignIn } from '@clerk/nextjs';
import { AuthShell } from '../../../components/AuthShell';
import { clerkAppearance } from '../../../lib/clerkAppearance';

export default function LoginPage() {
  return (
    <AuthShell eyebrow="Log in">
      <SignIn
        routing="path"
        path="/login"
        signUpUrl="/sign-up"
        fallbackRedirectUrl="/portal"
        forceRedirectUrl="/portal"
        appearance={clerkAppearance}
      />
    </AuthShell>
  );
}
