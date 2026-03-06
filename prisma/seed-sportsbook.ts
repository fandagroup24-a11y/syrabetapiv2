import { PrismaClient } from '@prisma/client';
import { seedSportsbook } from '../src/dev-seed/sportsbook-seeder';

const prisma = new PrismaClient();

async function main() {
  const result = await seedSportsbook(prisma);
  console.log(JSON.stringify(result, null, 2));
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
