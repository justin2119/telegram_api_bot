# Telegram API Bot 🤖

A robust Telegram bot built with **Dart** and the **Teledart** library, structured using **Clean Architecture** for maximum maintainability and testability.

## 🏗️ Architecture
This project follows Clean Architecture principles, ensuring that the business logic is independent of external factors like the Telegram API or data sources.

### lib/ Structure
- **Core**: Cross-cutting concerns like network clients, error handling, and environment configurations.
- **Data Layer**:
  - `models/`: Data Transfer Objects (DTOs) for JSON parsing.
  - `repositories/`: Implementations of domain repository interfaces.
  - `datasources/`: Remote API clients (e.g., OpenWeatherMap, Telegram).
- **Domain Layer**:
  - `entities/`: Plain Dart objects representing core data.
  - `repositories/`: Abstract definitions for data operations.
  - `usecases/`: Business logic for handling specific bot commands or events.
- **Presentation Layer**:
  - `bot/`: Teledart command handlers, message listeners, and bot initialization logic.

## 🚀 Getting Started
1. Clone the repo.
2. Run `dart pub get`.
3. Create a `.env` file with your `TELEGRAM_TOKEN` and `WEATHER_API_KEY`.
4. Run the bot: `dart bin/main.dart`.

## 🛠️ Tech Stack
- **Language**: Dart
- **Telegram Library**: Teledart
- **API Requests**: Http or Dio
- **Architecture**: Clean Architecture
