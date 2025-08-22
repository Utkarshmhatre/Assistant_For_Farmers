# FarmAssistX 🌾

## Empowering Farmers, Enriching Customers

FarmAssistX is a revolutionary Flutter-based mobile marketplace that bridges the gap between farmers and customers. By eliminating intermediaries, we ensure fair prices and create a transparent, efficient, and sustainable agricultural supply chain.

## 🌟 Key Features

### For Farmers
- **Detailed Profile Management**: Create and manage comprehensive profiles showcasing produce, pricing, and location
- **Smart Inventory Management**: Optimize stock levels using advanced algorithms
- **Route Optimization**: Efficient delivery planning based on multiple parameters
- **Weather Integration**: Smart mapping and algorithms to adapt delivery strategies based on weather conditions
- **Task & Schedule Planner**: Plan farm operations (sowing, irrigation, fertilizer, pesticide, harvest, market, veterinary, equipment maintenance) with notes/time, mark tasks done, and view by date
- **Real-time Order Management**: Instant notifications and order tracking
- **GPS-enabled Delivery System**: Streamlined delivery process with real-time tracking

### For Customers
- **Interactive Product Catalog**: Browse and purchase fresh produce directly from farmers
- **Real-time Order Tracking**: Monitor order status from harvest to delivery
- **Secure Payment Integration**: Safe and convenient payment processing
- **Rating & Review System**: Provide feedback and maintain quality standards
- **Push Notifications**: Stay updated with order status and delivery information

## App Screens & Features (Implemented)

- Home Dashboard: Animated, dark-themed landing with quick actions and upcoming features.
- Farmer Toolkit: Practical calculators and tips for farmers.
	- Seed Requirement: kg needed by area, seed rate, and germination %.
	- Fertilizer Planner: N–P2O5–K2O split using DAP, Urea, MOP.
	- Irrigation Water Need: Volume by area and application depth.
	- Profit Estimator: Revenue, cost, and estimated profit.
	- Quick Tips: Best practices for soil, irrigation, and cropping.
- AI Assistant: In-app chat powered by Google Gemini for guidance and Q&A.
- Weather: Current conditions to inform planning and logistics.
- Inventory/Warehouse: Manage stock and track items.
- Distribution/Map: Map screen to visualize sites and help plan routes.
- Payments: PhonePe SDK integration (sandbox) with animated UI and receipt dialog.
- Gallery/Products: Browse produce with images and details.
- Playlists: Curated educational or promotional videos.
- Events/Tasks Planner: Farmer-focused planner to track fieldwork.
	- Event types with icons/colors: sowing, irrigation, fertilizer, pesticide, harvest, market, veterinary, equipment, other
	- Quick add via bottom sheet: title, optional notes, optional time
	- Mark done/undo and delete tasks
	- Offline persistence using Shared Preferences
	- Calendar view powered by TableCalendar
- About Us: Project overview and benefits.

## 💪 Benefits

### Farmers
- Maximize profits by eliminating middlemen
- Access broader customer base beyond local markets
- Receive direct customer feedback for service improvement
- Smart inventory management with AI-powered optimization
- Efficient delivery routes with advanced algorithms
- Weather-aware delivery planning

### Customers
- Access to fresh, high-quality produce
- Competitive prices through direct farmer connection
- Complete transparency in the supply chain
- Real-time order tracking and updates

## 🛠️ Tech Stack

### Core Technologies
- **Frontend**: Flutter & Dart
- **Maps Integration**: OpenStreetMap & Apple Maps
- **Build System**: Gradle
- **Local Storage**: Shared Preferences

### Advanced Features
- **Machine Learning**: Random Forest algorithms for optimization
- **AI Support**: Google Generative AI (Gemini via `google_generative_ai`)
- **Payments**: PhonePe Payment SDK integration (sandbox)
- **Navigation**: Ultra-precise routing system
- **Additional Packages**: 12 specialized packages for enhanced functionality
- **Calendar & Scheduling**: Date-based task planning using `table_calendar`

## 🔄 What’s New (Aug 2025)
- Events/Tasks Planner
	- Added event types, notes and optional time fields
	- Mark done/undo and delete actions
	- Offline persistence with Shared Preferences
	- Calendar view (TableCalendar) with colored markers
	- Fixed overflow in the list area and improved search field contrast for dark mode
- App-wide Theming
	- Material 3 light/dark themes with high-contrast color scheme
	- Consistent chips, cards, inputs, and button styling via ThemeData
- Inventory/Warehouse
	- Images now display using safe asset/file avatar handling with graceful fallbacks
	- Seeded dummy products on first run to showcase features
	- Expanded Analytics: value and quantity by category charts, low stock and expiring soon lists, and top valuable products
	- Optimized charts with tooltips, grid lines, spacing, and better scaling

## 📱 Screenshots
[Coming Soon]

## 🚀 Getting Started

### Prerequisites
- Flutter (Latest Version)
- Dart SDK
- Android Studio / Xcode
- Git

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/FarmAssistX.git

# Navigate to project directory
cd FarmAssistX

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🤝 Contributing
We welcome contributions to FarmAssistX! Please read our contributing guidelines before submitting pull requests.

## 📄 License
This project is licensed under the [MIT License](LICENSE)

## 📞 Contact
- Project Lead - [Utkarsh Naresh Mhatre](mailto:utkarshmhatre434@gmail.com)
- Project Link: [https://github.com/Utkarshmhatre/Farm_AssistX](https://github.com/Utkarshmhatre/Farm_AssistX)

## 🙏 Acknowledgments

- The Flutter community for excellent tools and support
