# Budget Manager App

A professional Flutter budget management application built with **Clean Architecture**, **Riverpod state management**, and comprehensive testing.

## Features

### 1. Monthly Salary Management

- Set and update monthly salary/earnings
- Track total earnings and remaining balance
- View spending percentage with visual indicators

### 2. Budget Creation

- Create budgets for different categories (Food, Transport, Education, etc.)
- Allocate specific amounts to each category
- Budget allocation cannot exceed monthly salary
- Real-time budget tracking with progress indicators

### 3. Expense Tracking

- Add expenses to specific budget categories
- Expenses automatically reduce budget allocation
- Expenses impact both budget and monthly salary remaining balance
- View recent expense history with timestamps
- Optional descriptions for each expense

## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/          # Application constants
│   └── utils/             # Utility classes (currency formatting, etc.)
├── features/
│   ├── salary/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── datasources/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   ├── budget/            # Same structure as salary
│   ├── expense/           # Same structure as salary
│   └── home/              # Main dashboard
└── main.dart
```

### Layers:

1. **Domain Layer**: Business logic, entities, repository interfaces, and use cases
2. **Data Layer**: Repository implementations, data models, and data sources
3. **Presentation Layer**: Riverpod providers, UI pages, and widgets

## State Management

Uses **Riverpod 2.6+** for:

- Dependency injection
- State management
- Reactive programming
- Provider-based architecture

## Data Persistence

- **SharedPreferences** for local data storage
- JSON serialization for all data models
- Automatic data persistence across app restarts

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2+)
- Dart SDK (3.9.2+)

### Installation

1. **Install dependencies**

```bash
flutter pub get
```

2. **Generate test mocks**

```bash
flutter pub run build_runner build
```

3. **Run the app**

```bash
flutter run
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Dependencies

### Production Dependencies

- **flutter_riverpod** (^2.6.1): State management
- **shared_preferences** (^2.3.4): Local storage
- **uuid** (^4.5.1): Unique ID generation
- **equatable** (^2.0.7): Value equality
- **intl** (^0.20.1): Internationalization and formatting

### Development Dependencies

- **build_runner** (^2.4.15): Code generation
- **mockito** (^5.4.4): Testing mocks
- **flutter_lints** (^5.0.0): Linting rules

## Validation Rules

1. **Salary**: Must be >= 0
2. **Budget Allocation**:
   - Must be > 0
   - Total budgets cannot exceed monthly salary
3. **Expenses**:
   - Must be > 0
   - Cannot exceed remaining budget amount
   - Automatically reduces budget and salary

## License

This project is created as a demonstration of professional Flutter development practices.
