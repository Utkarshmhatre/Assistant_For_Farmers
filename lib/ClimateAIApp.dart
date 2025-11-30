import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/message_model.dart';
import 'services/phenology_analyzer.dart';
import 'widgets/markdown_message_bubble.dart';

void main() {
  runApp(const ClimateAIApp());
}

class ClimateAIApp extends StatelessWidget {
  const ClimateAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Climate & Kisan AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          centerTitle: false,
          toolbarHeight: 64,
        ),
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          bodyMedium:
              TextStyle(fontSize: 14, height: 1.4, color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1B5E20),
          toolbarHeight: 64,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

// Climate AI Engine
class ClimateAI {
  final Random _random = Random();
  final Map<String, List<String>> _conversationContext = {};
  final PhenologyAnalyzer _phenologyAnalyzer = PhenologyAnalyzer();

  String processMessage(String input, List<Message> history) {
    final query = input.toLowerCase().trim();

    // Extract keywords
    final keywords = _extractKeywords(query);

    // Determine intent
    final intent = _determineIntent(query, keywords);

    // Generate contextual response
    return _generateResponse(intent, keywords, query, history);
  }

  List<String> _extractKeywords(String query) {
    final words = query.split(RegExp(r'\s+'));
    final keywords = <String>[];

    final importantWords = {
      'climate',
      'change',
      'global',
      'warming',
      'temperature',
      'carbon',
      'co2',
      'emissions',
      'greenhouse',
      'gas',
      'fossil',
      'fuel',
      'renewable',
      'energy',
      'solar',
      'wind',
      'ice',
      'melt',
      'sea',
      'level',
      'ocean',
      'pollution',
      'deforestation',
      'forest',
      'conservation',
      'sustainability',
      'recycle',
      'reduce',
      'reuse',
      'electric',
      'vehicle',
      'plastic',
      'waste',
      'biodiversity',
      'ecosystem',
      'species',
      'extinction',
      'weather',
      'extreme',
      'drought',
      'flood',
      'hurricane',
      'wildfire',
      'agriculture',
      'food',
      'water',
      'scarcity',
      'impact',
      'solution',
      'action',
      'help',
      'save',
      // Indian Farm Keywords
      'farm',
      'farming',
      'farmer',
      'kisan',
      'kheti',
      'crop',
      'crops',
      'harvest',
      'seed',
      'seeds',
      'soil',
      'irrigation',
      'monsoon',
      'kharif',
      'rabi',
      'zaid',
      'wheat',
      'rice',
      'paddy',
      'cotton',
      'sugarcane',
      'maize',
      'millet',
      'bajra',
      'jowar',
      'pulses',
      'dal',
      'vegetables',
      'fruits',
      'mango',
      'banana',
      'potato',
      'onion',
      'tomato',
      'fertilizer',
      'urea',
      'pesticide',
      'organic',
      'compost',
      'vermicompost',
      'manure',
      'cattle',
      'cow',
      'buffalo',
      'goat',
      'poultry',
      'dairy',
      'milk',
      'tractor',
      'plough',
      'sowing',
      'transplanting',
      'weeding',
      'harvesting',
      'threshing',
      'msp',
      'apmc',
      'mandi',
      'market',
      'loan',
      'credit',
      'insurance',
      'pmfby',
      'subsidy',
      'government',
      'scheme',
      'pmkisan',
      'drip',
      'sprinkler',
      'tubewell',
      'borewell',
      'groundwater',
      'canal',
      'pond',
      'rainwater',
      'mulching',
      'intercropping',
      'rotation',
      'agroforestry',
      'permaculture',
      'hydroponics',
      'polyhouse',
      'cold storage',
      'warehouse',
      'fpo',
      'cooperative',
      'land',
      'acre',
      'hectare',
      'bigha',
      'yield',
      'production',
      'productivity',
      'income',
      'profit',
      'loss',
      'debt',
      'stubble',
      'burning',
      'residue',
      'pest',
      'disease',
      'locust',
      'weed',
      'horticulture',
      'floriculture',
      'sericulture',
      'apiculture',
      'fishery',
      'aquaculture',
      'mushroom',
      'spices',
      'turmeric',
      'ginger',
      'chilli',
      'tea',
      'coffee',
      'coconut',
      'cashew',
      'arecanut',
      'rubber',
      'jute',
      'oilseeds',
      'groundnut',
      'mustard',
      'soybean',
      'sunflower'
    };

    for (var word in words) {
      if (importantWords.contains(word)) {
        keywords.add(word);
      }
    }

    return keywords;
  }

