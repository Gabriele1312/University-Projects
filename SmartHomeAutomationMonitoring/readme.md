# 💡SMART HOME AUTOMATION & MONITORING

Before following the execution steps, please **contact the developers** to obtain any additional information necessary for full functionality. 

# 📚 Table of contents 

- [Poject Information](#-project-information)
  - [Overview](#overview)
  - [Usage](#usage)
  - [Functionalities](#functionalities)
  
- [Project Setup Environment Details](#-project-setup-environment-details)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Remote Connection](#remote-connection)
  - [System Access Credentials](#system-access-credential)
  - [Application Access Credentials](#application-access-credential)
  
- [Authors](#-authors)

---
## 🔍 Project Information

### Overview
This project is designed to manage and monitor a smart home environment, providing device automation and energy consumption monitoring. It was developed and tested on a Raspberry Pi. To explore the project in detail, please consult the following file: `IoT_Project_Sassi_Centore`

### Usage
- This system allows for smart home device management, energy consumption monitoring, and automation rule setup.
- Management interfaces are available via Node-RED and a dedicated dashboard.

### Functionalities
* Automated Lighting Control
* Automated Heating Control
* Automated HVAC Control
* Alarm and Intrusion Detection System
* Energy Consumption Monitoring
---
### 📝 Project Setup Environment Details

### Requirements
- Operating System: Ubuntu or equivalent
- Remote access to MongoDB, Node-RED, and Dashboard
- Sudo command privileges
  
### Installation
1. Connect to the remote desktop using the provided host and port. The remote desktop connection is essential for testing the project.
2. Ensure MongoDB Compass is installed and use the connection string provided to connect to the database.
3. Run Java Application following the instructions.
4. Access Node-RED and the dashboard through the respective URLs.

### Remote Connection
- **Remote Desktop Connection:**
  - Host: `centore.synology.me`
  - Port (if necessary): `3389`
  - Note: Remote desktop connection is essential for testing and managing the project.

- **MongoDB Connection via MongoDB Compass:**
  - Connection String: `mongodb://iot:iot@centore.synology.me:27017/`

- **Java Application Access:**
  - On the remote desktop, there is a file named `SmartHomeIntellij.sh`. Right-click on the file and select 'Run as a program'. IntelliJ IDEA will open. Once the IDE is open, click to 'Run' to start the application.
  - Alternatively, open a terminal, copy and paste the following path: `/opt/idea-IU-242.20224.419/bin/idea`. Once IntelliJ IDEA is open, click on **Run** to start the application.

- **Node-RED Connection:**
  - Host: `centore.synology.me`
  - Port: `1880`

- **Node-RED Dashboard Access:**
  - URL: `centore.synology.me:1880/ui`

### System Access Credentials
- Ubuntu Username: `iot`
- Ubuntu Password: `iot`
- Sudo Command Password: `iot`

### Application Access Credentials
- Admin Username: `admin` , Admin Password: `admin`
- User A Username: `a` , User A Password: `a`
- User B Username: `b` , User B Password: `b`

## 👨‍🏫 Authors

- Name: Sassi Gabriele
- Email: gsassi2@studenti.uninsubria.it
- GitHub Profile: lele1312
---
- Name: Centore Luca
- Email: lcentore@studenti.uninsubria.it
- GitHub Profile: zLuke2000


