<?php
/**
 * Helper functions for Example Complex MU-Plugin
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Example helper function that returns plugin info
 *
 * @return string Plugin information
 */
function example_complex_mu_get_info() {
    $plugin = Example_Complex_MU_Plugin::get_instance();
    return $plugin->get_plugin_info();
}

/**
 * Example helper function that does nothing but demonstrates structure
 *
 * @param string $message Message to log
 * @return bool Always returns true
 */
function example_complex_mu_log($message) {
    error_log('Example Complex MU-Plugin: ' . $message);
    return true;
}

/**
 * Example helper to check if the plugin is active
 *
 * @return bool Always true (since MU-plugins are always active)
 */
function is_example_complex_mu_active() {
    return true;
}

/**
 * Example helper to get plugin version
 *
 * @return string Plugin version
 */
function example_complex_mu_version() {
    return defined('EXAMPLE_COMPLEX_MU_VERSION') ? EXAMPLE_COMPLEX_MU_VERSION : '1.0.0';
}
