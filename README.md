# Ax-File-Manager

A lightweight web-based file management panel built with Node.js and Express.js.  
Easily manage files on your server with a simple dashboard, secured with username and password.

---

## Features

- Upload, download, and delete files from a web dashboard  
- Folder browsing and management  
- User authentication  
- Works with PM2 for automatic process management  
- Configurable root folder for file storage  

---

## Installation

### Prerequisites

- Ubuntu or Debian-based server  
- Node.js (v20 recommended)  
- npm  
- PM2 (for process management)  

### Using the Installer Script

1. Clone this repository
```bash
wget https://raw.githubusercontent.com/Mindula-Dilthushan/Ax-File-Manager/master/install.sh
```

3. Make the installer executable:

```bash
chmod +x install.sh
````

### Run the installer
```bash
./install.sh
```

### Enter the requested information:
- App folder path (where files will be stored)
- Panel username and password

### After installation, the panel will be running at
```bash
http://<your-server-ip>:4000
```
