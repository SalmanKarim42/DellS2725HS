# DellS2725HS Build Guide - Windows & Linux

**Complete step-by-step guide for building on both Windows and Linux**

---

## 🖥️ WINDOWS SETUP & BUILD

### Prerequisites (Windows)

```powershell
# 1. Docker Desktop installed? Check
docker --version

# 2. Git installed? Check
git --version

# 3. WSL2 installed? Check (required for Docker on Windows)
wsl --list --verbose

# 4. Check current directory
pwd
# Should show: E:\tiny-pilot\DellS2725HS (or similar)
```

### Prerequisites Installation (Windows)

If not installed:

```powershell
# Option 1: Using Chocolatey (fastest)
choco install docker-desktop git

# Option 2: Manual installation
# Docker Desktop: https://www.docker.com/products/docker-desktop
# Git: https://git-scm.com/download/win
```

### Full Build Process (Windows)

**Run these commands step-by-step in PowerShell:**

```powershell
# Step 1: Navigate to project
cd E:\tiny-pilot\DellS2725HS

# Step 2: Verify git setup
git log --oneline -5

# Step 3: Clean any old builds
Remove-Item -Path debian-pkg/releases/*.deb -Force -ErrorAction SilentlyContinue

# Step 4: Build Debian package (ARM v7 for Raspberry Pi)
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7'

# This will take 5-15 minutes (first time might take longer)
# Docker will download base images and compile everything
```

**Expected Output:**
```
Successfully built dells2725hs-20260119123456+abcd123-0ubuntu1_arm.deb
Output: debian-pkg/releases/
```

```powershell
# Step 5: Check if .deb file was created
ls debian-pkg/releases/

# Should see: dells2725hs-<VERSION>.deb
```

```powershell
# Step 6: Move to bundle folder
mv debian-pkg/releases/dells2725hs*.deb bundler/bundle/

# Step 7: Create installation bundle
./bundler/create-bundle

# This takes 2-5 minutes
```

**Expected Output:**
```
Bundle created: dells2725hs-<VARIANT>-<TIMESTAMP>-<VERSION>.tgz
Output: bundler/dist/
```

```powershell
# Step 8: Verify bundle (optional)
./bundler/verify-bundle

# Should show: ✓ Bundle integrity verified
```

```powershell
# Step 9: Check final output
ls bundler/dist/
ls debian-pkg/releases/

# Should see both .tgz and .deb files
```

---

### Windows Complete Build in ONE Command

