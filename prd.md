# Clearsky: No More Clouds - Product Requirements Document (PRD)

## 1. Overview
### 1.1 Product Name
Clearsky: No More Clouds

### 1.2 Product Description
Clearsky is a user-friendly, double-clickable desktop application that guides non-technical users through migrating their data from cloud services (e.g., Google Photos, Google Drive/Docs) to self-hosted, privacy-focused alternatives. It emphasizes data sovereignty by running everything locally on the user's machine, using containerized services orchestrated via Nix for reproducibility and safety. The app hides all technical complexity behind a simple graphical wizard, making self-hosting feel like a normal app installation.

The app is packaged as an AppImage for easy distribution and execution on Linux systems (primarily Ubuntu or NixOS for hackathon judges), with potential for Windows/Mac extension. It leverages Nix flakes for building reproducible OCI containers (e.g., for Immich, Etherpad, Tailscale) that handle the self-hosted services.

### 1.3 Version
1.0 (MVP for NixOS Hackathon)

### 1.4 Document Purpose
This PRD outlines the requirements for building Clearsky, to be fed into a coding agent for implementation. It focuses on making sovereign computing accessible, aligning with the hackathon theme of closing the gap between Nix's power and non-expert usability.

## 2. Goals and Objectives
### 2.1 Business Goals
- Enable non-technical users (e.g., families, privacy-conscious Europeans) to reclaim data from clouds without learning terminals or configs.
- Showcase Nix's strengths: reproducibility, declarative orchestration, atomic rollbacks—while hiding them.
- Win hackathon by providing a demo-friendly, emotionally resonant tool (e.g., "Get family photos off Google in 5 minutes").
- Promote data sovereignty subtly (e.g., GDPR-friendly local storage).

### 2.2 User Goals
- Migrate data effortlessly from clouds to local/self-hosted setups.
- Access migrated data securely from anywhere (via Tailscale).
- Feel in control with easy undo/rollback if something goes wrong.
- Avoid subscriptions and privacy risks without ideological lectures.

### 2.3 Success Metrics
- User can complete a full migration (e.g., Google Photos to Immich) in under 10 minutes without errors.
- App runs on standard Ubuntu without Nix installed; seamless on NixOS.
- Demo: Double-click AppImage → wizard → migration → access local dashboard.
- Rollback works atomically (e.g., revert to pre-migration state).

## 3. Target Audience
- Primary: Non-technical users (e.g., parents, small business owners) tired of cloud costs/privacy issues but intimidated by self-hosting.
- Secondary: Hackathon judges/developers on Linux (Ubuntu/NixOS) who value Nix but want accessible tools.
- Demographics: Europeans (GDPR focus), ages 30-60, basic computer skills (can download ZIPs, follow prompts).
- Pain Points: Cloud lock-in, data export hassles, fear of breaking setups.
- Assumptions: Users have a Linux machine (for MVP); access to Google/iCloud accounts for exports.

## 4. Features
### 4.1 Core Features
1. **Double-Clickable AppImage Launcher**
   - Single-file executable (~500MB-1GB) that bundles Electron GUI, Podman runtime, and pre-built OCI images.
   - On launch: Checks for Podman (guide install if missing, e.g., via system package manager).
   - Tray icon for ongoing status (e.g., "Migration in progress", "Open dashboard").

2. **Graphical Migration Wizard**
   - Electron-based UI (React or simple HTML/CSS/JS for MVP).
   - Steps:
     - Welcome screen: "No more clouds! What services do you use?" (checkboxes: Google Photos, Google Drive/Docs, etc.).
     - Service-specific guidance: Links to export tools (e.g., takeout.google.com), step-by-step instructions with screenshots.
     - File handling: Drag-drop zone for exported ZIPs; auto-detection of downloads folder.
     - Progress bars for imports (e.g., unzip, metadata preservation).
     - Confirmation: "Preview" button to test services before commit.
   - Theming: Clean, friendly (blue skies motif for "Clearsky").

