import { SignIn } from '@clerk/nextjs';
import { AuthShell } from '../../../components/AuthShell';
import { clerkAppearance } from '../../../lib/clerkAppearance';

export default function LoginPage() {
  return (
    <AuthShell mode="login">
      <SignIn
        routing="path"
        path="/login"
        signUpUrl="/sign-up"
        fallbackRedirectUrl="/dashboard"
        forceRedirectUrl="/dashboard"
        appearance={clerkAppearance}
      />
    </AuthShell>
  );
}
