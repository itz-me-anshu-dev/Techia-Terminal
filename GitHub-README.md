<div align="center">

# TECHIA TERMINAL

<img width="985" height="161" alt="image" src="https://github.com/user-attachments/assets/037882c4-8652-4662-967d-6f058b0dc997" />

**Your private terminal. Your machines. One login.**

[![version](https://img.shields.io/badge/version-v1.5.0_stable-00e0ff?style=for-the-badge)](https://github.com/itz-me-anshu-dev/Techia-Terminal/releases)
[![platform](https://img.shields.io/badge/platform-Windows_x64-1675ff?style=for-the-badge)](#install---desktop-windows)
[![backend](https://img.shields.io/badge/backend-online_24x7-00e676?style=for-the-badge)](#-central-backend)
[![license](https://img.shields.io/badge/license-proprietary-ff5252?style=for-the-badge)](#license)

</div>

---

## ✨ What is Techia?

Techia Terminal is a themed terminal workspace for Windows with a real
online backbone: **one account signs you in on any machine**, your devices
pair over an encrypted channel, and a central backend keeps everything in
sync. No Electron. No accounts on other people's servers. Per-user install,
no admin needed.

```diff
+ v1.5.0 addon: RDP is wired — pair a VPS with a code, connect over TLS, run programs remotely.
```

## 🖥️ Dashboard (what you see on launch)

<img width="1347" height="745" alt="image" src="https://github.com/user-attachments/assets/2070fd53-cf6e-4ba5-bee7-04daa6e30623" />


> 📸 **Screenshots:** 

## 🚀 Install — Desktop (Windows)

One line in PowerShell (no admin):

```powershell
irm https://github.com/itz-me-anshu-dev/Techia-Terminal/releases/download/v1.5.0/install.ps1 | iex
```

Or from CMD:

```cmd
powershell -NoProfile -Command "irm https://github.com/itz-me-anshu-dev/Techia-Terminal/releases/download/v1.5.0/install.ps1 | iex"
```

Then **close the terminal, open a new one**, and verify:

```cmd
techia doctor
```

Every download is SHA-256 verified *before* anything runs (see
`SHA256SUMS` in the release). First launch opens on login — `S` signs you
up, `L` logs you in. It stays logged in across restarts.

## 🔐 RDP — your VPS, one code away

| Step | Where | Command |
|---|---|---|
| 1. Join the VPS to your account | VPS | `techia-vps enroll --backend <url> --username YOU` |
| 2. Show a pairing code | VPS | `techia-vps pair show` |
| 3. Accept Desktops | VPS | `techia-vps serve --port 8443` |
| 4. Enter the code | Desktop Remote screen | `C` → type code → it pairs **and connects itself** |
| 5. Run things | Desktop Remote screen | `E` → program + args, output on screen |

TLS everywhere, fingerprint pinned on first connect (compare with
`pair show`), wrong certificates refused loudly. Live VPS-to-VPS shells
run programs directly — never through a shell string.

## 🧰 What's inside

| Piece | Role |
|---|---|
| **Desktop Techia** | Terminal UI: system, processes, network, vault, automation, themes, doctor |
| **VPS agent** | Linux monitoring + automation + the RDP serving side |
| **Bootstrapper** | Verified installer (`--sha256` always required, fail-closed) |
| **Techia Backend** | Central API on PostgreSQL: accounts, devices, machines, pairing, sync, releases |

## 🌐 Central backend

The public API (accounts/sync/pairing) runs 24×7 with a Postgres database
behind it. Desktop and VPS only ever talk HTTPS to the backend — database
credentials live server-side only, never in any download. A free status
pinger keeps the free tier awake so logins stay instant.

## 📦 Releases

Every release ships hash-verified assets (`SHA256SUMS` covers all files):

```diff
+ v1.5.0 (stable) — RDP wired, fingerprint pinning, console font, login gate
  v1.0.0 (stable) — central backend, cloud login, verified one-line installer
```

## 🛡️ Security model

- Passwords: Argon2id, verified server-side, never logged, never returned.
- Sessions: short access tokens (memory only) + rotating refresh tokens
  (OS keychain). Only SHA-256 hashes stored.
- Sync payloads stay end-to-end sealed; the server relays bytes it can't read.
- Releases: SHA-256 + Ed25519 verified before anything executes.
- Pairing codes: 5-minute TTL, one-time use, hash-stored.

## 📄 License

Proprietary — NextCore. All rights reserved.
