<?php
/**
 * Plugin Name: Example Complex MU-Plugin
 * Description: A complex must-use plugin with subdirectory structure (does nothing harmful)
 * Version: 1.0.0
 * Author: Development Team
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('EXAMPLE_COMPLEX_MU_PATH', __DIR__);
define('EXAMPLE_COMPLEX_MU_URL', content_url('mu-plugins/example-complex'));
define('EXAMPLE_COMPLEX_MU_VERSION', '1.0.0');

// Load additional files (if they exist)
$includes_path = EXAMPLE_COMPLEX_MU_PATH . '/includes/helper-functions.php';
if (file_exists($includes_path)) {
    require_once $includes_path;
}

/**
 * Main plugin class
 */
class Example_Complex_MU_Plugin {

    /**
     * Single instance of the class
     */
    private static $instance = null;

    /**
     * Get the singleton instance
     */
    public static function get_instance() {
        if (null === self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Constructor - sets up hooks
     */
    private function __construct() {
        $this->init_hooks();
    }

    /**
     * Initialize WordPress hooks
     */
    private function init_hooks() {
        // Hook into WordPress initialization
        add_action('init', array($this, 'on_init'));

        // Hook into admin initialization (only runs in admin)
        add_action('admin_init', array($this, 'on_admin_init'));

        // Add a custom filter (other code could use this)
        add_filter('example_complex_mu_filter', array($this, 'example_filter'), 10, 1);

        // Example admin notice
        add_action('admin_notices', array($this, 'admin_notice'));
    }

    /**
     * Runs on WordPress init
     */
    public function on_init() {
        // Log that the plugin initialized
        error_log('Example Complex MU-Plugin: Initialized at ' . current_time('mysql'));

        // Register a custom post type (example - commented out)
        // $this->register_custom_post_type();
    }

    /**
     * Runs on WordPress admin init
     */
    public function on_admin_init() {
        // Log admin initialization
        error_log('Example Complex MU-Plugin: Admin area initialized');
    }

    /**
     * Display admin notice (only visible in WordPress admin)
     */
    public function admin_notice() {
        // Only show on the plugins page
        $screen = get_current_screen();
        if ($screen && $screen->id === 'plugins') {
            echo '<div class="notice notice-info is-dismissible">';
            echo '<p><strong>Example Complex MU-Plugin</strong> is active and working!</p>';
            echo '</div>';
        }
    }

    /**
     * Example filter callback
     */
    public function example_filter($value) {
        // Other code could use this filter:
        // $result = apply_filters('example_complex_mu_filter', 'some value');
        return $value;
    }

    /**
     * Get plugin information
     */
    public function get_plugin_info() {
        return array(
            'name' => 'Example Complex MU-Plugin',
            'version' => EXAMPLE_COMPLEX_MU_VERSION,
            'path' => EXAMPLE_COMPLEX_MU_PATH,
            'url' => EXAMPLE_COMPLEX_MU_URL,
            'loaded' => true,
            'hooks_registered' => true
        );
    }

    /**
     * Example: Register a custom post type (commented out)
     */
    private function register_custom_post_type() {
        register_post_type('example_cpt', array(
            'labels' => array(
                'name' => 'Examples',
                'singular_name' => 'Example'
            ),
            'public' => true,
            'has_archive' => true,
            'supports' => array('title', 'editor', 'thumbnail'),
        ));
    }
}

// Initialize the plugin
Example_Complex_MU_Plugin::get_instance();
