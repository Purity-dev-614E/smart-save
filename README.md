# SmartSave - Financial Management App

SmartSave is a Flutter application designed to help users manage their savings goals and track their financial progress. The app features a clean, modern UI with Material Design principles and provides a comprehensive set of features for personal financial management.

![SmartSave App](https://via.placeholder.com/800x400?text=SmartSave+App)

## Features

### 1. Home Screen
- Display user savings goals in a visually appealing ListView
- Each goal card shows:
  - Goal name
  - Target amount
  - Current amount
  - Progress bar with color indicators
- Floating Action Button to add new savings goals

### 2. Savings Goal Creation
- Form with validation for creating new savings goals
- Input fields for goal name and target amount
- Automatic tracking of creation date

### 3. Savings Contributions
- Add contributions to existing savings goals
- Track deposit history
- Optional notes for each contribution

### 4. Withdrawals Management
- Make withdrawals from savings goals
- Validation to prevent exceeding available balance
- Track withdrawal history

### 5. Transaction History
- Comprehensive transaction history view
- Filter by deposits and withdrawals
- Detailed transaction information including date, amount, and notes

## Project Structure

```
lib/
├── models/              # Data models
│   ├── savings_goal.dart
│   └── transaction.dart
├── providers/           # State management
│   └── savings_provider.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── create_goal_screen.dart
│   ├── goal_detail_screen.dart
│   ├── contribution_screen.dart
│   ├── withdrawal_screen.dart
│   └── transaction_history_screen.dart
├── services/            # Backend services
│   ├── firebase_service.dart
│   └── mock_firebase_service.dart
├── widgets/             # Reusable UI components
│   ├── goal_card.dart
│   ├── transaction_list_item.dart
│   └── amount_input.dart
└── main.dart            # App entry point
```

## Technical Implementation

### State Management
The app uses the Provider package for state management, making it easy to manage and update the UI based on data changes.

### Firebase Integration
The app uses Firebase for data storage and authentication:
- Firestore for storing savings goals and transactions
- Firebase Authentication for user management (anonymous auth for now)
- Real-time data synchronization

### Responsive Design
The UI is designed to be responsive and work well on different screen sizes and orientations.

### Form Validation
All forms include validation to ensure data integrity and provide feedback to users.

## Getting Started

### Prerequisites
- Flutter SDK (version 3.7.0 or higher)
- Dart SDK (version 3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/smart_save.git
cd smart_save
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Future Enhancements

- Full user authentication with email/password and social login
- User profiles and settings
- Data visualization with charts and graphs
- Budget planning features
- Recurring transactions
- Export functionality for financial reports
- Dark mode support
- Localization for multiple languages

## Dependencies

- `provider`: ^6.1.1 - For state management
- `intl`: ^0.19.0 - For date and currency formatting
- `percent_indicator`: ^4.2.3 - For progress indicators
- `google_fonts`: ^6.1.0 - For typography
- `flutter_animate`: ^4.5.0 - For animations
- `uuid`: ^4.3.3 - For generating unique IDs

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI inspiration
- The open-source community for valuable packages
