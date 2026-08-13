# Papapreco 📊

**PapaPreco** is a **Flutter** mobile application designed for collaborative price comparison. Users can manually add product prices or scan NFC-e QR codes to input items automatically. The app supports searching by product name, price range, or location, allowing consumers to make more informed purchasing decisions.

---

## ✨ Key Features

- **QR Code Scanning**: Scan NFC-e receipts to extract product details and prices  
- **Manual Entry**: Input product information manually (name, price, store, etc.)  
- **Search & Compare**: Search products by name, filter by price range or store  
- **Collaborative Database**: Aggregates price data from multiple users for better coverage  
- **Price Alerts**: Set a target price for a product and receive a push notification when someone reports it at or below that price  
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

## 📸 Screenshots

### Home Screen
![Home Screen](screenshots/papa1.PNG)

### Map view
![Map view](screenshots/papa2.PNG)

### Searched Items
![Search Screen](screenshots/papa3.PNG)

---

## 🚀 Getting Started

This app **requires** the
[backend API](https://github.com/Juniorrek/papaprecoapi), which handles product
storage, search and NFC-e parsing. It always talks to one, either a copy
running on your own machine or a live deployment.

### Prerequisites

- **Flutter 3.44.1 (stable)**, which bundles Dart 3.12.1.
- Android Studio or VS Code with Flutter and Dart plugins
- An Android emulator.

### Installation

```bash
git clone https://github.com/Juniorrek/papapreco.git
cd papapreco
flutter pub get
```

### Running against a local API

Start the API first. See
[papaprecoapi's README](https://github.com/Juniorrek/papaprecoapi#running):

```bash
cd ../papaprecoapi
cp .env.example .env   # once, then fill in real values
docker compose up --build
```

Then launch an emulator and run the app. 

```bash
flutter emulators                       # lists available emulators
flutter emulators --launch <emulator-id>
flutter run
```

### Running against a deployed API

Point it at whichever deployment
you have:

```bash
flutter run --dart-define=API_BASE_URL=https://your-deployment.example.org/papaprecoapi
```

### Configuration

The app has no environment settings committed to source. Everything environment-specific
is passed at build time with `--dart-define`:

| Define | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:8080/papaprecoapi` | Base URL of the backend, **including the scheme and the API's context path**. The default is the Android emulator's alias for the host machine, so a bare `flutter run` targets a locally running API. |
| `DEV_QRCODE_URL` | *(empty)* | Optional NFC-e URL used to pre-fill the "insert QR code" field during development, so you don't have to scan a real receipt on every run. Empty means no pre-fill. |

```bash
# Deployed environment, for a distributable release build
flutter build apk --dart-define=API_BASE_URL=https://your-deployment.example.org/papaprecoapi
```

---

## 📚 More

- [docs/ROADMAP.md](docs/ROADMAP.md): engineering roadmap covering
  infrastructure, testing strategy, and the reasoning behind each decision
- [docs/MAINTENANCE.md](docs/MAINTENANCE.md): dependency watch-list and
  upgrades deliberately not taken yet
