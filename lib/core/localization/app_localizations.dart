import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'WeFix',
      'appSlogan': 'Smarter Garage Management. Better Vehicle Care.',
      'login': 'Sign In',
      'signIn': 'Sign In',
      'register': 'Create Account',
      'createAccount': 'Create Account',
      'email': 'Email Address',
      'password': 'Password',
      'fullName': 'Full Name',
      'phoneNumber': 'Phone Number',
      'whatsappNumber': 'WhatsApp Number',
      'sameAsPhone': 'Same as Phone',
      'selectRole': 'Select Experience',
      'roleCustomer': 'Customer',
      'roleMerchant': 'Merchant (Garage Owner)',
      'home': 'Home',
      'garages': 'Garages',
      'nearbyGarages': 'Nearby Garages',
      'myVehicles': 'My Vehicles',
      'myServices': 'My Services',
      'estimates': 'Estimates',
      'invoices': 'Invoices',
      'payments': 'Payments',
      'notifications': 'Notifications',
      'profile': 'Profile',
      'accountProfile': 'Account Profile',
      'settings': 'Settings',
      'dashboard': 'Dashboard',
      'overview': 'Overview',
      'customers': 'Customers',
      'vehicles': 'Vehicles',
      'addVehicle': 'Add Vehicle',
      'jobs': 'Service Jobs',
      'repairJobs': 'Repair Jobs',
      'jobCards': 'Job Cards',
      'inspections': 'Inspections',
      'appointments': 'Appointments',
      'reminders': 'Reminders',
      'serviceCatalog': 'Services Catalog',
      'activeJobs': 'Active Jobs',
      'activeRepairs': 'Active Repairs',
      'completedJobs': 'Completed Jobs',
      'serviceHistory': 'Service History',
      'readyForPickup': 'Ready for Pickup',
      'call': 'Call',
      'whatsapp': 'WhatsApp',
      'directions': 'Directions',
      'requestService': 'Request Service',
      'approve': 'Approve',
      'reject': 'Reject',
      'save': 'Save',
      'saveChanges': 'Save Changes',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
      'refresh': 'Refresh',
      'more': 'More',
      'confirm': 'Confirm',
      'confirmSwitch': 'Confirm Switch',
      'submit': 'Submit',
      'statusDraft': 'Draft',
      'statusReceived': 'Received',
      'statusInspectionPending': 'Inspection Pending',
      'statusEstimatePending': 'Estimate Pending',
      'statusEstimateApproved': 'Estimate Approved',
      'statusInProgress': 'In Progress',
      'statusWaitingForParts': 'Awaiting Parts',
      'statusQualityCheck': 'Quality Check',
      'statusReady': 'Ready for Collection',
      'statusCompleted': 'Completed',
      'statusCancelled': 'Cancelled',
      'statusOverdue': 'Overdue',
      'statusPending': 'Pending',
      'statusPaid': 'Paid',
      'statusUnpaid': 'Unpaid',
      'statusPartiallyPaid': 'Partially Paid',
      'statusUpcoming': 'Upcoming',
      'statusDueSoon': 'Due Soon',
      'statusDue': 'Due Now',
      'noDataFound': 'No records found',
      'noRecordsFound': 'No records found',
      'somethingWentWrong': 'Something went wrong',
      'tryAgain': 'Try Again',
      'signOut': 'Sign Out',
      'language': 'Language',
      'languagePreference': 'Language Preference',
      'theme': 'Theme',
      'currency': 'Currency',
      'odometer': 'Odometer Reading',
      'currentOdometer': 'Current Odometer',
      'licensePlate': 'Registration Number',
      'makeAndModel': 'Vehicle Make & Model',
      'year': 'Model Year',
      'nextServiceDue': 'Next Service Due',
      'lastServiceDate': 'Last Service Date',
      'partsNeeded': 'Parts Needed',
      'updateStatus': 'Update Status',
      'whatsappUpdate': 'WhatsApp Update',
      'selectAll': 'Select All',
      'deselectAll': 'Deselect All',
      'deleteSelected': 'Delete Selected',
      'statusCustom': 'Custom Update',
      'messages': 'Messages',
      'servicesAndPricing': 'Services & Pricing',
      'reviews': 'Reviews',
      'about': 'About',
      'smartPricing': 'Smart Pricing',
      'rateAndReview': 'Rate & Review',
      'consentShareName': 'Display my name publicly',
      'consentSharePhoto': 'Display my photo publicly',
      'selectVehicleForPrice': 'Select vehicle to calculate exact price',
      'fixedPrice': 'Fixed Price',
      'categoryPrice': 'Category Price',
      'attributePrice': 'Attribute Rule Price',
      'startingPrice': 'Starting From',
      'quotationRequired': 'Quotation Required (Inspection)',
      'typeMessage': 'Type a message...',
      'noMessages': 'No messages yet',
      'noConversations': 'No conversations found',
      'startRepair': 'Start Repair',
      'completeRepair': 'Complete Repair',
      'gatePass': 'Gate Pass',
      'gatePassOtp': 'Gate Pass Code',
      'warrantyVault': 'Warranty Vault',
      'inventory': 'Inventory',
      'totalAmount': 'Total Amount',
      'balanceDue': 'Balance Due',
      'taxInvoice': 'Tax Invoice',
      'downloadPdf': 'Download PDF',
      'allInvoices': 'All Invoices',
      'settledInvoices': 'Settled Invoices',
      'upcomingMaintenance': 'Upcoming Maintenance',
      'profileIncomplete': 'Profile Incomplete',
      'profileDetails': 'Profile Details',
      'completeProfileNow': 'Complete Profile Now',
      'editProfileDetails': 'Edit Profile Details',
      'saveProfileDetails': 'Save Profile Details',
      'customerAccount': 'Customer Account',
      'merchantAccount': 'Merchant Account',
      'accountSwitching': 'Account Switching',
      'active': 'Active',
      'switch': 'Switch',
      'switchToMerchant': 'Switch to Merchant Account?',
      'switchToCustomer': 'Switch to Customer Account?',
      'todayPipeline': 'Today\'s Pipeline',
      'monthlyRevenue': 'Monthly Revenue',
      'outstandingReceivables': 'Outstanding Receivables',
      'createJobCard': 'Create Job Card',
      'personalDetailsModeSwitching': 'Personal details & mode switching',
      'selectPreferredLanguage': 'Select your preferred display language',
      'viewReplacementCoverage':
          'View replacement parts coverage & guarantee certificates',
      'noWarrantiesOnFile': 'No Warranties on File',
      'genuinePartsWarrantiesAppear': 'Genuine replacement parts with manufacturer warranties will appear here automatically upon invoice settlement.',
      'noVehiclesRegistered': 'No vehicles registered',
      'addCarOrTwoWheeler':
          'Add your car or two-wheeler to track maintenance and book services.',
      'addFirstVehicle': 'Add First Vehicle',
      'allRepairs': 'All Repairs',
      'repairOrders': 'Repair Orders',
      'trackLiveProgress':
          'Track live repair status & digital inspection checklists',
      'invoicesAndPayments': 'Invoices & Payments',
      'trackBillingSettlements':
          'Track billing, settlement records & download PDFs',
      'workshopDashboard': 'Workshop Dashboard',
      'monitorOperations': 'Monitor daily repair throughput, bays & revenue',
      'businessAnalytics': 'Business Analytics',
      'financialInsights':
          'Financial performance, profit margins & growth trends',
      'moreOptions': 'More Options & Settings',
      'manageGarageProfile':
          'Manage workshop profile, inventory, staff & preferences',
      'garageProfile': 'Garage Profile',
      'businessInformation': 'Business Information',
      'operatingHours': 'Operating Hours',
      'googleAddress': 'Workshop Address',
      'noInternetConnection': 'No Internet Connection',
      'offlineModeDescription':
          'Check your network and try again. Offline cached data is displayed.',
      'completeProfileDetails': 'Complete Profile Details',
      'enterFullName': 'Enter your full name',
      'phoneNumberForCalling': 'Phone Number (for Calling & Login)',
      'whatsappHelperText':
          'Repair alerts and digital estimates will be delivered via WhatsApp',
      'complete': 'Complete',
      'completePersonalDetailsDesc': 'Complete your personal details to receive instant repair updates, digital estimates, and WhatsApp service notifications.',
      'notProvided': 'Not provided',
      'defaultTag': 'Default',
      'customer': 'Customer',
      'merchant': 'Merchant',
      'customerAccountDesc':
          'Vehicle registry, repair status & digital invoices',
      'merchantAccountDesc':
          'Garage operations, digital inspections & staff roles',
      'switchAccountDesc': 'You will switch workspace. Your session and account data will be maintained.',
      'hideDetails': 'Hide details',
      'showDetails': 'Show details',
      'featuredGarages': 'Featured & Verified Garages',
      'viewAll': 'View All',
      'repairs': 'Repairs',
      'support': 'Support',
      'featuredOffers': 'FEATURED OFFERS',
      'genuineParts': 'Genuine Parts',
      'exploreWorkshopPackages': 'Explore Workshop Packages',
      'workshopPackagesPeriodicCare': 'Workshop Packages & Periodic Care',
      'noActiveRepairs': 'No active repair jobs',
      'exploreWorkshops': 'Explore Workshops',
      'allOrders': 'All Orders',
      'noActiveRepairsInProgress': 'No active repairs in progress',
      'noCompletedServiceHistory': 'No completed service history',
      'noRepairOrdersFound': 'No repair orders found',
      'whenYouCheckVehicleDesc': 'When you check your vehicle into an authorized garage, your live repair status will appear here.',
      'loadingPortal': 'Loading your garage portal...',
      'searchGaragesServicesPackages': 'Search Garages, Services & Packages...',
      'searchPlaceholderSub': 'Bike wash, oil change, periodic maintenance...',
      'issuedOn': 'Issued on',
      'noHistoryRecorded': 'No history recorded yet.',
      'expired': 'Expired',
      'whatsappOnly': 'WhatsApp Only',
      'saveAndWhatsapp': 'Save & WhatsApp',
      'completeAndIssuePass': 'Complete & Issue Pass',
      'supportTickets': 'Support Tickets',
      'customerTickets': 'Customer Support Tickets',
      'customerTicketsSubtitle': 'Tickets & Service Inquiries',
      'merchantTicketsSubtitle': 'Client requests, inquiries & issues',
      'newTicket': 'New Ticket',
      'createSupportTicket': 'Create Support Ticket',
      'createTicketSubtitle': 'Submit an issue to workshop or platform',
      'ticketInformation': 'Ticket Details',
      'supportCategory': 'Support Category',
      'vehicleIssue': 'Vehicle Issue',
      'repairDelay': 'Repair Delay',
      'estimateInquiry': 'Estimate Inquiry',
      'invoiceDispute': 'Invoice / Payment Issue',
      'serviceQuality': 'Service Quality Feedback',
      'generalSupport': 'General Inquiry',
      'subject': 'Subject',
      'subjectHint': 'Brief summary of your inquiry',
      'issueDescription': 'Detailed Description',
      'descriptionHint': 'Explain what happened in detail...',
      'preferredContact': 'Preferred Contact Method',
      'inAppSupport': 'In-App Chat',
      'relatedEntities': 'Related Records',
      'relatedVehicle': 'Related Vehicle',
      'relatedRepairJob': 'Related Repair Job',
      'relatedInvoice': 'Related Invoice',
      'relatedGarage': 'Related Workshop',
      'generalPlatformSupport': 'WeFix Platform Support',
      'submitTicket': 'Submit Support Ticket',
      'searchTicketsHint': 'Search by ticket #, subject or garage...',
      'searchTicketsMerchantHint': 'Search by ticket #, customer or reg...',
      'allTickets': 'All Tickets',
      'waitingCustomer': 'Waiting on Customer',
      'waitingMerchant': 'Waiting on Workshop',
      'ticketDetails': 'Ticket Details',
      'ticketNotFound': 'Ticket Not Found',
      'noMatchingTickets': 'No Matching Tickets',
      'noCustomerTicketsYet': 'No Customer Tickets Yet',
      'noCustomerTicketsDescription':
          'When customers raise support inquiries, they will appear here.',
      'noTicketsYet': 'No Support Tickets Yet',
      'noTicketsDescription': 'Need help with a repair, estimate, or invoice? Raise a support ticket anytime.',
      'reopenTicket': 'Reopen Ticket',
      'reopenReason': 'Reason for Reopening',
      'resolveTicket': 'Resolve Ticket',
      'resolutionNote': 'Resolution Note',
      'confirmResolve': 'Confirm & Resolve',
      'confirmResolution': 'Confirm Resolution & Close',
      'closeTicket': 'Close Ticket',
      'replyToCustomer': 'Reply to Customer',
      'internalNoteStaffOnly': 'Internal Staff Note',
      'writeInternalNoteHint':
          'Write an internal note (visible only to workshop staff)...',
      'typeYourMessage': 'Type your reply...',
      'helpAndSupport': 'Help & Support Tickets',
      'noneNotApplicable': 'None / Not Applicable',
      'noMessagesYet': 'No Messages Yet',
      'noMessagesDescription':
          'Send a message to start this ticket conversation.',
      'workingHours': 'Working Hours',
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
      'open': 'Open',
      'closed': 'Closed',
      'openNow': 'Open Now',
    },
    'ml': {
      'appName': 'വിഫിക്സ് (WeFix)',
      'appSlogan': 'മികച്ച ഗാരേജ് മാനേജ്മെന്റ്. മികച്ച വാഹന പരിചരണം.',
      'login': 'ലോഗിൻ ചെയ്യുക',
      'signIn': 'സൈൻ ഇൻ ചെയ്യുക',
      'register': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
      'createAccount': 'അക്കൗണ്ട് സൃഷ്ടിക്കുക',
      'email': 'ഇമെയിൽ വിലാസം',
      'password': 'പാസ്‌വേഡ്',
      'fullName': 'പൂർണ്ണ നാമം',
      'phoneNumber': 'ഫോൺ നമ്പർ',
      'whatsappNumber': 'വാട്ട്‌സ്ആപ്പ് നമ്പർ',
      'sameAsPhone': 'ഫോൺ നമ്പർ തന്നെ',
      'selectRole': 'റോൾ തിരഞ്ഞെടുക്കുക',
      'roleCustomer': 'ഉപഭോക്താവ്',
      'roleMerchant': 'ഗാരേജ് ഉടമ (മെർച്ചന്റ്)',
      'home': 'ഹോം',
      'garages': 'വർക്ക്‌ഷോപ്പുകൾ',
      'nearbyGarages': 'സമീപമുള്ള ഗാരേജുകൾ',
      'myVehicles': 'എന്റെ വാഹനങ്ങൾ',
      'myServices': 'എന്റെ സർവീസുകൾ',
      'estimates': 'എസ്റ്റിമേറ്റുകൾ',
      'invoices': 'ഇൻവോയ്സുകൾ',
      'payments': 'പേയ്‌മെന്റുകൾ',
      'notifications': 'അറിയിപ്പുകൾ',
      'profile': 'പ്രൊഫൈൽ',
      'accountProfile': 'അക്കൗണ്ട് പ്രൊഫൈൽ',
      'settings': 'സെറ്റിംഗ്സ്',
      'dashboard': 'ഡാഷ്‌ബോർഡ്',
      'overview': 'അവലോകനം',
      'customers': 'ഉപഭോക്താക്കൾ',
      'vehicles': 'വാഹനങ്ങൾ',
      'addVehicle': 'വാഹനം ചേർക്കുക',
      'jobs': 'റിപ്പയർ ജോലികൾ',
      'repairJobs': 'റിപ്പയർ ജോലികൾ',
      'jobCards': 'ജോബ് കാർഡുകൾ',
      'inspections': 'പരിശോധനകൾ',
      'appointments': 'അപ്പോയിന്റ്മെന്റുകൾ',
      'reminders': 'ഓർമ്മപ്പെടുത്തലുകൾ',
      'serviceCatalog': 'സർവീസ് കാറ്റലോഗ്',
      'activeJobs': 'നിലവിലെ ജോലികൾ',
      'activeRepairs': 'നിലവിലെ റിപ്പയറുകൾ',
      'completedJobs': 'പൂർത്തിയായ ജോലികൾ',
      'serviceHistory': 'സർവീസ് ചരിത്രം',
      'readyForPickup': 'വാഹനം റെഡിയാണ്',
      'call': 'വിളിക്കുക',
      'whatsapp': 'വാട്ട്‌സ്ആപ്പ്',
      'directions': 'റൂട്ട്',
      'requestService': 'സർവീസ് ആവശ്യപ്പെടുക',
      'approve': 'അംഗീകരിക്കുക',
      'reject': 'നിരസിക്കുക',
      'save': 'സേവ് ചെയ്യുക',
      'saveChanges': 'മാറ്റങ്ങൾ സേവ് ചെയ്യുക',
      'cancel': 'റദ്ദാക്കുക',
      'delete': 'ഡിലീറ്റ് ചെയ്യുക',
      'edit': 'തിരുത്തുക',
      'search': 'തിരയുക',
      'filter': 'ഫിൽട്ടർ',
      'refresh': 'പുതുക്കുക',
      'more': 'കൂടുതൽ',
      'confirm': 'സ്ഥിരീകരിക്കുക',
      'confirmSwitch': 'മാറ്റം സ്ഥിരീകരിക്കുക',
      'submit': 'സമർപ്പിക്കുക',
      'statusDraft': 'ഡ്രാഫ്റ്റ്',
      'statusReceived': 'ലഭിച്ചു',
      'statusInspectionPending': 'പരിശോധന ബാക്കി',
      'statusEstimatePending': 'എസ്റ്റിമേറ്റ് ബാക്കി',
      'statusEstimateApproved': 'എസ്റ്റിമേറ്റ് അംഗീകരിച്ചു',
      'statusInProgress': 'പുരോഗമിക്കുന്നു',
      'statusWaitingForParts': 'പാർട്സുകൾക്കായി കാത്തിരിക്കുന്നു',
      'statusQualityCheck': 'ക്വാളിറ്റി ചെക്ക്',
      'statusReady': 'എടുക്കാൻ തയ്യാറാണ്',
      'statusCompleted': 'പൂർത്തിയായി',
      'statusCancelled': 'റദ്ദാക്കി',
      'statusOverdue': 'കാലഹരണപ്പെട്ടു',
      'statusPending': 'ബാക്കി',
      'statusPaid': 'നൽകി',
      'statusUnpaid': 'നൽകാനുണ്ട്',
      'statusPartiallyPaid': 'ഭാഗികമായി നൽകി',
      'statusUpcoming': 'വരാനിരിക്കുന്നത്',
      'statusDueSoon': 'ഉടൻ ചെയ്യേണ്ടത്',
      'statusDue': 'ഇപ്പോൾ ചെയ്യേണ്ടത്',
      'noDataFound': 'വിവരങ്ങൾ ഒന്നും ലഭ്യമല്ല',
      'noRecordsFound': 'രേഖകൾ ഒന്നും കണ്ടെത്തിയില്ല',
      'somethingWentWrong': 'എന്തോ തകരാർ സംഭവിച്ചു',
      'tryAgain': 'വീണ്ടും ശ്രമിക്കുക',
      'signOut': 'പുറത്തുകടക്കുക',
      'language': 'ഭാഷ',
      'languagePreference': 'ഭാഷാ മുൻഗണന',
      'theme': 'തീം',
      'currency': 'കറൻസി',
      'odometer': 'ഓഡോമീറ്റർ റീഡിംഗ്',
      'currentOdometer': 'നിലവിലെ ഓഡോമീറ്റർ',
      'licensePlate': 'രജിസ്ട്രേഷൻ നമ്പർ',
      'makeAndModel': 'വാഹന മോഡൽ',
      'year': 'നിർമ്മിത വർഷം',
      'nextServiceDue': 'അടുത്ത സർവീസ് തീയതി',
      'lastServiceDate': 'കഴിഞ്ഞ സർവീസ് തീയതി',
      'partsNeeded': 'ആവശ്യമായ പാർട്സുകൾ',
      'updateStatus': 'സ്റ്റാറ്റസ് പുതുക്കുക',
      'whatsappUpdate': 'വാട്ട്സ്ആപ്പ് അറിയിപ്പ്',
      'selectAll': 'എല്ലാം തിരഞ്ഞെടുക്കുക',
      'deselectAll': 'തിരഞ്ഞെടുക്കൽ ഒഴിവാക്കുക',
      'deleteSelected': 'തിരഞ്ഞെടുത്തവ നീക്കം ചെയ്യുക',
      'statusCustom': 'പ്രത്യേക സന്ദേശം',
      'messages': 'സന്ദേശങ്ങൾ',
      'servicesAndPricing': 'സർവീസുകളും നിരക്കുകളും',
      'reviews': 'അഭിപ്രായങ്ങൾ',
      'about': 'വിവരങ്ങൾ',
      'smartPricing': 'സ്മാർട്ട് പ്രൈസിംഗ്',
      'rateAndReview': 'റേറ്റിംഗും അഭിപ്രായവും',
      'consentShareName': 'എന്റെ പേര് പരസ്യമായി കാണിക്കുക',
      'consentSharePhoto': 'എന്റെ ഫോട്ടോ പരസ്യമായി കാണിക്കുക',
      'selectVehicleForPrice': 'കൃത്യമായ നിരക്കറിയാൻ വാഹനം തിരഞ്ഞെടുക്കുക',
      'fixedPrice': 'നിശ്ചിത നിരക്ക്',
      'categoryPrice': 'വിഭാഗം അനുസരിച്ചുള്ള നിരക്ക്',
      'attributePrice': 'നിബന്ധന അനുസരിച്ചുള്ള നിരക്ക്',
      'startingPrice': 'തുടക്ക നിരക്ക്',
      'quotationRequired': 'പരിശോധനയ്ക്ക് ശേഷം നിരക്ക്',
      'typeMessage': 'സന്ദേശം എഴുതുക...',
      'noMessages': 'സന്ദേശങ്ങൾ ഒന്നും ലഭ്യമല്ല',
      'noConversations': 'സംഭാഷണങ്ങൾ ഒന്നും ലഭ്യമല്ല',
      'startRepair': 'റിപ്പയർ ആരംഭിക്കുക',
      'completeRepair': 'റിപ്പയർ പൂർത്തിയാക്കുക',
      'gatePass': 'ഗേറ്റ് പാസ്',
      'gatePassOtp': 'ഗേറ്റ് പാസ് കോഡ്',
      'warrantyVault': 'വാറന്റി വോൾട്ട്',
      'inventory': 'സ്പെയർ പാർട്സുകൾ',
      'totalAmount': 'ആകെ തുക',
      'balanceDue': 'ബാക്കി നൽകാനുള്ള തുക',
      'taxInvoice': 'ടാക്സ് ഇൻവോയ്സ്',
      'downloadPdf': 'പിഡിഎഫ് ഡൗൺലോഡ്',
      'allInvoices': 'എല്ലാ ഇൻവോയ്സുകളും',
      'settledInvoices': 'നൽകിയവ',
      'upcomingMaintenance': 'വരാനിരിക്കുന്ന വാഹന പരിപാലനം',
      'profileIncomplete': 'പ്രൊഫൈൽ പൂർണ്ണമല്ല',
      'profileDetails': 'പ്രൊഫൈൽ വിവരങ്ങൾ',
      'completeProfileNow': 'പ്രൊഫൈൽ പൂർത്തിയാക്കുക',
      'editProfileDetails': 'പ്രൊഫൈൽ തിരുത്തുക',
      'saveProfileDetails': 'വിവരങ്ങൾ സേവ് ചെയ്യുക',
      'customerAccount': 'കസ്റ്റമർ അക്കൗണ്ട്',
      'merchantAccount': 'മെർച്ചന്റ് അക്കൗണ്ട്',
      'accountSwitching': 'അക്കൗണ്ട് മാറ്റം',
      'active': 'ആക്ടീവ്',
      'switch': 'മാറ്റുക',
      'switchToMerchant': 'മെർച്ചന്റ് അക്കൗണ്ടിലേക്ക് മാറുക',
      'switchToCustomer': 'കസ്റ്റമർ അക്കൗണ്ടിലേക്ക് മാറുക',
      'todayPipeline': 'ഇന്നത്തെ പ്രവർത്തനങ്ങൾ',
      'monthlyRevenue': 'പ്രതിമാസ വരുമാനം',
      'outstandingReceivables': 'ലഭിക്കാനുള്ള ബാക്കി തുക',
      'createJobCard': 'പുതിയ ജോബ് കാർഡ്',
      'personalDetailsModeSwitching': 'വ്യക്തിഗത വിവരങ്ങളും അക്കൗണ്ട് മാറ്റവും',
      'selectPreferredLanguage': 'നിങ്ങളുടെ ഭാഷ തിരഞ്ഞെടുക്കുക',
      'viewReplacementCoverage':
          'പാർട്സുകളുടെ വാറന്റിയും സർട്ടിഫിക്കറ്റുകളും കാണുക',
      'noWarrantiesOnFile': 'വാറന്റികൾ ഒന്നും ലഭ്യമല്ല',
      'genuinePartsWarrantiesAppear':
          'ഇൻവോയ്സ് പൂർത്തിയായതിനു ശേഷം പാർട്സുകളുടെ വാറന്റി ഇവിടെ കാണാം.',
      'noVehiclesRegistered': 'വാഹനങ്ങൾ ഒന്നും ചേർത്തിട്ടില്ല',
      'addCarOrTwoWheeler':
          'സർവീസ് ട്രാക്ക് ചെയ്യാൻ നിങ്ങളുടെ കാറോ ബൈക്കോ ചേർക്കുക.',
      'addFirstVehicle': 'ആദ്യ വാഹനം ചേർക്കുക',
      'allRepairs': 'എല്ലാ റിപ്പയറുകളും',
      'repairOrders': 'റിപ്പയർ ഓർഡറുകൾ',
      'trackLiveProgress':
          'തത്സമയ റിപ്പയർ വിവരങ്ങളും പരിശോധനാ റിപ്പോർട്ടും കാണുക',
      'invoicesAndPayments': 'ഇൻവോയ്സുകളും പേയ്‌മെന്റുകളും',
      'trackBillingSettlements': 'ബില്ലിംഗും പേയ്‌മെന്റുകളും ട്രാക്ക് ചെയ്യുക, പിഡിഎഫ് ഡൗൺലോഡ് ചെയ്യുക',
      'workshopDashboard': 'വർക്ക്‌ഷോപ്പ് ഡാഷ്‌ബോർഡ്',
      'monitorOperations': 'ദൈനംദിന റിപ്പയറുകളും വരുമാനവും നിരീക്ഷിക്കുക',
      'businessAnalytics': 'ബിസിനസ്സ് അനലിറ്റിക്സ്',
      'financialInsights': 'വരുമാനവും സാമ്പത്തിക പുരോഗതിയും പരിശോധിക്കുക',
      'moreOptions': 'കൂടുതൽ ഓപ്ഷനുകൾ',
      'manageGarageProfile':
          'വർക്ക്‌ഷോപ്പ് പ്രൊഫൈൽ, പാർട്സുകൾ, ജീവനക്കാർ എന്നിവ നിയന്ത്രിക്കുക',
      'garageProfile': 'ഗാരേജ് പ്രൊഫൈൽ',
      'businessInformation': 'ബിസിനസ്സ് വിവരങ്ങൾ',
      'operatingHours': 'പ്രവർത്തന സമയം',
      'googleAddress': 'വർക്ക്‌ഷോപ്പ് വിലാസം',
      'noInternetConnection': 'ഇന്റർനെറ്റ് കണക്ഷൻ ലഭ്യമല്ല',
      'offlineModeDescription': 'ഇന്റർനെറ്റ് കണക്ഷൻ പരിശോധിച്ച് വീണ്ടും ശ്രമിക്കുക. സംഭരിച്ച വിവരങ്ങൾ കാണിക്കുന്നു.',
      'completeProfileDetails': 'പ്രൊഫൈൽ വിവരങ്ങൾ നൽകുക',
      'enterFullName': 'നിങ്ങളുടെ പൂർണ്ണ നാമം നൽകുക',
      'phoneNumberForCalling':
          'ഫോൺ നമ്പർ (വിളിക്കുന്നതിനും ലോഗിൻ ചെയ്യുന്നതിനും)',
      'whatsappHelperText': 'റിപ്പയർ വിവരങ്ങളും ഡിജിറ്റൽ എസ്റ്റിമേറ്റുകളും വാട്ട്‌സ്ആപ്പിൽ ലഭിക്കും',
      'complete': 'പൂർത്തിയായി',
      'completePersonalDetailsDesc': 'തത്സമയ റിപ്പയർ വിവരങ്ങളും ഡിജിറ്റൽ എസ്റ്റിമേറ്റുകളും വാട്ട്‌സ്ആപ്പ് അറിയിപ്പുകളും ലഭിക്കുന്നതിന് വ്യക്തിഗത വിവരങ്ങൾ നൽകുക.',
      'notProvided': 'നൽകിയിട്ടില്ല',
      'defaultTag': 'സ്ഥിരസ്ഥിതി',
      'customer': 'ഉപഭോക്താവ്',
      'merchant': 'സ്ഥാപനം',
      'customerAccountDesc':
          'വാഹന വിവരങ്ങൾ, റിപ്പയർ സ്റ്റാറ്റസ്, ഡിജിറ്റൽ ഇൻവോയ്സുകൾ',
      'merchantAccountDesc':
          'വർക്ക്‌ഷോപ്പ് പ്രവർത്തനങ്ങൾ, ഡിജിറ്റൽ പരിശോധന, ജീവനക്കാർ',
      'switchAccountDesc': 'തിരഞ്ഞെടുത്ത വർക്ക്‌സ്‌പേസിലേക്ക് നിങ്ങൾ മാറുന്നതാണ്. നിങ്ങളുടെ അക്കൗണ്ട് വിവരങ്ങൾ സുരക്ഷിതമായിരിക്കും.',
      'hideDetails': 'വിശദാംശങ്ങൾ മറയ്ക്കുക',
      'showDetails': 'വിശദാംശങ്ങൾ കാണിക്കുക',
      'featuredGarages': 'പ്രമുഖ അംഗീകൃത വർക്ക്‌ഷോപ്പുകൾ',
      'viewAll': 'എല്ലാം കാണുക',
      'repairs': 'റിപ്പയറുകൾ',
      'support': 'സഹായം',
      'featuredOffers': 'പ്രത്യേക ഓഫറുകൾ',
      'genuineParts': 'യഥാർത്ഥ പാർട്സുകൾ',
      'exploreWorkshopPackages': 'സർവീസ് പാക്കേജുകൾ കാണുക',
      'workshopPackagesPeriodicCare': 'സർവീസ് പാക്കേജുകളും കൃത്യമായ പരിചരണവും',
      'noActiveRepairs': 'നിലവിൽ റിപ്പയറുകൾ ഒന്നും നടക്കുന്നില്ല',
      'exploreWorkshops': 'വർക്ക്‌ഷോപ്പുകൾ തിരയുക',
      'allOrders': 'എല്ലാ ഓർഡറുകളും',
      'noActiveRepairsInProgress': 'നിലവിൽ നടക്കുന്ന റിപ്പയറുകൾ ലഭ്യമല്ല',
      'noCompletedServiceHistory': 'പൂർത്തിയായ സർവീസ് വിവരങ്ങൾ ലഭ്യമല്ല',
      'noRepairOrdersFound': 'റിപ്പയർ ഓർഡറുകൾ ഒന്നും കണ്ടെത്തിയില്ല',
      'whenYouCheckVehicleDesc': 'നിങ്ങൾ വാഹനം വർക്ക്‌ഷോപ്പിൽ ഏൽപ്പിക്കുമ്പോൾ, ലൈവ് റിപ്പയർ വിവരങ്ങൾ ഇവിടെ കാണാം.',
      'loadingPortal': 'ഗാരേജ് പോർട്ടൽ തുറക്കുന്നു...',
      'searchGaragesServicesPackages':
          'വർക്ക്‌ഷോപ്പുകൾ, സർവീസുകൾ, പാക്കേജുകൾ തിരയുക...',
      'searchPlaceholderSub': 'ബൈക്ക് വാഷ്, ഓയിൽ മാറ്റം, സർവീസ്...',
      'issuedOn': 'നൽകിയ തീയതി',
      'noHistoryRecorded': 'ചരിത്രരേഖകൾ ഒന്നും ലഭ്യമല്ല',
      'expired': 'കാലഹരണപ്പെട്ടു',
      'whatsappOnly': 'വാട്ട്സ്ആപ്പ് മാത്രം',
      'saveAndWhatsapp': 'സേവ് ചെയ്യുക & വാട്ട്സ്ആപ്പ്',
      'completeAndIssuePass': 'പൂർത്തിയാക്കുക & ഗേറ്റ് പാസ്',
      'supportTickets': 'സപ്പോർട്ട് ടിക്കറ്റുകൾ',
      'customerTickets': 'ഉപഭോക്തൃ സപ്പോർട്ട് ടിക്കറ്റുകൾ',
      'customerTicketsSubtitle': 'ടിക്കറ്റുകളും സേവന അന്വേഷണങ്ങളും',
      'merchantTicketsSubtitle': 'ഉപഭോക്തൃ അഭ്യർത്ഥനകളും പരാതികളും',
      'newTicket': 'പുതിയ ടിക്കറ്റ്',
      'createSupportTicket': 'സപ്പോർട്ട് ടിക്കറ്റ് സൃഷ്ടിക്കുക',
      'createTicketSubtitle':
          'വർക്ക്‌ഷോപ്പിലേക്കോ പ്ലാറ്റ്‌ഫോമിലേക്കോ പരാതി അയക്കുക',
      'ticketInformation': 'ടിക്കറ്റ് വിവരങ്ങൾ',
      'supportCategory': 'സപ്പോർട്ട് വിഭാഗം',
      'vehicleIssue': 'വാഹന പ്രശ്നം',
      'repairDelay': 'റിപ്പയർ കാലതാമസം',
      'estimateInquiry': 'എസ്റ്റിമേറ്റ് അന്വേഷണം',
      'invoiceDispute': 'ഇൻവോയ്സ് / പേയ്‌മെന്റ് പ്രശ്നം',
      'serviceQuality': 'സർവീസ് നിലവാരം',
      'generalSupport': 'പൊതുവായ അന്വേഷണം',
      'subject': 'വിഷയം',
      'subjectHint': 'വിഷയത്തിന്റെ സംഗ്രഹം',
      'issueDescription': 'വിശദമായ വിവരണം',
      'descriptionHint': 'എന്താണ് സംഭവിച്ചതെന്ന് വിശദീകരിക്കുക...',
      'preferredContact': 'ബന്ധപ്പെടേണ്ട രീതി',
      'inAppSupport': 'ഇൻ-ആപ്പ് ചാറ്റ്',
      'relatedEntities': 'ബന്ധപ്പെട്ട രേഖകൾ',
      'relatedVehicle': 'ബന്ധപ്പെട്ട വാഹനം',
      'relatedRepairJob': 'ബന്ധപ്പെട്ട റിപ്പയർ ജോബ്',
      'relatedInvoice': 'ബന്ധപ്പെട്ട ഇൻവോയ്സ്',
      'relatedGarage': 'ബന്ധപ്പെട്ട വർക്ക്‌ഷോപ്പ്',
      'generalPlatformSupport': 'വിഫിക്സ് പ്ലാറ്റ്‌ഫോം സപ്പോർട്ട്',
      'submitTicket': 'ടിക്കറ്റ് സമർപ്പിക്കുക',
      'searchTicketsHint':
          'ടിക്കറ്റ് നമ്പർ, വിഷയം അല്ലെങ്കിൽ വർക്ക്‌ഷോപ്പ് തിരയുക...',
      'searchTicketsMerchantHint':
          'ടിക്കറ്റ് നമ്പർ, ഉപഭോക്താവ് അല്ലെങ്കിൽ വാഹനം തിരയുക...',
      'allTickets': 'എല്ലാ ടിക്കറ്റുകളും',
      'waitingCustomer': 'ഉപഭോക്താവിന്റെ മറുപടിക്കായി',
      'waitingMerchant': 'വർക്ക്‌ഷോപ്പിന്റെ മറുപടിക്കായി',
      'ticketDetails': 'ടിക്കറ്റ് വിവരങ്ങൾ',
      'ticketNotFound': 'ടിക്കറ്റ് കണ്ടെത്താനായില്ല',
      'noMatchingTickets': 'ടിക്കറ്റുകൾ കണ്ടെത്തിയില്ല',
      'noCustomerTicketsYet': 'ഉപഭോക്തൃ ടിക്കറ്റുകൾ ഒന്നും ലഭിച്ചിട്ടില്ല',
      'noCustomerTicketsDescription':
          'ഉപഭോക്താക്കൾ പരാതികൾ സമർപ്പിക്കുമ്പോൾ അവ ഇവിടെ കാണാം.',
      'noTicketsYet': 'സപ്പോർട്ട് ടിക്കറ്റുകൾ ഒന്നും സൃഷ്ടിച്ചിട്ടില്ല',
      'noTicketsDescription': 'റിപ്പയർ, എസ്റ്റിമേറ്റ് അല്ലെങ്കിൽ ഇൻവോയ്സ് എന്നിവയിൽ സഹായം ആവശ്യമുണ്ടോ? എപ്പോൾ വേണമെങ്കിലും ടിക്കറ്റ് സമർപ്പിക്കാം.',
      'reopenTicket': 'ടിക്കറ്റ് വീണ്ടും തുറക്കുക',
      'reopenReason': 'വീണ്ടും തുറക്കാനുള്ള കാരണം',
      'resolveTicket': 'ടിക്കറ്റ് പരിഹരിക്കുക',
      'resolutionNote': 'പരിഹാര വിവരണം',
      'confirmResolve': 'സ്ഥിരീകരിച്ച് പരിഹരിക്കുക',
      'confirmResolution': 'തൃപ്തികരമായി അടയ്ക്കുക',
      'closeTicket': 'ടിക്കറ്റ് അടയ്ക്കുക',
      'replyToCustomer': 'ഉപഭോക്താവിന് മറുപടി',
      'internalNoteStaffOnly': 'ജീവനക്കാരുടെ ആഭ്യന്തര കുറിപ്പ്',
      'writeInternalNoteHint':
          'ആഭ്യന്തര കുറിപ്പ് എഴുതുക (ജീവനക്കാർക്ക് മാത്രം)...',
      'typeYourMessage': 'മറുപടി ടൈപ്പ് ചെയ്യുക...',
      'helpAndSupport': 'സഹായവും സപ്പോർട്ട് ടിക്കറ്റുകളും',
      'noneNotApplicable': 'ഒന്നുമില്ല / ബാധകമല്ല',
      'noMessagesYet': 'സന്ദേശങ്ങൾ ഒന്നും ലഭിച്ചിട്ടില്ല',
      'noMessagesDescription': 'സംഭാഷണം ആരംഭിക്കാൻ സന്ദേശം അയക്കുക.',
      'workingHours': 'പ്രവർത്തന സമയം',
      'monday': 'തിങ്കൾ',
      'tuesday': 'ചൊവ്വ',
      'wednesday': 'ബുധൻ',
      'thursday': 'വ്യാഴം',
      'friday': 'വെള്ളി',
      'saturday': 'ശനി',
      'sunday': 'ഞായർ',
      'open': 'തുറന്നിരിക്കുന്നു',
      'closed': 'അടച്ചിരിക്കുന്നു',
      'openNow': 'ഇപ്പോൾ തുറന്നിരിക്കുന്നു',
    },
  };

  static final Map<String, String> _phraseToKeyMap = {
    'help & support': 'helpAndSupport',
    'support tickets': 'supportTickets',
    'customer support tickets': 'customerTickets',
    'home': 'home',
    'garages': 'garages',
    'nearby garages': 'nearbyGarages',
    'invoices': 'invoices',
    'invoices & payments': 'invoicesAndPayments',
    'profile': 'profile',
    'account profile': 'accountProfile',
    'personal details & mode switching': 'personalDetailsModeSwitching',
    'profile incomplete': 'profileIncomplete',
    'profile details': 'profileDetails',
    'complete profile now': 'completeProfileNow',
    'edit profile details': 'editProfileDetails',
    'language preference': 'languagePreference',
    'select your preferred display language': 'selectPreferredLanguage',
    'warranty vault': 'warrantyVault',
    'view replacement parts coverage & guarantee certificates':
        'viewReplacementCoverage',
    'account switching': 'accountSwitching',
    'customer account': 'customerAccount',
    'merchant account': 'merchantAccount',
    'active': 'active',
    'switch': 'switch',
    'sign out': 'signOut',
    'sign in': 'signIn',
    'create account': 'createAccount',
    'overview': 'overview',
    'jobs': 'jobs',
    'service jobs': 'jobs',
    'repair jobs': 'repairJobs',
    'repair orders': 'repairOrders',
    'analytics': 'analytics',
    'more': 'more',
    'more options': 'moreOptions',
    'dashboard': 'dashboard',
    'workshop dashboard': 'workshopDashboard',
    'my vehicles': 'myVehicles',
    'vehicles': 'vehicles',
    'add vehicle': 'addVehicle',
    'add first vehicle': 'addFirstVehicle',
    'no vehicles registered': 'noVehiclesRegistered',
    'today\'s pipeline': 'todayPipeline',
    'monthly revenue': 'monthlyRevenue',
    'outstanding receivables': 'outstandingReceivables',
    'create job card': 'createJobCard',
    'start repair': 'startRepair',
    'complete repair': 'completeRepair',
    'gate pass': 'gatePass',
    'no records found': 'noRecordsFound',
    'no data found': 'noDataFound',
    'something went wrong': 'somethingWentWrong',
    'try again': 'tryAgain',
    'save': 'save',
    'save changes': 'saveChanges',
    'cancel': 'cancel',
    'delete': 'delete',
    'edit': 'edit',
    'filter': 'filter',
    'search': 'search',
    'refresh': 'refresh',
    'call': 'call',
    'whatsapp': 'whatsapp',
    'directions': 'directions',
    'approve': 'approve',
    'reject': 'reject',
    'upcoming maintenance': 'upcomingMaintenance',
    'service history': 'serviceHistory',
    'active repairs': 'activeRepairs',
    'services catalog': 'serviceCatalog',
    'services & pricing': 'servicesAndPricing',
    'garage profile': 'garageProfile',
    'business information': 'businessInformation',
    'operating hours': 'operatingHours',
    'no warranties on file': 'noWarrantiesOnFile',
    'no internet connection': 'noInternetConnection',
    'complete profile details': 'completeProfileDetails',
    'enter your full name': 'enterFullName',
    'phone number (for calling & login)': 'phoneNumberForCalling',
    'repair alerts and digital estimates will be delivered via whatsapp':
        'whatsappHelperText',
    'save profile details': 'saveProfileDetails',
    'complete': 'complete',
    'complete your personal details to receive instant repair updates, digital estimates, and whatsapp service notifications.':
        'completePersonalDetailsDesc',
    'not provided': 'notProvided',
    'default': 'defaultTag',
    'customer': 'customer',
    'merchant': 'merchant',
    'vehicle registry, repair status & digital invoices': 'customerAccountDesc',
    'garage operations, digital inspections & staff roles':
        'merchantAccountDesc',
    'hide details': 'hideDetails',
    'show details': 'showDetails',
    'featured & verified garages': 'featuredGarages',
    'view all': 'viewAll',
    'repairs': 'repairs',
    'support': 'support',
    'featured offers': 'featuredOffers',
    'genuine parts': 'genuineParts',
    'explore workshop packages': 'exploreWorkshopPackages',
    'workshop packages & periodic care': 'workshopPackagesPeriodicCare',
    'no active repair jobs': 'noActiveRepairs',
    'explore workshops': 'exploreWorkshops',
    'all orders': 'allOrders',
    'no active repairs in progress': 'noActiveRepairsInProgress',
    'no completed service history': 'noCompletedServiceHistory',
    'no repair orders found': 'noRepairOrdersFound',
    'when you check your vehicle into an authorized garage, your live repair status will appear here.':
        'whenYouCheckVehicleDesc',
    'total amount': 'totalAmount',
    'balance due': 'balanceDue',
    'download pdf': 'downloadPdf',
    'issued on': 'issuedOn',
    'no history recorded yet.': 'noHistoryRecorded',
    'expired': 'expired',
    'whatsapp only': 'whatsappOnly',
    'save & whatsapp': 'saveAndWhatsapp',
    'start repair work': 'startRepair',
    'commence work': 'startRepair',
    'complete & issue pass': 'completeAndIssuePass',
  };

  String translate(String keyOrPhrase) {
    final langCode = locale.languageCode;
    final direct = _localizedValues[langCode]?[keyOrPhrase];
    if (direct != null) return direct;

    final mappedKey = _phraseToKeyMap[keyOrPhrase.trim().toLowerCase()];
    if (mappedKey != null) {
      final fromMapped = _localizedValues[langCode]?[mappedKey];
      if (fromMapped != null) return fromMapped;
    }

    return _localizedValues['en']?[keyOrPhrase] ?? keyOrPhrase;
  }

  String status(String rawStatus) {
    final normalized = rawStatus
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final repair = repairStatus(normalized);
    if (repair != normalized && repair != rawStatus) return repair;
    final inv = invoiceStatus(normalized);
    if (inv != normalized && inv != rawStatus) return inv;
    final est = estimateStatus(normalized);
    if (est != normalized && est != rawStatus) return est;
    final maint = maintenanceStatus(normalized);
    if (maint != normalized && maint != rawStatus) return maint;
    return translate(rawStatus);
  }

  String repairStatus(String rawStatus) {
    final normalized = rawStatus
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final key = switch (normalized) {
      'draft' => 'statusDraft',
      'received' => 'statusReceived',
      'inspectionpending' || 'inspection_pending' => 'statusInspectionPending',
      'estimatepending' || 'estimate_pending' => 'statusEstimatePending',
      'estimateapproved' || 'estimate_approved' => 'statusEstimateApproved',
      'inprogress' || 'in_progress' => 'statusInProgress',
      'waitingforparts' ||
      'waiting_for_parts' ||
      'awaiting_parts' => 'statusWaitingForParts',
      'qualitycheck' || 'quality_check' => 'statusQualityCheck',
      'readyforcollection' ||
      'ready_for_collection' ||
      'ready_for_pickup' ||
      'ready' => 'statusReady',
      'completed' => 'statusCompleted',
      'cancelled' => 'statusCancelled',
      _ => null,
    };
    if (key != null) return translate(key);
    return rawStatus;
  }

  String invoiceStatus(String rawStatus) {
    final normalized = rawStatus
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final key = switch (normalized) {
      'paid' => 'statusPaid',
      'unpaid' => 'statusUnpaid',
      'partiallypaid' || 'partially_paid' => 'statusPartiallyPaid',
      'overdue' => 'statusOverdue',
      'draft' => 'statusDraft',
      _ => null,
    };
    if (key != null) return translate(key);
    return rawStatus;
  }

  String estimateStatus(String rawStatus) {
    final normalized = rawStatus
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final key = switch (normalized) {
      'pending' => 'statusPending',
      'approved' => 'approve',
      'rejected' => 'reject',
      _ => null,
    };
    if (key != null) return translate(key);
    return rawStatus;
  }

  String maintenanceStatus(String rawStatus) {
    final normalized = rawStatus
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final key = switch (normalized) {
      'upcoming' => 'statusUpcoming',
      'due_soon' || 'duesoon' => 'statusDueSoon',
      'due' || 'due_now' => 'statusDue',
      'overdue' => 'statusOverdue',
      'completed' => 'statusCompleted',
      _ => null,
    };
    if (key != null) return translate(key);
    return rawStatus;
  }

  String relativeTime(DateTime? date) {
    if (date == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(date);
    final isMl = locale.languageCode == 'ml';

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes <= 1) {
          return isMl ? 'ഇപ്പോൾ' : 'Just now';
        }
        return isMl
            ? '${diff.inMinutes} മിനിറ്റ് മുൻപ്'
            : '${diff.inMinutes}m ago';
      }
      return isMl ? '${diff.inHours} മണിക്കൂർ മുൻപ്' : '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) {
      return isMl ? 'ഇന്നലെ' : 'Yesterday';
    }
    if (diff.inDays < 7) {
      return isMl ? '${diff.inDays} ദിവസം മുൻപ്' : '${diff.inDays}d ago';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  String plural(String key, int count) {
    final isMl = locale.languageCode == 'ml';
    if (key == 'jobs') {
      if (isMl) return '$count റിപ്പയർ ജോലികൾ';
      return count == 1 ? '1 repair job' : '$count repair jobs';
    }
    if (key == 'notifications') {
      if (isMl) return '$count അറിയിപ്പുകൾ';
      return count == 1 ? '1 notification' : '$count notifications';
    }
    if (key == 'vehicles') {
      if (isMl) return '$count വാഹനങ്ങൾ';
      return count == 1 ? '1 vehicle' : '$count vehicles';
    }
    return '$count ${translate(key)}';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ml'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

const String _localePrefKey = 'selected_locale_code';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadPersistedLocale();
    return const Locale('en');
  }

  Future<void> _loadPersistedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localePrefKey);
    if (savedCode != null && (savedCode == 'en' || savedCode == 'ml')) {
      state = Locale(savedCode);
    }
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode != 'en' && languageCode != 'ml') return;
    state = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  String tr(String keyOrPhrase) =>
      AppLocalizations.of(this).translate(keyOrPhrase);
}
