import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportReports(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: Colors.blue),
                    const SizedBox(width: 12),
                    const Text(
                      'Report Period: ',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Expanded(
                      child: Text(
                        '${DateTime.now().subtract(const Duration(days: 30)).toString().split(' ')[0]} - ${DateTime.now().toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selectDateRange(context),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Summary Cards
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildSummaryCard(
                    'Total Inspections',
                    '127',
                    Icons.assignment,
                    Colors.blue,
                  ),
                  _buildSummaryCard(
                    'Average Score',
                    '87%',
                    Icons.star,
                    Colors.green,
                  ),
                  _buildSummaryCard(
                    'Failed Inspections',
                    '8',
                    Icons.error,
                    Colors.red,
                  ),
                  _buildSummaryCard(
                    'Revenue',
                    '\$25,400',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Reports List
              const Text(
                'Generated Reports',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return _buildReportCard(context, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _generateReport(context),
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add_chart, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, int index) {
    final reportTypes = ['Monthly Summary', 'Inspection Analysis', 'Safety Report', 'Performance Review'];
    final reportType = reportTypes[index % 4];
    final date = DateTime.now().subtract(Duration(days: index * 7));
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(
            Icons.description,
            color: Colors.blue[900],
          ),
        ),
        title: Text(reportType),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generated: ${date.toString().split(' ')[0]}'),
            const SizedBox(height: 4),
            Text(
              'Size: ${(index + 1) * 250} KB',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            _handleReportAction(context, value, reportType);
          },
        ),
        onTap: () => _viewReport(context, reportType),
      ),
    );
  }

  void _selectDateRange(BuildContext context) {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    ).then((range) {
      if (range != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Date range updated: ${range.start.toString().split(' ')[0]} - ${range.end.toString().split(' ')[0]}'),
          ),
        );
      }
    });
  }

  void _exportReports(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Reports'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showExportSuccess(context, 'PDF');
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Excel'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showExportSuccess(context, 'Excel');
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('CSV'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showExportSuccess(context, 'CSV');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _generateReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Generate New Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Monthly Summary'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGenerateSuccess(context, 'Monthly Summary');
                },
              ),
              ListTile(
                title: const Text('Inspection Analysis'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGenerateSuccess(context, 'Inspection Analysis');
                },
              ),
              ListTile(
                title: const Text('Safety Report'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGenerateSuccess(context, 'Safety Report');
                },
              ),
              ListTile(
                title: const Text('Custom Report'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGenerateSuccess(context, 'Custom Report');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _viewReport(BuildContext context, String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $reportType...')),
    );
  }

  void _handleReportAction(BuildContext context, String action, String reportType) {
    String message = '';
    switch (action) {
      case 'view':
        message = 'Opening $reportType...';
        break;
      case 'download':
        message = 'Downloading $reportType...';
        break;
      case 'share':
        message = 'Sharing $reportType...';
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showExportSuccess(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reports exported as $format successfully!')),
    );
  }

  void _showGenerateSuccess(BuildContext context, String reportType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$reportType generated successfully!')),
    );
  }
}
