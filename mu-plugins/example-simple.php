<?php
/**
 * Plugin Name: Example Simple MU-Plugin
 * Description: A simple must-use plugin that does nothing harmful (just logs)
 * Version: 1.0.0
 * Author: Development Team
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Simple example that logs when WordPress initializes
 * This demonstrates that the MU-plugin is loading correctly
 */
add_action('init', function() {
    error_log('Example Simple MU-Plugin: WordPress initialized at ' . current_time('mysql'));
});

/**
 * Example filter that other code could use
 * Usage: $result = apply_filters('example_simple_mu_filter', 'test');
 */
add_filter('example_simple_mu_filter', function($value) {
    return $value;
}, 10, 1);
