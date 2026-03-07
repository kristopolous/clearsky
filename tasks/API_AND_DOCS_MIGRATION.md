# Google Photos API and Google Docs Migrations

## What Was Implemented

### 1. Google Docs to Etherpad Migration ✅

Created a complete migration path from Google Docs to Etherpad:

**Files Created:**
- `migrations/google-docs-to-etherpad/flake.nix` - Migration flake definition
- `migrations/google-docs-to-etherpad/migrate.nix` - Migration script
- `migrations/harnesses/import-etherpad.nix` - Etherpad import harness

**How It Works:**
1. User exports Google Docs from Google Takeout
2. Clearsky starts Etherpad container on port 9001
3. Documents (HTML, TXT, MD) are imported via Etherpad API
4. User accesses documents at `http://localhost:9001`

### 2. Google Photos API Integration ✅

Added automatic photo download using the Google Photos Library API:

**Files Created:**
- `migrations/harnesses/google-photos-download.nix` - API-based download harness

**Updated Files:**
- `migrations/google-photos-to-immich/migrate.nix` - Now supports both API and manual modes
- `migrations/harnesses/default.nix` - Registered new harnesses

**Two Modes:**
1. **API Mode (Recommended)**: User provides API key, photos download automatically
2. **Manual Mode**: User exports from Google Takeout and uploads ZIP file

### 3. UI for API Key Setup ✅

**Updated `app/index.html`:**

Added API key setup section with:
- Step-by-step instructions for getting a Google Photos API key
- Secure password input field for the API key
- Toggle between API mode and manual export
- Migration-specific guides (different instructions for Photos vs Docs)

**Instructions Provided:**
1. Go to Google Cloud Console
2. Create/select a project
3. Enable Google Photos Library API
4. Create API Key in Credentials
5. Paste key into Clearsky

### 4. Backend API Key Handling ✅

**Updated `app/main.js`:**

- `runMigration()` now accepts `options` parameter
- API key passed via `GOOGLE_PHOTOS_API_KEY` environment variable
- ZIP file path passed via `GOOGLE_PHOTOS_ZIP` environment variable
- Output streaming for real-time progress

## How to Use

### Google Photos Migration (API Mode)

1. Select "Google Photos to Immich" migration
2. Click "Set Up Google Photos API Access"
3. Follow instructions to get API key from Google Cloud Console
4. Paste API key into the input field
5. Ensure "Use API key for automatic download" is checked
6. Click Continue → Import
7. Photos download automatically and import to Immich

### Google Photos Migration (Manual Mode)

1. Select "Google Photos to Immich" migration
2. Check "I'll manually export from Google Takeout instead"
3. Go to takeout.google.com and export Photos
4. Download ZIP file
5. Drag and drop ZIP file into Clearsky
6. Click Import

### Google Docs Migration

1. Select "Google Docs to Etherpad" migration
2. Go to takeout.google.com and export Drive/Docs
3. Download ZIP file
4. Drag and drop ZIP file into Clearsky
5. Click Import
6. Access documents at http://localhost:9001

## Migration Registry

Updated `migrations/registry.nix` now includes:

```nix
{
  google-photos-to-immich = ...;
  google-docs-to-etherpad = ...;
}
```

## Harnesses Available

| Harness | Purpose |
|---------|---------|
| `download` | Download from URL |
| `extract` | Extract ZIP/TAR archives |
| `import-immich` | Import photos to Immich |
| `import-etherpad` | Import documents to Etherpad |
| `google-photos-download` | Download via Google Photos API |

## Security Notes

- API keys are stored only in memory during the session
- Keys are passed via environment variables (not logged)
- Keys never sent to external servers (only to Google's API)
- UI uses password input type to hide key on screen

## Next Steps

1. **OAuth 2.0 Support**: Upgrade from API key to full OAuth for better security
2. **Progress Tracking**: Show download progress for API mode
3. **Resume Support**: Resume interrupted downloads
4. **More Services**: Add migrations for Calendar, Contacts, etc.
