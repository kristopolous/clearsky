# Improved Google Photos API Flow

## What Changed

The user experience has been redesigned to make **API-based automatic download the primary flow**, with Google Takeout as a clearly-labeled fallback option.

## Before (Confusing)

- Both API setup AND Takeout instructions shown at the same time
- User had to choose between checkboxes
- Unclear which method was recommended
- Takeout felt like an equal option

## After (Clear & Simple)

### Primary Flow: API Download (Recommended)

```
┌─────────────────────────────────────────────────────────┐
│  ✅ Recommended: Automatic Download via API             │
│  Get an API key and Clearsky will download automatically│
│                                                         │
│  Get Your API Key:                                      │
│  1. Go to Google Cloud Console                          │
│  2. Create a project                                    │
│  3. Enable Google Photos Library API                    │
│  4. Create API Key                                      │
│  5. Paste key below                                     │
│                                                         │
│  [Paste your API key: ________________]                 │
│                                                         │
│  [🚀 Download My Photos Automatically]    (Big button)  │
│                                                         │
│  Having trouble with the API?                           │
│  [Use Google Takeout instead]  (Small secondary button) │
└─────────────────────────────────────────────────────────┘
```

### Fallback Flow: Google Takeout (Hidden by Default)

Only shown when user clicks "Use Google Takeout instead":

```
┌─────────────────────────────────────────────────────────┐
│  📦 Google Takeout (Manual Export)                      │
│  If the API isn't working for you:                      │
│                                                         │
│  1. Go to takeout.google.com                            │
│  2. Select Google Photos                                │
│  3. Download ZIP                                        │
│  4. Upload here                                         │
│                                                         │
│  [← Back to API download]                               │
└─────────────────────────────────────────────────────────┘
```

## User Journey

### API Flow (Primary)

1. **Select migration**: "Google Photos to Immich"
2. **See API setup** (shown by default)
3. **Get API key**: Click link to Google Cloud Console
4. **Paste key**: Input field with validation (checks for `AIzaSy` prefix)
5. **Click download**: Big green button "🚀 Download My Photos Automatically"
6. **Watch progress**: Real-time download and import progress
7. **Done**: Photos in Immich

### Takeout Flow (Fallback)

1. **Select migration**: "Google Photos to Immich"
2. **See API setup** (shown by default)
3. **Click "Use Google Takeout instead"**: Small link at bottom
4. **Takeout instructions appear**: API setup hidden
5. **Export from Takeout**: Follow instructions
6. **Upload ZIP**: Drag and drop
7. **Watch progress**: Import progress
8. **Done**: Photos in Immich

## Code Changes

### `app/index.html`

**New UI Structure:**
- `#api-key-setup` - Primary flow, shown by default for Google Photos
- `#manual-export-guide` - Fallback flow, hidden by default
- `#google-docs-guide` - For Google Docs migrations

**New Buttons:**
- `#btn-download-api` - Primary action (green, prominent)
- `#btn-show-manual` - Fallback trigger (small, secondary)
- `#btn-back-to-api` - Return to primary flow

**New JavaScript Functions:**
- `updateGuideForMigration()` - Shows appropriate guide based on migration
- `startMigrationWithApiKey()` - Runs migration with API key
- Toggle handlers for switching between API and Takeout

### Key UX Improvements

1. **Visual Hierarchy**
   - API setup has green accent color (success/recommended)
   - Download button is large, green, full-width
   - Takeout link is small, at bottom, secondary styling

2. **Progressive Disclosure**
   - Takeout instructions hidden until requested
   - Reduces cognitive load
   - Makes recommended path obvious

3. **Validation**
   - API key format checked (must start with `AIzaSy`)
   - Helpful error messages
   - Input focused on validation failure

4. **Clear Labels**
   - "Recommended" badge on API flow
   - "Fallback" language for Takeout
   - "Having trouble?" framing

## Google Docs Migration

For Google Docs → Etherpad, Takeout is the only option (no API available), so:
- Takeout instructions shown immediately
- No API key setup
- "Continue" button enabled to proceed with upload

## Migration Comparison

| Migration | Primary Flow | Fallback |
|-----------|-------------|----------|
| Google Photos → Immich | API Download | Takeout + Upload |
| Google Docs → Etherpad | Takeout + Upload | N/A |

## Testing Checklist

- [ ] API key input validates format
- [ ] Download button starts migration with API key
- [ ] Takeout toggle hides/shows appropriate sections
- [ ] Back to API button restores primary flow
- [ ] Progress shown during download/import
- [ ] Google Docs shows Takeout instructions directly

## Future Improvements

1. **OAuth 2.0 Flow**: Replace API key with full OAuth for better security
2. **Progress Indicators**: Show download progress (photos downloaded / total)
3. **Resume Support**: Resume interrupted downloads
4. **API Key Storage**: Securely store key for future use (optional)
5. **Error Recovery**: Better handling of API rate limits, network issues
