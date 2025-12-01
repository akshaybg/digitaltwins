# Construction Digital Twin — Project Documentation

This document provides a complete, implementation-level overview of the Construction Digital Twin project so another engineer or LLM can understand, run, and extend it quickly.

## 1) Overview
- Real-time construction site simulation + 3D visualization (Three.js) with equipment, workers, environment, safety, and project progress.
- Backend: Flask app with background threads for simulation and high-frequency telemetry (10ms) persisted to SQLite.
- Frontend: Single HTML dashboard that renders a 3D scene, polls APIs for state/health, and offers control actions.

## 2) Repository Structure
```
.
├─ construction_digital_twin.py       # Backend app, domain model, SQLite, API
├─ templates/
│  └─ construction_3d_dashboard.html  # Three.js dashboard UI
├─ API_DOCUMENTATION.html             # Human-friendly API docs (static)
├─ truck_route.json                   # Default concrete mixer route
├─ truck_route_correct.json           # Alternate route
├─ truck_route_wrong_route.json       # Alternate route (wrong behavior demo)
├─ requirements.txt                   # Python deps (Flask used; FastAPI etc. unused)
├─ construction_telemetry.db          # SQLite DB (created at runtime)
├─ Dockerfile                         # Production container, Gunicorn, $PORT
├─ render.yaml                        # Render.com IaC for free deploy
└─ docs/
   └─ PROJECT_OVERVIEW.md             # This document
```

## 3) Domain Model (Python)
### Enums
- `EquipmentType`: `excavator`, `crane`, `bulldozer`, `concrete_mixer`, `generator`, `compactor`
- `SafetyStatus`: `safe`, `warning`, `critical` (not stored; used conceptually)
- `ProjectPhase`: `foundation`, `structure`, `roofing`, `finishing`

### Dataclasses & Core Classes
- `Location { x: float, y: float, z: float=0.0 }`
- `Worker { id: str, name: str, location: Location, heart_rate: int, body_temp: float, has_helmet: bool, has_vest: bool, last_seen: datetime }`
- `ConstructionEquipment`
  - Identity: `id`, `type: EquipmentType`
  - Position & motion: `location`, `is_moving`, `movement_speed`, `rotation_angle`, `movement_path: List[Location]`, `path_index`
  - Telemetry: `engine_temp`, `fuel_level`, `vibration_level`, `load_weight`, `operating_hours`, `alerts`
  - Controls: `is_active`, `kill_switch` (optional), evacuation flags/target
  - Routes: `route_file` (optional), defaults to `truck_route.json` for concrete mixer
  - Key methods: `setup_truck_routes()`, `update_movement()`, `follow_path()`, `random_movement()`, `update_telemetry()`, `get_status()`
- `SafetyMonitor`
  - Holds workers and restricted zones; updates worker status; records PPE/health/zone violations; keeps last 24h
- `ProgressTracker`
  - Tracks per-phase progress; auto-advances phase when current hits 100%; computes overall progress
- `EnvironmentalMonitor`
  - Simulates environment metrics; can `trigger_emergency()` and `clear_emergency()`
- `TelemetryDatabase` (SQLite)
  - Thread-safe inserts via a shared `threading.Lock`
  - Query helpers for equipment, workers, environment

## 4) SQLite Schema
Tables created in `construction_telemetry.db` at startup:

- `equipment_telemetry`
  - Columns: `id INTEGER PK`, `timestamp REAL`, `equipment_id TEXT`, `equipment_type TEXT`, `pos_x REAL`, `pos_y REAL`, `pos_z REAL`, `engine_temp REAL`, `fuel_level REAL`, `vibration_level REAL`, `load_weight REAL`, `is_active INT`, `is_moving INT`, `rotation_angle REAL`, `movement_speed REAL`
  - Indexes: `idx_equip_ts(timestamp)`, `idx_equip_id(equipment_id)`

- `worker_telemetry`
  - Columns: `id INTEGER PK`, `timestamp REAL`, `worker_id TEXT`, `worker_name TEXT`, `pos_x REAL`, `pos_y REAL`, `pos_z REAL`, `heart_rate INT`, `body_temp REAL`, `has_helmet INT`, `has_vest INT`
  - Index: `idx_worker_ts(timestamp)`

- `environment_telemetry`
  - Columns: `id INTEGER PK`, `timestamp REAL`, `temperature REAL`, `humidity REAL`, `wind_speed REAL`, `air_quality REAL`, `noise_level REAL`, `dust_level REAL`
  - Index: `idx_env_ts(timestamp)`

## 5) Runtime Flows
- Startup
  - Initializes site: sample equipment (excavator, crane, concrete mixer, bulldozer) and 4 workers.
  - Builds SQLite schema if missing.
  - Starts simulation thread (`background_updates`, 100ms); if `AUTO_START=1`, starts operations + telemetry.
- Simulation loop (100ms)
  - Updates equipment telemetry, environment, workers (random walk or evacuation movement)
  - Tracks safety violations and phase progress
