import 'package:flutter/material.dart';

class TriviaPage extends StatefulWidget {
  const TriviaPage({super.key});

  @override
  _TriviaPageState createState() => _TriviaPageState();
}

class _TriviaPageState extends State<TriviaPage> {
  // Carbon emission constants (kg CO2 equivalent)
  static const double _fertilizerCO2Factor = 4.5;  // kg CO2 per kg N fertilizer
  static const double _dieselCO2Factor = 2.68;     // kg CO2 per liter diesel
  static const double _highCarbonThreshold = 500.0; // kg CO2 threshold for suggestions

  // Local styles for dark theme contrast
  TextStyle get _titleStyle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
  TextStyle get _subtleStyle => const TextStyle(
        fontSize: 13,
        color: Colors.white70,
      );
  ButtonStyle get _btnStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
  ShapeBorder get _cardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24),
      );
  // Seed rate
  final TextEditingController _seedAreaHaCtrl = TextEditingController();
  final TextEditingController _seedRateKgPerHaCtrl = TextEditingController();
  final TextEditingController _germinationPctCtrl =
      TextEditingController(text: '85');
  String _seedResult = '';

  // Fertilizer NPK
  final TextEditingController _fertAreaHaCtrl = TextEditingController();
  final TextEditingController _nTargetCtrl = TextEditingController();
  final TextEditingController _pTargetCtrl = TextEditingController(); // as P2O5
  final TextEditingController _kTargetCtrl = TextEditingController(); // as K2O
  String _fertResult = '';

  // Irrigation water need
  final TextEditingController _irrAreaHaCtrl = TextEditingController();
  final TextEditingController _irrDepthMmCtrl = TextEditingController();
  String _irrResult = '';

  // Profit estimator
  final TextEditingController _yieldTonPerHaCtrl = TextEditingController();
  final TextEditingController _profitAreaHaCtrl = TextEditingController();
  final TextEditingController _pricePerTonCtrl = TextEditingController();
  final TextEditingController _costPerHaCtrl = TextEditingController();
  String _profitResult = '';

  // Carbon footprint calculator
  final TextEditingController _carbonAreaHaCtrl = TextEditingController();
  final TextEditingController _fertilizerKgCtrl = TextEditingController();
  final TextEditingController _fuelLitersCtrl = TextEditingController();
  String _carbonResult = '';

  @override
  void dispose() {
    _seedAreaHaCtrl.dispose();
    _seedRateKgPerHaCtrl.dispose();
    _germinationPctCtrl.dispose();
    _fertAreaHaCtrl.dispose();
    _nTargetCtrl.dispose();
    _pTargetCtrl.dispose();
    _kTargetCtrl.dispose();
    _irrAreaHaCtrl.dispose();
    _irrDepthMmCtrl.dispose();
    _yieldTonPerHaCtrl.dispose();
    _profitAreaHaCtrl.dispose();
    _pricePerTonCtrl.dispose();
    _costPerHaCtrl.dispose();
    _carbonAreaHaCtrl.dispose();
    _fertilizerKgCtrl.dispose();
    _fuelLitersCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Climate-Smart Toolkit'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.white70),
            hintStyle: const TextStyle(color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.greenAccent),
            ),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCarbonCard(context),
              const SizedBox(height: 12),
              _buildSeedRateCard(context),
              const SizedBox(height: 12),
              _buildIrrigationCard(context),
              const SizedBox(height: 12),
              _buildFertilizerCard(context),
              const SizedBox(height: 12),
              _buildProfitCard(context),
              const SizedBox(height: 12),
              _buildClimateTipsCard(context),
            ],
          ),
        ),
      ),
    );
  }

  // Carbon Footprint Calculator (NEW)
  Widget _buildCarbonCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 2,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.eco, color: Colors.lightGreenAccent),
              const SizedBox(width: 8),
              Text('Carbon Footprint Calculator', style: _titleStyle),
            ]),
            const SizedBox(height: 8),
            Text(
              'Estimate your farm\'s carbon emissions.\nCO2 = (Fertilizer × 4.5) + (Fuel × 2.68) kg CO2 equivalent',
              style: _subtleStyle,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField(_carbonAreaHaCtrl, label: 'Area (ha)')),
              const SizedBox(width: 8),
              Expanded(
                  child: _numField(_fertilizerKgCtrl,
                      label: 'Fertilizer (kg)')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child:
                      _numField(_fuelLitersCtrl, label: 'Diesel fuel (L)')),
              const SizedBox(width: 8),
              ElevatedButton(
                style: _btnStyle,
                onPressed: _calcCarbonFootprint,
                child: const Text('Calculate'),
              ),
            ]),
            if (_carbonResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_carbonResult,
                  style: const TextStyle(color: Colors.lightGreenAccent)),
            ]
          ],
        ),
      ),
    );
  }

  // UI cards
  Widget _buildSeedRateCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 2,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.spa, color: Colors.lightGreenAccent),
              const SizedBox(width: 8),
              Text('Climate-Resilient Seed Calculator', style: _titleStyle),
            ]),
            const SizedBox(height: 8),
            Text(
              'Estimate seed needed for climate-adapted varieties.\nSeed needed (kg) = Area (ha) × Seed rate (kg/ha) × (100 / Germination %)',
              style: _subtleStyle,
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField(_seedAreaHaCtrl, label: 'Area (ha)')),
              const SizedBox(width: 8),
              Expanded(
                  child: _numField(_seedRateKgPerHaCtrl,
                      label: 'Seed rate (kg/ha)')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child:
                      _numField(_germinationPctCtrl, label: 'Germination %')),
              const SizedBox(width: 8),
              ElevatedButton(
                style: _btnStyle,
                onPressed: _calcSeedRequirement,
                child: const Text('Calculate'),
              ),
            ]),
            if (_seedResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_seedResult,
                  style: const TextStyle(color: Colors.lightGreenAccent)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFertilizerCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 2,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.grass, color: Colors.lightGreenAccent),
              const SizedBox(width: 8),
              Text('Sustainable Fertilizer Planner', style: _titleStyle),
            ]),
            const SizedBox(height: 8),
            Text(
                'Calculate eco-friendly fertilizer needs (N-P2O5-K2O).\nUsing DAP (18-46-0), Urea (46-0-0), MOP (0-0-60).',
                style: _subtleStyle),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField(_fertAreaHaCtrl, label: 'Area (ha)')),
              const SizedBox(width: 8),
              Expanded(
                  child: _numField(_nTargetCtrl, label: 'Target N (kg/ha)')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _numField(_pTargetCtrl, label: 'Target P2O5 (kg/ha)')),
              const SizedBox(width: 8),
              Expanded(
                  child: _numField(_kTargetCtrl, label: 'Target K2O (kg/ha)')),
            ]),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: _btnStyle,
                onPressed: _calcFertilizerPlan,
                child: const Text('Calculate'),
              ),
            ),
            if (_fertResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_fertResult,
                  style: const TextStyle(color: Colors.lightGreenAccent)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildIrrigationCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 2,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.water_drop, color: Colors.lightBlueAccent),
              const SizedBox(width: 8),
              Text('Water Conservation Planner', style: _titleStyle),
            ]),
            const SizedBox(height: 8),
            Text('Calculate optimal water usage for climate-smart irrigation.\nVolume = Area (ha) × 10,000 × Depth (mm) / 1000',
                style: _subtleStyle),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _numField(_irrAreaHaCtrl, label: 'Area (ha)')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_irrDepthMmCtrl, label: 'Depth (mm)')),
            ]),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: _btnStyle,
                onPressed: _calcIrrigationNeed,
                child: const Text('Calculate'),
              ),
            ),
            if (_irrResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_irrResult,
                  style: const TextStyle(color: Colors.cyanAccent)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProfitCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 2,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.attach_money, color: Colors.amberAccent),
              const SizedBox(width: 8),
              Text('Climate-Smart Profit Estimator', style: _titleStyle),
            ]),
            const SizedBox(height: 8),
            Text('Factor in sustainable practices for better returns.\nProfit = Revenue − Cost. Revenue = Yield × Area × Price',
                style: _subtleStyle),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child:
                      _numField(_yieldTonPerHaCtrl, label: 'Yield (ton/ha)')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_profitAreaHaCtrl, label: 'Area (ha)')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _numField(_pricePerTonCtrl, label: 'Price (₹/ton)')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_costPerHaCtrl, label: 'Cost (₹/ha)')),
            ]),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: _btnStyle,
                onPressed: _calcProfit,
                child: const Text('Calculate'),
              ),
            ),
            if (_profitResult.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_profitResult,
                  style: const TextStyle(color: Colors.amberAccent)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildClimateTipsCard(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.06),
      elevation: 2,
      shape: _cardShape,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.tips_and_updates, color: Colors.orangeAccent),
              const SizedBox(width: 8),
              Text('Climate Adaptation Tips', style: _titleStyle),
            ]),
            const SizedBox(height: 8),
            Text('🌡️ Monitor weather forecasts and adjust planting schedules.',
                style: _subtleStyle),
            Text('💧 Use drip irrigation to reduce water usage by up to 70%.',
                style: _subtleStyle),
            Text('🌱 Choose drought-resistant and heat-tolerant crop varieties.',
                style: _subtleStyle),
            Text('🌿 Practice crop rotation and intercropping for soil health.',
                style: _subtleStyle),
            Text('♻️ Avoid stubble burning; use mulching or composting instead.',
                style: _subtleStyle),
            Text('🌳 Plant trees on field boundaries for windbreaks and carbon capture.',
                style: _subtleStyle),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _numField(TextEditingController c, {required String label}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  void _calcSeedRequirement() {
    final area = _p(_seedAreaHaCtrl);
    final rate = _p(_seedRateKgPerHaCtrl);
    final germ = _p(_germinationPctCtrl);
    if (area <= 0 || rate <= 0 || germ <= 0) {
      setState(() => _seedResult = 'Please enter valid positive numbers.');
      return;
    }
    final factor = 100 / germ; // more seed if lower germination
    final kg = area * rate * factor;
    setState(() =>
        _seedResult = 'Estimated seed needed: ${kg.toStringAsFixed(2)} kg');
  }

  void _calcFertilizerPlan() {
    final area = _p(_fertAreaHaCtrl);
    final nPerHa = _p(_nTargetCtrl);
    final pPerHa = _p(_pTargetCtrl); // P2O5
    final kPerHa = _p(_kTargetCtrl); // K2O
    if (area <= 0) {
      setState(() => _fertResult = 'Enter a valid area.');
      return;
    }
    final nTotal = nPerHa * area;
    final pTotal = pPerHa * area;
    final kTotal = kPerHa * area;

    // DAP to satisfy P first
    final dapKg = pTotal > 0 ? (pTotal / 0.46) : 0.0;
    final nFromDap = dapKg * 0.18;
    double remainingN = (nTotal - nFromDap);
    if (remainingN < 0) remainingN = 0;
    final ureaKg = remainingN / 0.46;
    final mopKg = kTotal / 0.60;

    setState(() {
      _fertResult = 'For $area ha:\n'
          '• DAP: ${dapKg.isFinite ? dapKg.toStringAsFixed(1) : '0'} kg\n'
          '• Urea: ${ureaKg.isFinite ? ureaKg.toStringAsFixed(1) : '0'} kg\n'
          '• MOP: ${mopKg.isFinite ? mopKg.toStringAsFixed(1) : '0'} kg';
    });
  }

  void _calcIrrigationNeed() {
    final area = _p(_irrAreaHaCtrl);
    final depth = _p(_irrDepthMmCtrl);
    if (area <= 0 || depth <= 0) {
      setState(() => _irrResult = 'Please enter valid positive numbers.');
      return;
    }
    final m3 = area * 10000 * (depth / 1000);
    final liters = m3 * 1000;
    setState(() => _irrResult =
        'Water needed: ${m3.toStringAsFixed(1)} m³ (${liters.toStringAsFixed(0)} L)');
  }

  void _calcProfit() {
    final yieldT = _p(_yieldTonPerHaCtrl);
    final area = _p(_profitAreaHaCtrl);
    final price = _p(_pricePerTonCtrl);
    final costPerHa = _p(_costPerHaCtrl);
    if (yieldT < 0 || area <= 0 || price < 0 || costPerHa < 0) {
      setState(() => _profitResult = 'Please enter valid numbers (area > 0).');
      return;
    }
    final revenue = yieldT * area * price;
    final cost = costPerHa * area;
    final profit = revenue - cost;
    setState(() => _profitResult =
        'Revenue: ₹${revenue.toStringAsFixed(0)}  |  Cost: ₹${cost.toStringAsFixed(0)}\nEstimated Profit: ₹${profit.toStringAsFixed(0)}');
  }

  void _calcCarbonFootprint() {
    final area = _p(_carbonAreaHaCtrl);
    final fertilizer = _p(_fertilizerKgCtrl);
    final fuel = _p(_fuelLitersCtrl);
    if (area <= 0) {
      setState(() => _carbonResult = 'Please enter a valid area.');
      return;
    }
    // Calculate carbon emissions using defined constants
    final fertilizerCO2 = fertilizer * _fertilizerCO2Factor;
    final fuelCO2 = fuel * _dieselCO2Factor;
    final totalCO2 = fertilizerCO2 + fuelCO2;
    final perHa = totalCO2 / area;
    
    String offsetSuggestion = '';
    if (totalCO2 > _highCarbonThreshold) {
      offsetSuggestion = '\n💡 Consider: organic fertilizers, solar pumps, minimum tillage';
    }
    
    setState(() => _carbonResult =
        'Total CO2: ${totalCO2.toStringAsFixed(1)} kg\nPer hectare: ${perHa.toStringAsFixed(1)} kg CO2/ha$offsetSuggestion');
  }
}
