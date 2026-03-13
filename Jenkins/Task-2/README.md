# Jenkins Task 2 - CI/CD with Auto-Build & Email Notification

Automated CI/CD pipeline using **AWS EC2**, **GitHub**, and **Jenkins**. When a commit is pushed to GitHub, Jenkins automatically triggers a build and sends the result via email.

---

## 📁 Project Structure

```
├── build.sh          # Main build script (executed by Jenkins)
├── Jenkinsfile       # Pipeline definition with email notification
├── .gitignore        # Excludes build artifacts from Git
└── README.md         # This file
```

---

## 🚀 Setup Guide

### Step 1: Launch AWS EC2 Instance

1. Go to **AWS Console → EC2 → Launch Instance**
2. Configure:
   - **Name**: `Jenkins-Server`
   - **AMI**: Ubuntu 22.04 LTS
   - **Instance type**: `t2.medium` (Jenkins needs at least 2GB RAM)
   - **Key pair**: Create or select existing
   - **Security Group** — open these ports:

| Port  | Protocol | Source    | Purpose         |
|-------|----------|-----------|-----------------|
| 22    | TCP      | Your IP   | SSH             |
| 8080  | TCP      | Anywhere  | Jenkins Web UI  |
| 443   | TCP      | Anywhere  | GitHub Webhooks |

3. **Launch** the instance and note the **Public IP**.

---

### Step 2: Install Jenkins on EC2

SSH into the instance and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 17
sudo apt install -y openjdk-17-jdk

# Add Jenkins repo
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update
sudo apt install -y jenkins

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

📸 **Screenshot 1**: Jenkins running on `http://<EC2_PUBLIC_IP>:8080`

---

### Step 3: Configure Jenkins (First-Time Setup)

1. Open `http://<EC2_PUBLIC_IP>:8080` in browser
2. Paste the **initial admin password**
3. Click **Install suggested plugins**
4. Create an **Admin User**
5. Set the Jenkins URL

📸 **Screenshot 2**: Jenkins Dashboard after setup

---

### Step 4: Install Required Jenkins Plugins

Go to **Manage Jenkins → Plugins → Available plugins** and install:

- ✅ **Git Plugin** (usually pre-installed)
- ✅ **GitHub Plugin**
- ✅ **Email Extension Plugin** (for email notifications)
- ✅ **Pipeline Plugin** (usually pre-installed)

Restart Jenkins after installing.

---

### Step 5: Push Code to GitHub

```bash
# Initialize and push to GitHub
cd "d:\disk D\AWS\Guvi\Jenkins\Task 2"
git init
git add .
git commit -m "Initial commit - Jenkins CI/CD Task 2"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/<YOUR_REPO>.git
git push -u origin main
```

📸 **Screenshot 3**: GitHub repository with files

---

### Step 6: Configure Email in Jenkins (SMTP)

Go to **Manage Jenkins → System**:

#### E-mail Notification (scroll to bottom):
| Setting             | Value                      |
|---------------------|----------------------------|
| SMTP Server         | `smtp.gmail.com`           |
| Use SMTP Auth       | ✅ Checked                  |
| Username            | `your.email@gmail.com`     |
| Password            | *App Password (see below)* |
| Use SSL             | ✅ Checked                  |
| SMTP Port           | `465`                      |

#### Extended E-mail Notification:
| Setting             | Value                          |
|---------------------|--------------------------------|
| SMTP Server         | `smtp.gmail.com`               |
| SMTP Port           | `465`                          |
| Credentials         | Add Gmail credentials          |
| Use SSL             | ✅ Checked                      |
| Default Recipients  | `your.email@gmail.com`         |

> **📝 Gmail App Password**: Go to [Google Account Security](https://myaccount.google.com/security) → 2-Step Verification → App passwords → Generate one for "Mail".

📸 **Screenshot 4**: Jenkins email configuration

---

### Step 7: Create Jenkins Pipeline Project

1. Click **New Item** on Jenkins Dashboard
2. Enter name: `Jenkins-Task-2-Pipeline`
3. Select **Pipeline** → Click **OK**
4. Configure:

#### General:
- ✅ Check **GitHub project**
- Enter your GitHub repo URL

#### Build Triggers:
- ✅ Check **GitHub hook trigger for GITScm polling**

#### Pipeline:
| Setting                    | Value                            |
|----------------------------|----------------------------------|
| Definition                 | Pipeline script from SCM         |
| SCM                        | Git                              |
| Repository URL             | `https://github.com/<user>/<repo>.git` |
| Branch Specifier           | `*/main`                         |
| Script Path                | `Jenkinsfile`                    |

5. Click **Save**

> **⚠️ Important**: Update `YOUR_EMAIL@example.com` in the `Jenkinsfile` with your actual email address before pushing!

📸 **Screenshot 5**: Jenkins Pipeline configuration

---

### Step 8: Configure GitHub Webhook

1. Go to your **GitHub repo → Settings → Webhooks → Add webhook**
2. Configure:

| Setting       | Value                                        |
|---------------|----------------------------------------------|
| Payload URL   | `http://<EC2_PUBLIC_IP>:8080/github-webhook/` |
| Content type  | `application/json`                           |
| Events        | Just the push event                          |
| Active        | ✅ Checked                                    |

3. Click **Add webhook**

📸 **Screenshot 6**: GitHub Webhook configuration (green ✓ after delivery)

---

### Step 9: Test the Auto-Build

1. Make a small code change:
```bash
echo "# Trigger build - $(date)" >> README.md
git add .
git commit -m "Test commit to trigger Jenkins build"
git push origin main
```

2. Go to Jenkins → Your pipeline should be **building automatically**!

📸 **Screenshot 7**: Jenkins build triggered automatically
📸 **Screenshot 8**: Jenkins build console output (SUCCESS)
📸 **Screenshot 9**: Email notification received

---

## 📸 Required Screenshots Checklist

| # | Screenshot                                    | Status |
|---|-----------------------------------------------|--------|
| 1 | EC2 Instance running                          | ☐      |
| 2 | Jenkins Dashboard                             | ☐      |
| 3 | GitHub repo with project files                | ☐      |
| 4 | Jenkins email (SMTP) configuration            | ☐      |
| 5 | Jenkins Pipeline job configuration            | ☐      |
| 6 | GitHub Webhook configuration                  | ☐      |
| 7 | Auto-triggered build in Jenkins               | ☐      |
| 8 | Build console output (SUCCESS)                | ☐      |
| 9 | Email notification received                   | ☐      |

---

## 🔗 URLs to Submit

1. **GitHub Repository URL**: `https://github.com/<YOUR_USERNAME>/<YOUR_REPO>`
2. **Jenkins URL**: `http://<EC2_PUBLIC_IP>:8080`

---

## 🛠️ Troubleshooting

| Issue | Solution |
|-------|---------|
| Jenkins not accessible | Check EC2 Security Group → port 8080 open |
| Webhook not delivering | Ensure EC2 public IP in webhook URL, port 8080 open to all |
| Email not sending | Use Gmail App Password (not regular password), enable 2FA first |
| Build not triggering | Verify "GitHub hook trigger" is checked in job config |
| Permission denied on build.sh | The Jenkinsfile already runs `chmod +x build.sh` |
