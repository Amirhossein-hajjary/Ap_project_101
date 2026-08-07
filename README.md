# AP_Project

An online **Gallery/Photo Album** application built with a **Client–Server architecture**.

## 📋 Overview

- **Frontend:** Flutter (Dart)
- **Backend:** Java Multi-threaded Socket Server
- **Communication:** TCP Socket using a line-delimited JSON protocol
- **Default Port:** `5000`

---

# 🏗️ Project Structure

## Frontend (Flutter)

```
lib/
├── main.dart                     # Entry point, Provider initialization, authentication check
├── models/                       # Data models (User, Album, Image, Comment)
├── pages/
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── gallery_page.dart
│   ├── albums_page.dart
│   ├── albums_overview_page.dart
│   ├── album_details_page.dart
│   ├── photo_details_page.dart
│   ├── profile_page.dart
│   ├── search_page.dart
│   ├── upload_page.dart
│   ├── camera_or_local_page.dart
│   ├── test_connection_page.dart
│   └── main_scaffold.dart
├── providers/                    # State management using Provider
│   ├── auth_provider.dart
│   └── gallery_provider.dart
├── services/                     # Socket communication & authentication
│   ├── socket_service.dart
│   ├── auth_service.dart
│   └── local_auth_service.dart
├── themes/
│   ├── app_theme.dart
│   └── theme_provider.dart
└── widgets/
    ├── custom_text_field.dart
    ├── glass_container.dart
    ├── photo_image.dart
    └── pressable.dart
```

---

## Backend (Java)

```
src/main/java/
├── server/
│   ├── Server.java               # Main server (Port 5000, multi-threaded)
│   ├── ClientHandler.java        # Handles each client connection
│   ├── Request.java              # JSON request model
│   └── Response.java             # JSON response model
├── handlers/
│   ├── UserController.java
│   ├── AlbumController.java
│   └── GalleryController.java
├── database/
│   ├── UserDatabase.java
│   └── ImageStorage.java
├── models/                       # User, Admin, Album, Image, Comment models
└── admin/
    └── AdminPanel.java
```

---

# 🔌 Communication Protocol

The application communicates through a **raw TCP socket** using **JSON messages**, where each request and response is sent as **a single JSON object followed by a newline (`\n`)**.

---

## Client Request Format

```json
{
  "method": "GET|POST|PUT|DELETE",
  "username": "current_user",
  "route": "/path/to/endpoint",
  "payload": {
    ...
  }
}
```

---

## Server Response Format

```json
{
  "statusCode": 200,
  "message": "Success message",
  "payload": {
    ...
  }
}
```

### Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Invalid request or malformed JSON |
| 401 | Authentication failed |
| 404 | Route not found |

---

# 🚀 Features

## Authentication (Public Routes)

| Method | Route | Description |
|---------|-------|-------------|
| POST | `/user/signup/` | Register a new user |
| POST | `/user/login/` | User login |

---

## User Management (Authenticated)

| Method | Route |
|---------|------|
| PUT | `/user/changeUsername/` |
| PUT | `/user/changePassword/` |
| DELETE | `/user/deleteAccount/` |

---

## Album Management (Authenticated)

| Method | Route | Description |
|---------|-------|-------------|
| POST | `/album/create/` | Create a new album |
| GET | `/album/list/` | List user's albums |
| POST | `/album/upload/` | Upload an image |
| GET | `/album/getImage/` | Retrieve an image |
| PUT | `/album/addImageToAlbum/` | Add image to album |
| PUT | `/album/removeImageFromAlbum/` | Remove image from album |
| DELETE | `/album/delete/` | Delete an album |
| PUT | `/album/rename/` | Rename an album |

---

## Image Management (Authenticated)

| Method | Route |
|---------|------|
| DELETE | `/image/delete/` |
| PUT | `/image/like/` |
| POST | `/image/comment/add/` |
| PUT | `/image/commentable/set/` |

---

## Gallery

| Method | Route | Description |
|---------|-------|-------------|
| GET | `/gallery/list/` | Retrieve all public images |

---

## Health Check

| Method | Route | Response |
|---------|-------|----------|
| GET | `/ping` | `{"statusCode":200,"message":"pong","payload":null}` |

---

# ⚙️ Getting Started

## Backend (Java)

Compile and run the server:

```bash
cd src

javac -d bin src/main/java/server/Server.java

java -cp bin server.Server
```

The server starts listening on **port 5000**.

---

## Frontend (Flutter)

```bash
flutter pub get

flutter run
```

> **Note:**  
> The server IP address is configured in **`socket_service.dart`** (around line 16).  
> The default value is:

```text
192.168.1.54
```

Change it if your backend is running on another machine or IP.

---

# 🔐 Authentication

Every authenticated request must include a valid `username`.

The server validates the username against the `UserDatabase`.

If the user does not exist, the server returns:

```json
{
  "statusCode": 401,
  "message": "You should enter first",
  "payload": null
}
```

---

# 📦 Dependencies

## Flutter

- provider
- dart:io
- dart:async
- dart:convert

---

## Java

- Gson (`com.google.gson`) for JSON serialization/deserialization

---

# 📝 Development Notes

- Multi-threaded server architecture.
- Each client connection is handled in its own thread.
- Uses **raw TCP sockets**, not HTTP.
- Requests are sent sequentially through `SocketService`.
- Application state is managed with **Provider**.
- Supports dynamic theme switching.

---

# 🎨 Application Pages

| Page | Description |
|------|-------------|
| Login | User authentication |
| Register | New user registration |
| Gallery | Browse public images |
| Albums | Album management |
| Album Details | View album contents |
| Photo Details | View image, likes, and comments |
| Profile | User profile |
| Search | Search images/albums |
| Upload | Upload images |
| Camera or Local | Choose image source |
| Test Connection | Verify server connectivity |

---

# 📄 License

This project is licensed under the **MIT License**.
