# Clearsky CLI

Command-line interface for testing and running Clearsky migrations.

## Installation

No installation needed - the CLI is included with Clearsky.

## Usage

```bash
# Show help
node clearsky-cli.js help

# List available migrations
node clearsky-cli.js list

# Validate a migration (check it can run)
node clearsky-cli.js validate google-photos-to-immich

# Run a migration with API key
node clearsky-cli.js run google-photos-to-immich --api-key AIzaSy...

# Run a migration with ZIP file
node clearsky-cli.js run google-photos-to-immich --zip ~/Downloads/takeout.zip

# Run with verbose logging
node clearsky-cli.js run nextcloud-setup --verbose

# Dry run (validate without executing)
node clearsky-cli.js run google-photos-to-immich --dry-run

# Check running services
node clearsky-cli.js status
```

## Safety Guarantees

### COPY-Only Operations

**All migrations COPY data from cloud services. They NEVER:**
- Delete data from cloud services
- Modify data in cloud services
- Revoke your access to cloud services

### Abort Anytime

**You can stop the migration at any time:**
- Press Ctrl+C to abort
- Your cloud data remains untouched
- You can continue using cloud services as before

### Failed Migrations

**If a migration fails:**
- Your cloud data is SAFE
- No partial changes are made
- You can retry or continue using cloud services

## Output

### Colors

- 🟢 Green: Success
- 🔴 Red: Error
- 🟡 Yellow: Warning
- 🔵 Blue: Info
- 🟣 Cyan: Verbose

### Verbose Mode

Use `--verbose` or `-v` to see:
- Nix build output
- Flake evaluation details
- Container startup logs
- Step-by-step progress

## Example: Google Photos Migration

```bash
# First validate
node clearsky-cli.js validate google-photos-to-immich

# Then run with API key
node clearsky-cli.js run google-photos-to-immich --api-key AIzaSy...

# Or run with Takeout ZIP
node clearsky-cli.js run google-photos-to-immich --zip ~/Downloads/takeout.zip
```

## Example: Nextcloud Setup

```bash
# Validate
node clearsky-cli.js validate nextcloud-setup

# Run setup
node clearsky-cli.js run nextcloud-setup

# Check status
node clearsky-cli.js status
```

## Troubleshooting

### "Nix is not installed"

Install Nix:
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.nixos.sh | sh
```

### "Failed to build migration"

Run with verbose to see details:
```bash
node clearsky-cli.js run google-photos-to-immich --verbose
```

### "Command not found: clearsky-cli"

Run from the project directory:
```bash
cd /path/to/clearsky
node clearsky-cli.js <command>
```

Or add an alias:
```bash
alias clearsky-cli='node /path/to/clearsky/clearsky-cli.js'
```

## Architecture

The CLI:
1. Validates migration files exist
2. Checks Nix is available
3. Sources Nix environment
4. Builds migration with `nix build`
5. Executes migration script
6. Streams output to terminal

All operations are logged with timestamps for debugging.
