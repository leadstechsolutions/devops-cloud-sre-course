# Before Class 1 — Install Your Tools

Welcome to the DevOps · Cloud · SRE program! If you can, install these **five tools** before our
first class. **Don't stress if you get stuck** — bring your laptop and we'll sort out anything that
didn't work, together, in class.

## The five tools (and what each one is)

| Tool | What it's for |
|---|---|
| **Git** | Tracks changes to code and files |
| **VS Code** | The editor where you'll write everything |
| **AWS CLI** | Command-line access to AWS |
| **Docker Desktop** | Packages apps into containers |
| **Terraform** | Describes cloud infrastructure as code |

You'll also use a **terminal** — Windows: *Windows Terminal* or *PowerShell*; macOS: *Terminal*;
Linux: your terminal app.

---

## Install — pick your operating system

### 🪟 Windows
Open **PowerShell** (Start → type "PowerShell") and run each line:
```powershell
winget install --id Git.Git -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Amazon.AWSCLI -e
winget install --id Hashicorp.Terraform -e
winget install --id Docker.DockerDesktop -e
```
Then **close and reopen** PowerShell. Open **Docker Desktop** once so it finishes setting up.

### 🍎 macOS
Open **Terminal**. If `brew --version` doesn't work, install Homebrew first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Then:
```bash
brew install git awscli
brew install --cask visual-studio-code docker
brew install hashicorp/tap/terraform
```
Open **Docker Desktop** once. For the `code` command: open VS Code → **Cmd-Shift-P** → type
"Shell Command: Install 'code' command in PATH" → Enter.

### 🐧 Linux (Ubuntu / Debian)
```bash
sudo apt update && sudo apt install -y git unzip
sudo snap install code --classic
# AWS CLI v2:
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install
# Docker:
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER   # then log out and back in
```
For **Terraform**, download it from the official page below, unzip, and move it into `/usr/local/bin`.

---

## Check that it worked

Open a **new** terminal and run these five commands one at a time. Each should print a version:
```bash
git --version
aws --version
docker --version
terraform version
code --version
```
✅ If you see a version line, that tool is ready. ❌ If you see **"command not found,"** that tool
isn't installed yet (or the terminal needs to be reopened) — just note it and bring it to class.

## If something goes wrong (quick tips)
- **"command not found"** right after installing → **close and reopen the terminal** and try again.
- **Docker says "Cannot connect to the daemon"** → open **Docker Desktop** and wait for it to start.
- **Any install command errors** → use the official download page instead (below); it always works.

## Official download pages (always work)
- Git — https://git-scm.com/downloads
- VS Code — https://code.visualstudio.com/download
- AWS CLI — https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Docker Desktop — https://www.docker.com/products/docker-desktop/
- Terraform — https://developer.hashicorp.com/terraform/install

---

## Bring to Class 1
- Your laptop.
- A quick note of which of the five commands **worked** and which **didn't** (with the exact error).
- Any questions — nothing is a silly question in Week 1. See you there! 👋
