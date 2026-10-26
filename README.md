# AbayoNet Enterprise Network Monitoring System v10.0

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production-success.svg)]()

> **Enterprise-grade network monitoring and management platform** built with Python, featuring real-time host monitoring, SNMP bandwidth tracking, intelligent alerting, and interactive visualizations.

## 🚀 Project Overview

AbayoNet is a comprehensive network operations center (NOC) solution designed for monitoring and managing enterprise network infrastructure. Built from the ground up with modern web technologies and network protocols, it provides real-time visibility into network health, performance metrics, and automated alerting.

**Live Demo**: [Contact for demo access]

## ✨ Key Features

### 🔍 **Real-Time Network Monitoring**
- **Multi-Protocol Support**: ICMP (ping), SNMP v1/v2c/v3, TCP port checks
- **Concurrent Monitoring**: Asyncio-based architecture for simultaneous host monitoring
- **Adaptive Polling**: Smart refresh rates based on database size (5-30 second intervals)
- **Live Streaming**: Real-time metric updates with WebSocket-like polling

### 📊 **Advanced Visualizations**
- **Host Status Dashboard**: Color-coded cards with latency, packet loss, uptime metrics
- **Performance Heatmap**: Visual heat map with 5-tier color coding for instant health assessment
- **Geographic Map**: Interactive bubble chart showing host distribution across Nigeria
- **Real-Time Charts**: Chart.js-powered latency graphs with up to 1-hour history
- **Distribution Analytics**: Latency distribution and slowest host identification

### 📡 **SNMP Bandwidth Monitoring**
- **Interface Discovery**: Automatic detection of network interfaces via SNMP walk
- **Real-Time Bandwidth**: In/Out traffic measurement in bytes/sec and Mbps
- **Utilization Tracking**: Interface bandwidth utilization percentage
- **Multi-Vendor Support**: Works with Cisco, Juniper, MikroTik, and other SNMP-capable devices
- **Historical Data**: Time-series bandwidth data storage with graphing

### 🚨 **Intelligent Alerting System**
- **Flexible Rules Engine**: Configure alerts based on latency, packet loss, uptime thresholds
- **Multi-Condition Logic**: AND/OR operators for complex alert scenarios
- **Severity Levels**: Critical, Warning, Info classifications
- **Alert Correlation**: Duplicate suppression (5-minute cooldown)
- **Acknowledgment System**: Mark alerts as acknowledged with user tracking
- **Alert History**: Searchable alert log with filtering and export

### 🔐 **Enterprise Security**
- **Role-Based Access Control (RBAC)**: Admin, Operator, ReadOnly user roles
- **Session Management**: Secure cookie-based sessions with 8-hour timeout
- **Rate Limiting**: Configurable request throttling (50 req/min default)
- **Audit Logging**: Complete audit trail of all user actions
- **Password Security**: Bcrypt hashing with strength validation
- **Input Validation**: SQL injection and XSS protection
- **Security Headers**: HSTS, X-Frame-Options, Content Security Policy

### 📈 **Performance & Scalability**
- **Optimized Database**: Automatic performance mode switching (fast/normal/slow)
- **Data Retention**: Configurable retention policies (default: 30 days)
- **Efficient Caching**: Report cache with adaptive warming
- **Memory Management**: Watchdog for memory leak detection
- **Index Optimization**: Proper database indexing for fast queries
- **Concurrent Processing**: Thread-based monitoring with proper isolation

### 🛠️ **Management Features**
- **Host Management**: Add, edit, delete, pause/resume host monitoring
- **Group Organization**: Organize hosts into logical groups
- **Bulk Operations**: CSV import/export for host configuration
- **Maintenance Windows**: Schedule maintenance to suppress alerts
- **Network Scanner**: Discover active hosts on network segments
- **Tags & Labels**: Flexible host categorization

### 📱 **Modern UI/UX**
- **Dark Theme**: Professional dark mode interface optimized for NOCs
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Single Page Application**: Fast navigation with no page reloads
- **Live Updates**: Auto-refreshing dashboard (5-second intervals)
- **Accessibility**: WCAG compliance, keyboard navigation, screen reader support
- **Toast Notifications**: Non-intrusive user feedback

## 🏗️ Architecture

AbayoNet follows a **three-tier architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│   (HTML5, CSS3, Vanilla JavaScript, Chart.js)           │
├─────────────────────────────────────────────────────────┤
│                      Application Layer                   │
│   (Python HTTP Server, REST API, Session Management)    │
├─────────────────────────────────────────────────────────┤
│                         Data Layer                       │
│   (SQLite Database, In-Memory Cache, File Storage)      │
└─────────────────────────────────────────────────────────┘
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed system design.

## 🛠️ Tech Stack

### Backend
- **Python 3.8+**: Core application language
- **http.server**: Built-in HTTP server (no external web framework)
- **sqlite3**: Relational database for persistent storage
- **threading**: Concurrent host monitoring
- **asyncio**: Asynchronous SNMP operations
- **bcrypt**: Password hashing and verification
- **pysnmp**: SNMP protocol implementation

