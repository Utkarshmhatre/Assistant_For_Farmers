enum PhenologicalStage {
  preSowing,
  sowing,
  germination,
  vegetativeGrowth,
  floweringBudFormation,
  flowering,
  fruitFormation,
  maturation,
  harvesting,
  postHarvest,
}

enum CropType {
  foodGrain,
  cashCrop,
  pulse,
  oilseed,
  vegetable,
  fruit,
  spice,
  other,
}

class CropPhase {
  final String cropName;
  final PhenologicalStage stage;
  final int daysAfterSowing;
  final String description;
  final List<String> criticalFactors;

  CropPhase({
    required this.cropName,
    required this.stage,
    required this.daysAfterSowing,
    required this.description,
    required this.criticalFactors,
  });
}

class RegionalInfo {
  final String state;
  final double productionMT;
  final double areaHectares;
  final double yieldKgPerHa;
  final String season;
  final List<String> varieties;

  RegionalInfo({
    required this.state,
    required this.productionMT,
    required this.areaHectares,
    required this.yieldKgPerHa,
    required this.season,
    required this.varieties,
  });
}

class ClimateImpact {
  final String cropName;
  final String weatherParameter;
  final String phenologicalStage;
  final String impact;
  final String pathology;
  final List<String> mitigationSteps;

  ClimateImpact({
    required this.cropName,
    required this.weatherParameter,
    required this.phenologicalStage,
    required this.impact,
    required this.pathology,
    required this.mitigationSteps,
  });
}

class CropProfile {
  final String name;
  final CropType type;
  final List<CropPhase> phenologicalCycle;
  final List<RegionalInfo> regionalProduction;
  final List<ClimateImpact> climateImpacts;
  final String optimalTemperature;
  final String optimalRainfall;
  final String sowingWindow;

  CropProfile({
    required this.name,
    required this.type,
    required this.phenologicalCycle,
    required this.regionalProduction,
    required this.climateImpacts,
    required this.optimalTemperature,
    required this.optimalRainfall,
    required this.sowingWindow,
  });
}

class AgriculturalDatabase {
  static final Map<String, CropProfile> _cropDatabase = {
    'onion': _buildOnionProfile(),
    'rice': _buildRiceProfile(),
    'wheat': _buildWheatProfile(),
    'cotton': _buildCottonProfile(),
    'potato': _buildPotatoProfile(),
  };

  static Map<String, CropProfile> get cropDatabase => _cropDatabase;

