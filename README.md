# Papapreco 📊

**PapaPreco** is a **Flutter** mobile application designed for collaborative price comparison. Users can manually add product prices or scan NFC-e QR codes to input items automatically. The app supports searching by product name, price range, or location, allowing consumers to make more informed purchasing decisions.

---

## ✨ Key Features

- **QR Code Scanning**: Scan NFC-e receipts to extract product details and prices  
- **Manual Entry**: Input product information manually (name, price, store, etc.)  
- **Search & Compare**: Search products by name, filter by price range or store  
- **Collaborative Database**: Aggregates price data from multiple users for better coverage  
- **Intuitive UI**: Designed for a smooth and straightforward user experience

---

## 🛠️ Technology Stack

| Component        | Technology                                  |
|------------------|---------------------------------------------|
| **Frontend**     | Flutter                                     |
| **Backend**       | [API](https://github.com/Juniorrek/papaprecoapi) (Java/Spring) |
| **Platform**      | Android (iOS compatibility planned)         |
| **Storage**       | PostgreSQL |

---

### Home Screen
![Home Screen](screenshots/papa1.PNG)

### Map view
![Scan Screen](screenshots/papa2.PNG)

### Searched Items
![Search Screen](screenshots/papa3.PNG)

---

## 🔗 Backend Dependency

This project **requires the backend service** available at:

👉 [https://github.com/Juniorrek/papaprecoapi](https://github.com/Juniorrek/papaprecoapi)

The backend handles product storage, search functionality, and NFC-e data parsing. Make sure the API is running and accessible (locally or remotely) for the mobile app to function correctly.


## 🚀 Getting Started

Follow these steps to run the app locally:

### Prerequisites

- Flutter SDK
- Android Studio or VS Code with Flutter and Dart plugins  
- Android emulator or connected device  

### Installation

```bash
git clone https://github.com/Juniorrek/papapreco.git
cd papapreco
flutter pub get
flutter run
```
