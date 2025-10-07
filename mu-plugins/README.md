# Must-Use Plugins (mu-plugins) Directory

Must-use plugins are WordPress plugins that are automatically loaded without needing to be activated through the WordPress admin interface. They load before regular plugins and cannot be disabled from the WordPress admin.

## How to Add MU-Plugins

### Option 1: Single File Plugin (Simple)

For simple plugins, just place the `.php` file directly in this directory.

**Example: `example-simple-plugin.php`**
```php
<?php
/**
 * Plugin Name: Example Simple MU-Plugin
 * Description: A simple must-use plugin example
 * Version: 1.0.0
 * Author: Your Name
 */

// Your plugin code here
add_action('wp_footer', function() {
    // This does nothing visible, just demonstrates the hook works
    error_log('Example Simple MU-Plugin loaded');
});
```

### Option 2: Plugin in Subdirectory (Complex)

For more complex plugins with multiple files, you need:
1. A subdirectory containing your plugin files
2. A loader file in the root `mu-plugins/` directory

**Directory Structure:**
```
mu-plugins/
├── my-complex-plugin/              # Plugin directory
│   ├── my-complex-plugin.php       # Main plugin file
│   ├── includes/                   # Additional files
│   │   └── helper-functions.php
│   └── assets/
│       └── style.css
└── my-complex-plugin-loader.php    # REQUIRED: Loader in root
```

**Example Plugin Directory: `my-complex-plugin/my-complex-plugin.php`**
```php
<?php
/**
 * Plugin Name: My Complex MU-Plugin
 * Description: A complex must-use plugin with multiple files
 * Version: 1.0.0
 * Author: Your Name
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('MY_COMPLEX_PLUGIN_PATH', __DIR__);
define('MY_COMPLEX_PLUGIN_URL', content_url('mu-plugins/my-complex-plugin'));

// Load additional files
require_once MY_COMPLEX_PLUGIN_PATH . '/includes/helper-functions.php';

// Main plugin class
class My_Complex_MU_Plugin {

    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('admin_notices', array($this, 'admin_notice'));
    }

    public function init() {
        // Initialization code
        error_log('My Complex MU-Plugin initialized');
    }

    public function admin_notice() {
        // This shows a notice in WordPress admin
        echo '<div class="notice notice-info"><p>My Complex MU-Plugin is active!</p></div>';
    }
}

// Initialize the plugin
new My_Complex_MU_Plugin();
```

**REQUIRED Loader File: `my-complex-plugin-loader.php`**
```php
<?php
/**
 * MU-Plugin Loader: My Complex Plugin
 *
 * This file must be in the root mu-plugins directory to load
 * the plugin from its subdirectory.
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Load the main plugin file from subdirectory
require_once WPMU_PLUGIN_DIR . '/my-complex-plugin/my-complex-plugin.php';
```

**Helper File Example: `my-complex-plugin/includes/helper-functions.php`**
```php
<?php
/**
 * Helper functions for My Complex MU-Plugin
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

function my_complex_plugin_helper() {
    // Helper function that does nothing but demonstrates structure
    return 'Helper function called';
}
```

## Complete Example: Do-Nothing MU-Plugin

Here's a complete example of a subdirectory plugin that doesn't do anything harmful but demonstrates the structure:

**File: `example-mu-plugin-loader.php` (in root mu-plugins/)**
```php
<?php
/**
 * MU-Plugin Loader: Example Do-Nothing Plugin
 */
if (!defined('ABSPATH')) exit;
require_once WPMU_PLUGIN_DIR . '/example-mu-plugin/example-mu-plugin.php';
```

**File: `example-mu-plugin/example-mu-plugin.php`**
```php
<?php
/**
 * Plugin Name: Example Do-Nothing MU-Plugin
 * Description: Demonstrates MU-plugin structure without doing anything visible
 * Version: 1.0.0
 */

if (!defined('ABSPATH')) exit;

class Example_MU_Plugin {

    private static $instance = null;

    public static function get_instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    private function __construct() {
        $this->init_hooks();
    }

    private function init_hooks() {
        // Hook into WordPress initialization
        add_action('init', array($this, 'on_init'));

        // Hook into admin initialization
        add_action('admin_init', array($this, 'on_admin_init'));

        // Add a custom filter (other code could use this)
        add_filter('example_mu_plugin_filter', array($this, 'example_filter'), 10, 1);
    }

    public function on_init() {
        // Runs on every page load (front-end and admin)
        // This just logs that the plugin loaded
        error_log('Example MU-Plugin: Initialized on ' . current_time('mysql'));
    }

    public function on_admin_init() {
        // Runs only in WordPress admin
        // Does nothing visible
        error_log('Example MU-Plugin: Admin initialized');
    }

    public function example_filter($value) {
        // Example filter that other code could use
        // Usage: $result = apply_filters('example_mu_plugin_filter', 'some value');
        return $value;
    }

    public function get_plugin_info() {
        // Example method that returns plugin information
        return array(
            'name' => 'Example Do-Nothing MU-Plugin',
            'version' => '1.0.0',
            'loaded' => true
        );
    }
}

// Initialize the plugin
Example_MU_Plugin::get_instance();
```

## Why Use a Loader File?

WordPress only automatically loads `.php` files in the **root** of the `mu-plugins/` directory. Files in subdirectories are ignored. The loader file acts as a bridge:

1. WordPress finds `my-plugin-loader.php` in the root
2. The loader file requires the main plugin file from the subdirectory
3. Your plugin loads with all its organized files

## Key Differences from Regular Plugins

| Feature | Regular Plugins | MU-Plugins |
|---------|----------------|------------|
| Activation | Must be activated in admin | Always active |
| Deactivation | Can be deactivated | Cannot be disabled |
| Load Order | After mu-plugins | First (before regular plugins) |
| Admin UI | Visible in Plugins page | Not shown (or separate list) |
| Auto-updates | Supported | Not supported |
| Subdirectories | Automatically detected | Need loader file |

## Best Practices

1. **Use for critical functionality** - Things that must always be active
2. **Keep it lightweight** - MU-plugins load on every request
3. **Document well** - Since they're "hidden" from admin UI
4. **Version control** - Keep them in your repository
5. **Test thoroughly** - They can't be easily disabled if something breaks

## Debugging

To verify your MU-plugins are loading:

1. Check WordPress admin: **Plugins → Must-Use**
2. Add logging: `error_log('My plugin loaded');`
3. View logs: `docker compose logs -f wordpress`
4. Use WP-CLI: `docker compose exec wordpress wp plugin list --status=must-use --allow-root`

## Common Use Cases

- Custom post types and taxonomies
- Site-wide security hardening
- Performance optimizations
- Custom admin functionality
- API integrations
- Development/debugging tools
- Multisite network functionality