  static CropProfile _buildOnionProfile() {
    return CropProfile(
      name: 'Onion',
      type: CropType.vegetable,
      phenologicalCycle: [
        CropPhase(
          cropName: 'Onion',
          stage: PhenologicalStage.preSowing,
          daysAfterSowing: -15,
          description: 'Seed treatment and bed preparation',
          criticalFactors: ['Soil pH 6.0-6.8', 'Well-draining soil'],
        ),
        CropPhase(
          cropName: 'Onion',
          stage: PhenologicalStage.sowing,
          daysAfterSowing: 0,
          description: 'Seed sowing in nursery beds',
          criticalFactors: ['Seed rate 8-10 kg/ha', 'Temperature 20-25C'],
        ),
        CropPhase(
          cropName: 'Onion',
          stage: PhenologicalStage.germination,
          daysAfterSowing: 7,
          description: 'Seed germination phase',
          criticalFactors: ['Moisture 60-70%', 'Temperature 20-25C'],
        ),
        CropPhase(
          cropName: 'Onion',
          stage: PhenologicalStage.vegetativeGrowth,
          daysAfterSowing: 45,
          description: 'Vegetative growth and leaf development',
          criticalFactors: ['Nitrogen requirement high', 'Consistent moisture'],
        ),
        CropPhase(
          cropName: 'Onion',
          stage: PhenologicalStage.floweringBudFormation,
          daysAfterSowing: 80,
          description: 'Bulb development initiation',
          criticalFactors: ['Long day length triggers bulbing', 'Potassium critical'],
        ),
        CropPhase(
          cropName: 'Onion',
          stage: PhenologicalStage.maturation,
          daysAfterSowing: 120,
          description: 'Bulb maturation and drying',
          criticalFactors: ['Reduce irrigation', 'Low humidity for curing'],
        ),
      ],
      regionalProduction: [
        RegionalInfo(
          state: 'Maharashtra',
          productionMT: 2500000,
          areaHectares: 380000,
          yieldKgPerHa: 6580,
          season: 'Kharif and Rabi',
          varieties: ['Baswant 780', 'Nasik Red', 'Phule Safed'],
        ),
        RegionalInfo(
          state: 'Madhya Pradesh',
          productionMT: 1200000,
          areaHectares: 185000,
          yieldKgPerHa: 6480,
          season: 'Rabi',
          varieties: ['Local cultivars', 'Pusa Red'],
        ),
        RegionalInfo(
          state: 'Karnataka',
          productionMT: 800000,
          areaHectares: 135000,
          yieldKgPerHa: 5925,
          season: 'Kharif',
          varieties: ['Red Creole', 'Bellary Red'],
        ),
      ],
      climateImpacts: [
        ClimateImpact(
          cropName: 'Onion',
          weatherParameter: 'Excessive Rainfall',
          phenologicalStage: 'Bulb Development to Maturation',
          impact: 'Waterlogging causes bulb rot and secondary fungal infections',
          pathology: 'Purple blotch (Alternaria porri), Basal rot (Fusarium oxysporum)',
          mitigationSteps: [
            'Ensure field drainage within 24 hours of rain',
            'Apply fungicide (Carbendazim 1% or Mancozeb 2.5%) if humidity exceeds 85%',
            'Reduce irrigation frequency during monsoon',
            'Space rows 45cm apart for better air circulation',
          ],
        ),
        ClimateImpact(
          cropName: 'Onion',
          weatherParameter: 'Heatwave (Above 35C)',
          phenologicalStage: 'Bulb Development',
          impact: 'Premature bolting, reduced bulb size, lower yield and quality',
          pathology: 'Early flowering reduces bulb expansion, Thrips infestation increases',
          mitigationSteps: [
            'Plant bolt-resistant varieties (Nasik Red, Baswant 780)',
            'Mulch soil with straw to reduce temperature by 2-3C',
            'Increase irrigation to maintain soil moisture',
            'Spray Neem oil to control heat-induced pest pressure',
          ],
        ),
        ClimateImpact(
          cropName: 'Onion',
          weatherParameter: 'Unseasonal Rain (March-April Rabi)',
          phenologicalStage: 'Harvesting and Post-Harvest',
          impact: 'Delayed drying, bulb sprouting, fungal contamination during storage',
          pathology: 'White rot (Sclerotium cepivorum), Black mold (Aspergillus niger)',
          mitigationSteps: [
            'Harvest before rainfall forecast',
            'Dry bulbs in shade under tarps (10-15 days)',
            'Store at 0-2C with 65-70% humidity for long-term preservation',
            'Inspect stored bulbs weekly for mold signs',
          ],
        ),
      ],
      optimalTemperature: '13-24C for growth, 15-21C for bulbing',
      optimalRainfall: '60-75 cm annually',
      sowingWindow: 'Rabi: June-August (Nursery), September-October (Field transplant)',
    );
  }

  static CropProfile _buildRiceProfile() {
    return CropProfile(
      name: 'Rice',
      type: CropType.foodGrain,
      phenologicalCycle: [
        CropPhase(
          cropName: 'Rice',
          stage: PhenologicalStage.sowing,
          daysAfterSowing: 0,
          description: 'Seed sowing in prepared nursery or direct seeding',
          criticalFactors: ['Pre-soaking 24 hours', 'Nursery water level 5cm'],
        ),
        CropPhase(
          cropName: 'Rice',
          stage: PhenologicalStage.germination,
          daysAfterSowing: 3,
          description: 'Germination phase',
          criticalFactors: ['Water temperature 25-30C', 'Continuous flooding'],
        ),
        CropPhase(
          cropName: 'Rice',
          stage: PhenologicalStage.vegetativeGrowth,
          daysAfterSowing: 45,
          description: 'Tillering and vegetative growth (Transplanting at 25-30 days)',
          criticalFactors: ['Nitrogen 60 kg/ha', 'Standing water 5-7cm'],
        ),
        CropPhase(
          cropName: 'Rice',
          stage: PhenologicalStage.floweringBudFormation,
          daysAfterSowing: 75,
          description: 'Panicle initiation',
          criticalFactors: ['Phosphorus critical', 'Avoid water stress'],
        ),
        CropPhase(
          cropName: 'Rice',
          stage: PhenologicalStage.flowering,
          daysAfterSowing: 95,
          description: 'Flowering phase (1-3 days per panicle)',
          criticalFactors: ['Temperature 20-30C', 'Wind pollination'],
        ),
        CropPhase(
          cropName: 'Rice',
          stage: PhenologicalStage.maturation,
          daysAfterSowing: 120,
          description: 'Grain filling and maturation',
          criticalFactors: ['Reduce water to 2-3cm', 'Monitor grain moisture'],
        ),
      ],
      regionalProduction: [
        RegionalInfo(
          state: 'West Bengal',
          productionMT: 15000000,
          areaHectares: 5600000,
          yieldKgPerHa: 2675,
          season: 'Kharif',
          varieties: ['IET 4786', 'MTU 1010', 'Rajendra Kasturi'],
        ),
        RegionalInfo(
          state: 'Uttar Pradesh',
          productionMT: 12000000,
          areaHectares: 4200000,
          yieldKgPerHa: 2857,
          season: 'Kharif and Rabi',
          varieties: ['Basmati 1121', 'Pusa Basmati 1509'],
        ),
      ],
      climateImpacts: [
        ClimateImpact(
          cropName: 'Rice',
          weatherParameter: 'Delayed Monsoon',
          phenologicalStage: 'Germination and Seedling',
          impact: 'Delayed transplanting, reduced vegetative period, lower tiller formation',
          pathology: 'Increased pest populations due to extended growing window',
          mitigationSteps: [
            'Use stored rainwater for seedbed irrigation',
            'Adopt direct seeded rice (DSR) to reduce water dependency',
            'Apply pre-emergence herbicide for weed control in DSR',
            'Monitor aphids and leaf folder if drought stress occurs',
          ],
        ),
      ],
      optimalTemperature: '20-30C throughout growing season',
      optimalRainfall: '100-150 cm during Kharif',
      sowingWindow: 'Kharif: May-July, Rabi: September-October',
    );
  }

