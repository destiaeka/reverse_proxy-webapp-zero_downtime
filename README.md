<h1> High Availability WebApp & Zero Downtime </h1>

Client → Reverse Proxy (HAProxy/Nginx) → [Blue App | Green App] → Database

Jadi ada container Blue app dan Green App yang terhubung ke 1 database yang sama. lalu bisa switch tanpa ada waktu down. namun client akan akses reverse proxynya bukan langsung ke Node.js App

- Reverse Proxy
Client akan akses HA lalu diteruskan ke Node.js App
- Shared Database Postgresql
Blue & Green app terhubung ke database yang sama sehingga tampilan endpoint dari ke2 App akan sama. 
