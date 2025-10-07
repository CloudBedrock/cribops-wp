<?php
/**
 * MU-Plugin Loader: Example Complex Plugin
 *
 * This file MUST be in the root mu-plugins directory to load
 * the plugin from its subdirectory.
 *
 * WordPress only automatically loads .php files in the root of mu-plugins/.
 * Files in subdirectories are ignored unless explicitly loaded via a loader file.
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Load the main plugin file from subdirectory
require_once WPMU_PLUGIN_DIR . '/example-complex/example-complex.php';
