# Local Editing with VSCode/Cursor

This guide explains how to edit WordPress plugins, themes, and mu-plugins locally using your preferred code editor.

## Two Approaches

### Option 1: Development Mode (Direct Bind Mounts) - RECOMMENDED

**Best for:** Active development where you're frequently editing code

**How it works:** Files are directly bind-mounted from your local machine into the container. Changes in either direction sync instantly.

**Pros:**
- ✅ Instant two-way sync (local → container, container → local)
- ✅ No restart needed to see changes
- ✅ Edit with VSCode/Cursor and changes appear immediately in WordPress
- ✅ WordPress can write files (plugin installs, theme customizer, etc.)

**Cons:**
- ⚠️ Slower on macOS/Windows due to Docker volume performance
- ⚠️ WordPress modifications to files will affect your local source

**Usage:**

```bash
# Start in development mode
docker compose -f compose.yml -f compose.dev.yml up -d

# Edit files locally in VSCode/Cursor
# Changes appear instantly in the container

# Stop
docker compose -f compose.yml -f compose.dev.yml down
```

**File Structure:**
```
cribops-wp/
├── plugins/          # Edit here with VSCode
│   ├── my-plugin/    # Directly mounted to /var/www/html/wp-content/plugins/
├── themes/           # Edit here with VSCode
│   └── my-theme/     # Directly mounted to /var/www/html/wp-content/themes/
└── mu-plugins/       # Edit here with VSCode
    └── my-mu.php     # Directly mounted to /var/www/html/wp-content/mu-plugins/
```

### Option 2: Production Mode (One-Way Copy) - DEFAULT

**Best for:** Testing production deployment or when you want to protect source files

**How it works:** Files are copied once from local directories to the container on startup. Local files are read-only and protected from WordPress modifications.

**Pros:**
- ✅ Protects your source files from WordPress modifications
- ✅ Better performance on macOS/Windows
- ✅ Simulates production deployment

**Cons:**
- ⚠️ Requires container restart to sync changes: `docker compose restart wordpress`
- ⚠️ One-way sync only (local → container)
- ⚠️ WordPress cannot modify files in wp-content (plugin installs won't affect local files)

**Usage:**

```bash
# Start in production mode (default)
docker compose up -d

# Edit files locally in VSCode/Cursor
# Then restart to sync changes:
docker compose restart wordpress

# Stop
docker compose down
```

## Setup Instructions

### For VSCode

1. **Open the project:**
   ```bash
   cd /path/to/cribops-wp
   code .
   ```

2. **Recommended extensions:**
   - PHP Intelephense (for PHP autocomplete)
   - WordPress Snippets
   - phpcs (PHP Code Sniffer)

3. **Start containers in dev mode:**
   ```bash
   docker compose -f compose.yml -f compose.dev.yml up -d
   ```

4. **Edit files in:**
   - `plugins/` - Your custom plugins
   - `themes/` - Your custom themes
   - `mu-plugins/` - Must-use plugins

### For Cursor

Same as VSCode - Cursor uses VSCode's extension ecosystem.

## Switching Between Modes

### Switch from Production → Development Mode

```bash
# Stop production mode
docker compose down

# Start development mode
docker compose -f compose.yml -f compose.dev.yml up -d
```

### Switch from Development → Production Mode

```bash
# Stop development mode
docker compose -f compose.yml -f compose.dev.yml down

# Start production mode
docker compose up -d
```

## File Permissions

When using **development mode**, you may encounter permission issues because:
- Container runs as `www-data` (UID 33)
- Your local user has a different UID

**Fix permission issues:**

```bash
# Option 1: Allow your user to read files created by container
docker compose -f compose.yml -f compose.dev.yml exec wordpress chown -R www-data:www-data /var/www/html/wp-content/plugins
docker compose -f compose.yml -f compose.dev.yml exec wordpress chown -R www-data:www-data /var/www/html/wp-content/themes
docker compose -f compose.yml -f compose.dev.yml exec wordpress chown -R www-data:www-data /var/www/html/wp-content/mu-plugins

# Option 2: Make files readable/writable by all (less secure but convenient)
docker compose -f compose.yml -f compose.dev.yml exec wordpress chmod -R 777 /var/www/html/wp-content/plugins
docker compose -f compose.yml -f compose.dev.yml exec wordpress chmod -R 777 /var/www/html/wp-content/themes
docker compose -f compose.yml -f compose.dev.yml exec wordpress chmod -R 777 /var/www/html/wp-content/mu-plugins
```

## Best Practices

### Development Workflow

1. **Start in development mode** for active coding:
   ```bash
   docker compose -f compose.yml -f compose.dev.yml up -d
   ```

2. **Edit locally** with VSCode/Cursor - changes appear instantly

3. **Test your changes** at https://wpdemo.local:8443

4. **Before committing**, test in production mode:
   ```bash
   # Switch to production mode
   docker compose -f compose.yml -f compose.dev.yml down
   docker compose up -d

   # Verify everything still works
   ```

### When to Use Each Mode

| Scenario | Mode | Command |
|----------|------|---------|
| Writing new plugin code | Development | `docker compose -f compose.yml -f compose.dev.yml up -d` |
| Debugging theme issues | Development | `docker compose -f compose.yml -f compose.dev.yml up -d` |
| Testing deployment | Production | `docker compose up -d` |
| Sharing with team | Production | `docker compose up -d` |
| Making quick edits | Development | `docker compose -f compose.yml -f compose.dev.yml up -d` |

## Troubleshooting

### Changes don't appear in container (Production Mode)

**Solution:** Restart the container to trigger the copy:
```bash
docker compose restart wordpress
```

### Changes don't appear in container (Development Mode)

**Issue:** This shouldn't happen with direct bind mounts.

**Debug:**
```bash
# Verify mounts
docker compose -f compose.yml -f compose.dev.yml exec wordpress ls -la /var/www/html/wp-content/plugins

# Check if using dev compose file
docker compose -f compose.yml -f compose.dev.yml ps
```

### Permission denied when editing locally

**Solution:** Fix permissions in container:
```bash
docker compose -f compose.yml -f compose.dev.yml exec wordpress chown -R www-data:www-data /var/www/html/wp-content
docker compose -f compose.yml -f compose.dev.yml exec wordpress chmod -R 755 /var/www/html/wp-content
```

### WordPress says "Could not create directory"

**In Production Mode:** This is expected - WordPress cannot write to one-way mounted directories.

**In Development Mode:** Fix permissions:
```bash
docker compose -f compose.yml -f compose.dev.yml exec wordpress chmod -R 777 /var/www/html/wp-content/plugins
docker compose -f compose.yml -f compose.dev.yml exec wordpress chmod -R 777 /var/www/html/wp-content/themes
```

## Creating Aliases (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# WordPress development aliases
alias wp-dev='docker compose -f compose.yml -f compose.dev.yml'
alias wp-prod='docker compose'

# Usage:
# wp-dev up -d          # Start development mode
# wp-dev down           # Stop development mode
# wp-prod up -d         # Start production mode
# wp-prod down          # Stop production mode
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

Now you can use:
```bash
wp-dev up -d     # Development mode
wp-prod up -d    # Production mode
```
