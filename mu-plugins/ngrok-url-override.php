<?php
/**
 * Plugin Name: Ngrok URL Override
 * Description: Forces WordPress to use ngrok URLs when accessed via ngrok tunnel
 * Version: 1.0.0
 */

// Exit if accessed directly
if (!defined('ABSPATH')) {
    exit;
}

/**
 * Detect if the request is coming through ngrok and override URLs
 */
function ngrok_override_urls() {
    // Check if we're being accessed via ngrok
    if (!empty($_SERVER['HTTP_HOST']) && strpos($_SERVER['HTTP_HOST'], 'ngrok') !== false) {
        $ngrok_url = 'https://' . $_SERVER['HTTP_HOST'];

        // Override siteurl and home options with filters
        // These filters run AFTER database retrieval, forcing the value
        add_filter('option_siteurl', function($value) use ($ngrok_url) {
            return $ngrok_url;
        }, 99);

        add_filter('option_home', function($value) use ($ngrok_url) {
            return $ngrok_url;
        }, 99);

        // Also override when WordPress tries to build URLs
        add_filter('site_url', function($url) use ($ngrok_url) {
            return str_replace(get_option('siteurl'), $ngrok_url, $url);
        }, 99, 1);

        add_filter('home_url', function($url) use ($ngrok_url) {
            return str_replace(get_option('home'), $ngrok_url, $url);
        }, 99, 1);

        // Force HTTPS
        $_SERVER['HTTPS'] = 'on';
        $_SERVER['SERVER_PORT'] = 443;
    }
}

// Run early, but after WordPress core loads
add_action('muplugins_loaded', 'ngrok_override_urls', 1);
