import { PrismaClient, UserRole, ReservationStatus, PaymentStatus } from '@prisma/client';
import { hash } from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Create a restaurant
  const restaurant = await prisma.restaurant.create({
    data: {
      name: 'TechPlus Restaurant',
      description: 'Un restaurant moderne avec une cuisine française raffinée',
      address: '123 Rue de la Paix, 75001 Paris, France',
      phone: '+33 1 23 45 67 89',
      email: 'contact@techplus-restaurant.com',
      website: 'https://techplus-restaurant.com',
      images: [
        'https://example.com/restaurant-1.jpg',
        'https://example.com/restaurant-2.jpg',
        'https://example.com/restaurant-3.jpg'
      ],
      settings: {
        bufferTime: 30, // 30 minutes entre les réservations
        maxPartySize: 12,
        advanceBookingDays: 30
      },
      openingHours: {
        monday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
        tuesday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
        wednesday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
        thursday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
        friday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
        saturday: { open: '12:00', close: '14:30', evening: { open: '19:00', close: '22:30' } },
        sunday: { closed: true }
      },
      averagePricePerPerson: 45.00,
      minimumDepositAmount: 15.00,
      paymentThreshold: 6,
      cancellationPolicy: 'Annulation gratuite jusqu\'à 24h avant la réservation'
    }
  });

  console.log('✅ Restaurant created:', restaurant.name);

  // Create tables
  const tables = [];
  for (let i = 1; i <= 20; i++) {
    const capacity = i <= 10 ? 2 : i <= 15 ? 4 : i <= 18 ? 6 : 8;
    const position = i <= 5 ? 'Terrasse' : i <= 10 ? 'Salle principale' : i <= 15 ? 'Salle privée' : 'VIP';
    
    const table = await prisma.table.create({
      data: {
        number: i,
        capacity,
        position,
        isActive: true,
        restaurantId: restaurant.id
      }
    });
    tables.push(table);
  }

  console.log('✅ Tables created:', tables.length);

  // Create admin user
  const hashedAdminPassword = await hash('admin123', 12);
  const adminUser = await prisma.user.create({
    data: {
      email: 'admin@techplus-restaurant.com',
      password: hashedAdminPassword,
      name: 'Admin TechPlus',
      phone: '+33 1 23 45 67 89',
      role: UserRole.ADMIN,
      isActive: true,
      lastLoginAt: new Date()
    }
  });

  console.log('✅ Admin user created:', adminUser.email);

  // Create test client user
  const hashedClientPassword = await hash('client123', 12);
  const clientUser = await prisma.user.create({
    data: {
      email: 'client@example.com',
      password: hashedClientPassword,
      name: 'Jean Dupont',
      phone: '+33 6 12 34 56 78',
      role: UserRole.CLIENT,
      isActive: true,
      lastLoginAt: new Date()
    }
  });

  console.log('✅ Client user created:', clientUser.email);

  // Create menu items
  const menuItems = [
    {
      name: 'Entrée - Terrine de Foie Gras',
      description: 'Terrine de foie gras de canard, chutney de figues, pain brioche toasté',
      price: 18.00,
      category: 'Entrées',
      allergens: ['gluten', 'œufs']
    },
    {
      name: 'Entrée - Salade de Chèvre Chaud',
      description: 'Salade verte, chèvre chaud sur toast, noix, vinaigrette balsamique',
      price: 14.00,
      category: 'Entrées',
      allergens: ['lait', 'gluten', 'fruits à coque']
    },
    {
      name: 'Plat - Magret de Canard',
      description: 'Magret de canard grillé, sauce aux cerises, légumes de saison',
      price: 28.00,
      category: 'Plats',
      allergens: []
    },
    {
      name: 'Plat - Saumon en Croûte',
      description: 'Filet de saumon en croûte d\'herbes, risotto aux champignons',
      price: 26.00,
      category: 'Plats',
      allergens: ['gluten', 'lait', 'œufs', 'poisson']
    },
    {
      name: 'Plat - Côte de Bœuf',
      description: 'Côte de bœuf grillée (pour 2 personnes), pommes de terre rôties',
      price: 65.00,
      category: 'Plats',
      allergens: []
    },
    {
      name: 'Dessert - Tarte Tatin',
      description: 'Tarte tatin aux pommes, crème anglaise vanille',
      price: 12.00,
      category: 'Desserts',
      allergens: ['gluten', 'lait', 'œufs']
    },
    {
      name: 'Dessert - Crème Brûlée',
      description: 'Crème brûlée à la vanille de Madagascar',
      price: 10.00,
      category: 'Desserts',
      allergens: ['lait', 'œufs']
    },
    {
      name: 'Boisson - Vin Rouge',
      description: 'Bordeaux 2018, Château Margaux',
      price: 45.00,
      category: 'Vins',
      allergens: ['sulfites']
    },
    {
      name: 'Boisson - Champagne',
      description: 'Champagne Dom Pérignon 2013',
      price: 180.00,
      category: 'Vins',
      allergens: ['sulfites']
    }
  ];

  for (const item of menuItems) {
    await prisma.menuItem.create({
      data: {
        ...item,
        restaurantId: restaurant.id,
        isAvailable: true
      }
    });
  }

  console.log('✅ Menu items created:', menuItems.length);

  // Create sample reservations
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  tomorrow.setHours(20, 0, 0, 0);

  const reservation1 = await prisma.reservation.create({
    data: {
      date: tomorrow,
      time: '20:00',
      duration: 90, // 1h30
      partySize: 2,
      status: ReservationStatus.CONFIRMED,
      notes: 'Anniversaire de mariage',
      specialRequests: 'Table près de la fenêtre si possible',
      userId: clientUser.id,
      tableId: tables[0]!.id,
      restaurantId: restaurant.id,
      requiresPayment: false,
      paymentStatus: PaymentStatus.NONE
    }
  });

  const dayAfterTomorrow = new Date();
  dayAfterTomorrow.setDate(dayAfterTomorrow.getDate() + 2);
  dayAfterTomorrow.setHours(19, 30, 0, 0);

  const reservation2 = await prisma.reservation.create({
    data: {
      date: dayAfterTomorrow,
      time: '19:30',
      duration: 120, // 2h00
      partySize: 8,
      status: ReservationStatus.PENDING,
      notes: 'Dîner d\'entreprise',
      clientName: 'Marie Martin',
      clientEmail: 'marie.martin@company.com',
      clientPhone: '+33 6 98 76 54 32',
      tableId: tables[15]!.id, // Table pour 8 personnes
      restaurantId: restaurant.id,
      requiresPayment: true,
      estimatedAmount: 360.00, // 8 personnes × 45€
      depositAmount: 60.00, // 15€ par personne
      paymentStatus: PaymentStatus.PENDING,
      managementToken: 'guest_' + Math.random().toString(36).substr(2, 9),
      tokenExpiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 jours
    }
  });

  console.log('✅ Sample reservations created:', 2);

  // Create sample analytics data
  const today = new Date();
  for (let i = 0; i < 30; i++) {
    const date = new Date(today);
    date.setDate(date.getDate() - i);
    
    await prisma.analytics.create({
      data: {
        date,
        metric: 'reservations_count',
        value: Math.floor(Math.random() * 20) + 5, // 5-25 réservations par jour
        restaurantId: restaurant.id
      }
    });

    await prisma.analytics.create({
      data: {
        date,
        metric: 'revenue',
        value: Math.floor(Math.random() * 2000) + 500, // 500-2500€ par jour
        restaurantId: restaurant.id
      }
    });

    await prisma.analytics.create({
      data: {
        date,
        metric: 'occupancy_rate',
        value: Math.floor(Math.random() * 40) + 40, // 40-80% d'occupation
        restaurantId: restaurant.id
      }
    });
  }

  console.log('✅ Analytics data created for 30 days');

  console.log('🎉 Database seeding completed successfully!');
  console.log('\n📊 Summary:');
  console.log(`- Restaurant: ${restaurant.name}`);
  console.log(`- Tables: ${tables.length}`);
  console.log(`- Users: 2 (1 admin, 1 client)`);
  console.log(`- Menu items: ${menuItems.length}`);
  console.log(`- Reservations: 2`);
  console.log(`- Analytics: 90 records (30 days × 3 metrics)`);
  console.log('\n🔑 Test credentials:');
  console.log('- Admin: admin@techplus-restaurant.com / admin123');
  console.log('- Client: client@example.com / client123');
  console.log('- Guest reservation token: ' + reservation2.managementToken);
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
