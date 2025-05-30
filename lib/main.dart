import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const TemperatureConverterScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() =>
      _TemperatureConverterScreenState();
}

/// Represents a single conversion entry in the history
class ConversionEntry {
  final String operation;
  final double inputValue;
  final double resultValue;
  final DateTime timestamp;

  ConversionEntry({
    required this.operation,
    required this.inputValue,
    required this.resultValue,
    required this.timestamp,
  });

  /// Formats the entry for display in history
  String get displayText {
    return '$operation: ${inputValue.toStringAsFixed(1)} => ${resultValue.toStringAsFixed(1)}';
  }

  /// Formats the entry for display in constrained spaces
  String get compactDisplayText {
    return '$operation: ${inputValue.toStringAsFixed(0)}°=>${resultValue.toStringAsFixed(0)}°';
  }
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with SingleTickerProviderStateMixin {
  // Controllers and form management
  final TextEditingController _temperatureController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables
  String _conversionType = 'F to C'; // Default conversion type
  String _result = '';
  List<ConversionEntry> _conversionHistory = [];

  // Animation controller for result display
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation for smooth result display
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Converts Fahrenheit to Celsius using the formula: °C = (°F - 32) × 5/9
  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Converts Celsius to Fahrenheit using the formula: °F = °C × 9/5 + 32
  double _celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  /// Validates and performs the temperature conversion
  void _convertTemperature() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputText = _temperatureController.text.trim();
    final inputValue = double.tryParse(inputText);

    if (inputValue == null) {
      _showErrorSnackBar('Please enter a valid number');
      return;
    }

    double convertedValue;
    String operation;

    // Perform conversion based on selected type
    if (_conversionType == 'F to C') {
      convertedValue = _fahrenheitToCelsius(inputValue);
      operation = 'F to C';
    } else {
      convertedValue = _celsiusToFahrenheit(inputValue);
      operation = 'C to F';
    }

    // Update result with 2 decimal places
    setState(() {
      _result = convertedValue.toStringAsFixed(2);
      // Add to history
      _conversionHistory.insert(
          0,
          ConversionEntry(
            operation: operation,
            inputValue: inputValue,
            resultValue: convertedValue,
            timestamp: DateTime.now(),
          ));
    });

    // Trigger result animation
    _animationController.reset();
    _animationController.forward();

    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  /// Shows error message using SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Clears all conversion history
  void _clearHistory() {
    setState(() {
      _conversionHistory.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Validates temperature input
  String? _validateTemperature(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a temperature value';
    }

    final numValue = double.tryParse(value.trim());
    if (numValue == null) {
      return 'Please enter a valid number';
    }

    // Check for extreme values that might cause overflow
    if (numValue.abs() > 1000000) {
      return 'Temperature value is too extreme';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temperature Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            // Responsive layout based on orientation
            if (orientation == Orientation.portrait) {
              return _buildPortraitLayout();
            } else {
              return _buildLandscapeLayout();
            }
          },
        ),
      ),
    );
  }

  /// Portrait layout for vertical screen orientation
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConverterCard(),
          const SizedBox(height: 20),
          _buildResultCard(),
          const SizedBox(height: 20),
          _buildHistoryCard(),
        ],
      ),
    );
  }

  /// Landscape layout for horizontal screen orientation
  Widget _buildLandscapeLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Converter and Result
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildConverterCard(),
                const SizedBox(height: 16),
                _buildResultCard(),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right side: History
          Expanded(
            flex: 2,
            child: _buildHistoryCard(),
          ),
        ],
      ),
    );
  }

  /// Main converter input and controls card
  Widget _buildConverterCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temperature Converter',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 20),

              // Conversion type selection
              Text(
                'Conversion Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              _buildConversionTypeSelector(),

              const SizedBox(height: 20),

              // Temperature input field
              Text(
                'Enter Temperature',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                validator: _validateTemperature,
                decoration: InputDecoration(
                  hintText: 'Enter temperature value',
                  prefixIcon: const Icon(Icons.thermostat),
                  suffixText: _conversionType == 'F to C' ? '°F' : '°C',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                ],
              ),

              const SizedBox(height: 24),

              // Convert button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _convertTemperature,
                  icon: const Icon(Icons.calculate),
                  label: const Text(
                    'Convert',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Radio button selector for conversion type
  Widget _buildConversionTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Fahrenheit to Celsius (°F → °C)'),
            value: 'F to C',
            groupValue: _conversionType,
            onChanged: (value) {
              setState(() {
                _conversionType = value!;
                _result = ''; // Clear previous result
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
          RadioListTile<String>(
            title: const Text('Celsius to Fahrenheit (°C → °F)'),
            value: 'C to F',
            groupValue: _conversionType,
            onChanged: (value) {
              setState(() {
                _conversionType = value!;
                _result = ''; // Clear previous result
              });
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  /// Result display card with animation
  Widget _buildResultCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Result',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: _result.isEmpty
                  ? Text(
                      'Enter a temperature and press Convert',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer
                                .withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    )
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            _result,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _conversionType == 'F to C'
                                ? '°Celsius'
                                : '°Fahrenheit',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.8),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// History display card with clear functionality
  Widget _buildHistoryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    MediaQuery.of(context).orientation == Orientation.landscape
                        ? 'History'
                        : 'Conversion History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 16
                              : null,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_conversionHistory.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: Text(
                      MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 'Clear'
                          : 'Clear',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height:
                  MediaQuery.of(context).orientation == Orientation.landscape
                      ? 150
                      : 200,
              child: _conversionHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No conversions yet',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _conversionHistory.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final entry = _conversionHistory[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            child: Text(
                              entry.operation == 'F to C' ? 'F→C' : 'C→F',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? entry.compactDisplayText
                                : entry.displayText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
                            '${entry.timestamp.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
