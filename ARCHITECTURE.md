# AbayoNet System Architecture

## Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Component Design](#component-design)
- [Data Flow](#data-flow)
- [Database Schema](#database-schema)
- [Security Architecture](#security-architecture)
- [Monitoring Engine](#monitoring-engine)
- [API Design](#api-design)
- [Performance Optimization](#performance-optimization)
- [Deployment Architecture](#deployment-architecture)

## Overview

AbayoNet is a **monolithic, single-process application** built with Python's standard library, designed for simplicity, reliability, and ease of deployment. The architecture prioritizes:

- **Zero external dependencies** for core HTTP serving
- **Self-contained deployment** (single Python file + static assets)
- **Embedded database** (SQLite) for portability
- **Thread-based concurrency** for monitoring
- **Stateful session management** with in-memory storage

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Browser                           │
│              (HTML5, CSS3, JavaScript, Chart.js)                │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTP/HTTPS
                            │ (Port 8080/443)
┌───────────────────────────▼─────────────────────────────────────┐
│                    HTTP Request Handler                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Authentication & Session Management                      │  │
│  │  - Cookie-based sessions (8h timeout)                     │  │
│  │  - Bcrypt password verification                           │  │
│  │  - Role-based access control (Admin/Operator/ReadOnly)    │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Rate Limiting & Security                                 │  │
│  │  - IP-based rate limiting (50 req/min)                    │  │
│  │  - Request validation & sanitization                      │  │
│  │  - Audit logging                                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  REST API Endpoints                                       │  │
│  │  - /api/hosts, /api/alerts, /api/rules                   │  │
│  │  - /api/report, /api/dashboard                            │  │
│  │  - /api/bandwidth, /api/snmp                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Static File Server                                       │  │
│  │  - Single Page Application (index.html)                   │  │
│  │  - CSS, JavaScript, Images                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                    Business Logic Layer                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Host Manager                                             │  │
│  │  - CRUD operations for hosts                              │  │
│  │  - Group management                                       │  │
│  │  - Maintenance window scheduling                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Alert Engine                                             │  │
│  │  - Rule evaluation (thresholds, conditions)               │  │
│  │  - Alert generation & deduplication                       │  │
│  │  - Severity classification                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Monitoring Engine                                        │  │
│  │  - ICMP ping (subprocess)                                 │  │
│  │  - SNMP polling (pysnmp async)                            │  │
│  │  - TCP port scanning                                      │  │
│  │  - Concurrent execution (threading)                       │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Report Generator                                         │  │
│  │  - Statistical calculations (avg, min, max, p95, p99)     │  │
│  │  - Uptime percentage                                      │  │
│  │  - Cached reports (15-min refresh)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                         Data Layer                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  SQLite Database (abayonet.db)                            │  │
│  │  - Embedded, ACID-compliant                               │  │
│  │  - WAL mode for concurrency                               │  │
│  │  - Automatic schema creation                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  In-Memory Cache                                          │  │
│  │  - Session store (dict)                                   │  │
│  │  - Report cache (15-min TTL)                              │  │
│  │  - Rate limit counters                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  File Storage                                             │  │
│  │  - Configuration (abayonet.cfg)                           │  │
│  │  - Logs (data/abayonet.log)                               │  │
│  │  - SSL certificates (ssl/)                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Component Design

### 1. HTTP Server (`http.server.HTTPServer`)

**Purpose**: Handle HTTP requests and serve API endpoints + static files

**Implementation**:
```python
class AbayoNetHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Route handling
        if path.startswith('/api/'):
            # API endpoint
        else:
            # Static file serving
    
    def do_POST(self):
        # Write operations
```

**Features**:
- Custom routing logic (no frameworks)
- JSON request/response handling
- Cookie-based session management
- CORS headers for future API access
- Error handling with appropriate HTTP status codes

### 2. Authentication & Authorization

**Session Management**:
```python
SESSIONS = {}  # In-memory session store

{
    'session_id': {
        'user_id': 1,
        'username': 'admin',
        'role': 'admin',
        'created': timestamp,
        'last_access': timestamp
    }
}
```

**Session Lifecycle**:
1. Login → Generate UUID session_id
2. Set HTTP-only cookie
3. Validate on each request
4. Expire after 8 hours (28800s)
5. Cleanup via background watchdog

**RBAC Matrix**:
| Role | View | Edit Hosts | Manage Users | Configure |
|------|------|------------|--------------|-----------|
| Admin | ✓ | ✓ | ✓ | ✓ |
| Operator | ✓ | ✓ | ✗ | ✗ |
| ReadOnly | ✓ | ✗ | ✗ | ✗ |

### 3. Monitoring Engine

**Architecture**:
```
Main Process
    │
    ├─► Host Monitor Thread 1 ──► Ping Host A ──► SQLite Write
    ├─► Host Monitor Thread 2 ──► Ping Host B ──► SQLite Write
    ├─► Host Monitor Thread N ──► Ping Host N ──► SQLite Write
    │
    └─► SNMP Poller Thread ──► Poll Devices ──► SQLite Write
```

**Host Monitoring Flow**:
```python
def monitor_host(host):
    while True:
        # 1. Execute ping
        latency, loss = ping(host.ip)
        
        # 2. Store result
        db.execute("INSERT INTO ping_results ...")
        
        # 3. Update host status
        host.status = 'online' if latency else 'offline'
        
        # 4. Check alert rules
        evaluate_alerts(host, latency, loss)
        
        # 5. Sleep until next interval
        time.sleep(host.check_interval)
```

**SNMP Bandwidth Monitoring**:
```python
async def poll_bandwidth():
    while True:
        for device in snmp_enabled_hosts:
            # 1. Discover interfaces (if not cached)
            interfaces = await snmp_walk(device, ifTable)
            
            # 2. Get counters
            in_octets = await snmp_get(device, ifInOctets)
            out_octets = await snmp_get(device, ifOutOctets)
            
            # 3. Calculate bandwidth (delta)
            bandwidth = (current - previous) / time_delta
            
            # 4. Store
            db.execute("INSERT INTO bandwidth_data ...")
        
        await asyncio.sleep(30)  # 30-second polling
```

### 4. Alert Engine

**Alert Evaluation Pipeline**:
```
Monitor Result → Rule Engine → Alert Generator → Deduplicator → Database
```

**Rule Evaluation**:
```python
def evaluate_rule(host, metric_value):
    rules = get_rules_for_host(host)
    
    for rule in rules:
        if rule.metric == 'latency':
            if metric_value > rule.threshold:
                generate_alert(host, rule, metric_value)
        
        elif rule.metric == 'packet_loss':
            if loss_pct > rule.threshold:
                generate_alert(host, rule, loss_pct)
        
        elif rule.metric == 'uptime':
            if uptime_pct < rule.threshold:
                generate_alert(host, rule, uptime_pct)
```

**Deduplication**:
- 5-minute cooldown per (host, rule) combination
- Prevents alert spam
- Stored in-memory: `last_alert_time[(host_id, rule_id)]`

### 5. Database Layer

**Connection Management**:
```python
def get_db():
    conn = sqlite3.connect('abayonet.db', 
                          check_same_thread=False,
                          timeout=30)
    conn.execute('PRAGMA journal_mode=WAL')  # Write-Ahead Logging
    conn.execute('PRAGMA synchronous=NORMAL')
    return conn
```

**Schema Design**: See [Database Schema](#database-schema)

**Query Optimization**:
- Indexed columns: `host_id`, `timestamp`, `acknowledged`
- Prepared statements (parameterized queries)
- Batch inserts for bulk operations
- EXPLAIN QUERY PLAN for slow queries

## Data Flow

### 1. User Login Flow
```
Browser → POST /api/login
    ↓
Validate credentials (bcrypt)
    ↓
Generate session_id (UUID)
    ↓
Store in SESSIONS dict
    ↓
Set HTTP cookie
    ↓
Return 200 OK + user info
```

### 2. Dashboard Load Flow
```
Browser → GET /api/dashboard
    ↓
Validate session cookie
    ↓
Query latest ping results (last 5 min)
    ↓
Aggregate by host
    ↓
Return JSON response
    ↓
JavaScript renders cards
```

### 3. Monitoring Flow
```
Thread Start
    ↓
while True:
    Execute ping (subprocess)
        ↓
    Parse output (latency, loss)
        ↓
    INSERT INTO ping_results
        ↓
    UPDATE hosts SET status=...
        ↓
    Check alert rules
        ↓
        if threshold exceeded:
            INSERT INTO alerts
        ↓
    Sleep (check_interval)
```

### 4. Alert Notification Flow
```
Monitor detects issue
    ↓
Evaluate alert rules
    ↓
Check deduplication (5-min cooldown)
    ↓
Generate alert
    ↓
INSERT INTO alerts
    ↓
Dashboard polls /api/alerts
    ↓
Browser displays notification
```

## Database Schema

### Tables

#### 1. **hosts**
```sql
CREATE TABLE hosts (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    ip TEXT NOT NULL UNIQUE,
    group_id INTEGER,
    enabled INTEGER DEFAULT 1,
    check_interval INTEGER DEFAULT 30,
    tags TEXT,
    location TEXT,
    snmp_enabled INTEGER DEFAULT 0,
    snmp_version TEXT DEFAULT 'v2c',
    snmp_community TEXT DEFAULT 'public',
    snmp_port INTEGER DEFAULT 161,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_hosts_enabled ON hosts(enabled);
CREATE INDEX idx_hosts_group ON hosts(group_id);
```

#### 2. **ping_results**
```sql
CREATE TABLE ping_results (
    id INTEGER PRIMARY KEY,
    host_id INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    latency REAL,
    packet_loss REAL,
    status TEXT,
    ttl INTEGER,
    FOREIGN KEY (host_id) REFERENCES hosts(id)
);

CREATE INDEX idx_ping_host_time ON ping_results(host_id, timestamp DESC);
CREATE INDEX idx_ping_timestamp ON ping_results(timestamp);
```

#### 3. **alerts**
```sql
CREATE TABLE alerts (
    id INTEGER PRIMARY KEY,
    host_id INTEGER NOT NULL,
    rule_id INTEGER,
    severity TEXT,
    message TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    acknowledged INTEGER DEFAULT 0,
    ack_by TEXT,
    ack_at TIMESTAMP,
    FOREIGN KEY (host_id) REFERENCES hosts(id),
    FOREIGN KEY (rule_id) REFERENCES alert_rules(id)
);

CREATE INDEX idx_alerts_host ON alerts(host_id);
CREATE INDEX idx_alerts_ack ON alerts(acknowledged, timestamp DESC);
```

#### 4. **alert_rules**
```sql
CREATE TABLE alert_rules (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    host_id INTEGER,
    metric TEXT NOT NULL,  -- 'latency', 'packet_loss', 'uptime'
    operator TEXT NOT NULL,  -- '>', '<', '>=', '<=', '=='
    threshold REAL NOT NULL,
    severity TEXT NOT NULL,  -- 'critical', 'warning', 'info'
    enabled INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 5. **bandwidth_data**
```sql
CREATE TABLE bandwidth_data (
    id INTEGER PRIMARY KEY,
    host_id INTEGER NOT NULL,
    if_index INTEGER NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    in_bytes_per_sec REAL,
    out_bytes_per_sec REAL,
    in_mbps REAL,
    out_mbps REAL,
    utilization REAL,
    FOREIGN KEY (host_id) REFERENCES hosts(id)
);

CREATE INDEX idx_bandwidth_host_if ON bandwidth_data(host_id, if_index, timestamp DESC);
```

#### 6. **users**
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,  -- bcrypt hash
    role TEXT NOT NULL,  -- 'admin', 'operator', 'readonly'
    email TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);
```

#### 7. **audit_log**
```sql
CREATE TABLE audit_log (
    id INTEGER PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER,
    username TEXT,
    action TEXT,
    resource TEXT,
    details TEXT,
    ip_address TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_audit_timestamp ON audit_log(timestamp DESC);
CREATE INDEX idx_audit_user ON audit_log(user_id);
```

## Security Architecture

### 1. Authentication Flow
```
POST /api/login
    ↓
Rate limit check (10 attempts/min)
    ↓
Fetch user from database
    ↓
bcrypt.checkpw(password, hash)
    ↓
if valid:
    Generate session_id
    Store in SESSIONS
    Set cookie (HTTP-only, Secure)
    Log audit event
else:
    Return 401 Unauthorized
    Log failed attempt
```

### 2. Authorization Middleware
```python
def require_auth(role='any'):
    def decorator(func):
        def wrapper(self):
            # 1. Get session from cookie
            session = get_session(self.cookies)
            
            # 2. Validate session exists & not expired
            if not session or is_expired(session):
                return 401
            
            # 3. Check role
            if role != 'any' and session['role'] != role:
                return 403
            
            # 4. Update last_access
            session['last_access'] = time.time()
            
            # 5. Execute handler
            return func(self, session)
        
        return wrapper
    return decorator
```

### 3. Input Validation
```python
def validate_ip(ip):
    pattern = r'^(\d{1,3}\.){3}\d{1,3}$'
    if not re.match(pattern, ip):
        return False
    octets = ip.split('.')
    return all(0 <= int(oct) <= 255 for oct in octets)

def sanitize_sql(value):
    # Use parameterized queries - never string concatenation
    cursor.execute("SELECT * FROM hosts WHERE ip=?", (ip,))
```

### 4. Rate Limiting
```python
RATE_LIMITS = {}  # {ip: {'count': N, 'reset_time': T}}

def check_rate_limit(ip, limit=50, window=60):
    now = time.time()
    
    if ip not in RATE_LIMITS:
        RATE_LIMITS[ip] = {'count': 1, 'reset_time': now + window}
        return True
    
    if now > RATE_LIMITS[ip]['reset_time']:
        RATE_LIMITS[ip] = {'count': 1, 'reset_time': now + window}
        return True
    
    RATE_LIMITS[ip]['count'] += 1
    
    if RATE_LIMITS[ip]['count'] > limit:
        return False  # Rate limit exceeded
    
    return True
```

## Monitoring Engine

### Thread Architecture
```
Main Thread (HTTP Server)
    │
    ├─► Monitor Thread Pool
    │   ├─► Thread 1: Host A (every 30s)
    │   ├─► Thread 2: Host B (every 30s)
    │   └─► Thread N: Host N (every 30s)
    │
    ├─► SNMP Bandwidth Thread (asyncio event loop)
    │   └─► Poll all SNMP devices (every 30s)
    │
    ├─► Watchdog Thread (every 60s)
    │   ├─► Session cleanup
    │   ├─► Data retention enforcement
    │   └─► Memory leak detection
    │
    └─► Report Cache Warmer (every 15 min)
        └─► Pre-calculate statistics
```

### Concurrency Strategy
- **Threading** for I/O-bound operations (ping, database)
- **Asyncio** for SNMP (concurrent async operations)
- **Thread-safe SQLite** (WAL mode, timeouts)
- **Lock-free session dict** (atomic reads, write locks only on cleanup)

## API Design

### RESTful Endpoints

#### Host Management
```
GET    /api/hosts          # List all hosts
POST   /api/hosts          # Create host
GET    /api/host/{id}      # Get host details
PUT    /api/host/{id}      # Update host
DELETE /api/host/{id}      # Delete host
POST   /api/host/{id}/pause   # Pause monitoring
POST   /api/host/{id}/resume  # Resume monitoring
```

#### Monitoring Data
```
GET /api/dashboard           # Dashboard summary
GET /api/dashboard/chart     # Chart data (6 hosts, 1h)
GET /api/host/{id}/chart     # Single host chart (24h)
GET /api/host/{id}/stats     # Statistics (24h)
GET /api/bandwidth/{id}      # Bandwidth data
```

#### Alerts
```
GET    /api/alerts              # List alerts
POST   /api/alert/{id}/ack     # Acknowledge alert
DELETE /api/alert/{id}          # Delete alert
GET    /api/alerts?limit=N      # Paginated alerts
```

#### Configuration
```
GET  /api/config               # Get configuration
POST /api/config               # Update configuration
GET  /api/users                # List users (admin only)
POST /api/users                # Create user (admin only)
```

### Response Format
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "timestamp": 1698765432
}
```

## Performance Optimization

### 1. Database Optimization
- **WAL Mode**: Concurrent reads during writes
- **Connection Pooling**: Reuse connections (single shared conn)
- **Indexed Queries**: All foreign keys and timestamp columns
- **Batch Operations**: Bulk inserts for imports
- **Prepared Statements**: Query plan caching

### 2. Caching Strategy
```python
CACHE = {
    'reports': {
        'data': {...},
        'timestamp': T,
        'ttl': 900  # 15 minutes
    }
}

def get_report(host_id):
    cache_key = f'report_{host_id}'
    
    if cache_key in CACHE:
        if time.time() < CACHE[cache_key]['timestamp'] + CACHE[cache_key]['ttl']:
            return CACHE[cache_key]['data']
    
    # Cache miss - compute
    data = compute_report(host_id)
    CACHE[cache_key] = {
        'data': data,
        'timestamp': time.time(),
        'ttl': 900
    }
    return data
```

### 3. Adaptive Refresh
```python
def get_refresh_interval(ping_count):
    if ping_count < 100_000:
        return 5   # Fast mode: 5 seconds
    elif ping_count < 500_000:
        return 15  # Normal mode: 15 seconds
    else:
        return 30  # Slow mode: 30 seconds
```

### 4. Data Retention
- **Default**: 30 days of ping results
- **Automatic cleanup**: Watchdog thread (daily)
- **Configurable**: `retention_days` in config
- **Soft delete**: Alerts retained indefinitely (unless manually deleted)

## Deployment Architecture

### Single-Server Deployment
```
┌────────────────────────────────────┐
│       Linux Server (Ubuntu)        │
│                                    │
│  ┌──────────────────────────────┐ │
│  │  AbayoNet Python Process     │ │
│  │  - HTTP Server (port 8080)   │ │
│  │  - Monitor Threads           │ │
│  │  - SQLite DB                 │ │
│  └──────────────────────────────┘ │
│                                    │
│  Network: 192.168.0.x             │
└────────────────────────────────────┘
```

### Production Deployment (Recommended)
```
                 Internet
                    │
                    ▼
         ┌──────────────────┐
         │   NAT Router     │
         │  Port Forward    │
         │  80→8080         │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  Nginx Proxy     │
         │  - SSL/TLS       │
         │  - Rate limiting │
         │  - Static cache  │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  AbayoNet        │
         │  - Python app    │
         │  - HTTP:8080     │
         └────────┬─────────┘
                  │
                  ▼
         ┌──────────────────┐
         │  SQLite DB       │
         │  - WAL mode      │
         │  - Backup script │
         └──────────────────┘
```

### Backup Strategy
```bash
# Daily backup script
#!/bin/bash
sqlite3 abayonet.db ".backup /backup/abayonet_$(date +%Y%m%d).db"

# Retention: 30 days
find /backup -name "abayonet_*.db" -mtime +30 -delete
```

### Monitoring the Monitor
```bash
# SystemD service with auto-restart
[Unit]
Description=AbayoNet Network Monitor

[Service]
ExecStart=/usr/bin/python3 /opt/abayonet/abayonet.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## Scalability Considerations

### Current Limitations
- **Single process**: No horizontal scaling
- **SQLite**: Single-writer limit (~500 req/sec)
- **In-memory sessions**: Lost on restart
- **No clustering**: Single point of failure

### Future Enhancements
1. **PostgreSQL/MySQL**: Multi-writer support
2. **Redis**: Distributed session storage
3. **Message Queue**: Decouple monitoring from HTTP
4. **Microservices**: Separate monitoring engine
5. **Load Balancer**: Multiple HTTP instances
6. **Distributed Monitoring**: Regional collectors

## Technology Decisions

### Why Python?
- ✅ Rich networking libraries (ping, SNMP)
- ✅ Cross-platform
- ✅ Built-in HTTP server
- ✅ Easy deployment (no compilation)

### Why SQLite?
- ✅ Zero configuration
- ✅ Single-file portability
- ✅ ACID compliance
- ✅ Sufficient for <1000 hosts
- ✅ Built into Python

### Why No Framework?
- ✅ Learning experience (understand HTTP deeply)
- ✅ Zero dependencies (easier deployment)
- ✅ Full control over routing and performance
- ✅ Smaller attack surface

### Why Threading (not async)?
- ✅ Ping requires subprocess (blocking I/O)
- ✅ SQLite works better with threads than async
- ✅ Simpler mental model for monitoring tasks
- ✅ Python GIL not an issue (I/O bound)

---

**Document Version**: 1.0  
**Last Updated**: October 2026  
**Author**: Olusega Bayonet