  String _determineIntent(String query, List<String> keywords) {
    // Detect crop name for phenological analysis
    final cropName = _detectCropName(query, keywords);
    if (cropName != null) {
      if (query.contains('stage') ||
          query.contains('growth') ||
          query.contains('phase') ||
          query.contains('cycle')) {
        return 'phenology_$cropName';
      }

      if (query.contains('weather') ||
          query.contains('climate') ||
          query.contains('rain') ||
          query.contains('heat') ||
          query.contains('frost') ||
          query.contains('impact')) {
        return 'climate_impact_$cropName';
      }

      if (query.contains('region') ||
          query.contains('state') ||
          query.contains('production') ||
          query.contains('variety') ||
          query.contains('yield')) {
        return 'regional_$cropName';
      }

      if (query.contains('disease') ||
          query.contains('pest') ||
          query.contains('problem') ||
          query.contains('affected')) {
        return 'disease_$cropName';
      }
    }

    // Question patterns
    if (query.contains('what is') || query.contains('what are')) {
      return 'definition';
    }
    if (query.contains('how') &&
        (query.contains('work') || query.contains('happen'))) {
      return 'explanation';
    }
    if (query.contains('why')) return 'reason';
    if (query.contains('when')) return 'timeline';
    if (query.contains('where')) return 'location';
    if (query.contains('can i') ||
        query.contains('how can') ||
        query.contains('what can')) {
      return 'action';
    }

    // Topic detection
    if (keywords.contains('temperature') || keywords.contains('warming')) {
      return 'temperature';
    }
    if (keywords.contains('emissions') ||
        keywords.contains('carbon') ||
        keywords.contains('co2')) {
      return 'emissions';
    }
    if (keywords.contains('renewable') ||
        keywords.contains('solar') ||
        keywords.contains('wind')) {
      return 'renewable_energy';
    }
    if (keywords.contains('ice') ||
        keywords.contains('melt') ||
        keywords.contains('sea')) {
      return 'ice_melt';
    }
    if (keywords.contains('ocean')) return 'ocean';
    if (keywords.contains('deforestation') || keywords.contains('forest')) {
      return 'deforestation';
    }
    if (keywords.contains('recycle') ||
        keywords.contains('waste') ||
        keywords.contains('plastic')) {
      return 'waste';
    }
    if (keywords.contains('species') ||
        keywords.contains('extinction') ||
        keywords.contains('biodiversity')) {
      return 'biodiversity';
    }
    if (keywords.contains('weather') || query.contains('extreme')) {
      return 'extreme_weather';
    }

    // Indian Farm Topics
    if (keywords.contains('kharif') ||
        keywords.contains('rabi') ||
        keywords.contains('zaid') ||
        (query.contains('season') &&
            (keywords.contains('crop') || keywords.contains('farming')))) {
      return 'crop_seasons';
    }
    if (keywords.contains('rice') ||
        keywords.contains('paddy') ||
        keywords.contains('wheat') ||
        keywords.contains('maize') ||
        keywords.contains('millet') ||
        keywords.contains('bajra') ||
        keywords.contains('jowar')) {
      return 'food_crops';
    }
    if (keywords.contains('cotton') ||
        keywords.contains('sugarcane') ||
        keywords.contains('jute') ||
        keywords.contains('rubber') ||
        keywords.contains('tea') ||
        keywords.contains('coffee')) {
      return 'cash_crops';
    }
    if (keywords.contains('pulses') ||
        keywords.contains('dal') ||
        keywords.contains('groundnut') ||
        keywords.contains('mustard') ||
        keywords.contains('soybean') ||
        keywords.contains('oilseeds')) {
      return 'pulses_oilseeds';
    }
    if (keywords.contains('vegetables') ||
        keywords.contains('potato') ||
        keywords.contains('onion') ||
        keywords.contains('tomato') ||
        keywords.contains('horticulture')) {
      return 'vegetables';
    }
    if (keywords.contains('fruits') ||
        keywords.contains('mango') ||
        keywords.contains('banana') ||
        keywords.contains('coconut') ||
        keywords.contains('cashew')) {
      return 'fruits';
    }
    if (keywords.contains('spices') ||
        keywords.contains('turmeric') ||
        keywords.contains('ginger') ||
        keywords.contains('chilli')) {
      return 'spices';
    }
    if (keywords.contains('irrigation') ||
        keywords.contains('drip') ||
        keywords.contains('sprinkler') ||
        keywords.contains('tubewell') ||
        keywords.contains('borewell') ||
        keywords.contains('canal')) {
      return 'irrigation';
    }
    if (keywords.contains('monsoon') ||
        (query.contains('rain') &&
            (keywords.contains('farm') || keywords.contains('crop')))) {
      return 'monsoon_farming';
    }
    if (keywords.contains('organic') ||
        keywords.contains('compost') ||
        keywords.contains('vermicompost') ||
        keywords.contains('manure') ||
        (query.contains('natural') && keywords.contains('farming'))) {
      return 'organic_farming';
    }
    if (keywords.contains('fertilizer') ||
        keywords.contains('urea') ||
        keywords.contains('pesticide')) {
      return 'fertilizers_pesticides';
    }
    if (keywords.contains('soil') ||
        query.contains('soil health') ||
        query.contains('soil testing')) {
      return 'soil_health';
    }
    if (keywords.contains('cattle') ||
        keywords.contains('cow') ||
        keywords.contains('buffalo') ||
        keywords.contains('goat') ||
        keywords.contains('dairy') ||
        keywords.contains('milk') ||
        keywords.contains('poultry')) {
      return 'livestock';
    }
    if (keywords.contains('msp') ||
        keywords.contains('apmc') ||
        keywords.contains('mandi') ||
        (keywords.contains('market') && keywords.contains('farm'))) {
      return 'msp_marketing';
    }
    if (keywords.contains('pmkisan') ||
        keywords.contains('pmfby') ||
        keywords.contains('subsidy') ||
        keywords.contains('scheme') ||
        (keywords.contains('government') && keywords.contains('farmer'))) {
      return 'govt_schemes';
    }
    if (keywords.contains('loan') ||
        keywords.contains('credit') ||
        keywords.contains('insurance') ||
        keywords.contains('debt')) {
      return 'farm_finance';
    }
    if (keywords.contains('stubble') ||
        keywords.contains('burning') ||
        keywords.contains('residue')) {
      return 'stubble_management';
    }
    if (keywords.contains('pest') ||
        keywords.contains('disease') ||
        keywords.contains('locust') ||
        keywords.contains('weed')) {
      return 'pest_management';
    }
    if (keywords.contains('tractor') ||
        keywords.contains('plough') ||
        query.contains('farm equipment') ||
        query.contains('machinery')) {
      return 'farm_machinery';
    }
    if (keywords.contains('fpo') ||
        keywords.contains('cooperative') ||
        query.contains('farmer producer')) {
      return 'fpo_cooperatives';
    }
    if (keywords.contains('hydroponics') ||
        keywords.contains('polyhouse') ||
        query.contains('protected cultivation') ||
        query.contains('vertical farming')) {
      return 'modern_farming';
    }
    if (keywords.contains('agroforestry') ||
        keywords.contains('intercropping') ||
        keywords.contains('rotation') ||
        keywords.contains('permaculture')) {
      return 'sustainable_farming';
    }
    if (keywords.contains('fishery') ||
        keywords.contains('aquaculture') ||
        query.contains('fish farming')) {
      return 'fishery';
    }
    if (keywords.contains('apiculture') ||
        query.contains('bee') ||
        query.contains('honey')) {
      return 'apiculture';
    }
    if (keywords.contains('sericulture') || query.contains('silk')) {
      return 'sericulture';
    }
    if (keywords.contains('mushroom')) {
      return 'mushroom_farming';
    }
    if (keywords.contains('floriculture') || query.contains('flower')) {
      return 'floriculture';
    }
    if (keywords.contains('cold storage') ||
        keywords.contains('warehouse') ||
        query.contains('post harvest') ||
        query.contains('storage')) {
      return 'post_harvest';
    }
    if (keywords.contains('yield') ||
        keywords.contains('production') ||
        keywords.contains('productivity')) {
      return 'crop_productivity';
    }
    if (keywords.contains('farm') ||
        keywords.contains('farming') ||
        keywords.contains('farmer') ||
        keywords.contains('kisan') ||
        keywords.contains('kheti') ||
        keywords.contains('agriculture')) {
      return 'general_farming';
    }

    // Greeting
    if (query.contains('hello') ||
        query.contains('hi') ||
        query.contains('hey')) {
      return 'greeting';
    }

    // Help request
    if (query.contains('help') ||
        query.contains('save') ||
        query.contains('action')) {
      return 'action';
    }

    return 'general';
  }

  String? _detectCropName(String query, List<String> keywords) {
    final cropNames = ['onion', 'rice', 'wheat', 'cotton', 'potato'];

    for (var crop in cropNames) {
      if (query.contains(crop) || keywords.contains(crop)) {
        return crop;
      }
    }
    return null;
  }

  String _extractWeatherParameter(String query) {
    if (query.contains('rain') || query.contains('monsoon')) {
      return 'Excessive Rainfall';
    }
    if (query.contains('heat') ||
        query.contains('temperature') ||
        query.contains('warm')) {
      return 'Heatwave';
    }
    if (query.contains('frost') || query.contains('cold')) {
      return 'Frost';
    }
    if (query.contains('dry') || query.contains('drought')) {
      return 'Drought';
    }
    return 'Weather Event';
  }

