/// Service for generating CSV exports and printable report data for all 9 Dairy Operations categories.
class ReportService {
  static const List<String> reportTypes = [
    'Daily Collection Report',
    'Weekly Collection Report',
    'Monthly Collection Report',
    'Collector Performance Report',
    'Payment & Payouts Report',
    'Dispatch & Logistics Report',
    'Commercial Seller Report',
    'Milk Quality & Lab Report',
    'Custom Date Range Report',
  ];

  static String generateCsv({
    required String reportType,
    required DateTime fromDate,
    required DateTime toDate,
    String center = 'All Centers',
  }) {
    final buffer = StringBuffer();
    final generatedAt = DateTime.now().toIso8601String();

    buffer.writeln('# Farm2Factory Dairy Operations - $reportType');
    buffer.writeln('# Date Range: ${fromDate.day}/${fromDate.month}/${fromDate.year} to ${toDate.day}/${toDate.month}/${toDate.year}');
    buffer.writeln('# Center: $center | Generated At: $generatedAt');
    buffer.writeln('');

    if (reportType.contains('Collection')) {
      buffer.writeln('Date,Center,Morning (L),Evening (L),Total (L),Avg FAT,Avg SNF,Gross Value (INR)');
      buffer.writeln('2026-10-07,Behror Center,520.0,480.0,1000.0,4.3,8.6,48500.0');
      buffer.writeln('2026-10-07,Jaipur Center,740.0,690.0,1430.0,4.4,8.7,69500.0');
      buffer.writeln('2026-10-07,Ajmer Center,490.0,430.0,920.0,4.1,8.4,44200.0');
      buffer.writeln('2026-10-07,Sikar Center,610.0,570.0,1180.0,4.25,8.55,57000.0');
      buffer.writeln('2026-10-07,Tonk Center,340.0,310.0,650.0,4.05,8.35,31500.0');
    } else if (reportType.contains('Collector')) {
      buffer.writeln('Collector ID,Name,Center,Farmers Handled,Today Litres (L),Monthly Total (L),Status,Payment Status');
      buffer.writeln('C-BHN-001,Ramesh Kumar,Behror Center,84,1000.0,28000.0,Active,Paid');
      buffer.writeln('C-JAI-002,Suresh Sharma,Jaipur Center,112,1430.0,40040.0,Collecting,Paid');
      buffer.writeln('C-AJM-003,Mahesh Verma,Ajmer Center,76,920.0,25760.0,On Duty,Pending');
      buffer.writeln('C-SKR-004,Vikram Singh,Sikar Center,95,1180.0,33040.0,Active,Paid');
      buffer.writeln('C-TNK-005,Kailash Choudhary,Tonk Center,54,650.0,18200.0,Offline,Pending');
    } else if (reportType.contains('Dispatch')) {
      buffer.writeln('Dispatch ID,Vehicle No,Driver Name,From,To,Capacity (L),Loaded (L),Temp (C),Status');
      buffer.writeln('DSP-101,RJ-14-GA-1022,Vikram Singh,Behror Center,Jaipur Plant,5000,4650,4.0,En Route');
      buffer.writeln('DSP-102,RJ-01-EA-4520,Harish Chandra,Ajmer Center,Jaipur Plant,4500,4100,3.9,Dispatched');
      buffer.writeln('DSP-103,RJ-23-MA-8819,Dharmendra Yadav,Sikar Center,Jaipur Plant,6000,5850,4.2,Delivered');
      buffer.writeln('DSP-104,RJ-26-PA-3211,Mukesh Gujjar,Tonk Center,Jaipur Plant,3500,3200,4.1,Loading');
    } else if (reportType.contains('Payment')) {
      buffer.writeln('Payment ID,Recipient,Type,Center/Location,Litres (L),Rate (INR),Final Payout (INR),Cycle,Status');
      buffer.writeln('PAY-COL-001,Ramesh Kumar,Collector,Behror Center,14000.0,48.5,681500.0,10 Days,Pending');
      buffer.writeln('PAY-COL-002,Suresh Sharma,Collector,Jaipur Center,20020.0,49.0,986180.0,10 Days,Paid');
      buffer.writeln('PAY-SEL-001,Green Valley Farm,Seller,Jaipur Farm,20000.0,49.5,990000.0,10 Days,Paid');
      buffer.writeln('PAY-SEL-002,Surya Cattle Farms,Seller,Ajmer Farm,14500.0,48.0,693000.0,10 Days,Pending');
    } else {
      buffer.writeln('Record ID,Category,Entity,Volume (L),Quality Grade,Status,Date');
      buffer.writeln('GEN-01,Inflow,Jaipur Chilling,14200.0,Grade A,Verified,2026-10-07');
      buffer.writeln('GEN-02,Inflow,Behror Chilling,10000.0,Grade A,Verified,2026-10-07');
      buffer.writeln('GEN-03,Commercial,Green Valley Farm,2000.0,Grade A,Verified,2026-10-07');
    }

    return buffer.toString();
  }
}
