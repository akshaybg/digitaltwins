# 🏗️ Construction Site Digital Twin - 3D Visualization

A real-time 3D digital twin system for monitoring construction sites, equipment, workers, and environmental conditions.

## 🚀 Quick Start

### Run the Demo (One Command!)

**Linux/Mac:**
```bash
./run_demo.sh
```

**Windows:**
```bash
run_demo.bat
```

**Access the visualization:**
- Open your browser to: **http://localhost:8001/**

That's it! The 3D construction site will load immediately.

---

## 📋 Requirements

- Python 3.8+
- Flask and dependencies (auto-installed by run script)
- Modern web browser with WebGL support

---

## 🎮 Features

### Real-Time 3D Visualization
- Interactive 3D construction site environment
- Equipment models (excavators, cranes, concrete mixers, bulldozers)
- Worker position tracking with 3D characters
- Safety zone visualization
- Dynamic camera controls

### Equipment Monitoring
- Real-time telemetry (fuel, temperature, vibration, load)
- Automated route following (concrete mixer trucks)
- Operating hours tracking
- Alert system (low fuel, high temperature, overload)

### Worker Safety
- PPE compliance monitoring (helmets, vests)
- Health metrics (heart rate, body temperature)
- Restricted zone violation detection
- Real-time position tracking

### Environmental Monitoring
- Temperature, humidity, wind speed
- Air quality index
- Noise level monitoring
- Dust level tracking

---

## 📁 Project Structure

```
digitaltwins/
├── construction_digital_twin.py   # Main application
├── templates/
│   └── construction_3d_dashboard.html  # 3D visualization UI
├── run_demo.sh                    # Linux/Mac launcher
├── run_demo.bat                   # Windows launcher
├── requirements.txt               # Python dependencies
├── DEMO_GUIDE.md                  # Detailed demo guide
└── README.md                      # This file
```

---

## 🎬 Demo Tips

1. **Start operations** - Click "Start Operations" to see equipment move
2. **Zoom in** - Use mouse wheel to zoom into specific equipment
3. **Rotate view** - Click and drag to rotate the camera
4. **Equipment details** - Click on equipment to see telemetry
5. **Watch the mixer** - The concrete truck follows a realistic route!

---

## 🛑 Stop the Demo

Press `Ctrl+C` in the terminal

Or:
```bash
pkill -f construction_digital_twin.py
```

---

## 🔧 Manual Setup (Advanced)

If you want to set up manually:

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate.bat  # Windows

# Install dependencies
pip install -r requirements.txt

# Run the application
python3 construction_digital_twin.py
```

---

## 🎓 For Presentations

See **DEMO_GUIDE.md** for:
- Detailed demo flow (3-5 minute presentation)
- Talking points for professors
- Technical architecture overview
- Troubleshooting tips

---

## 🌐 Technology Stack

- **Backend:** Python + Flask
- **Frontend:** Three.js (3D rendering)
- **Real-time Updates:** Background threading (2-second intervals)
- **Architecture:** Digital Twin pattern with in-memory state

---

## 📊 What is a Digital Twin?

A digital twin is a virtual representation of physical assets that mirrors their real-world state in real-time. This project simulates:
- Physical equipment → Virtual 3D models
- Sensor data → Telemetry updates
- Worker positions → Safety monitoring
- Environmental conditions → Decision support

---

## 🤝 Contributing

This is a college project for demonstration purposes. Feel free to:
- Add more equipment types
- Implement new safety rules
- Enhance 3D visualizations
- Add new telemetry sensors

---

## 📝 License

Educational/Demo Project - Free to use and modify

---

**Built for construction site monitoring and safety management** 🏗️✨
