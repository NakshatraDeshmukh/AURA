<div align="center">

# 🟣 AURA – AI-Powered Women Safety Application  
### *Smart • Agentic • Context-Aware • Offline-Capable*

[![Flutter](https://img.shields.io/badge/Flutter-3.0-blue)]()
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange)]()
[![Python](https://img.shields.io/badge/Python-Agentic%20Logic-blueviolet)]()

AURA is an advanced **AI-driven safety system** that predicts danger, monitors user context, and autonomously triggers emergency responses — even in **no-network zones**.

</div>

---

## 🚨 **Why AURA?**
Safety apps today rely on **manual activation**.  
AURA goes beyond — it uses **Agentic AI**, **offline intelligence**, and **automatic escalation** to proactively protect users.

---

## ⭐ **Key Features**

### 🧠 1. Agentic AI Safety Engine
- Computes **Online** & **Offline** safety probability  
- Monitors GPS, mic triggers, network level, motion, and power-button presses  
- Predicts danger and **acts autonomously**  
- Escalates alerts if the user is unresponsive  

### 📴 2. Works in No-Network / Low-Network Zones
- Offline probability engine  
- Stores emergency packets locally  
- Auto-sends alerts when network returns  
- Cloud detects missing heartbeats  

### 🆘 3. Emergency Activation Modes
- Triple power-button press  
- SOS button (tap & long-press)  
- Secret phrase detection  
- Sudden movement stop  
- Route deviation  

### 🗺️ 4. Location Awareness
- Live GPS tracking  
- Last-known location  
- Safe zone suggestions  
- “Entering low-network area” warnings  

### 👨‍👩‍👧 5. Trusted Contact System
- SMS / WhatsApp / Email alerts  
- Multi-level escalation  
- Includes map link + timestamp + risk score  

### 🔐 6. Secure User Management
- Firebase Auth  
- Firestore profile storage  
- Password reset  
- Auto login  

---

## 🏗️ **System Architecture**

             ┌───────────────────────────┐
             │         Mobile App         │
             │     (Flutter + Kotlin)     │
             │  - SOS Triggers            │
             │  - GPS / Network Monitor   │
             │  - Offline Risk Engine     │
             └──────────────┬─────────────┘
                            │
                (Heartbeat + Data Sync)
                            │
             ┌──────────────┴─────────────┐
             │         Cloud Layer         │
             │   Firebase Auth + Firestore │
             │   - User Data               │
             │   - Heartbeat Watchdog      │
             └──────────────┬─────────────┘
                            │
            (Agentic Planning + Decisions)
                            │
             ┌──────────────┴─────────────┐
             │      Agentic AI Backend     │
             │        (Python Logic)       │
             │   - Risk Modeling           │
             │   - Alert Escalation        │
             └─────────────────────────────┘

---

## 🛠️ **Tech Stack**

### **Frontend**
- Flutter (UI + Logic)
- Kotlin (Power button detection)
- Google Maps SDK

### **Backend**
- Python (Agentic Logic)
- Firebase Cloud Functions (Automation)
- Node.js Optional (Alert Pipeline)

### **Database**
- Firebase Firestore (User Profiles)
- Local Hive/SQLite (Offline Emergency Packets)

### **Notifications**
- Twilio (SMS/WhatsApp)
- SendGrid (Email)
- Firebase Cloud Messaging

  ---

## 🧪 **Testing Scenarios**

### ✔ Online Mode
- Change GPS location  
- Disconnect/reconnect internet  
- Tap / long-press SOS button  
- Press power button 3×  

### ✔ Offline Mode
- Turn off mobile data & WiFi  
- Move with location ON  
- Trigger SOS  
- Wait for heartbeat timeout  

---

## 🤝 **Contributing**

Contributions are welcome!  
Please open issues or submit PRs.

---

## 👨‍💻 **Developed By**
**Team AURA – B.E. Computer Engineering (2025–26)**  
- Nakshatra Deshmukh  
- Vaibhavi Bhise
- Saher Shaikh
- Preshal Sharma


---