3. **Containerized Self-Hosted Services**
   - Orchestrated via Podman (rootless for safety).
   - Services (MVP focus on Photos and Docs):
     - Photos: Immich (OCI image with server, CLI tools like immich-go for import).
     - Docs: Etherpad or Nextcloud Office lite (for collaborative editing).
     - Remote Access: Tailscale client (auto-auth wizard; joins user's tailnet).
   - Data storage: Persistent volumes in `~/Clearsky` (e.g., ~/Clearsky/photos).
   - Auto-start: Services run in background containers; dashboard links (e.g., http://localhost:2283 for Immich).

4. **Migration Tools**
   - Google Photos → Immich: Use immich-go to import ZIPs, preserving albums/EXIF.
   - Google Docs → Etherpad: Export as Markdown/ODT, upload via wizard.
   - Error handling: Graceful retries, user-friendly messages (e.g., "ZIP too large? Try splitting.").

5. **Safety and Rollback**
   - Atomic operations: Use Podman image tags for versions (e.g., pull v1.0 for rollback).
   - "Undo" button in wizard: Reverts volumes to snapshots or restarts with previous config.
   - Sandbox mode: Test migrations in temp containers before applying to real data.

### 4.2 Nice-to-Have Features (Post-MVP)
- Expand to more services (e.g., Calendar → Radicale, Files → Nextcloud).
- AI-assisted prompts (tiny local LLM via Ollama container for "How do I export?").
- Windows/Mac support (via Podman Desktop or WSL).
- Multi-user/family accounts.

## 5. User Flows
### 5.1 Primary Flow: Google Photos Migration
1. Double-click Clearsky.AppImage.
2. Wizard opens: Select "Google Photos".
3. Guide: "Go to takeout.google.com, select Photos, download ZIP" (embedded link/browser).
4. Drag-drop ZIP or browse to file.
5. Wizard unzips/imports via containerized immich-go (progress bar).
6. Set up Tailscale: "Want remote access? Authenticate here" (embedded auth flow).
7. Preview: Open temporary Immich dashboard to verify.
8. Commit: Apply changes; services now running persistently.
9. Done: "Your photos are local! Access via app tray."

### 5.2 Error/Rollback Flow
1. During import: Error detected (e.g., corrupt file).
2. Prompt: "Retry or undo?"
3. Undo: Roll back container state; delete temp data.
4. Success: User can restart wizard.

## 6. Technical Requirements
### 6.1 Platform
- Target OS: Linux (Ubuntu 20.04+, NixOS for judges).
- Runtime: Podman 4.0+ (rootless mode).
- Build Tool: Nix flakes (for reproducible AppImage and OCI images).

### 6.2 Stack
- Frontend: Electron (with Node.js for Podman exec).
- Backend: Podman for containers; Nix-generated OCI images (using dockerTools.buildImage).
- Tools: immich-go (Nix-packaged), Tailscale CLI.
- Dependencies: Bundled in AppImage (glibc, fuse, etc.).

### 6.3 Data Handling
- Persistent storage: Host-mounted volumes (~/.clearsky).
- Security: No root access; container isolation; secrets (e.g., Tailscale keys) via environment vars.

### 6.4 Build Process
- Nix flake: Outputs include appimage, devShell for testing.
- Command: `nix build .#appimage` → Clearsky.AppImage.

## 7. Non-Functional Requirements
### 7.1 Performance
- Startup: <10s to wizard.
- Migration: Handle 10GB ZIPs without crashing (chunked processing).
- Resource Use: <4GB RAM, <2 CPU cores (configurable via cgroups in Podman).

### 7.2 Usability
- No terminal exposure.
- Accessible: High-contrast UI, keyboard navigation.
- Localization: English MVP; easy to add (e.g., EU languages).

### 7.3 Security
- Local-only by default; Tailscale for remote.
- No data sent externally (all processing in containers).
- Compliance: GDPR-friendly (data stays local).

### 7.4 Reliability
- Error recovery: Auto-retry failed imports.
- Logging: Simple tray notifications; debug logs in ~/.clearsky/logs.

## 8. Assumptions and Dependencies
- Assumptions: Users can download large ZIPs; have internet for initial Takeout/Tailscale auth.
- Dependencies: Podman installed (app guides if missing); Nix for building (not runtime).
- External: Google Takeout API (no auth needed); Tailscale account (free tier).

## 9. Risks and Mitigations
- Risk: Large files overwhelm resources → Mitigation: Streamed processing, size warnings.
- Risk: Podman not installed → Mitigation: In-app install guide (e.g., "Run sudo apt install podman").
- Risk: Compatibility on non-Ubuntu → Mitigation: Test on NixOS; bundle fallbacks.
- Risk: Hackathon time crunch → Mitigation: MVP on one migration (Photos).

## 10. Appendix
- Wireframes: [Describe simple sketches – e.g., Welcome screen with checkboxes, progress bar page.]
- References: NixOS modules for Immich/Tailscale; Podman docs; immich-go GitHub.

This PRD provides a complete blueprint for the coding agent to implement Clearsky. Focus on MVP: AppImage + Wizard + Photos Migration.