  String _generateResponse(String intent, List<String> keywords, String query,
      List<Message> history) {
    if (intent.startsWith('phenology_')) {
      final cropName = intent.split('_')[1];
      final stage = _phenologyAnalyzer.detectPhenologicalStage(
        cropName,
        query,
        null,
      );
      if (stage != null) {
        return _phenologyAnalyzer.generatePhenologyReport(cropName, stage);
      }
    }

    if (intent.startsWith('climate_impact_')) {
      final cropName = intent.split('_')[2];
      final weatherParam = _extractWeatherParameter(query);
      final stage = _phenologyAnalyzer.detectPhenologicalStage(
        cropName,
        query,
        null,
      );
      return _phenologyAnalyzer.analyzeClimateImpact(
          cropName, weatherParam, stage);
    }

    if (intent.startsWith('regional_')) {
      final cropName = intent.split('_')[1];
      return _phenologyAnalyzer.getRegionalAdvice(cropName);
    }

    switch (intent) {
      case 'greeting':
        return _getRandomResponse([
          "Hello! I'm your Climate AI assistant. I'm here to help you understand climate change and what we can do about it. What would you like to know?",
          "Hi there! I specialize in climate change topics. Ask me anything about global warming, renewable energy, or how you can make a difference!",
          "Welcome! I'm passionate about helping people understand our climate crisis. How can I assist you today?",
        ]);

      case 'definition':
        if (keywords.contains('climate') && keywords.contains('change')) {
          return "Climate change refers to long-term shifts in global temperatures and weather patterns. While natural factors play a role, human activities—especially burning fossil fuels—have been the primary driver since the 1800s. This releases greenhouse gases like CO2 that trap heat in our atmosphere, warming the planet.";
        }
        if (keywords.contains('greenhouse') || keywords.contains('gas')) {
          return "Greenhouse gases are gases in Earth's atmosphere that trap heat. The main ones are carbon dioxide (CO2), methane (CH4), and nitrous oxide (N2O). They act like a blanket around Earth, keeping it warm enough for life—but too much creates dangerous warming.";
        }
        if (keywords.contains('global') && keywords.contains('warming')) {
          return "Global warming is the long-term heating of Earth's surface due to human activities, primarily fossil fuel burning. Since the pre-industrial period, Earth's average temperature has increased by about 1.1°C (2°F). This might sound small, but it's causing massive changes to our climate systems.";
        }
        return "Climate change involves complex interactions between our atmosphere, oceans, ice, and living things. Could you be more specific about what aspect you'd like to understand?";

      case 'temperature':
        return "Earth's average temperature has risen about 1.1°C since 1880, with most warming occurring in the past 40 years. Scientists predict we could see 1.5°C warming by 2030-2052 if current trends continue. Even small temperature increases cause significant impacts: melting ice, rising seas, and more extreme weather events.";

      case 'emissions':
        return "Carbon emissions from human activities have increased dramatically since the Industrial Revolution. We now emit about 36 billion tons of CO2 annually. The main sources are: burning fossil fuels for energy (75%), deforestation (10-15%), and agriculture (10%). Reducing these emissions is critical to limiting global warming.";

      case 'renewable_energy':
        return "Renewable energy sources like solar, wind, hydroelectric, and geothermal don't produce greenhouse gas emissions. Solar panels convert sunlight to electricity, wind turbines harness wind power, and both are becoming increasingly affordable. Transitioning to 100% renewable energy is one of our most important climate solutions. Countries like Iceland already run on nearly 100% renewable energy!";

      case 'ice_melt':
        return "Arctic sea ice is melting at an alarming rate—about 13% per decade. Greenland and Antarctica are losing ice mass, contributing to sea level rise. Since 1880, sea levels have risen about 21-24 cm (8-9 inches), and the rate is accelerating. This threatens coastal cities and island nations, potentially displacing hundreds of millions of people.";

      case 'ocean':
        return "Oceans absorb about 30% of human-produced CO2 and 90% of excess heat from global warming. This causes ocean acidification (harmful to coral and shellfish) and ocean warming (disrupting marine ecosystems). Warmer oceans also fuel stronger hurricanes and typhoons. Protecting our oceans is crucial for climate stability.";

      case 'deforestation':
        return "Forests are Earth's lungs—they absorb CO2 and produce oxygen. We're losing about 10 million hectares of forest annually, mostly in tropical regions. This releases stored carbon and eliminates CO2 absorption capacity. Deforestation contributes 10-15% of global emissions. Protecting and restoring forests is a powerful climate solution that also preserves biodiversity.";

      case 'waste':
        return "Reducing waste helps fight climate change! Here's how: 1) Recycle plastic, glass, and metal to save energy vs. making new materials. 2) Reduce single-use plastics—they're made from fossil fuels. 3) Compost food waste instead of sending it to landfills where it produces methane. 4) Buy less, choose reusable items, and repair things instead of replacing them.";

      case 'biodiversity':
        return "Climate change is driving a biodiversity crisis. Species are going extinct 1,000 times faster than the natural rate. As temperatures shift, animals and plants must migrate or adapt—many can't keep pace. Coral reefs, home to 25% of marine species, are dying from warming oceans. Protecting biodiversity helps ecosystems remain resilient and continue providing crucial services like clean air, water, and food.";

      case 'extreme_weather':
        return "Climate change is making extreme weather more frequent and severe. We're seeing: more intense hurricanes fueled by warmer oceans, longer and more severe droughts, devastating wildfires due to hotter, drier conditions, and intense flooding from heavier rainfall. These events cause loss of life, destroy infrastructure, and cost billions. Limiting warming can reduce these impacts.";

      case 'action':
        return _getActionResponse(query);

      // Indian Farm Topic Responses
      case 'crop_seasons':
        return "🌾 **Indian Crop Seasons:**\n\n**Kharif (Monsoon - June to October):**\n• Crops: Rice, Maize, Bajra, Jowar, Cotton, Sugarcane, Groundnut, Soybean\n• Sown with monsoon onset, harvested in autumn\n\n**Rabi (Winter - October to March):**\n• Crops: Wheat, Barley, Mustard, Gram, Peas, Lentils\n• Sown after monsoon, harvested in spring\n\n**Zaid (Summer - March to June):**\n• Crops: Watermelon, Muskmelon, Cucumber, Moong Dal\n• Short duration crops between Rabi harvest and Kharif sowing\n\nClimate change is shifting these traditional patterns, requiring farmers to adapt!";

      case 'food_crops':
        return "🍚 **Major Food Crops of India:**\n\n**Rice (धान):**\n• India's staple, grown in 43+ million hectares\n• Major states: West Bengal, UP, Punjab, Odisha\n• Requires 100-200 cm rainfall or irrigation\n\n**Wheat (गेहूं):**\n• Second most important crop\n• Major states: UP, Punjab, Haryana, MP\n• Rabi crop needing cool climate\n\n**Millets (मोटा अनाज):**\n• Bajra, Jowar, Ragi - drought resistant\n• Highly nutritious, climate-resilient\n• Government promoting as 'Shree Anna'\n\n**Maize (मक्का):**\n• Used for food, fodder, and industry\n• Karnataka, Maharashtra, Bihar lead production\n\nThese crops feed 1.4 billion Indians!";

      case 'cash_crops':
        return "💰 **Major Cash Crops of India:**\n\n**Cotton (कपास):**\n• India is world's largest producer\n• Gujarat, Maharashtra, Telangana lead\n• BT Cotton covers 95% area\n\n**Sugarcane (गन्ना):**\n• UP produces 50% of India's sugar\n• Needs 75-150 cm water, tropical climate\n• 12-18 months crop duration\n\n**Tea (चाय):**\n• Assam, West Bengal, Tamil Nadu\n• India is 2nd largest producer globally\n\n**Coffee (कॉफी):**\n• Karnataka produces 70% of Indian coffee\n• Arabica and Robusta varieties\n\n**Jute (पटसन):**\n• West Bengal dominates production\n• Called 'Golden Fiber'\n\nCash crops provide vital income but need careful market planning!";

      case 'pulses_oilseeds':
        return "🫘 **Pulses & Oilseeds in India:**\n\n**Pulses (दालें):**\n• India is largest producer & consumer\n• Types: Chana, Tur/Arhar, Moong, Urad, Masoor\n• Rich in protein (20-25%)\n• Fix nitrogen in soil naturally\n• MP, Maharashtra, Rajasthan lead production\n\n**Oilseeds (तिलहन):**\n• Groundnut: Gujarat, Rajasthan\n• Mustard: Rajasthan, UP, Haryana\n• Soybean: MP, Maharashtra\n• Sunflower: Karnataka, Maharashtra\n• Sesame: Gujarat, West Bengal\n\n**Government Initiatives:**\n• National Food Security Mission\n• PM-AASHA for price support\n• Yellow Revolution for oilseeds\n\nBoth are crucial for nutrition security!";

      case 'vegetables':
        return "🥬 **Vegetable Farming in India:**\n\n**Major Vegetables:**\n• Potato: UP, West Bengal, Bihar (largest producer)\n• Onion: Maharashtra, MP, Karnataka\n• Tomato: Andhra Pradesh, MP, Karnataka\n• Cauliflower & Cabbage: UP, MP, Odisha\n• Brinjal, Okra, Chilli across India\n\n**Horticulture Facts:**\n• India is 2nd largest vegetable producer\n• 180+ million tonnes annually\n• Provides employment to millions\n\n**Key Challenges:**\n• Price volatility (onion, tomato)\n• Cold storage shortage\n• Transportation losses (25-30%)\n\n**Tips for Farmers:**\n• Grow off-season vegetables in polyhouse\n• Adopt drip irrigation\n• Connect with FPOs for better prices\n• Consider contract farming";

      case 'fruits':
        return "🥭 **Fruit Farming in India:**\n\n**Major Fruits:**\n• **Mango**: King of fruits, 1500+ varieties, UP & AP lead\n• **Banana**: Tamil Nadu, Maharashtra, Gujarat\n• **Citrus**: Nagpur oranges, Coorg mandarins\n• **Grapes**: Maharashtra (Nashik), Karnataka\n• **Apple**: J&K, Himachal Pradesh, Uttarakhand\n• **Papaya**: Gujarat, AP, Karnataka\n• **Guava**: UP, Bihar, MP\n\n**Plantation Crops:**\n• Coconut: Kerala, Karnataka, Tamil Nadu\n• Cashew: Maharashtra, Goa, Kerala\n• Arecanut: Karnataka, Kerala\n\n**Opportunities:**\n• Export potential is huge\n• Value addition (juices, dried fruits)\n• High returns per hectare\n• Government subsidies available for orchard development";

      case 'spices':
        return "🌶️ **Spice Farming in India:**\n\nIndia is the 'Spice Bowl of the World'!\n\n**Major Spices:**\n• **Chilli**: Andhra Pradesh, Telangana, Karnataka\n• **Turmeric**: Telangana, Maharashtra, Tamil Nadu\n• **Ginger**: Kerala, Karnataka, Assam\n• **Black Pepper**: Kerala, Karnataka (King of Spices)\n• **Cardamom**: Kerala, Tamil Nadu (Queen of Spices)\n• **Cumin**: Gujarat, Rajasthan\n• **Coriander**: Rajasthan, MP, Gujarat\n\n**Facts:**\n• India produces 75 of 109 spices listed by ISO\n• Largest producer, consumer & exporter\n• Spices Board of India regulates exports\n\n**Climate & Cultivation:**\n• Most spices need tropical climate\n• Inter-cropping with other crops is common\n• Organic spices fetch premium prices";

      case 'irrigation':
        return "💧 **Irrigation in Indian Agriculture:**\n\n**Methods:**\n• **Surface Irrigation**: Canals, tanks, traditional\n• **Groundwater**: Tubewells, borewells (60% of irrigation)\n• **Drip Irrigation**: Water savings up to 70%\n• **Sprinkler**: Suitable for vegetables, groundnut\n\n**Major Irrigation Projects:**\n• Indira Gandhi Canal (Rajasthan)\n• Bhakra Nangal (Punjab/Haryana)\n• Hirakud Dam (Odisha)\n\n**Challenges:**\n• Only 48% farmland irrigated\n• Groundwater depletion critical\n• Power subsidies encourage overuse\n\n**Government Schemes:**\n• PM Krishi Sinchayee Yojana (PMKSY)\n• Per Drop More Crop\n• Micro Irrigation Fund\n\n**Tips:**\n• Adopt drip/sprinkler for water savings\n• Rainwater harvesting in farm ponds\n• Check water quality regularly";

      case 'monsoon_farming':
        return "🌧️ **Monsoon & Indian Farming:**\n\n**Monsoon Importance:**\n• 60% of India's farmland is rain-fed\n• Southwest Monsoon (June-September) brings 70% rainfall\n• Critical for Kharif crop sowing\n\n**Monsoon Patterns:**\n• Arrival: Kerala coast (June 1)\n• Advances across India by July 15\n• Withdrawal: September-October\n\n**Climate Change Impacts:**\n• Erratic rainfall patterns\n• Delayed monsoon onset\n• More extreme events (droughts/floods)\n• Shifting cropping windows\n\n**Farmer Strategies:**\n• Monitor IMD forecasts regularly\n• Prepare seeds before monsoon\n• Maintain farm drainage\n• Consider crop insurance (PMFBY)\n• Keep contingency crop plans\n• Rainwater harvesting structures";

      case 'organic_farming':
        return "🌿 **Organic Farming in India:**\n\n**What is Organic Farming?**\nFarming without synthetic fertilizers, pesticides using natural inputs.\n\n**Key Practices:**\n• **Composting**: Farm waste decomposition\n• **Vermicompost**: Using earthworms\n• **Green Manuring**: Dhaincha, Sesbania\n• **Bio-fertilizers**: Rhizobium, Azotobacter\n• **Bio-pesticides**: Neem, cow urine\n\n**Certification:**\n• PGS (Participatory Guarantee System) - groups\n• Third-party certification for exports\n\n**Government Support:**\n• Paramparagat Krishi Vikas Yojana (PKVY)\n• Mission Organic Value Chain (NE states)\n• ₹50,000/ha assistance available\n\n**Benefits:**\n• 20-30% premium prices\n• Better soil health long-term\n• Lower input costs\n• Export opportunities\n\n**States Leading:** Sikkim (100% organic), Uttarakhand, MP";

      case 'fertilizers_pesticides':
        return "🧪 **Fertilizers & Pesticides in India:**\n\n**Major Fertilizers:**\n• **Urea**: Most used, 46% Nitrogen, subsidized\n• **DAP**: Di-Ammonium Phosphate\n• **MOP**: Muriate of Potash (imported)\n• **NPK Complex**: Balanced nutrition\n\n**Government Subsidies:**\n• Urea heavily subsidized (₹242/bag MRP)\n• DBT for fertilizer subsidy\n• Neem-coated urea mandatory\n\n**Integrated Nutrient Management:**\n• Soil testing before application\n• Combine organic + chemical fertilizers\n• Micro-nutrients (Zinc, Boron) often deficient\n\n**Pesticide Safety:**\n• Use only recommended pesticides\n• Follow dosage instructions\n• Wear protective gear\n• Observe waiting period before harvest\n• Integrated Pest Management (IPM) preferred\n\n**Soil Health Card:**\n• Free soil testing by government\n• Get fertilizer recommendations\n• Available at KVK/agriculture offices";

      case 'soil_health':
        return "🌱 **Soil Health in Indian Agriculture:**\n\n**Soil Types in India:**\n• **Alluvial**: Indo-Gangetic plains (most fertile)\n• **Black/Regur**: Deccan (good for cotton)\n• **Red & Yellow**: Eastern/Southern India\n• **Laterite**: Heavy rainfall areas\n• **Desert**: Rajasthan (sandy)\n\n**Soil Health Issues:**\n• Declining organic carbon\n• Nutrient imbalances (excess N, low P/K)\n• Micronutrient deficiencies\n• Soil salinity/alkalinity\n\n**Soil Health Card Scheme:**\n• Free soil testing every 3 years\n• Recommendations for 12 parameters\n• Available via KVK, agriculture dept\n\n**Improving Soil Health:**\n• Add organic matter (compost, FYM)\n• Green manuring crops\n• Crop rotation with legumes\n• Avoid burning crop residue\n• Reduce tillage (zero tillage)\n• Apply lime for acidic soils\n• Gypsum for saline soils";

      case 'livestock':
        return "🐄 **Livestock & Dairy Farming in India:**\n\n**India's Livestock Wealth:**\n• Largest milk producer globally (220+ MT)\n• 300 million cattle & buffaloes\n• 150 million goats\n• 800 million poultry\n\n**Major Breeds:**\n• **Cows**: Gir, Sahiwal, Red Sindhi, Tharparkar\n• **Buffaloes**: Murrah, Mehsana, Jaffarabadi\n• **Goats**: Jamunapari, Beetal, Sirohi\n\n**Dairy Farming Tips:**\n• Balanced nutrition (green + dry fodder + concentrate)\n• Clean drinking water\n• Regular vaccination\n• Proper housing (ventilation, cleanliness)\n\n**Government Schemes:**\n• Rashtriya Gokul Mission\n• National Livestock Mission\n• Dairy Processing & Infrastructure Fund\n• NABARD dairy loans\n\n**Income Sources:**\n• Milk sales\n• Biogas from dung\n• Vermicompost\n• Organic manure";

      case 'msp_marketing':
        return "💹 **MSP & Agricultural Marketing:**\n\n**Minimum Support Price (MSP):**\n• Government announces MSP for 23 crops\n• Ensures minimum price to farmers\n• Based on production cost + 50% margin\n\n**MSP Crops (2024-25 examples):**\n• Paddy: ₹2,300/quintal\n• Wheat: ₹2,275/quintal\n• Mustard: ₹5,650/quintal\n• Cotton: ₹7,020/quintal (medium)\n\n**Selling Channels:**\n• **APMC Mandis**: Regulated markets\n• **e-NAM**: Online trading platform\n• **Private Markets**: After farm laws\n• **Direct Purchase**: FCI, state agencies\n• **FPOs**: Collective bargaining\n\n**Marketing Tips:**\n• Check daily mandi prices\n• Grade & sort produce\n• Store if prices are low\n• Join FPO for better negotiation\n• Use e-NAM for price discovery\n\n**Challenges:** Low MSP coverage, middlemen, storage issues";

      case 'govt_schemes':
        return "🏛️ **Government Schemes for Farmers:**\n\n**Income Support:**\n• **PM-KISAN**: ₹6,000/year direct transfer\n• **PM-AASHA**: Price support for pulses/oilseeds\n\n**Insurance:**\n• **PMFBY**: Crop insurance at 2% premium (Kharif)\n\n**Irrigation:**\n• **PMKSY**: Per Drop More Crop\n• Micro-irrigation subsidies (55-90%)\n\n**Credit:**\n• **KCC**: Kisan Credit Card (4% interest)\n• Interest subvention on crop loans\n\n**Infrastructure:**\n• **RKVY**: Rashtriya Krishi Vikas Yojana\n• Cold storage, warehouse subsidies\n\n**Soil & Seeds:**\n• Soil Health Card\n• Sub-Mission on Seeds\n\n**Organic:**\n• Paramparagat Krishi Vikas Yojana\n\n**Apply via:**\n• CSC centers\n• PM-KISAN portal\n• Agriculture dept office\n• Bank branches";

      case 'farm_finance':
        return "💳 **Farm Finance & Credit:**\n\n**Kisan Credit Card (KCC):**\n• Crop loans at 4% interest (with subvention)\n• Limit: Based on landholding\n• Covers crop + allied activities\n• Personal accident insurance included\n\n**Crop Loans:**\n• Short-term (up to 1 year)\n• Medium-term (1-5 years)\n• Long-term (equipment, land development)\n\n**PMFBY Crop Insurance:**\n• Premium: 2% Kharif, 1.5% Rabi\n• Covers yield losses, prevented sowing\n• Claim via bank/CSC\n\n**Sources of Credit:**\n• Commercial banks\n• Regional Rural Banks (RRBs)\n• Cooperative banks\n• NABARD refinance\n• Microfinance institutions\n\n**Avoiding Debt Trap:**\n• Borrow only as needed\n• Avoid informal moneylenders\n• Insure crops\n• Maintain repayment discipline\n• Diversify income sources";

      case 'stubble_management':
        return "🔥 **Stubble Burning & Management:**\n\n**The Problem:**\n• 20 million tonnes stubble burned annually\n• Major air pollution in North India\n• Loss of soil nutrients\n• Health hazards\n\n**Why Farmers Burn:**\n• Short window between crops (15-20 days)\n• High cost of removal\n• No profitable use\n\n**Alternatives to Burning:**\n• **Happy Seeder**: Direct sowing in stubble\n• **Mulching**: Spread on field for moisture\n• **Baling**: Sell to power plants, paper mills\n• **Composting**: Make organic manure\n• **Biogas**: Energy production\n• **Mushroom Cultivation**: Using straw\n\n**Government Support:**\n• Subsidy on machinery (50-80%)\n• Custom Hiring Centers\n• Ex-situ management (biomass plants)\n\n**Benefits of Retaining Stubble:**\n• Adds organic matter\n• Reduces irrigation need\n• Improves soil structure\n• Saves ₹2,000-3,000/acre fertilizer cost";

      case 'pest_management':
        return "🦗 **Pest & Disease Management:**\n\n**Common Pests:**\n• **Bollworm**: Cotton\n• **Stem Borer**: Rice, sugarcane\n• **Aphids**: Mustard, vegetables\n• **Fruit Fly**: Mango, guava\n• **Locusts**: Desert areas\n\n**Common Diseases:**\n• **Blast**: Rice\n• **Rust**: Wheat\n• **Wilt**: Pulses, cotton\n• **Blight**: Potato, tomato\n\n**Integrated Pest Management (IPM):**\n1. **Prevention**: Resistant varieties, crop rotation\n2. **Cultural**: Timely sowing, field hygiene\n3. **Biological**: Natural predators, bio-pesticides\n4. **Chemical**: Last resort, targeted spraying\n\n**Bio-Pesticides:**\n• Neem-based formulations\n• Trichoderma (fungal diseases)\n• Beauveria (insect control)\n• Pheromone traps\n\n**Safety Measures:**\n• Use recommended pesticides only\n• Follow dosage strictly\n• Spray in morning/evening\n• Wear protective equipment";

      case 'farm_machinery':
        return "🚜 **Farm Machinery & Equipment:**\n\n**Essential Equipment:**\n• **Tractor**: 35-50 HP for small/medium farms\n• **Power Tiller**: For small landholdings\n• **Rotavator**: Soil preparation\n• **Seed Drill**: Precision sowing\n• **Sprayer**: Pesticide application\n• **Harvester**: Combine for wheat/rice\n\n**Government Subsidies:**\n• 25-50% on most equipment\n• Higher for SC/ST, women farmers\n• Apply through agriculture dept\n\n**Custom Hiring Centers (CHC):**\n• Rent equipment at affordable rates\n• Reduces individual investment\n• FPO-run CHCs available\n\n**Buying Tips:**\n• Match HP to farm size\n• Check after-sales service\n• Compare fuel efficiency\n• Consider resale value\n\n**New Technologies:**\n• Drone spraying\n• GPS-guided tractors\n• Laser land leveler\n• Solar-powered equipment";

      case 'fpo_cooperatives':
        return "🤝 **FPOs & Cooperatives:**\n\n**What is FPO?**\nFarmer Producer Organization - company owned by farmers.\n\n**Benefits of Joining FPO:**\n• Collective bargaining power\n• Better prices for produce\n• Bulk input purchase (lower costs)\n• Access to credit & schemes\n• Training and technology\n\n**Government Support:**\n• 10,000 FPOs being formed\n• ₹15 lakh equity grant\n• ₹2 crore credit guarantee\n• NABARD & SFAC support\n\n**Successful Examples:**\n• Amul (dairy cooperative)\n• IFFCO (fertilizer cooperative)\n• Mahindra & Mahindra FPOs\n\n**How to Form/Join FPO:**\n• Minimum 300 farmers (plains), 100 (hills)\n• Register as Producer Company\n• Contact NABARD/SFAC/State dept\n\n**Cooperative Societies:**\n• PACS (credit)\n• Marketing societies\n• Dairy cooperatives\n• Service cooperatives";

      case 'modern_farming':
        return "🔬 **Modern Farming Techniques:**\n\n**Protected Cultivation:**\n• **Polyhouse/Greenhouse**: Year-round vegetable production\n• **Shade Net**: Reduced temperature, pest control\n• **Mulching**: Plastic/organic mulch for moisture\n\n**Hydroponics:**\n• Soil-less cultivation\n• 90% less water than conventional\n• Higher yields in less space\n• Suitable for urban farming\n\n**Precision Agriculture:**\n• Drone-based spraying & monitoring\n• Soil sensors for irrigation\n• GPS-guided farm equipment\n• Variable rate application\n\n**Vertical Farming:**\n• Multi-layer cultivation\n• LED lighting\n• Climate-controlled\n\n**Government Subsidies:**\n• 50-90% on polyhouse\n• Mission for Integrated Development of Horticulture\n• State horticulture missions\n\n**Crops Suitable:**\n• Capsicum, tomato, cucumber\n• Exotic vegetables, flowers\n• Leafy greens, herbs";

      case 'sustainable_farming':
        return "♻️ **Sustainable Farming Practices:**\n\n**Crop Diversification:**\n• Don't depend on single crop\n• Mix cereals, pulses, vegetables\n• Reduces risk & improves income\n\n**Crop Rotation:**\n• Cereal → Legume → Vegetable\n• Breaks pest cycles\n• Improves soil fertility naturally\n\n**Intercropping:**\n• Grow 2+ crops together\n• Sugarcane + Potato, Maize + Pulses\n• Better land use efficiency\n\n**Agroforestry:**\n• Trees + crops on same land\n• Poplar, Eucalyptus with wheat\n• Additional income from timber\n\n**Conservation Agriculture:**\n• Minimum tillage\n• Permanent soil cover\n• Crop rotation\n\n**Natural Farming:**\n• Zero Budget Natural Farming (ZBNF)\n• Jeevamrutha, Beejamrutha\n• Pioneered in Andhra Pradesh\n\n**Climate-Smart Agriculture:**\n• Drought-tolerant varieties\n• Water-efficient irrigation\n• Weather-based advisories";

      case 'fishery':
        return "🐟 **Fishery & Aquaculture:**\n\n**Types:**\n• **Inland Fishery**: Rivers, ponds, reservoirs\n• **Marine Fishery**: Sea fishing\n• **Aquaculture**: Fish farming in ponds\n\n**Major Fish Species:**\n• **Carps**: Rohu, Catla, Mrigal (Indian major carps)\n• **Catfish**: Singhi, Magur\n• **Prawns/Shrimp**: Coastal areas\n• **Tilapia**: Fast-growing\n\n**Fish Farming Steps:**\n1. Pond construction (0.1-1 hectare)\n2. Water quality management\n3. Stocking fingerlings\n4. Feeding (natural + supplementary)\n5. Harvesting (6-12 months)\n\n**Government Schemes:**\n• PM Matsya Sampada Yojana\n• Blue Revolution\n• KCC for fishermen\n\n**Income Potential:**\n• ₹3-5 lakh/hectare/year\n• Can integrate with agriculture (rice-fish)\n\n**Leading States:** Andhra Pradesh, West Bengal, Gujarat";

      case 'apiculture':
        return "🐝 **Apiculture (Beekeeping):**\n\n**Why Beekeeping?**\n• Honey production\n• Beeswax, royal jelly, propolis\n• Pollination services (increases crop yield 25%)\n• Low investment, high returns\n\n**Bee Species:**\n• **Apis Cerana**: Indian bee, easy to manage\n• **Apis Mellifera**: Italian bee, high honey yield\n• **Apis Dorsata**: Rock bee, wild\n\n**Getting Started:**\n• Start with 10-20 colonies\n• Place near flowering crops/forests\n• Bee boxes cost ₹3,000-5,000 each\n\n**Honey Yield:**\n• 15-20 kg/colony/year (Cerana)\n• 25-40 kg/colony/year (Mellifera)\n\n**Government Support:**\n• National Beekeeping & Honey Mission\n• Training through KVKs\n• Subsidy on bee boxes\n\n**Best Locations:** Sundarban, Himalayan foothills, Western Ghats\n\n**Income:** ₹1-2 lakh/year from 50 colonies";

      case 'sericulture':
        return "🦋 **Sericulture (Silk Farming):**\n\n**What is Sericulture?**\nRearing silkworms for silk production.\n\n**Types of Silk:**\n• **Mulberry Silk**: 70% of production (Karnataka)\n• **Tasar Silk**: Wild silk (Jharkhand, Chhattisgarh)\n• **Eri Silk**: Assam, Meghalaya\n• **Muga Silk**: Golden silk, only in Assam\n\n**Process:**\n1. Mulberry plantation\n2. Silkworm rearing (25-30 days)\n3. Cocoon formation\n4. Reeling/spinning silk thread\n\n**Investment & Returns:**\n• 1 acre mulberry needed\n• 5-6 crops per year possible\n• ₹50,000-1 lakh/acre/year income\n\n**Government Support:**\n• Central Silk Board training\n• Subsidy on mulberry plantation\n• Cluster development programs\n\n**Leading States:** Karnataka, Andhra Pradesh, Tamil Nadu, Assam\n\n**Tip:** Combine with other farming activities for best returns";

      case 'mushroom_farming':
        return "🍄 **Mushroom Farming:**\n\n**Popular Varieties:**\n• **Oyster Mushroom**: Easiest, year-round\n• **Button Mushroom**: Needs temperature control\n• **Paddy Straw Mushroom**: Summer crop\n• **Milky Mushroom**: Tropical climates\n\n**Requirements:**\n• Shade/room (can use thatched hut)\n• Substrate (paddy straw, wheat straw)\n• Spawn (seeds) - ₹100/kg\n• Humidity 80-90%\n\n**Investment:**\n• Small scale: ₹10,000-25,000\n• Uses agricultural waste\n• No land required\n\n**Production Cycle:**\n• Oyster: 45-60 days\n• 1 kg spawn → 10-15 kg mushrooms\n\n**Income Potential:**\n• ₹200-300/kg retail price\n• ₹50,000-1 lakh/year (small scale)\n\n**Markets:**\n• Hotels, restaurants\n• Supermarkets\n• Direct consumer sales\n\n**Training:** Available at KVKs, agriculture universities";

      case 'floriculture':
        return "💐 **Floriculture (Flower Farming):**\n\n**Major Flowers:**\n• **Marigold**: Easy, high demand (festivals)\n• **Rose**: Throughout year, good returns\n• **Jasmine**: Tamil Nadu, Karnataka\n• **Tuberose**: Fragrant, perfume industry\n• **Gladiolus**: Cut flowers\n• **Chrysanthemum**: Winter bloom\n\n**Cultivation Methods:**\n• Open field cultivation\n• Polyhouse/greenhouse (premium flowers)\n• Pot cultivation\n\n**Markets:**\n• Temple/religious markets\n• Weddings, functions\n• Export (rose, carnation)\n• Essential oil extraction\n\n**Investment & Returns:**\n• Marigold: ₹40,000-60,000/acre profit\n• Rose: ₹1-2 lakh/acre/year\n• Jasmine: ₹1.5-2 lakh/acre/year\n\n**Government Support:**\n• NHB subsidies\n• State horticulture missions\n• Export promotion\n\n**Leading States:** Tamil Nadu, Karnataka, West Bengal, Maharashtra";

      case 'post_harvest':
        return "🏭 **Post-Harvest Management:**\n\n**Losses in India:**\n• 25-30% of fruits/vegetables wasted\n• 5-7% of food grains lost\n• Annual loss: ₹90,000+ crore\n\n**Storage Solutions:**\n• **Warehouse**: Grain storage (regulated)\n• **Cold Storage**: Fruits, vegetables\n• **CA Storage**: Controlled atmosphere\n• **Traditional**: Metal bins, mud structures\n\n**Government Infrastructure:**\n• Warehouse Development & Regulatory Authority\n• Gramin Bhandaran Yojana (subsidy)\n• Integrated Cold Chain\n\n**Processing Options:**\n• Primary: Cleaning, grading, packaging\n• Secondary: Pulping, drying, freezing\n• Tertiary: Ready-to-eat products\n\n**Tips:**\n• Harvest at right maturity\n• Avoid mechanical damage\n• Sort & grade before storage\n• Use proper packaging\n• Monitor temperature/humidity\n\n**e-NAM Warehouse:** Pledge finance available against stored produce";

      case 'crop_productivity':
        return "📈 **Improving Crop Productivity:**\n\n**Current Yields (India vs World):**\n• Rice: 4 t/ha (China: 7 t/ha)\n• Wheat: 3.5 t/ha (France: 8 t/ha)\n• Huge scope for improvement!\n\n**Key Factors:**\n\n**1. Quality Seeds:**\n• Use certified seeds\n• Replace every 3-4 years\n• Hybrid varieties for higher yield\n\n**2. Balanced Nutrition:**\n• Soil testing first\n• Right NPK ratio\n• Micronutrients (Zn, B, S)\n\n**3. Water Management:**\n• Timely irrigation\n• Efficient methods (drip/sprinkler)\n• Avoid waterlogging\n\n**4. Pest Management:**\n• IPM approach\n• Timely intervention\n\n**5. Agronomic Practices:**\n• Proper spacing\n• Timely sowing\n• Weed control\n\n**Resources:**\n• KVK demonstrations\n• Agriculture university recommendations\n• Digital platforms (Kisan Suvidha app)";

      case 'general_farming':
        return "🌾 **Indian Agriculture Overview:**\n\nI can help you with many farming topics! Here's what I know:\n\n**Crops:**\n• Kharif, Rabi, Zaid seasons\n• Food crops (rice, wheat, millets)\n• Cash crops (cotton, sugarcane)\n• Fruits, vegetables, spices\n\n**Farming Practices:**\n• Organic & natural farming\n• Irrigation methods\n• Soil health management\n• Pest & disease control\n\n**Allied Activities:**\n• Dairy & livestock\n• Poultry, fishery\n• Beekeeping, mushroom farming\n\n**Support Systems:**\n• Government schemes (PM-KISAN, PMFBY)\n• MSP & marketing\n• FPOs & cooperatives\n• Farm credit & insurance\n\n**Modern Techniques:**\n• Polyhouse farming\n• Precision agriculture\n• Sustainable practices\n\nWhat specific topic would you like to know more about?";

      case 'reason':
        if (query.contains('important') || query.contains('matter')) {
          return "Climate change matters because it affects everything: our food, water, health, homes, and future. Rising temperatures, extreme weather, and sea level rise threaten billions of people. Ecosystems are collapsing, species are going extinct, and climate refugees are increasing. But there's hope—if we act now, we can still prevent the worst impacts and create a sustainable future.";
        }
        return "Climate change is primarily caused by human activities, especially burning fossil fuels for energy, transportation, and industry. This releases greenhouse gases that trap heat in our atmosphere. Deforestation, agriculture, and industrial processes also contribute significantly.";

      case 'timeline':
        return "Climate change began accelerating during the Industrial Revolution (1760s), but impacts have intensified since 1950. The past decade was the warmest on record. Scientists say we have until 2030 to cut emissions by 45% to limit warming to 1.5°C and avoid catastrophic impacts. Every year of delay makes the challenge harder—but it's not too late to act!";

      case 'explanation':
        return "The greenhouse effect works like this: sunlight enters Earth's atmosphere and warms the surface. Earth then releases this energy as heat. Greenhouse gases trap some of this heat, preventing it from escaping to space. This natural process keeps Earth habitable—but burning fossil fuels has increased these gases, trapping too much heat and causing global warming.";

      default:
        return _getGeneralResponse(keywords);
    }
  }

