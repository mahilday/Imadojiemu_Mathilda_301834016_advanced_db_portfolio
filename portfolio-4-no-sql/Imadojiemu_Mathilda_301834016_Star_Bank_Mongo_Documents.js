// Star Bank document model (Portfolio 4)
// Run with mongosh against a MongoDB server. Safe to re-run: it rebuilds both collections.

db = db.getSiblingDB('star_bank');
db.members.drop();
db.transactions.drop();

// ---------------------------------------------------------------------
// 1. Collections with validation rules
//    A document database has no fixed schema by default. These rules put
//    back the checks that matter most, mirroring the Portfolio 1 constraints.
// ---------------------------------------------------------------------
db.createCollection('members', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['full_name', 'email', 'phone', 'country', 'accounts'],
      properties: {
        full_name: { bsonType: 'string' },
        email: { bsonType: 'string' },
        phone: { bsonType: 'string' },
        country: { enum: ['NG', 'KE'] }, // BR2
        accounts: {
          bsonType: 'array',
          items: {
            bsonType: 'object',
            required: ['account_number', 'currency', 'balance', 'status'],
            properties: {
              account_number: { bsonType: 'string' },
              currency: { enum: ['NGN', 'KES'] }, // BR5
              balance: { bsonType: 'decimal', minimum: 0 }, // BR6
              status: { enum: ['ACTIVE', 'FROZEN', 'CLOSED'] }, // BR7
            },
          },
        },
      },
    },
  },
});

db.createCollection('transactions', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: [
        'reference',
        'type',
        'amount',
        'currency',
        'status',
        'entries',
        'created_at',
      ],
      properties: {
        reference: { bsonType: 'string' },
        type: { enum: ['DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'BILL_PAYMENT'] }, // BR8
        amount: { bsonType: 'decimal', minimum: 0, exclusiveMinimum: true }, // BR9
        currency: { enum: ['NGN', 'KES'] },
        status: { enum: ['PENDING', 'COMPLETED', 'FAILED', 'REVERSED'] }, // BR11
        entries: {
          bsonType: 'array',
          items: {
            bsonType: 'object',
            required: ['account_number', 'type', 'amount'],
            properties: {
              account_number: { bsonType: 'string' },
              type: { enum: ['DEBIT', 'CREDIT'] },
              amount: { bsonType: 'decimal' },
            },
          },
        },
        created_at: { bsonType: 'date' },
      },
    },
  },
});

// ---------------------------------------------------------------------
// 2. Indexes
// ---------------------------------------------------------------------
db.members.createIndex({ email: 1 }, { unique: true }); // BR1
db.members.createIndex({ 'accounts.account_number': 1 }, { unique: true }); // BR4
db.transactions.createIndex({ reference: 1 }, { unique: true });
db.transactions.createIndex({ 'entries.account_number': 1, created_at: -1 }); // statements

// ---------------------------------------------------------------------
// 3. Sample data: the same members and transactions as the Portfolio 1 sample data
//    Accounts are EMBEDDED in their member. Ledger entries are EMBEDDED in
//    their transaction. No joins are needed to read either.
// ---------------------------------------------------------------------
db.members.insertMany([
  {
    full_name: 'Adaeze Okafor',
    email: 'adaeze.okafor@mail.example',
    phone: '+2348030000001',
    country: 'NG',
    accounts: [
      {
        account_number: '0100000001',
        currency: 'NGN',
        balance: NumberDecimal('35000.00'),
        status: 'ACTIVE',
      },
      {
        account_number: '0100000002',
        currency: 'NGN',
        balance: NumberDecimal('0.00'),
        status: 'ACTIVE',
      },
    ],
  },
  {
    full_name: 'Tunde Bakare',
    email: 'tunde.bakare@mail.example',
    phone: '+2348030000002',
    country: 'NG',
    accounts: [
      {
        account_number: '0100000003',
        currency: 'NGN',
        balance: NumberDecimal('27000.00'),
        status: 'ACTIVE',
      },
    ],
  },
  {
    full_name: 'Wanjiru Kamau',
    email: 'wanjiru.kamau@mail.example',
    phone: '+254710000001',
    country: 'KE',
    accounts: [
      {
        account_number: '0200000001',
        currency: 'KES',
        balance: NumberDecimal('11000.00'),
        status: 'ACTIVE',
      },
    ],
  },
  {
    full_name: 'Otieno Odhiambo',
    email: 'otieno.odhiambo@mail.example',
    phone: '+254710000002',
    country: 'KE',
    accounts: [
      {
        account_number: '0200000002',
        currency: 'KES',
        balance: NumberDecimal('4000.00'),
        status: 'ACTIVE',
      },
    ],
  },
]);