  static CropProfile _buildWheatProfile() {
    return CropProfile(
      name: 'Wheat',
      type: CropType.foodGrain,
      phenologicalCycle: [
        CropPhase(
          cropName: 'Wheat',
          stage: PhenologicalStage.sowing,
          daysAfterSowing: 0,
          description: 'Seed sowing in winter',
          criticalFactors: ['Seed rate 100-125 kg/ha', 'Temperature 10-15C optimal'],
        ),
        CropPhase(
          cropName: 'Wheat',
          stage: PhenologicalStage.germination,
          daysAfterSowing: 5,
          description: 'Germination and emergence',
          criticalFactors: ['Soil moisture 60%', 'Temperature 15-20C'],
        ),
        CropPhase(
          cropName: 'Wheat',
          stage: PhenologicalStage.vegetativeGrowth,
          daysAfterSowing: 45,
          description: 'Tillering and vegetative growth',
          criticalFactors: ['Temperature 10-15C', 'Nitrogen 120 kg/ha'],
        ),
        CropPhase(
          cropName: 'Wheat',
          stage: PhenologicalStage.floweringBudFormation,
          daysAfterSowing: 90,
          description: 'Stem elongation and boot stage',
          criticalFactors: ['Booting stage sensitive to frost', 'Phosphorus essential'],
        ),
        CropPhase(
          cropName: 'Wheat',
          stage: PhenologicalStage.flowering,
          daysAfterSowing: 105,
          description: 'Anthesis and grain formation',
          criticalFactors: ['Temperature 15-20C for grain set', 'Avoid heat stress'],
        ),
        CropPhase(
          cropName: 'Wheat',
          stage: PhenologicalStage.maturation,
          daysAfterSowing: 140,
          description: 'Grain filling and hardening',
          criticalFactors: ['Dough stage to hard dough', 'Reduce irrigation'],
        ),
      ],
      regionalProduction: [
        RegionalInfo(
          state: 'Uttar Pradesh',
          productionMT: 30000000,
          areaHectares: 9200000,
          yieldKgPerHa: 3260,
          season: 'Rabi',
          varieties: ['HD 2967', 'DBW 187', 'PBW 773'],
        ),
        RegionalInfo(
          state: 'Punjab',
          productionMT: 18000000,
          areaHectares: 3500000,
          yieldKgPerHa: 5142,
          season: 'Rabi',
          varieties: ['DBW 187', 'WH 1105'],
        ),
      ],
      climateImpacts: [
        ClimateImpact(
          cropName: 'Wheat',
          weatherParameter: 'Late Frost (February-March)',
          phenologicalStage: 'Boot and Anthesis',
          impact: 'Spikelet sterility, chaffy grains, 30-50% yield loss',
          pathology: 'Frost damage irreversible at anthesis',
          mitigationSteps: [
            'Plant frost-tolerant varieties (DBW 187, HD 3086)',
            'Delay sowing by 7-10 days to avoid peak frost exposure',
            'Monitor temperature forecasts during boot stage',
            'Avoid excess nitrogen in late season (increases frost sensitivity)',
          ],
        ),
        ClimateImpact(
          cropName: 'Wheat',
          weatherParameter: 'Heat Wave (April, Above 35C)',
          phenologicalStage: 'Grain Filling and Maturation',
          impact: 'Accelerated maturation, shriveled grains, 15-40% yield loss',
          pathology: 'Premature senescence, reduced grain weight',
          mitigationSteps: [
            'Sow early-maturing varieties (HD 2967, 120-135 days)',
            'Increase irrigation at milk stage (2-3 days interval)',
            'Mulch to reduce soil surface temperature',
            'Monitor for heat-induced Spot Blotch disease',
          ],
        ),
      ],
      optimalTemperature: '10-20C during growth, 15-20C during grain filling',
      optimalRainfall: '50-90 cm (mostly during winter)',
      sowingWindow: 'Rabi: October-November',
    );
  }

