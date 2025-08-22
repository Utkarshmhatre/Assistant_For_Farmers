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

## App Screens & Features

### Splash & Onboarding
- Branded splash with smooth transition into the app.
- First-run seeding for demo content where applicable.

### Home Dashboard
- Animated, dark-optimized landing with quick-action cards.
- Highlights key modules (Inventory, Tasks, Weather, Payments).
- Helpful tips and entry points to farmer tools.

### Farmer Toolkit
- Compact utilities to speed up field decisions:
	- Seed Requirement: kg by area, seed rate, germination %.
	- Fertilizer Planner: N–P2O5–K2O split using DAP, Urea, MOP.
	- Irrigation Water Need: Volume by area and application depth.
	- Profit Estimator: Revenue, cost, and estimated profit.
	- Quick Tips: Practical guidance for soil, irrigation, and cropping.

### Inventory / Warehouse
- Unified with the app theme (Material 3 ColorScheme) for readable light/dark UI.
- Product management: add, edit, delete with category selection.
- Image handling: pick from gallery; images are copied to app documents directory for persistence and displayed reliably.
- Search and sort: by name, quantity, and expiry date.
- Overview: capacity indicator, expiring-soon alerts, and quick tips.
- Analytics dashboard (farmer-centric):
	- Inventory value by category (bar chart) and category distribution (pie/bar toggle)
	- Low stock alerts (<= 10) and Expiring soon (14 days)
	- Top value items and Average shelf-life by category (progress bars)
	- Themed charts and labels optimized for readability and performance

### Events & Tasks Planner
- Plan sowing, irrigation, fertilizer, pesticide, harvest, market, veterinary, equipment, and other tasks.
- Quick-add via bottom sheet with title, notes, optional time.
- Mark done/undo, edit, and delete actions.
- Offline persistence using Shared Preferences.
- Calendar view powered by TableCalendar with colored markers.

### Distribution / Map
- Visualize locations and navigate to planning views.
- Location-aware features using Geolocator; optimized dark map styling.
- Designed to assist with route planning and site visits.

### Weather
- Current conditions to inform planning and logistics.
- Uses clear, contrast-friendly visualizations aligned with the app theme.

### AI Assistant
- In-app chat powered by Google Gemini for guidance and Q&A.
- Helpful summaries and suggestions tailored for farming workflows.

### Payments
- PhonePe SDK (sandbox) with animated UI and receipt dialog.
- Clear success/failure feedback and optional share/print flow.

### Gallery / Products
- Browse produce and marketing visuals with clean, responsive layouts.
- Fast image loading and graceful fallbacks.

### Playlists
- Curated educational and promotional videos.
- Lightweight player controls and smooth switching.

### About Us
- Project overview, goals, and benefits for both farmers and customers.

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
- **File Storage**: path_provider + path (for persistent product images)
- **Charting**: fl_chart (analytics)

### Advanced Features
- **Machine Learning**: Random Forest algorithms for optimization
- **AI Support**: Google Generative AI (Gemini via `google_generative_ai`)
- **Payments**: PhonePe Payment SDK integration (sandbox)
- **Navigation**: Ultra-precise routing system
- **Additional Packages**: 12 specialized packages for enhanced functionality
- **Calendar & Scheduling**: Date-based task planning using `table_calendar`

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