```powershell
# Copy and paste this entire block:
cd E:\tiny-pilot\DellS2725HS ; `
Remove-Item -Path debian-pkg/releases/*.deb -Force -ErrorAction SilentlyContinue ; `
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7' ; `
mv debian-pkg/releases/dells2725hs*.deb bundler/bundle/ ; `
./bundler/create-bundle ; `
./bundler/verify-bundle ; `
ls bundler/dist/ ; `
Write-Host "✓ Build complete!" -ForegroundColor Green
```

---

### Windows Troubleshooting

**Problem:** "Docker daemon is not running"
```powershell
# Solution: Start Docker Desktop
# Open Docker Desktop application from Start menu
# Wait 30 seconds for it to fully start

# Check if running
docker ps
```

**Problem:** "Permission denied" on script files
```powershell
# Solution: Change execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or run with bash explicitly
bash ./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7'
```

**Problem:** "WSL2 not installed"
```powershell
# Solution: Install WSL2
wsl --install

# Restart computer after installation
# Then retry Docker Desktop
```

**Problem:** Build timeout or very slow
```powershell
# Solution: Increase Docker memory
# Docker Desktop → Settings → Resources → Memory: Set to 4GB or more
# Then retry build
```

---

## 🐧 LINUX SETUP & BUILD

### Prerequisites (Linux)

```bash
# Check all requirements
docker --version
git --version
bash --version

# Check current directory
pwd
# Should show: /path/to/DellS2725HS
```

### Prerequisites Installation (Linux)

If not installed:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y docker.io git

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional, allows running without sudo)
sudo usermod -aG docker $USER
newgrp docker
```

### Full Build Process (Linux)

**Run these commands step-by-step in Bash:**

```bash
# Step 1: Navigate to project
cd /path/to/DellS2725HS

# Step 2: Verify git setup
git log --oneline -5

# Step 3: Clean any old builds
rm -f debian-pkg/releases/*.deb

# Step 4: Build Debian package (ARM v7 for Raspberry Pi)
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7'

# This will take 5-15 minutes (first time might take longer)
# Docker will download base images and compile everything
```

**Expected Output:**
```
Successfully built dells2725hs-20260119123456+abcd123-0ubuntu1_arm.deb
Output: debian-pkg/releases/
```

```bash
# Step 5: Check if .deb file was created
ls -lh debian-pkg/releases/

# Should see: dells2725hs-<VERSION>.deb
```

```bash
# Step 6: Move to bundle folder
mv debian-pkg/releases/dells2725hs*.deb bundler/bundle/

# Step 7: Create installation bundle
./bundler/create-bundle

# This takes 2-5 minutes
```

**Expected Output:**
```
Bundle created: dells2725hs-<VARIANT>-<TIMESTAMP>-<VERSION>.tgz
Output: bundler/dist/
```

```bash
# Step 8: Verify bundle (optional)
./bundler/verify-bundle

# Should show: ✓ Bundle integrity verified
```

```bash
# Step 9: Check final output
ls -lh bundler/dist/
ls -lh debian-pkg/releases/

# Should see both .tgz and .deb files
```

---

### Linux Complete Build in ONE Command

```bash
# Copy and paste this entire block:
cd /path/to/DellS2725HS && \
rm -f debian-pkg/releases/*.deb && \
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7' && \
mv debian-pkg/releases/dells2725hs*.deb bundler/bundle/ && \
./bundler/create-bundle && \
./bundler/verify-bundle && \
ls -lh bundler/dist/ && \
echo "✓ Build complete!"
```

---

### Linux Troubleshooting

**Problem:** "Permission denied" running docker
```bash
# Solution 1: Use sudo
sudo ./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7'

# Solution 2: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
# Then retry without sudo
```

**Problem:** "Docker daemon is not running"
```bash
# Solution: Start Docker service
sudo systemctl start docker

# Or check status
sudo systemctl status docker
```

**Problem:** "Not enough disk space"
```bash
# Check available space
df -h

# Clean up old Docker images
docker system prune -a

# Try build again
```

**Problem:** Build timeout
```bash
# Check Docker resources
docker system df

# Increase Docker daemon timeout
# Edit /etc/docker/daemon.json and add:
# "graph": "/var/lib/docker",
# "max-concurrent-downloads": 5

sudo systemctl restart docker
```

---

## 📊 BUILD OUTPUT LOCATIONS

### After Successful Build

```
DellS2725HS/
├── debian-pkg/
│   └── releases/
│       └── dells2725hs-<VERSION>.deb          ← Debian package
│
└── bundler/
    └── dist/
        └── dells2725hs-<VARIANT>-<TIMESTAMP>-<VERSION>.tgz  ← Installation bundle
```

### File Sizes (Approximate)

```
.deb file: 200-400 MB (Debian package)
.tgz file: 100-200 MB (Compressed bundle)
```

---

## 🏗️ BUILD ARCHITECTURE OPTIONS

### For Different Devices

```bash
# Option 1: Raspberry Pi (32-bit ARM) - RECOMMENDED
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7'

# Option 2: x86-64 Server/PC
./dev-scripts/build-debian-pkg --build-targets 'linux/amd64'

# Option 3: Both architectures (takes longer)
./dev-scripts/build-debian-pkg --build-targets 'linux/arm/v7,linux/amd64'

# Option 4: Custom version
./dev-scripts/build-debian-pkg --dells2725hs-version '1.0.0' --build-targets 'linux/arm/v7'
```

---

## 📝 WHAT EACH STEP DOES

| Step | Command | Purpose | Time |
|------|---------|---------|------|
| 1 | Clean old builds | Remove previous artifacts | <1 min |
| 2 | Build Debian package | Compile Python/JS code, create .deb | 5-15 min |
| 3 | Move to bundle | Prepare package for bundling | <1 min |
| 4 | Create bundle | Package everything into .tgz | 2-5 min |
| 5 | Verify bundle | Check integrity and completeness | 1-2 min |
| **Total** | | | **10-25 min** |

---

## ✅ VERIFICATION CHECKLIST

After build completes, verify:

```bash
# Windows (PowerShell)
ls debian-pkg/releases/  # Should show .deb file
ls bundler/dist/         # Should show .tgz file

# Linux (Bash)
ls -lh debian-pkg/releases/  # Should show .deb file
ls -lh bundler/dist/         # Should show .tgz file
```

Check file content:

```bash
# Windows (PowerShell)
Get-Item debian-pkg/releases/dells2725hs*.deb | Select-Object Name, Length

# Linux (Bash)
file debian-pkg/releases/dells2725hs*.deb
file bundler/dist/dells2725hs*.tgz
```

---

## 🚀 NEXT STEPS AFTER BUILD

1. **Transfer to Raspberry Pi:**
   ```bash
   scp bundler/dist/dells2725hs*.tgz pi@192.168.1.100:/tmp/
   ```

2. **Install on Raspberry Pi:**
   ```bash
   ssh pi@192.168.1.100
   cd /tmp
   tar -xzf dells2725hs*.tgz
   sudo ./dells2725hs-installer.sh
   ```

3. **Access Web Interface:**
   ```
   http://raspberrypi.local:8000
   ```

---

## 💾 EXPECTED FILES

After successful build, you'll have:

```
dells2725hs-20260119123456+abcd1234-0ubuntu1_armhf.deb
├─ Application code
├─ Dependencies
├─ Configuration files
└─ Installation scripts

dells2725hs-armhf-20260119-123456-0ubuntu1.tgz
├─ .deb file
├─ Installation helper scripts
├─ Documentation
└─ Verification tools
```

---

## 📞 COMMON ISSUES & SOLUTIONS

| Issue | Windows | Linux |
|-------|---------|-------|
| Docker not running | Start Docker Desktop GUI | `sudo systemctl start docker` |
| Permission denied | Run PowerShell as Admin | `sudo` command |
| Disk space | Increase Docker disk in settings | `docker system prune -a` |
| Network timeout | Increase Docker timeout | Edit daemon.json |
| Build very slow | Check Docker memory allocation | Check system resources |

---

**Ready to build? Choose your OS and run the commands!** 🎯