  String _getActionResponse(String query) {
    if (query.contains('reduce') || query.contains('lower')) {
      return "Great question! Here are effective ways to reduce your carbon footprint:\n\n🔋 Energy: Use LED bulbs, unplug devices, improve insulation\n🚗 Transport: Walk, bike, use public transit, or choose electric vehicles\n🍽️ Food: Eat less meat, reduce food waste, buy local\n♻️ Consumption: Reduce, reuse, recycle, avoid single-use plastics\n🌳 Support: Plant trees, support green businesses and policies\n\nEven small actions add up when millions take them!";
    }

    return "You can make a difference! Start with: 1) Reducing energy use at home, 2) Choosing sustainable transportation, 3) Eating less meat and more plants, 4) Reducing waste and recycling, 5) Supporting renewable energy and climate policies. Talk to friends and family—spreading awareness is powerful! Remember: individual actions matter, but we also need systemic change through policy and corporate responsibility.";
  }

  String _getGeneralResponse(List<String> keywords) {
    if (keywords.isEmpty) {
      return "I'm here to help you with climate change and Indian farming! You can ask me about:\n\n🌍 **Climate:**\n• Global warming & carbon emissions\n• Renewable energy solutions\n• How you can take action\n\n🌾 **Indian Farming:**\n• Crop seasons & major crops\n• Irrigation & soil health\n• Government schemes (PM-KISAN, PMFBY)\n• MSP & marketing\n• Organic farming\n• Livestock & dairy\n\nWhat would you like to know?";
    }

    return "That's an interesting topic! Could you be more specific? I can help with climate change science, Indian farming practices, government schemes for farmers, crop cultivation, or environmental actions.";
  }