- Telemetry loop (10ms)
  - When running, writes equipment, worker, and environment snapshots to SQLite
- Concrete mixer routes
  - Loads from `route_file` if set; otherwise from `truck_route.json`
  - `POST /api/route/select` swaps route at runtime and reinitializes path; resumes movement unless killed
- Emergency evacuation
  - `POST /api/trigger-emergency`: sets high dust, sends all entities to nearest assembly point at faster speed
  - `POST /api/clear-emergency`: clears flags, restores normal routes (truck resumes unless kill switch active)
- Kill switch
  - `POST /api/truck/kill`: freezes mixer; `POST /api/truck/resume`: unfreezes and resumes

## 6) HTTP API
Base URL: `http://<host>:<port>` (default port 8001 locally). JSON responses.

### Core
- `GET /`
  - Returns the 3D dashboard HTML page
- `GET /api/dashboard-data`
  - Returns a site snapshot: `site_info`, `equipment`, `workers`, `safety`, `progress`, `environment`, `assembly_points`, `timestamp`

### Operations
- `POST /api/start-operations`
- `POST /api/stop-operations`

### Emergency
- `POST /api/trigger-emergency`
  - Body: `{ "dust_level": number (optional, default 90.0) }`
- `POST /api/clear-emergency`

### Truck Control
- `POST /api/truck/kill`
  - Body: `{ "equipment_id": "MIX001" (optional) }`
- `POST /api/truck/resume`
  - Body: `{ "equipment_id": "MIX001" (optional) }`

### Telemetry Reads
- `GET /api/telemetry/equipment?equipment_id=MIX001&limit=100`
- `GET /api/telemetry/workers?worker_id=W001&limit=100`
- `GET /api/telemetry/environment?limit=100`

### Health & Route
- `GET /health`
  - Response: `{ status: "ok", app_running: bool, telemetry_running: bool, equipment_count: int, worker_count: int }`
- `POST /api/route/select`
  - Body: `{ "route_file": "truck_route_wrong_route.json", "equipment_id": "MIX001" }`
  - Response: `{ status: "route_applied", equipment_id, route_file, waypoints }`

### Sample PowerShell (Windows) cURL
```powershell
curl http://localhost:8001/health
curl -Method POST http://localhost:8001/api/start-operations
$body = @{ route_file = "truck_route_wrong_route.json"; equipment_id = "MIX001" } | ConvertTo-Json
curl -Method POST -ContentType 'application/json' -Body $body http://localhost:8001/api/route/select
```

## 7) Frontend (Three.js Dashboard)
- Tech: Three.js r128 + OrbitControls; Chart.js included; custom CSS; inline JS.
- UI elements:
  - Sidebar header: “site status” auto-updates every 5s by polling `/health` (color + tooltip)
  - Controls: Start/Stop, Reset View, Wireframe, Grid, Show Coords, Toggle Routes
  - Panels: Selected Object details, Equipment list, Environment stats, Site stats (active equipment, workers, alerts, progress)
- Data flow: Periodic fetch of `/api/dashboard-data` to update meshes/labels and stats overlays.

## 8) Configuration
- Environment variables
  - `PORT` (default 8001): App bind port (platforms like Render set this automatically)
  - `AUTO_START` (default 0, Dockerfile sets 1): Start operations on boot if `1`
- Route files
  - Default: `truck_route.json`; swap via `/api/route/select`
- SQLite DB
  - `construction_telemetry.db` file in project root

## 9) Run & Deploy
### Local (Windows PowerShell)
```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python construction_digital_twin.py
```
Open http://localhost:8001

### Docker (local)
```powershell
docker build -t construction-twin .
docker run -p 8001:8001 -e AUTO_START=1 construction-twin
```

### Render.com (free)
- Uses `Dockerfile` + `render.yaml`. The Docker `CMD` uses shell form so `$PORT` expands:
  - `sh -c "gunicorn -b 0.0.0.0:${PORT:-8001} --workers 3 --threads 4 construction_digital_twin:app"`
- Health check: `/health`

## 10) Performance & Security Notes
- Telemetry loop (10ms) is CPU/IO intensive; on free tiers, consider longer intervals or batch inserts.
- SQLite writes are protected by a lock; indices help reads but DB growth will accumulate quickly during long runs.
- Control endpoints (start/stop, emergency, route, kill/resume) are unauthenticated by default — protect them if public.

## 11) Extension Ideas
- Add auth (API key/bearer) for control endpoints.
- Configurable telemetry interval and/or batching to reduce IO.
- WebSocket/SSE for live updates instead of polling.
- Modularize frontend JS/CSS; add asset pipeline.
- More equipment types and scenario scripting.

## 12) Known Non-Functional Details
- Requirements include `fastapi`, `uvicorn`, `pydantic`, `python-json-logger` but current server uses Flask only. Safe to remove or refactor to FastAPI.
- Large inline HTML; acceptable for demo, consider splitting for maintainability.

---
This document mirrors the current codebase on branch `master` and is suitable as a prompt/context for other LLMs or new contributors.
