# Zenith AI - Project Structure

## Complete Folder Structure

```
zenith_ai/
├── android/                 # Android platform files
├── ios/                     # iOS platform files
├── lib/                     # Main application code
│   ├── app/
│   │   ├── core/           # Core app functionality
│   │   │   ├── constants/  # App constants and routes
│   │   │   │   ├── app_constants.dart
│   │   │   │   └── app_routes.dart
│   │   │   ├── theme/      # App theme and colors
│   │   │   │   ├── app_colors.dart
│   │   │   │   └── app_theme.dart
│   │   │   └── utils/      # Helper functions
│   │   │       └── helpers.dart
│   │   ├── data/           # Data layer
│   │   │   ├── models/     # Data models
│   │   │   │   └── user_model.dart
│   │   │   ├── repositories/ # Data repositories
│   │   │   │   └── auth_repository.dart
│   │   │   └── services/   # API and local services
│   │   │       ├── api/
│   │   │       │   ├── api_client.dart
│   │   │       │   └── api_endpoints.dart
│   │   │       └── local/
│   │   │           └── biometric_service.dart
│   │   ├── modules/        # Feature modules
│   │   │   ├── auth/       # Authentication module
│   │   │   │   ├── bindings/
│   │   │   │   │   └── auth_binding.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── auth_controller.dart
│   │   │   │   └── views/
│   │   │   │       └── login_view.dart
│   │   │   ├── dashboard/  # Dashboard module
│   │   │   │   ├── bindings/
│   │   │   │   │   └── dashboard_binding.dart
│   │   │   │   ├── controllers/
│   │   │   │   │   └── dashboard_controller.dart
│   │   │   │   └── views/
│   │   │   │       └── dashboard_view.dart
│   │   │   ├── overview/   # Overview screen
│   │   │   │   └── views/
│   │   │   │       └── overview_view.dart
│   │   │   ├── airtime/    # Airtime module
│   │   │   │   └── views/
│   │   │   │       └── airtime_view.dart
│   │   │   ├── zai/        # zAI module
│   │   │   │   └── views/
│   │   │   │       └── zai_view.dart
│   │   │   ├── transfer/   # Transfer module
│   │   │   │   └── views/
│   │   │   │       └── transfer_view.dart
│   │   │   └── bills/      # Bills module
│   │   │       └── views/
│   │   │           └── bills_view.dart
│   │   └── routes/         # App routing
│   │       └── app_pages.dart
│   ├── widgets/            # Reusable widgets
│   │   ├── buttons/
│   │   │   └── custom_button.dart
│   │   └── modals/
│   │       └── custom_modal.dart
│   └── main.dart           # App entry point
├── assets/                 # App assets
│   ├── images/             # Image assets
│   ├── icons/              # Icon assets
│   ├── animations/         # Animation files
│   └── fonts/              # Custom fonts
├── test/                   # Test files
├── pubspec.yaml            # Dependencies
└── README.md               # Project documentation
```

## Key Features

### 1. **Core Layer**
- **Constants**: App-wide constants and route definitions
- **Theme**: Color scheme and theme configuration (Primary: #E00605)
- **Utils**: Helper functions for formatting, validation, etc.

### 2. **Data Layer**
- **Models**: Data models (User, Transaction, etc.)
- **Repositories**: Data access layer
- **Services**: API client and local services (biometric, storage)

### 3. **Modules**
Each module follows the GetX pattern:
- **Controllers**: Business logic and state management
- **Views**: UI components
- **Bindings**: Dependency injection

### 4. **Widgets**
- **CustomButton**: Reusable button with multiple styles
- **CustomModal**: Custom modal and dialog widgets

### 5. **Routing**
- GetX routing for navigation
- Dashboard with bottom navigation
- 5 main menu items: Overview, Airtime, zAI, Transfer, Bills

## Color Scheme

- **Primary**: #E00605 (Zenith Red)
- **Background**: White/Light Grey
- **Text**: Black/Grey shades
- **Success**: Green
- **Error**: Red

## Dependencies

- **GetX**: State management and navigation
- **Dio**: HTTP client
- **Local Auth**: Biometric authentication
- **Get Storage**: Local storage
- **Intl**: Formatting utilities

## Next Steps

1. Implement API integration
2. Add transaction features
3. Complete zAI chat interface
4. Add bill payment functionality
5. Implement transfer features
6. Add account management