// The "details" field holds different information for each transaction type.
// A relational table would need extra nullable columns or extra tables for this.
db.transactions.insertMany([
  {
    reference: 'TXN-0001',
    type: 'DEPOSIT',
    amount: NumberDecimal('50000.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-01T09:00:00Z'),
    details: { channel: 'AGENT', agent_code: 'AG-LAG-014' },
    entries: [
      {
        account_number: '0100000001',
        type: 'CREDIT',
        amount: NumberDecimal('50000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0002',
    type: 'DEPOSIT',
    amount: NumberDecimal('20000.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-01T10:30:00Z'),
    details: { channel: 'BANK_TRANSFER' },
    entries: [
      {
        account_number: '0100000003',
        type: 'CREDIT',
        amount: NumberDecimal('20000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0003',
    type: 'DEPOSIT',
    amount: NumberDecimal('15000.00'),
    currency: 'KES',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-02T08:15:00Z'),
    details: { channel: 'MOBILE_MONEY', provider_reference: 'MM-88213' },
    entries: [
      {
        account_number: '0200000001',
        type: 'CREDIT',
        amount: NumberDecimal('15000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0004',
    type: 'TRANSFER',
    amount: NumberDecimal('10000.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-03T12:00:00Z'),
    details: { narration: 'Payment for fabric supplies' },
    entries: [
      {
        account_number: '0100000001',
        type: 'DEBIT',
        amount: NumberDecimal('10000.00'),
      },
      {
        account_number: '0100000003',
        type: 'CREDIT',
        amount: NumberDecimal('10000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0005',
    type: 'BILL_PAYMENT',
    amount: NumberDecimal('5000.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-04T16:45:00Z'),
    biller: {
      name: 'Lagos Power Distribution',
      category: 'Electricity',
      country: 'NG',
    },
    details: { meter_number: '04172839465', token_units: 62.5 },
    entries: [
      {
        account_number: '0100000001',
        type: 'DEBIT',
        amount: NumberDecimal('5000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0006',
    type: 'WITHDRAWAL',
    amount: NumberDecimal('3000.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-05T11:20:00Z'),
    details: { channel: 'AGENT', agent_code: 'AG-LAG-022' },
    entries: [
      {
        account_number: '0100000003',
        type: 'DEBIT',
        amount: NumberDecimal('3000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0007',
    type: 'TRANSFER',
    amount: NumberDecimal('4000.00'),
    currency: 'KES',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-06T09:10:00Z'),
    details: { narration: 'Stock restock' },
    entries: [
      {
        account_number: '0200000001',
        type: 'DEBIT',
        amount: NumberDecimal('4000.00'),
      },
      {
        account_number: '0200000002',
        type: 'CREDIT',
        amount: NumberDecimal('4000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0008',
    type: 'TRANSFER',
    amount: NumberDecimal('2000.00'),
    currency: 'NGN',
    status: 'REVERSED',
    created_at: ISODate('2026-11-07T14:00:00Z'),
    details: { narration: 'Sent to wrong account' },
    entries: [
      {
        account_number: '0100000001',
        type: 'DEBIT',
        amount: NumberDecimal('2000.00'),
      },
      {
        account_number: '0100000002',
        type: 'CREDIT',
        amount: NumberDecimal('2000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0009',
    type: 'TRANSFER',
    amount: NumberDecimal('2000.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    created_at: ISODate('2026-11-07T15:30:00Z'),
    reverses: 'TXN-0008',
    details: {
      narration: 'Reversal of TXN-0008',
      approved_by: 'halima.yusuf@starbank.example',
    },
    entries: [
      {
        account_number: '0100000002',
        type: 'DEBIT',
        amount: NumberDecimal('2000.00'),
      },
      {
        account_number: '0100000001',
        type: 'CREDIT',
        amount: NumberDecimal('2000.00'),
      },
    ],
  },
  {
    reference: 'TXN-0010',
    type: 'WITHDRAWAL',
    amount: NumberDecimal('90000.00'),
    currency: 'NGN',
    status: 'FAILED',
    created_at: ISODate('2026-11-08T10:05:00Z'),
    details: { channel: 'AGENT', failure_reason: 'INSUFFICIENT_FUNDS' },
    entries: [],
  },
]);

print('--- Counts ---');
print(
  'members: ' +
    db.members.countDocuments() +
    ', transactions: ' +
    db.transactions.countDocuments(),
);

// ---------------------------------------------------------------------
// 4. Queries
// ---------------------------------------------------------------------
print('--- Q1: a member with all accounts, in one read and no join ---');
printjson(
  db.members.findOne({ email: 'adaeze.okafor@mail.example' }, { _id: 0 }),
);

print('--- Q2: statement for account 0100000001, newest first ---');
db.transactions
  .find(
    { 'entries.account_number': '0100000001' },
    { _id: 0, reference: 1, type: 1, amount: 1, status: 1, created_at: 1 },
  )
  .sort({ created_at: -1 })
  .forEach((doc) => printjson(doc));

print('--- Q3: failed and pending transactions ---');
db.transactions
  .find(
    { status: { $in: ['FAILED', 'PENDING'] } },
    {
      _id: 0,
      reference: 1,
      type: 1,
      amount: 1,
      status: 1,
      'details.failure_reason': 1,
    },
  )
  .forEach((doc) => printjson(doc));

print(
  '--- Q4: completed transactions by type and currency (aggregation pipeline) ---',
);
db.transactions
  .aggregate([
    { $match: { status: 'COMPLETED' } },
    {
      $group: {
        _id: { type: '$type', currency: '$currency' },
        transactions: { $sum: 1 },
        total_amount: { $sum: '$amount' },
      },
    },
    { $sort: { '_id.currency': 1, '_id.type': 1 } },
  ])
  .forEach((doc) => printjson(doc));

print('--- Q5: ledger balance per account, from the embedded entries ---');
db.transactions
  .aggregate([
    { $unwind: '$entries' },
    {
      $group: {
        _id: '$entries.account_number',
        ledger_balance: {
          $sum: {
            $cond: [
              { $eq: ['$entries.type', 'CREDIT'] },
              '$entries.amount',
              { $multiply: ['$entries.amount', -1] },
            ],
          },
        },
      },
    },
    { $sort: { _id: 1 } },
  ])
  .forEach((doc) => printjson(doc));

print('--- Q6: bill payments, using a field that only bill payments have ---');
db.transactions
  .find(
    { 'details.meter_number': { $exists: true } },
    {
      _id: 0,
      reference: 1,
      'biller.name': 1,
      'details.meter_number': 1,
      amount: 1,
    },
  )
  .forEach((doc) => printjson(doc));

// ---------------------------------------------------------------------
// 5. Validation tests: each insert breaks a rule and should be rejected
// ---------------------------------------------------------------------
print('--- V1: member in a country outside NG and KE (expect rejection) ---');
try {
  db.members.insertOne({
    full_name: 'Kofi Mensah',
    email: 'kofi.mensah@mail.example',
    phone: '+233200000001',
    country: 'GH',
    accounts: [],
  });
  print('NOT rejected');
} catch (e) {
  print('Rejected: ' + e.message);
}

print('--- V2: duplicate member email (expect rejection) ---');
try {
  db.members.insertOne({
    full_name: 'Duplicate Person',
    email: 'adaeze.okafor@mail.example',
    phone: '+2348039999999',
    country: 'NG',
    accounts: [],
  });
  print('NOT rejected');
} catch (e) {
  print('Rejected: ' + e.message);
}

print('--- V3: transaction with an amount of zero (expect rejection) ---');
try {
  db.transactions.insertOne({
    reference: 'TXN-V003',
    type: 'DEPOSIT',
    amount: NumberDecimal('0.00'),
    currency: 'NGN',
    status: 'COMPLETED',
    entries: [],
    created_at: new Date(),
  });
  print('NOT rejected');
} catch (e) {
  print('Rejected: ' + e.message);
}

// ---------------------------------------------------------------------
// 6. Confirm the statement query uses its index
// ---------------------------------------------------------------------
print('--- Query plan for the statement query ---');
printjson(
  db.transactions
    .find({ 'entries.account_number': '0100000001' })
    .sort({ created_at: -1 })
    .explain('queryPlanner').queryPlanner.winningPlan,
);
