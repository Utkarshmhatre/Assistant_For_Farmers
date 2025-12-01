import '../models/agricultural_data.dart';

class PhenologyAnalyzer {
  PhenologicalStage? detectPhenologicalStage(
    String cropName,
    String userQuery,
    int? daysAfterSowing,
  ) {
    final query = userQuery.toLowerCase();
    final crop = AgriculturalDatabase.cropDatabase[cropName.toLowerCase()];

    if (crop == null) return null;

    // Keyword-based detection
    if (query.contains('seedling') ||
        query.contains('emergence') ||
        query.contains('germination')) {
      return PhenologicalStage.germination;
    }

    if (query.contains('shoot') ||
        query.contains('leaf') ||
        query.contains('growth') ||
        query.contains('vegetative')) {
      return PhenologicalStage.vegetativeGrowth;
    }

    if (query.contains('tiller') ||
        query.contains('branch') ||
        query.contains('bud') ||
        query.contains('square') ||
        query.contains('panicle initiation')) {
      return PhenologicalStage.floweringBudFormation;
    }

    if (query.contains('flower') ||
        query.contains('bloom') ||
        query.contains('anthesis')) {
      return PhenologicalStage.flowering;
    }

    if (query.contains('fruit') ||
        query.contains('boll') ||
        query.contains('grain') ||
        query.contains('tuber')) {
      return PhenologicalStage.fruitFormation;
    }

    if (query.contains('mature') ||
        query.contains('ripen') ||
        query.contains('harden') ||
        query.contains('dry')) {
      return PhenologicalStage.maturation;
    }

    if (query.contains('harvest')) {
      return PhenologicalStage.harvesting;
    }

    // Days-based estimation
    if (daysAfterSowing != null) {
      for (var phase in crop.phenologicalCycle) {
        if (daysAfterSowing >= phase.daysAfterSowing &&
            daysAfterSowing < (phase.daysAfterSowing + 25)) {
          return phase.stage;
        }
      }
    }

    return null;
  }

  String generatePhenologyReport(
    String cropName,
    PhenologicalStage stage,
  ) {
    final crop = AgriculturalDatabase.cropDatabase[cropName.toLowerCase()];
    if (crop == null) return 'Crop information not found.';

    final phase = crop.phenologicalCycle
        .firstWhere((p) => p.stage == stage, orElse: () => crop.phenologicalCycle.first);

    return 'CROP: $cropName\n\nCURRENT STAGE: ${_stageName(stage)}\n\n'
        'DESCRIPTION: ${phase.description}\n\n'
        'DAYS AFTER SOWING: ${phase.daysAfterSowing}\n\n'
        'CRITICAL FACTORS:\n${phase.criticalFactors.map((f) => '- $f').join('\n')}\n\n'
        'OPTIMAL CONDITIONS:\n'
        'Temperature: ${crop.optimalTemperature}\n'
        'Rainfall: ${crop.optimalRainfall}';
  }

  String analyzeClimateImpact(
    String cropName,
    String weatherParameter,
    PhenologicalStage? stage,
  ) {
    final crop = AgriculturalDatabase.cropDatabase[cropName.toLowerCase()];
    if (crop == null) return 'Crop information not found.';

    final impacts = crop.climateImpacts.where((impact) {
      final parameterMatch =
          impact.weatherParameter.toLowerCase().contains(weatherParameter.toLowerCase());

      if (stage == null) return parameterMatch;

      final stageMatch = impact.phenologicalStage.toLowerCase().contains(stage.toString());
      return parameterMatch && stageMatch;
    }).toList();

    if (impacts.isEmpty) {
      return 'No specific climate impact data available for this combination.';
    }

    final impact = impacts.first;

    return 'WEATHER IMPACT ANALYSIS\n\n'
        'CROP: $cropName\n'
        'WEATHER PARAMETER: ${impact.weatherParameter}\n'
        'CRITICAL STAGE: ${impact.phenologicalStage}\n\n'
        'IMPACT ON CROP:\n${impact.impact}\n\n'
        'DISEASE/STRESS RISK:\n${impact.pathology}\n\n'
        'MITIGATION STEPS:\n${impact.mitigationSteps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}\n\n'
        'ACTION REQUIRED: Implement immediately if weather conditions match.';
  }

  String getRegionalAdvice(String cropName) {
    final crop = AgriculturalDatabase.cropDatabase[cropName.toLowerCase()];
    if (crop == null) return 'Crop information not found.';

    final states = crop.regionalProduction;
    final report = StringBuffer();

    report.writeln('REGIONAL CROP PRODUCTION DATA FOR: ${cropName.toUpperCase()}\n');

    for (var region in states) {
      report.writeln('STATE: ${region.state}');
      report.writeln('Production: ${region.productionMT} Million Tonnes');
      report.writeln('Area: ${region.areaHectares} Hectares');
      report.writeln('Yield: ${region.yieldKgPerHa} kg/ha');
      report.writeln('Season: ${region.season}');
      report.writeln('Recommended Varieties: ${region.varieties.join(', ')}');
      report.writeln('');
    }

    return report.toString();
  }

  String _stageName(PhenologicalStage stage) {
    const stageNames = {
      PhenologicalStage.preSowing: 'Pre-Sowing Preparation',
      PhenologicalStage.sowing: 'Sowing',
      PhenologicalStage.germination: 'Germination and Emergence',
      PhenologicalStage.vegetativeGrowth: 'Vegetative Growth',
      PhenologicalStage.floweringBudFormation: 'Flowering / Bud Formation',
      PhenologicalStage.flowering: 'Flowering / Bloom',
      PhenologicalStage.fruitFormation: 'Fruit / Boll / Tuber Formation',
      PhenologicalStage.maturation: 'Maturation and Ripening',
      PhenologicalStage.harvesting: 'Harvesting',
      PhenologicalStage.postHarvest: 'Post-Harvest',
    };
    return stageNames[stage] ?? 'Unknown Stage';
  }
}
