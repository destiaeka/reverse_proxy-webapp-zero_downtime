
<h1> High Availability WebApp & Zero Downtime </h1>

## 🏗️ Arsitektur Sistem
Client → Reverse Proxy (HAProxy/Nginx) → [Green App | Blue App] → Database
- Client: Mengakses App menggunakan IP/Domain reverse proxy
- Reverse Proxy: Trafic Switching
- Blue App/Green App: 2 versi App yang berbeda
- Database: Menyimpan data utama dan digunakan bersama oleh kedua environment. 

## 💡 Konsep Blue-Green Deployment
- Green App (v1): App yang aktif melayani client
- Blue App (v2): App yang sedang dipersiapkan dan diuji
- Apabila uji berhasil Reverse Proxy menggarahkan trafic ke Blue App

## 🧱 Konfigurasi & Deployment
1. **Setup Reverse Proxy**
   - Green App: 3001
   - Blue App: 3000
   - Reverse Proxy: 802
     
2. **Jalankan Environment**
   ``` docker-compose up -d ```
    Apabila ingin switch tampilan
   ``` bash switch.sh ```

## 🧩 Fitur Utama
- Zero Downtime Deployment
- Failover otomatis (jika satu instance down)
- Traffic Switching

