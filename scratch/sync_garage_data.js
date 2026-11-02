const fs = require('fs');
const os = require('os');
const path = require('path');

const PROJECT_ID = 'garage-b7ed1';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

function getAccessToken() {
  const confPath = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  const conf = JSON.parse(fs.readFileSync(confPath, 'utf8'));
  return conf.tokens.access_token;
}

function toFirestoreValue(val) {
  if (val === null || val === undefined) {
    return { nullValue: null };
  }
  if (typeof val === 'string') {
    return { stringValue: val };
  }
  if (typeof val === 'boolean') {
    return { booleanValue: val };
  }
  if (typeof val === 'number') {
    if (Number.isInteger(val)) {
      return { integerValue: val.toString() };
    }
    return { doubleValue: val };
  }
  if (Array.isArray(val)) {
    return {
      arrayValue: {
        values: val.map(toFirestoreValue)
      }
    };
  }
  if (typeof val === 'object') {
    const fields = {};
    for (const [k, v] of Object.entries(val)) {
      fields[k] = toFirestoreValue(v);
    }
    return { mapValue: { fields } };
  }
  return { stringValue: String(val) };
}

function toFirestoreDoc(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) {
    fields[k] = toFirestoreValue(v);
  }
  return { fields };
}

async function setDoc(token, docPath, data) {
  const url = `${BASE_URL}/${docPath}`;
  const doc = toFirestoreDoc(data);
  const resp = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(doc)
  });
  if (!resp.ok) {
    const errText = await resp.text();
    throw new Error(`Failed to set ${docPath}: ${resp.status} ${errText}`);
  }
  console.log(`✔ Synced ${docPath}`);
}

