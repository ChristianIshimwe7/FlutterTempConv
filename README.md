# 🌡️ Temperature Converter App

A simple and user-friendly Flutter application that converts temperatures between Fahrenheit and Celsius. Designed with clear UI, input validation, state management, and conversion history.

## 📱 Features

- 🔄 Convert between Fahrenheit and Celsius
- ✅ Input validation and error handling
- 💾 Conversion history with scrollable list
- 🧠 Stateful widget using `setState` for UI updates
- 📋 Copy results to clipboard
- 🎨 Clean and responsive UI with animated result display
- 🗑️ Clear history button

---

## 🧠 Project Architecture

This application follows a **stateful widget architecture** with clean separation of logic and UI components inside a single file for simplicity.

- `main()` – Entry point
- `MyApp` – Stateless widget for setting theme and home page
- `TemperatureConverter` – Stateful widget containing:
  - `TextField` for input
  - `DropdownButton` for selecting conversion direction
  - `ElevatedButton` for triggering conversion
  - `AnimatedOpacity` for result
  - `ListView` for history
  - `IconButton` for copying results

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- An IDE like **VS Code** or **Android Studio**

### Run the App

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/temp-converter-flutter.git
   cd temp-converter-flutter

🧪 Usage
1. Enter a temperature value.

2. Choose the conversion type from the dropdown.

3. Tap the Convert button