### Frontend
- **Vanilla JavaScript (ES6+)**: No frameworks, pure JS
- **Chart.js 4.4.0**: Interactive charts and graphs
- **HTML5 & CSS3**: Modern web standards
- **Flexbox & Grid**: Responsive layouts

### Network Protocols
- **ICMP**: Ping-based host availability checks
- **SNMP v1/v2c/v3**: Device monitoring and bandwidth tracking
- **TCP**: Port availability scanning
- **HTTP/HTTPS**: Web interface and API

## 📦 Installation

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip iputils-ping

# CentOS/RHEL
sudo yum install python3 python3-pip iputils
```

### Setup
```bash
# Clone repository
git clone https://github.com/olusegab/abayonet.git
cd DevOps-Projects/abayonet

# Install dependencies
pip3 install -r requirements.txt

# Run application
python3 abayonet.py
```

### First Access
1. Open browser: `http://localhost:8080`
2. Default credentials: `admin` / `admin123`
3. **Change password immediately** in Settings

## 🚀 Usage

### Quick Start
```bash
# Start server
python3 abayonet.py

# Access dashboard
http://localhost:8080

# Add your first host
Click "+ Add Host" → Enter IP → Save

# Configure alerts
Navigate to "Alert Rules" → Create rule
```

### Configuration
Edit `abayonet.cfg` for custom settings:
```ini
[server]
port = 8080
refresh_seconds = 5

[monitoring]
ping_timeout = 2
max_threads = 10

[database]
retention_days = 30

[security]
session_timeout = 28800
rate_limit = 50
```

### SNMP Configuration
```python
# Add SNMP-enabled host
IP: 192.168.1.1
SNMP Version: v2c
Community: public
SNMP Port: 161

# System automatically discovers interfaces
# Bandwidth monitoring starts immediately
```

## 📊 Screenshots

### Dashboard - Host Status Cards
![Dashboard](docs/screenshots/dashboard.png)

### Performance Heatmap View
![Heatmap](docs/screenshots/heatmap.png)

### Geographic Map Visualization
![Map](docs/screenshots/geographic-map.png)

### SNMP Bandwidth Monitoring
![Bandwidth](docs/screenshots/bandwidth.png)

### Alert Management
![Alerts](docs/screenshots/alerts.png)

## 📈 Performance Metrics

- **Monitoring Capacity**: 500+ hosts simultaneously
- **API Response Time**: < 50ms (average)
- **Database Queries**: Optimized for < 100ms
- **Memory Footprint**: ~150MB (100 hosts)
- **Dashboard Refresh**: 5 seconds (configurable)

## 🔒 Security Features

- ✅ Password hashing with bcrypt (cost factor: 12)
- ✅ Session management with secure cookies
- ✅ Rate limiting per IP address
- ✅ SQL injection protection (parameterized queries)
- ✅ XSS prevention (input escaping)
- ✅ Audit logging for all actions
- ✅ Role-based access control (3 levels)
- ✅ HTTPS support with OpenSSL

## 🧪 Testing

```bash
# Test SNMP connectivity
python3 test_snmp.py 192.168.1.1 public

# Test bandwidth monitoring
python3 test_bandwidth.py

# Run with debug mode
ABAYONET_DEBUG=1 python3 abayonet.py
```

## 📚 Documentation

- [Architecture Overview](ARCHITECTURE.md)
- [Security Guide](SECURITY.md)
- [Security Quick Start](SECURITY_QUICKSTART.md)
- [SNMP Setup Guide](SNMP_SETUP.md)
- [Heatmap Add-on](HEATMAP_ADDON.md)
- [Geographic Map Guide](GEOGRAPHIC_MAP.md)
- [Linux Setup](SETUP_LINUX.md)

## 🤝 Contributing

This is a portfolio project, but feedback and suggestions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🐛 Known Issues

- SSL timeout issues when running behind certain NAT configurations (workaround: use HTTP or nginx proxy)
- SNMP v3 requires additional configuration for auth/priv protocols
- Large datasets (>1M ping results) may require manual database optimization

## 🗺️ Roadmap

- [ ] Email/SMS alert notifications
- [ ] Multi-tenancy support
- [ ] REST API for third-party integrations
- [ ] Docker containerization
- [ ] Kubernetes deployment manifests
- [ ] Mobile app (React Native)
- [ ] Machine learning for anomaly detection
- [ ] NetFlow/sFlow support
- [ ] Integration with Grafana/Prometheus

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Olusegun Abayomi**
- GitHub: [@olusegab](https://github.com/olusegab)
- LinkedIn: https://github.com/olusegab

## 🙏 Acknowledgments

- Chart.js team for excellent charting library
- Python community for robust networking libraries
- Network engineering community for SNMP best practices
- Open source contributors worldwide

## 📞 Support

For questions, issues, or suggestions:
- Open an issue on GitHub
- Email: oabayomi24@gmail.com

---

**⭐ Star this repository if you find it useful!**

Built with ❤️ for network engineers and DevOps professionals.