  static CropProfile _buildCottonProfile() {
    return CropProfile(
      name: 'Cotton',
      type: CropType.cashCrop,
      phenologicalCycle: [
        CropPhase(
          cropName: 'Cotton',
          stage: PhenologicalStage.sowing,
          daysAfterSowing: 0,
          description: 'Seed sowing at 15-20mm depth',
          criticalFactors: ['Soil temperature 18C minimum', 'Well-drained soil'],
        ),
        CropPhase(
          cropName: 'Cotton',
          stage: PhenologicalStage.vegetativeGrowth,
          daysAfterSowing: 60,
          description: 'Vegetative growth and branch formation',
          criticalFactors: ['Temperature 25-30C optimal', 'Adequate moisture'],
        ),
        CropPhase(
          cropName: 'Cotton',
          stage: PhenologicalStage.floweringBudFormation,
          daysAfterSowing: 90,
          description: 'Bud formation (Squares)',
          criticalFactors: ['Potassium critical', 'Avoid water stress'],
        ),
        CropPhase(
          cropName: 'Cotton',
          stage: PhenologicalStage.flowering,
          daysAfterSowing: 120,
          description: 'Flowering (Bloom)',
          criticalFactors: ['Flowers open early morning', 'Pollinator activity essential'],
        ),
        CropPhase(
          cropName: 'Cotton',
          stage: PhenologicalStage.fruitFormation,
          daysAfterSowing: 140,
          description: 'Boll formation and development',
          criticalFactors: ['Temperature 20-30C', 'Moisture 50-60%'],
        ),
        CropPhase(
          cropName: 'Cotton',
          stage: PhenologicalStage.maturation,
          daysAfterSowing: 180,
          description: 'Boll opening and fiber maturation',
          criticalFactors: ['Dry weather for fiber development', 'Reduce irrigation'],
        ),
      ],
      regionalProduction: [
        RegionalInfo(
          state: 'Gujarat',
          productionMT: 2200000,
          areaHectares: 3400000,
          yieldKgPerHa: 647,
          season: 'Kharif',
          varieties: ['BT Cotton Bt-11', 'BT Cotton MON-531'],
        ),
        RegionalInfo(
          state: 'Maharashtra',
          productionMT: 2800000,
          areaHectares: 3900000,
          yieldKgPerHa: 718,
          season: 'Kharif',
          varieties: ['BT Cotton Bt-11', 'BT Cotton Nuziveerachya-2'],
        ),
      ],
      climateImpacts: [
        ClimateImpact(
          cropName: 'Cotton',
          weatherParameter: 'Excess Monsoon Rain',
          phenologicalStage: 'Flowering and Boll Formation',
          impact: 'Bud and flower drop, reduced fruit set, increased pest/disease',
          pathology: 'Leaf reddening, Angular leaf spot (Xanthomonas), Leaf curl virus',
          mitigationSteps: [
            'Ensure field drainage within 12 hours of rain',
            'Apply systemic insecticide for whitefly and thrips control',
            'Spray fungicide (Mancozeb 2.5%) for angular leaf spot',
            'Avoid excess nitrogen during monsoon',
          ],
        ),
        ClimateImpact(
          cropName: 'Cotton',
          weatherParameter: 'Early Frost (December)',
          phenologicalStage: 'Boll Maturation',
          impact: 'Unopen bolls, reduced fiber quality, harvest losses',
          pathology: 'Fiber maturity incomplete, staple length reduced',
          mitigationSteps: [
            'Sow early (May first week) to complete cycle before frost',
            'Avoid excess nitrogen (delays maturity)',
            'Harvest mature bolls on time',
            'Monitor weather forecasts post-October',
          ],
        ),
      ],
      optimalTemperature: '25-30C for growth, 20-30C for fruiting',
      optimalRainfall: '60-100 cm during Kharif',
      sowingWindow: 'Kharif: May-June',
    );
  }