async function run() {
  const token = getAccessToken();
  console.log('Using authenticated Firebase token...');

  const USER_UID = 'U07kBjbFDcWGFwqPooqfql1zx0g1';
  const USER_EMAIL = 'vishnushaji431@gmail.com';
  const GARAGE_ID = 'garage_U07kBjbFDcWGFwqPooqfql1zx0g1';

  // 1. Update user profile
  await setDoc(token, `users/${USER_UID}`, {
    uid: USER_UID,
    email: USER_EMAIL,
    fullName: 'Vishnu Shaji',
    phoneNumber: '+91 90614 44999',
    whatsappNumber: '+91 90614 44999',
    role: 'merchant',
    garageId: GARAGE_ID,
    avatarUrl: 'https://lh3.googleusercontent.com/a/ACg8ocK_PXDtS5ozIUxZgUJYoIbY_LXbLV8pdFDQPXlhnlVui8KH6Mo3=s96-c',
    preferredLanguage: 'en',
    createdAt: new Date().toISOString()
  });

  // 2. Customer Vehicles for Vishnu Shaji
  const vehicles = [
    {
      id: 'veh_honda_city',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      make: 'Honda',
      model: 'City ZX i-VTEC',
      year: 2021,
      licensePlate: 'KL 11 BP 4512',
      vehicleType: 'car',
      engineCc: 1498,
      fuelType: 'Petrol',
      color: 'Platinum White Pearl',
      currentOdometer: 32450,
      vin: 'MAKGM668M102948',
      lastServiceDate: '2026-08-15T10:00:00.000Z',
      lastServiceType: 'Major Service',
      nextServiceDue: new Date(Date.now() + 10 * 86400000).toISOString(),
      nextServiceOdometer: 35000,
      maintenanceIntervalMonths: 6,
      maintenanceIntervalKm: 5000,
      createdAt: new Date().toISOString()
    },
    {
      id: 'veh_re_classic',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      make: 'Royal Enfield',
      model: 'Classic 350 Reborn',
      year: 2022,
      licensePlate: 'KL 11 BS 8920',
      vehicleType: 'motorcycle',
      engineCc: 349,
      fuelType: 'Petrol',
      color: 'Stealth Black',
      currentOdometer: 12180,
      vin: 'ME3J3A5F7M02847',
      lastServiceDate: '2026-09-02T11:00:00.000Z',
      lastServiceType: 'Routine Service',
      nextServiceDue: new Date(Date.now() + 5 * 86400000).toISOString(),
      nextServiceOdometer: 14000,
      maintenanceIntervalMonths: 6,
      maintenanceIntervalKm: 3000,
      createdAt: new Date().toISOString()
    },
    {
      id: 'veh_ather_450x',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      make: 'Ather',
      model: '450X Gen 3',
      year: 2023,
      licensePlate: 'KL 11 CB 1042',
      vehicleType: 'scooter',
      engineCc: 0,
      fuelType: 'Electric',
      color: 'Space Grey',
      currentOdometer: 8400,
      vin: 'MB8450XG3N01934',
      lastServiceDate: '2026-07-20T09:30:00.000Z',
      lastServiceType: 'General Inspection',
      nextServiceDue: new Date(Date.now() + 25 * 86400000).toISOString(),
      nextServiceOdometer: 10000,
      maintenanceIntervalMonths: 12,
      maintenanceIntervalKm: 5000,
      createdAt: new Date().toISOString()
    }
  ];

  for (const v of vehicles) {
    await setDoc(token, `users/${USER_UID}/vehicles/${v.id}`, v);
  }

  // 3. Customer Reminders for Vishnu Shaji
  const reminders = [
    {
      id: 'rem_1',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      vehicleId: 'veh_honda_city',
      vehicleDisplay: '2021 Honda City ZX (KL 11 BP 4512)',
      title: 'Periodic Maintenance & Oil Change Due',
      serviceType: 'Periodic Service',
      dueDate: new Date(Date.now() + 10 * 86400000).toISOString(),
      dueMileage: 35000,
      status: 'pending',
      notes: 'Synthetic oil, air filter, and brake inspection due.',
      createdAt: new Date().toISOString()
    },
    {
      id: 'rem_2',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      vehicleId: 'veh_re_classic',
      vehicleDisplay: '2022 Royal Enfield Classic 350 (KL 11 BS 8920)',
      title: 'Drive Chain Tension & Lubrication Service',
      serviceType: 'Routine Service',
      dueDate: new Date(Date.now() + 5 * 86400000).toISOString(),
      dueMileage: 13000,
      status: 'pending',
      notes: 'Clean and lube O-ring chain, check clutch play.',
      createdAt: new Date().toISOString()
    }
  ];

  for (const rem of reminders) {
    await setDoc(token, `users/${USER_UID}/reminders/${rem.id}`, rem);
  }

  // 4. Update AUTO REPAIR garage profile (Vishnu Shaji's Garage)
  await setDoc(token, `garages/${GARAGE_ID}`, {
    name: 'AUTO REPAIR',
    address: 'Kannankara, Chelannur, Kozhikode, Kerala 673611',
    googleAddress: 'Kannankara, Chelannur, Kozhikode',
    city: 'Kozhikode',
    latitude: 11.3673718,
    longitude: 75.794424,
    googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=11.3673718,75.794424',
    phone: '+91 90614 44999',
    whatsappNumber: '+91 90614 44999',
    email: USER_EMAIL,
    currencyCode: 'INR',
    description: 'Premier multi-brand auto repair, body shop and periodic maintenance workshop in Chelannur, Kozhikode. Specializing in computer diagnostics, air conditioning overhaul, engine tuning, and express detailing.',
    rating: 4.85,
    reviewCount: 14,
    isVerified: true,
    isDoorstepRepairAvailable: true,
    isRoadsideAssistanceAvailable: true,
    ownerUid: USER_UID,
    taxNumber: '32AABCA1234F1Z8',
    coverImageUrl: 'https://images.unsplash.com/photo-1613214149922-f1809c99b414?auto=format&fit=crop&w=1200&q=80',
    bannerUrl: 'https://images.unsplash.com/photo-1613214149922-f1809c99b414?auto=format&fit=crop&w=1200&q=80',
    logoUrl: 'https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5?auto=format&fit=crop&w=300&q=80',
    openHours: 'Mon - Sat: 08:30 AM - 07:30 PM, Sun: 09:00 AM - 05:00 PM',
    supportedVehicleCategories: ['car', 'motorcycle', 'scooter'],
    servicesOffered: [
      'Periodic Maintenance',
      'Computer Diagnostics',
      'Brake Services',
      'AC Overhaul & Gas Refill',
      'Wheel Alignment & 3D Balancing',
      'Detailing & Ceramic Coating'
    ],
    dailyWorkingHours: [
      { day: 'monday', isOpen: true, openTime: '08:30 AM', closeTime: '07:30 PM' },
      { day: 'tuesday', isOpen: true, openTime: '08:30 AM', closeTime: '07:30 PM' },
      { day: 'wednesday', isOpen: true, openTime: '08:30 AM', closeTime: '07:30 PM' },
      { day: 'thursday', isOpen: true, openTime: '08:30 AM', closeTime: '07:30 PM' },
      { day: 'friday', isOpen: true, openTime: '08:30 AM', closeTime: '07:30 PM' },
      { day: 'saturday', isOpen: true, openTime: '08:30 AM', closeTime: '07:30 PM' },
      { day: 'sunday', isOpen: true, openTime: '09:00 AM', closeTime: '05:00 PM' }
    ],
    createdAt: '2026-11-01T19:25:09.755Z'
  });

  // 5. Dynamic Services for AUTO REPAIR
  const services = [
    {
      id: 'srv_periodic_care',
      garageId: GARAGE_ID,
      merchantId: USER_UID,
      name: 'Comprehensive Periodic Maintenance',
      description: 'Complete 40-point vehicle checkup, high-grade fully synthetic engine oil change, oil filter replacement, brake inspection, suspension check, spark plug cleaning, and complimentary pressure foam wash.',
      category: 'Periodic Service',
      imageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=800&q=80',
      pricingType: 'fixed',
      pricingMethod: 'fixed',
      fixedPrice: 3499.0,
      startingPrice: 3499.0,
      estimatedDuration: '2-3 hrs',
      applicableVehicleTypes: ['car', 'motorcycle', 'scooter'],
      includedItems: [
        'Engine Oil Change (Fully Synthetic)',
        'Oil Filter Replacement',
        'Air Filter & Cabin AC Filter Clean',
        'Brake Pad & Caliper Inspection',
        'Coolant & Brake Fluid Top-up',
        '40-Point Electronic Diagnostic Scan',
        'Complimentary Exterior Foam Wash'
      ],
      excludedItems: [
        'Major mechanical replacements',
        'Transmission fluid change'
      ],
      requiredParts: ['Engine Oil 5W-30 / 10W-40', 'Oil Filter Element'],
      isActive: true,
      createdAt: new Date().toISOString()
    },
    {
      id: 'srv_brake_overhaul',
      garageId: GARAGE_ID,
      merchantId: USER_UID,
      name: 'Brake System Overhaul & Pad Replacement',
      description: 'Precision front & rear brake service with premium ceramic pads, rotor disc skimming inspection, caliper lubrication, and high-temperature brake fluid flush.',
      category: 'Brakes',
      imageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=800&q=80',
      pricingType: 'fixed',
      pricingMethod: 'fixed',
      fixedPrice: 1850.0,
      startingPrice: 1850.0,
      estimatedDuration: '1.5 hrs',
      applicableVehicleTypes: ['car', 'motorcycle'],
      includedItems: [
        'Front Brake Pad Replacement',
        'Disc Rotor Measurement & Cleaning',
        'Caliper Pin De-greasing & High-Temp Lube',
        'DOT4 Brake Fluid Bleeding'
      ],
      isActive: true,
      createdAt: new Date().toISOString()
    },
    {
      id: 'srv_ac_gas_refill',
      garageId: GARAGE_ID,
      merchantId: USER_UID,
      name: 'AC System Service & R134a Gas Recharge',
      description: 'High-vacuum air conditioning leak test, condenser cleaning, compressor oil top-up, and genuine R134a refrigerant recharge for maximum cooling performance.',
      category: 'Air Conditioning',
      imageUrl: 'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?auto=format&fit=crop&w=800&q=80',
      pricingType: 'fixed',
      pricingMethod: 'fixed',
      fixedPrice: 2200.0,
      startingPrice: 2200.0,
      estimatedDuration: '1 hr',
      applicableVehicleTypes: ['car'],
      includedItems: [
        'Deep Vacuum & Nitrogen Leak Testing',
        'R134a Refrigerant Gas Recharge',
        'PAG Compressor Lubricant Top-up',
        'Condenser Coil High-Pressure Flush',
        'Cabin Blower Deodorization'
      ],
      isActive: true,
      createdAt: new Date().toISOString()
    },
    {
      id: 'srv_ecu_diagnostics',
      garageId: GARAGE_ID,
      merchantId: USER_UID,
      name: 'Computerized ECU Diagnostics & Sensor Scan',
      description: 'OBD-II full electronic scanning across ECM, BCM, ABS, and SRS airbags. Detailed error code clearing and live sensor waveform analysis.',
      category: 'Diagnostics',
      imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80',
      pricingType: 'fixed',
      pricingMethod: 'fixed',
      fixedPrice: 999.0,
      startingPrice: 999.0,
      estimatedDuration: '45 mins',
      applicableVehicleTypes: ['car', 'motorcycle', 'scooter'],
      includedItems: [
        'Full OBD-II Diagnostic Scan',
        'Clear False DTC Codes',
        'Live Throttle & O2 Sensor Graphs',
        'Battery & Alternator Health Report'
      ],
      isActive: true,
      createdAt: new Date().toISOString()
    },
    {
      id: 'srv_wheel_alignment',
      garageId: GARAGE_ID,
      merchantId: USER_UID,
      name: '3D Wheel Alignment & Computerized Balancing',
      description: 'State-of-the-art camera sensor alignment across camber, caster, and toe. 4-wheel dynamic balancing with clip weights.',
      category: 'Wheels & Tyres',
      imageUrl: 'https://images.unsplash.com/photo-1578844251758-2f71da64c96f?auto=format&fit=crop&w=800&q=80',
      pricingType: 'fixed',
      pricingMethod: 'fixed',
      fixedPrice: 1200.0,
      startingPrice: 1200.0,
      estimatedDuration: '1 hr',
      applicableVehicleTypes: ['car'],
      includedItems: [
        '3D Laser Alignment Calibration',
        '4-Wheel Dynamic High-Speed Balancing',
        'Tyre Rotation & Tread Depth Check',
        'Nitrogen Tyre Inflation'
      ],
      isActive: true,
      createdAt: new Date().toISOString()
    },
    {
      id: 'srv_ceramic_coating',
      garageId: GARAGE_ID,
      merchantId: USER_UID,
      name: '9H Ceramic Shield Detailing & Paint Protection',
      description: '3-stage rotary paint correction, swirl & scratch removal, followed by dual-layer 9H nano ceramic coat with 2-year hydrophobic warranty.',
      category: 'Detailing',
      imageUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=800&q=80',
      pricingType: 'range',
      pricingMethod: 'range',
      minPrice: 5999.0,
      maxPrice: 12999.0,
      startingPrice: 5999.0,
      estimatedDuration: '1-2 days',
      applicableVehicleTypes: ['car', 'motorcycle'],
      includedItems: [
        'Clay Bar Decontamination',
        '3-Stage Machine Compound & Polish',
        '9H Graphene/Ceramic Coating (2 Coats)',
        'Windshield Rain Repellent Layer',
        'Interior Deep Steam Extraction'
      ],
      isActive: true,
      createdAt: new Date().toISOString()
    }
  ];

  for (const s of services) {
    await setDoc(token, `garages/${GARAGE_ID}/services/${s.id}`, s);
  }

  // 6. Spare Parts Inventory for AUTO REPAIR
  const inventory = [
    {
      id: 'part_oil_5w30',
      garageId: GARAGE_ID,
      sku: 'LUB-MOB-5W30',
      name: 'Mobil 1 5W-30 Fully Synthetic Engine Oil (4L)',
      category: 'Lubricants',
      unitCost: 2400.0,
      sellingPrice: 3100.0,
      currentStock: 24,
      minStockAlert: 5,
      unit: 'cans',
      supplier: 'Mobil Dist. Kerala',
      location: 'Rack A1',
      createdAt: new Date().toISOString()
    },
    {
      id: 'part_brake_pad_front',
      garageId: GARAGE_ID,
      sku: 'BRK-BOS-CER-01',
      name: 'Bosch Ceramic Front Brake Pad Set',
      category: 'Brakes',
      unitCost: 1100.0,
      sellingPrice: 1650.0,
      currentStock: 15,
      minStockAlert: 4,
      unit: 'sets',
      supplier: 'Bosch Automotive Calicut',
      location: 'Rack B2',
      createdAt: new Date().toISOString()
    },
    {
      id: 'part_oil_filter',
      garageId: GARAGE_ID,
      sku: 'FLT-MAN-W712',
      name: 'Mann-Filter High Performance Oil Filter Element',
      category: 'Filters',
      unitCost: 280.0,
      sellingPrice: 450.0,
      currentStock: 32,
      minStockAlert: 8,
      unit: 'units',
      supplier: 'Mann Parts India',
      location: 'Bin 12',
      createdAt: new Date().toISOString()
    },
    {
      id: 'part_coolant',
      garageId: GARAGE_ID,
      sku: 'LUB-CAS-RAD-1L',
      name: 'Castrol Radicool Long-Life Concentrated Coolant (1L)',
      category: 'Fluids',
      unitCost: 320.0,
      sellingPrice: 480.0,
      currentStock: 18,
      minStockAlert: 6,
      unit: 'bottles',
      supplier: 'Castrol India',
      location: 'Rack A3',
      createdAt: new Date().toISOString()
    },
    {
      id: 'part_spark_plug',
      garageId: GARAGE_ID,
      sku: 'IGN-NGK-IRID',
      name: 'NGK Laser Iridium Spark Plug',
      category: 'Ignition',
      unitCost: 420.0,
      sellingPrice: 650.0,
      currentStock: 40,
      minStockAlert: 10,
      unit: 'units',
      supplier: 'NGK Spares Kerala',
      location: 'Drawer 4',
      createdAt: new Date().toISOString()
    }
  ];

  for (const inv of inventory) {
    await setDoc(token, `garages/${GARAGE_ID}/inventory/${inv.id}`, inv);
  }

  // 7. Service Jobs for AUTO REPAIR
  const serviceJobs = [
    {
      id: 'job_101',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      vehicleId: 'veh_honda_city',
      jobNumber: 'JOB-2026-101',
      status: 'completed',
      odometerReading: 32450,
      complaints: ['Regular 30,000 km periodic service', 'Front wiper shuddering'],
      customerNotes: 'Please check brake bite and clean cabin AC filter.',
      internalNotes: 'All fluids replaced. Filter replaced. Road test completed smoothly.',
      technicianName: 'Arun Kumar',
      actualStartTime: '2026-10-31T09:30:00.000Z',
      completedDate: '2026-10-31T15:00:00.000Z',
      vehicleDisplay: '2021 Honda City ZX (KL 11 BP 4512)',
      customerName: 'Vishnu Shaji',
      customerPhone: '+91 90614 44999',
      customerWhatsApp: '+91 90614 44999',
      gatePassCode: 'GP-84291',
      isGatePassVerified: true,
      gatePassVerifiedAt: '2026-10-31T15:30:00.000Z',
      isQcPassed: true,
      qcInspectorName: 'Suresh V (Chief QC)',
      qcInspectedAt: '2026-10-31T14:45:00.000Z',
      qcChecklist: {
        'Engine Oil Level': true,
        'Brake Fluid Moisture': true,
        'Tyre Pressure & Torque': true,
        'Battery Health': true,
        'Road Test Clearance': true
      },
      createdAt: '2026-10-31T09:00:00.000Z',
      updatedAt: '2026-10-31T15:30:00.000Z'
    },
    {
      id: 'job_102',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      vehicleId: 'veh_re_classic',
      jobNumber: 'JOB-2026-102',
      status: 'in_progress',
      odometerReading: 12180,
      complaints: ['Chain noise at low speeds', 'Front disc squeaking'],
      customerNotes: 'Check chain slack and inspect front brake pads.',
      internalNotes: 'Brake pads inspected; chain tension adjusted. Awaiting final lube test.',
      technicianName: 'Biju Nair',
      actualStartTime: new Date(Date.now() - 2 * 3600000).toISOString(),
      estimatedCompletionDate: new Date(Date.now() + 4 * 3600000).toISOString(),
      vehicleDisplay: '2022 Royal Enfield Classic 350 (KL 11 BS 8920)',
      customerName: 'Vishnu Shaji',
      customerPhone: '+91 90614 44999',
      customerWhatsApp: '+91 90614 44999',
      isGatePassVerified: false,
      isQcPassed: false,
      createdAt: new Date(Date.now() - 3 * 3600000).toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
      id: 'job_103',
      garageId: GARAGE_ID,
      customerId: 'cust_external_1',
      vehicleId: 'veh_ext_creta',
      jobNumber: 'JOB-2026-103',
      status: 'awaiting_parts',
      odometerReading: 48900,
      complaints: ['AC not blowing cold air', 'Hissing sound from dashboard'],
      customerNotes: 'Urgent cooling issue. Going out of station on weekend.',
      internalNotes: 'Cooling coil leak detected. Replacement OEM evaporator ordered from supplier.',
      technicianName: 'Arun Kumar',
      actualStartTime: new Date(Date.now() - 5 * 3600000).toISOString(),
      estimatedCompletionDate: new Date(Date.now() + 24 * 3600000).toISOString(),
      vehicleDisplay: '2022 Hyundai Creta SX (KL 11 BY 7700)',
      customerName: 'Deepak K',
      customerPhone: '+91 98471 55667',
      customerWhatsApp: '+91 98471 55667',
      isGatePassVerified: false,
      isQcPassed: false,
      createdAt: new Date(Date.now() - 6 * 3600000).toISOString(),
      updatedAt: new Date().toISOString()
    },
    {
      id: 'job_104',
      garageId: GARAGE_ID,
      customerId: 'cust_external_2',
      vehicleId: 'veh_ext_swift',
      jobNumber: 'JOB-2026-104',
      status: 'quality_check',
      odometerReading: 61200,
      complaints: ['Clutch pedal very stiff', 'Slight burning smell on hills'],
      customerNotes: 'Replace clutch assembly if worn out.',
      internalNotes: 'Clutch plate and release bearing replaced. On lift for final inspection.',
      technicianName: 'Biju Nair',
      actualStartTime: new Date(Date.now() - 8 * 3600000).toISOString(),
      estimatedCompletionDate: new Date(Date.now() + 1 * 3600000).toISOString(),
      vehicleDisplay: '2019 Maruti Suzuki Swift ZXi (KL 11 BN 3311)',
      customerName: 'Anoop S',
      customerPhone: '+91 97450 88991',
      customerWhatsApp: '+91 97450 88991',
      isGatePassVerified: false,
      isQcPassed: false,
      createdAt: new Date(Date.now() - 10 * 3600000).toISOString(),
      updatedAt: new Date().toISOString()
    }
  ];

  for (const job of serviceJobs) {
    await setDoc(token, `garages/${GARAGE_ID}/serviceJobs/${job.id}`, job);
  }

  // 8. Invoices for AUTO REPAIR (Provides authentic numbers for Analytics & Revenue Charts!)
  const invoices = [
    {
      id: 'inv_101',
      garageId: GARAGE_ID,
      jobId: 'job_101',
      customerId: USER_UID,
      invoiceNumber: 'INV-2026-001',
      subtotal: 4850.0,
      taxRate: 18.0,
      taxAmount: 873.0,
      discountAmount: 350.0,
      totalAmount: 5373.0,
      paidAmount: 5373.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      dueDate: '2026-10-31T17:00:00.000Z',
      issuedAt: '2026-10-31T15:15:00.000Z',
      items: [
        { description: 'Comprehensive Periodic Service', quantity: 1, unitPrice: 3499.0, total: 3499.0 },
        { description: 'Castrol Radicool Long-Life Coolant', quantity: 1, unitPrice: 480.0, total: 480.0 },
        { description: 'Bosch Wiper Blade Pair', quantity: 1, unitPrice: 871.0, total: 871.0 }
      ],
      createdAt: '2026-10-31T15:15:00.000Z'
    },
    {
      id: 'inv_102',
      garageId: GARAGE_ID,
      jobId: 'job_104',
      customerId: 'cust_external_2',
      invoiceNumber: 'INV-2026-002',
      subtotal: 7800.0,
      taxRate: 18.0,
      taxAmount: 1404.0,
      discountAmount: 500.0,
      totalAmount: 8704.0,
      paidAmount: 5000.0,
      balanceDue: 3704.0,
      currencyCode: 'INR',
      status: 'partially_paid',
      dueDate: new Date(Date.now() + 2 * 86400000).toISOString(),
      issuedAt: new Date(Date.now() - 4 * 3600000).toISOString(),
      items: [
        { description: 'Clutch Assembly Replacement Labor', quantity: 1, unitPrice: 2800.0, total: 2800.0 },
        { description: 'Valeo OEM Clutch Disc & Pressure Plate', quantity: 1, unitPrice: 4200.0, total: 4200.0 },
        { description: 'Gearbox Oil 75W-90 (2L)', quantity: 2, unitPrice: 400.0, total: 800.0 }
      ],
      createdAt: new Date(Date.now() - 4 * 3600000).toISOString()
    },
    {
      id: 'inv_103',
      garageId: GARAGE_ID,
      jobId: 'job_102',
      customerId: USER_UID,
      invoiceNumber: 'INV-2026-003',
      subtotal: 1850.0,
      taxRate: 18.0,
      taxAmount: 333.0,
      discountAmount: 0.0,
      totalAmount: 2183.0,
      paidAmount: 0.0,
      balanceDue: 2183.0,
      currencyCode: 'INR',
      status: 'unpaid',
      dueDate: new Date(Date.now() + 1 * 86400000).toISOString(),
      issuedAt: new Date().toISOString(),
      items: [
        { description: 'Brake System Service & Pad Replacement', quantity: 1, unitPrice: 1850.0, total: 1850.0 }
      ],
      createdAt: new Date().toISOString()
    },
    {
      id: 'inv_104',
      garageId: GARAGE_ID,
      jobId: 'job_ext_past',
      customerId: 'cust_external_1',
      invoiceNumber: 'INV-2026-004',
      subtotal: 6200.0,
      taxRate: 18.0,
      taxAmount: 1116.0,
      discountAmount: 400.0,
      totalAmount: 6916.0,
      paidAmount: 6916.0,
      balanceDue: 0.0,
      currencyCode: 'INR',
      status: 'paid',
      dueDate: '2026-10-24T18:00:00.000Z',
      issuedAt: '2026-10-24T16:30:00.000Z',
      items: [
        { description: 'AC Refrigerant Recharge & Leak Test', quantity: 1, unitPrice: 2200.0, total: 2200.0 },
        { description: 'Synthetic Engine Oil Flush', quantity: 1, unitPrice: 4000.0, total: 4000.0 }
      ],
      createdAt: '2026-10-24T16:30:00.000Z'
    }
  ];

  for (const inv of invoices) {
    await setDoc(token, `garages/${GARAGE_ID}/invoices/${inv.id}`, inv);
  }

  // 9. Estimates for AUTO REPAIR
  const estimates = [
    {
      id: 'est_101',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      vehicleId: 'veh_honda_city',
      estimateNumber: 'EST-2026-001',
      status: 'approved',
      subtotal: 4850.0,
      taxAmount: 873.0,
      totalAmount: 5723.0,
      currencyCode: 'INR',
      vehicleDisplay: '2021 Honda City ZX (KL 11 BP 4512)',
      createdAt: '2026-10-30T10:00:00.000Z'
    },
    {
      id: 'est_102',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      vehicleId: 'veh_re_classic',
      estimateNumber: 'EST-2026-002',
      status: 'pending',
      subtotal: 1850.0,
      taxAmount: 333.0,
      totalAmount: 2183.0,
      currencyCode: 'INR',
      vehicleDisplay: '2022 Royal Enfield Classic 350 (KL 11 BS 8920)',
      createdAt: new Date().toISOString()
    }
  ];

  for (const est of estimates) {
    await setDoc(token, `garages/${GARAGE_ID}/estimates/${est.id}`, est);
  }

  // 9b. Appointments for AUTO REPAIR
  const appointments = [
    {
      id: 'app_101',
      garageId: GARAGE_ID,
      customerId: USER_UID,
      customerName: 'Vishnu Shaji',
      customerPhone: '+91 90614 44999',
      vehicleInfo: '2021 Honda City ZX (KL 11 BP 4512)',
      preferredDate: new Date(Date.now() + 2 * 86400000).toISOString(),
      preferredTime: 'Morning (09:30 AM)',
      issueDescription: 'General checkup, air conditioning gas refill, and cabin air filter cleaning.',
      status: 'confirmed',
      createdAt: new Date().toISOString()
    }
  ];

  for (const app of appointments) {
    await setDoc(token, `garages/${GARAGE_ID}/appointments/${app.id}`, app);
  }

  // 9c. Authentic Customer Reviews for AUTO REPAIR
  const reviews = [
    {
      id: 'rev_1',
      garageId: GARAGE_ID,
      customerId: 'cust_review_1',
      customerName: 'Rahul Menon',
      customerPhotoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
      jobId: 'job_101',
      rating: 5.0,
      reviewText: 'Outstanding service and high precision mechanical work. Completed full periodic service on time with detailed inspection report.',
      consentSharePhoto: true,
      consentShareName: true,
      isReported: false,
      createdAt: '2026-10-31T17:00:00.000Z'
    },
    {
      id: 'rev_2',
      garageId: GARAGE_ID,
      customerId: 'cust_review_2',
      customerName: 'Deepak Krishnan',
      customerPhotoUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
      jobId: 'job_103',
      rating: 4.8,
      reviewText: 'Very transparent billing and professional mechanics. Diagnosed and fixed the AC cooling problem in my Creta immediately.',
      consentSharePhoto: true,
      consentShareName: true,
      isReported: false,
      createdAt: '2026-10-28T14:30:00.000Z'
    },
    {
      id: 'rev_3',
      garageId: GARAGE_ID,
      customerId: 'cust_review_3',
      customerName: 'Anoop Sasidharan',
      customerPhotoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      jobId: 'job_104',
      rating: 5.0,
      reviewText: 'Best multi-brand garage in Chelannur. Clutch replacement was smooth and car drives like brand new.',
      consentSharePhoto: true,
      consentShareName: true,
      isReported: false,
      createdAt: '2026-10-25T11:00:00.000Z'
    }
  ];

  for (const rev of reviews) {
    await setDoc(token, `garages/${GARAGE_ID}/reviews/${rev.id}`, rev);
  }

  // 10. Web Scraped & Discovered Real Garages in Kozhikode / Calicut Area
  const discoveredGarages = [
    {
      id: 'garage_prompt_motors_calicut',
      name: 'Prompt Motors - Multi-Brand Specialist',
      address: 'Silk Street, Beach Road Junction, Kozhikode, Kerala 673011',
      googleAddress: 'Silk Street, Beach Road Junction, Kozhikode',
      city: 'Kozhikode',
      latitude: 11.2723330,
      longitude: 75.7650962,
      googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=11.2723330,75.7650962',
      phone: '+91 90614 44999',
      whatsappNumber: '+91 90614 44999',
      email: 'promptmotors.calicut@gmail.com',
      currencyCode: 'INR',
      description: 'Specialized luxury and multi-brand automotive service workshop in Silk Street, Calicut. Expert care for German and Japanese cars including Mercedes, BMW, Audi, VW, and Skoda with diagnostic scanning and dent repair.',
      rating: 4.8,
      reviewCount: 38,
      isVerified: true,
      isDoorstepRepairAvailable: false,
      isRoadsideAssistanceAvailable: true,
      ownerUid: 'merchant_prompt_motors',
      taxNumber: '32AABCP9944M1Z2',
      coverImageUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=1200&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=1200&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5?auto=format&fit=crop&w=300&q=80',
      openHours: 'Mon - Sat: 09:00 AM - 07:00 PM',
      supportedVehicleCategories: ['car'],
      servicesOffered: [
        'Luxury Car Diagnostics',
        'Automatic Transmission Service',
        'Suspension Overhaul',
        'Dent Removal & Spray Painting'
      ],
      createdAt: '2026-10-20T10:00:00.000Z'
    },
    {
      id: 'garage_malabar_motors_calicut',
      name: 'Malabar Motors & Car Care',
      address: 'Mini Bypass Road, East Nadakkavu, Eranhipalam, Kozhikode, Kerala 673006',
      googleAddress: 'Mini Bypass Road, East Nadakkavu, Kozhikode',
      city: 'Kozhikode',
      latitude: 11.2797646,
      longitude: 75.7848617,
      googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=11.2797646,75.7848617',
      phone: '+91 98470 12345',
      whatsappNumber: '+91 98470 12345',
      email: 'malabarmotors.clt@gmail.com',
      currencyCode: 'INR',
      description: 'Comprehensive mechanical works, AC service, laser wheel alignment, body work, and insurance cashless accident claim repairs in East Nadakkavu.',
      rating: 4.7,
      reviewCount: 26,
      isVerified: true,
      isDoorstepRepairAvailable: true,
      isRoadsideAssistanceAvailable: true,
      ownerUid: 'merchant_malabar_motors',
      taxNumber: '32AABCM8822K1Z5',
      coverImageUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?auto=format&fit=crop&w=1200&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=300&q=80',
      openHours: 'Mon - Sat: 08:30 AM - 07:30 PM',
      supportedVehicleCategories: ['car', 'motorcycle'],
      servicesOffered: [
        'Periodic Oil Service',
        'AC Disinfection & Gas Top-up',
        'Brake & Clutch Repair',
        'Towing & Roadside Assistance'
      ],
      createdAt: '2026-10-22T10:00:00.000Z'
    },
    {
      id: 'garage_new_top_bikes_calicut',
      name: 'New-Top Bikes & EV Hub',
      address: 'Mavoor Road, KTC Nagar, Kozhikode, Kerala 670016',
      googleAddress: 'Mavoor Road, KTC Nagar, Kozhikode',
      city: 'Kozhikode',
      latitude: 11.2582514,
      longitude: 75.8016463,
      googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=11.2582514,75.8016463',
      phone: '+91 99958 25314',
      whatsappNumber: '+91 99958 25314',
      email: 'newtopbikes.calicut@gmail.com',
      currencyCode: 'INR',
      description: 'Dedicated motorcycle and electric scooter service hub on Mavoor Road. Genuine spares, battery pack health testing, motor rewiring, carburetor/EFI tuning, and suspension service.',
      rating: 4.9,
      reviewCount: 42,
      isVerified: true,
      isDoorstepRepairAvailable: false,
      isRoadsideAssistanceAvailable: true,
      ownerUid: 'merchant_new_top_bikes',
      taxNumber: '32AABCN4411P1Z9',
      coverImageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=1200&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=300&q=80',
      openHours: 'Mon - Sat: 09:00 AM - 08:00 PM',
      supportedVehicleCategories: ['motorcycle', 'scooter'],
      servicesOffered: [
        'Superbike Service',
        'EV Battery & Motor Diagnostics',
        'Chain Sprocket Replacement',
        'Fork & Monoshock Overhaul'
      ],
      createdAt: '2026-10-25T10:00:00.000Z'
    },
    {
      id: 'garage_ride_n_repair_calicut',
      name: 'Ride N Repair Doorstep Auto Care',
      address: 'NH Bypass, Thondayad Junction, Kozhikode, Kerala 673017',
      googleAddress: 'NH Bypass, Thondayad, Kozhikode',
      city: 'Kozhikode',
      latitude: 11.2650299,
      longitude: 75.8116611,
      googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=11.2650299,75.8116611',
      phone: '+91 94471 22334',
      whatsappNumber: '+91 94471 22334',
      email: 'ridenrepair.kerala@gmail.com',
      currencyCode: 'INR',
      description: 'On-demand mobile mechanic van and doorstep periodic servicing across Kozhikode district. Emergency breakdown jumping, puncture fixes, battery replacements, and home periodic services.',
      rating: 4.8,
      reviewCount: 31,
      isVerified: true,
      isDoorstepRepairAvailable: true,
      isRoadsideAssistanceAvailable: true,
      ownerUid: 'merchant_ride_n_repair',
      taxNumber: '32AABCR3377J1Z1',
      coverImageUrl: 'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?auto=format&fit=crop&w=1200&q=80',
      bannerUrl: 'https://images.unsplash.com/photo-1517524008697-84bbe3c3fd98?auto=format&fit=crop&w=1200&q=80',
      logoUrl: 'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?auto=format&fit=crop&w=300&q=80',
      openHours: 'Open 24/7 for Emergency Roadside Assistance',
      supportedVehicleCategories: ['car', 'motorcycle', 'scooter'],
      servicesOffered: [
        'Doorstep Periodic Maintenance',
        '24x7 Roadside Jump Start',
        'Mobile Puncture & Tyre Swap',
        'Pre-Purchase Inspection'
      ],
      createdAt: '2026-10-27T10:00:00.000Z'
    }
  ];

  for (const g of discoveredGarages) {
    await setDoc(token, `garages/${g.id}`, g);

    // Add a signature periodic package for each discovered garage
    await setDoc(token, `garages/${g.id}/services/srv_signature_pack`, {
      id: 'srv_signature_pack',
      garageId: g.id,
      merchantId: g.ownerUid,
      name: 'Workshop Periodic Care & Inspection Package',
      description: `Complete periodic vehicle maintenance and comprehensive multi-point diagnostic check by certified technicians at ${g.name}.`,
      category: 'Periodic Service',
      imageUrl: g.coverImageUrl,
      pricingType: 'fixed',
      pricingMethod: 'fixed',
      fixedPrice: 2999.0,
      startingPrice: 2999.0,
      estimatedDuration: '2 hrs',
      applicableVehicleTypes: g.supportedVehicleCategories,
      includedItems: [
        'Engine Oil Replacement',
        'Filter Cleansing & Inspection',
        'Brake Inspection',
        'Fluid Top-up',
        'Computerized Diagnostic Scan'
      ],
      isActive: true,
      createdAt: new Date().toISOString()
    });
  }

  console.log('✅ ALL CUSTOMER, MERCHANT, AND DISCOVERED GARAGE DATA SYNCED SUCCESSFULLY!');
}

run().catch(err => {
  console.error('❌ Sync failed:', err);
  process.exit(1);
});
