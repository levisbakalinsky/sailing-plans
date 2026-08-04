import { clerkMiddleware, getAuth } from '@clerk/hono';
import { Hono } from 'hono';
import { getPrisma } from '../db.js';

export const meRoutes = new Hono();

meRoutes.use('*', clerkMiddleware());

meRoutes.get('/', async (c) => {
  const { userId } = getAuth(c);
  if (!userId) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const clerk = c.get('clerk');
  const clerkUser = await clerk.users.getUser(userId);
  const email =
    clerkUser.primaryEmailAddress?.emailAddress ??
    clerkUser.emailAddresses[0]?.emailAddress;

  if (!email) {
    return c.json({ error: 'Clerk user has no email address' }, 400);
  }

  const prisma = getPrisma();
  const user = await prisma.user.upsert({
    where: { clerkId: userId },
    create: { clerkId: userId, email },
    update: { email },
  });

  return c.json({
    id: user.id,
    clerkId: user.clerkId,
    email: user.email,
  });
});