  static CropProfile _buildPotatoProfile() {
    return CropProfile(
      name: 'Potato',
      type: CropType.vegetable,
      phenologicalCycle: [
        CropPhase(
          cropName: 'Potato',
          stage: PhenologicalStage.preSowing,
          daysAfterSowing: -15,
          description: 'Seed potato selection and treatment',
          criticalFactors: ['Certified seed tubers', 'Disease-free stock'],
        ),
        CropPhase(
          cropName: 'Potato',
          stage: PhenologicalStage.sowing,
          daysAfterSowing: 0,
          description: 'Planting at 20cm depth',
          criticalFactors: ['Soil temperature 10-20C optimal', 'Plant spacing 60x20cm'],
        ),
        CropPhase(
          cropName: 'Potato',
          stage: PhenologicalStage.germination,
          daysAfterSowing: 10,
          description: 'Emergence and sprout growth',
          criticalFactors: ['Temperature 15-20C', 'Soil moisture 70%'],
        ),
        CropPhase(
          cropName: 'Potato',
          stage: PhenologicalStage.vegetativeGrowth,
          daysAfterSowing: 35,
          description: 'Stolonization and tuber initiation',
          criticalFactors: ['Day length critical', 'Temperature 18-20C optimal'],
        ),
        CropPhase(
          cropName: 'Potato',
          stage: PhenologicalStage.fruitFormation,
          daysAfterSowing: 70,
          description: 'Tuber bulking phase',
          criticalFactors: ['Consistent moisture', 'Potassium essential'],
        ),
        CropPhase(
          cropName: 'Potato',
          stage: PhenologicalStage.maturation,
          daysAfterSowing: 100,
          description: 'Tuber maturation and skin set',
          criticalFactors: ['Reduce irrigation', 'Allow 7-10 days skin hardening'],
        ),
      ],
      regionalProduction: [
        RegionalInfo(
          state: 'Uttar Pradesh',
          productionMT: 9500000,
          areaHectares: 770000,
          yieldKgPerHa: 12337,
          season: 'Rabi',
          varieties: ['Kufri Badshah', 'Kufri Jyoti', 'Kufri Chandramukhi'],
        ),
        RegionalInfo(
          state: 'West Bengal',
          productionMT: 6200000,
          areaHectares: 370000,
          yieldKgPerHa: 16757,
          season: 'Winter',
          varieties: ['Kufri Badshah', 'Kufri Lalima'],
        ),
      ],
      climateImpacts: [
        ClimateImpact(
          cropName: 'Potato',
          weatherParameter: 'High Humidity and Cool Temperature',
          phenologicalStage: 'Vegetative Growth to Tuber Bulking',
          impact: 'Late blight epidemic, 70-100% yield loss without control',
          pathology: 'Late blight (Phytophthora infestans), causes foliage and tuber rot',
          mitigationSteps: [
            'Use resistant varieties (Kufri Ashoka, Kufri Bahar)',
            'Spray Metalaxyl + Mancozeb (2.5%) every 10 days if humidity exceeds 90%',
            'Remove infected foliage immediately',
            'Ensure proper field drainage and spacing for air circulation',
            'Start preventive spraying when first symptoms appear in region',
          ],
        ),
        ClimateImpact(
          cropName: 'Potato',
          weatherParameter: 'Unseasonal Heat (March-April)',
          phenologicalStage: 'Tuber Bulking and Maturation',
          impact: 'Reduced tuber size, lower yield, poor keeping quality',
          pathology: 'Tuber deformation, increased bacterial wilt susceptibility',
          mitigationSteps: [
            'Sow early-maturing varieties (Kufri Pukhraj, 60-70 days)',
            'Plant earlier in season (October-November for Rabi)',
            'Provide shade net (30-50%) in extreme heat regions',
            'Maintain consistent irrigation every 5-7 days',
            'Harvest before heat stress peaks',
          ],
        ),
      ],
      optimalTemperature: '15-20C for growth, 18-20C for tuberization',
      optimalRainfall: '50-60 cm well-distributed',
      sowingWindow: 'Rabi: September-November',
    );
  }
}