  String _getRandomResponse(List<String> responses) {
    return responses[_random.nextInt(responses.length)];
  }
}

// Storage Service
class StorageService {
  static const String _messagesKey = 'climate_messages';

  Future<void> saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = messages.map((m) => jsonEncode(m.toJson())).toList();
    await prefs.setStringList(_messagesKey, jsonList);
  }

  Future<List<Message>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_messagesKey) ?? [];
    return jsonList.map((json) => Message.fromJson(jsonDecode(json))).toList();
  }

  Future<void> clearMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_messagesKey);
  }
}

// Chat Screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ClimateAI _climateAI = ClimateAI();
  final StorageService _storageService = StorageService();
  bool _isTyping = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadMessages();
    _sendWelcomeMessage();
  }

  Future<void> _loadMessages() async {
    final messages = await _storageService.loadMessages();
    if (messages.isNotEmpty) {
      setState(() => _messages.addAll(messages));
    }
  }

  void _sendWelcomeMessage() {
    if (_messages.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final welcomeMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: '''🌾 **Welcome to Climate & Kisan AI Assistant**

I'm your offline guide to climate change and Indian agriculture!

**Topics I Can Help With:**

**CLIMATE CHANGE:**
- Global warming & carbon emissions
- Renewable energy solutions
- Extreme weather events
- How you can take action

**INDIAN FARMING:**
- Crop seasons (Kharif, Rabi, Zaid)
- Major crops and their cultivation
- Irrigation & water management
- Soil health & organic farming
- Government schemes (PM-KISAN, PMFBY)
- MSP & agricultural marketing
- Pest management & diseases
- Farm machinery & modern techniques

**CROP ANALYSIS:**
- Phenological stages and growth cycles
- Climate impact on specific crops
- Regional production data
- Weather-related risks

Ask me anything! For example:
- "How will climate change affect my onions?"
- "What's the best irrigation method for wheat?"
- "Tell me about rice farming in West Bengal"
- "How do I reduce my carbon footprint?"''',
          isUser: false,
          timestamp: DateTime.now(),
        );
        setState(() => _messages.add(welcomeMessage));
        _storageService.saveMessages(_messages);
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isTyping) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _controller.text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();
    await _storageService.saveMessages(_messages);

    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));

    final response = _climateAI.processMessage(
      userMessage.content,
      _messages.sublist(0, _messages.length - 1),
    );

    final aiMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(aiMessage);
      _isTyping = false;
    });

    await _storageService.saveMessages(_messages);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text('Are you sure you want to delete all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storageService.clearMessages();
              setState(() => _messages.clear());
              if (mounted) Navigator.pop(context);
              _sendWelcomeMessage();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.eco, color: Colors.green),
            SizedBox(width: 8),
            Text('About This App'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Climate & Kisan AI is a comprehensive offline chatbot for climate change awareness and Indian agricultural guidance.\n\n'
            'Features:\n'
            '• No internet required\n'
            '• Real-time phenological stage detection\n'
            '• Climate impact analysis\n'
            '• Regional farming data\n'
            '• Government scheme information\n'
            '• Markdown-formatted responses\n\n'
            'Version 2.1 Enhanced UI',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, size: 24),
                SizedBox(width: 12),
                Text(
                  'Climate & Kisan AI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Offline Agricultural & Climate Guide',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
            tooltip: 'About',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _messages.isEmpty ? null : _clearChat,
            tooltip: 'Clear Chat',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return MarkdownMessageBubble(
                          message: _messages[index],
                        );
                      },
                    ),
            ),
            if (_isTyping) _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[100],
              ),
              child: Icon(Icons.eco, size: 80, color: Colors.green[600]),
            ),
            const SizedBox(height: 24),
            Text(
              'Climate & Kisan AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your offline guide to farming & climate action',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Topics:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickTopic('Crop Farming', 'Rice, Wheat, Onion...'),
                  _buildQuickTopic('Climate Change', 'Global warming effects'),
                  _buildQuickTopic('Government Schemes', 'PM-KISAN, PMFBY...'),
                  _buildQuickTopic('Pest Management', 'Disease & pest control'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTopic(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green[400],
            child: const Icon(Icons.eco, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Row(
                children: List.generate(3, (index) {
                  final delay = index * 0.2;
                  final value = (_animationController.value + delay) % 1.0;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3 + (value * 0.7)),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'AI is analyzing...',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about farming, crops, or climate...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.green[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: isDark ? Colors.green[700]! : Colors.green[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: Colors.green[400]!, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  suffixIcon: Icon(
                    Icons.eco_outlined,
                    color: Colors.green[400],
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isTyping,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.green[600],
              radius: 24,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _isTyping ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
