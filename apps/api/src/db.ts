import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from './generated/prisma/client.js';

const globalForPrisma = globalThis as unknown as {
  prisma?: PrismaClient;
};

export function getPrisma(): PrismaClient {
  if (globalForPrisma.prisma) {
    return globalForPrisma.prisma;
  }

  const connectionString = process.env.DATABASE_URL;
  if (!connectionString) {
    throw new Error('DATABASE_URL is required to create PrismaClient');
  }

  // DigitalOcean managed Postgres uses TLS; node-pg honors sslmode in the URL.
  const adapter = new PrismaPg({ connectionString });
  const prisma = new PrismaClient({ adapter });

  if (process.env.NODE_ENV !== 'production') {
    globalForPrisma.prisma = prisma;
  }

  return prisma;
}
