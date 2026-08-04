import { SignUp } from '@clerk/nextjs';
import { AuthShell } from '../../../components/AuthShell';
import { clerkAppearance } from '../../../lib/clerkAppearance';

export default function SignUpPage() {
  return (
    <AuthShell eyebrow="Sign up">
      <SignUp
        routing="path"
        path="/sign-up"
        signInUrl="/login"
        fallbackRedirectUrl="/portal"
        forceRedirectUrl="/portal"
        appearance={clerkAppearance}
      />
    </AuthShell>
  );
}
