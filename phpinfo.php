<?php
/**
 * PHP Info Page
 *
 * Access this at: http://localhost:8090/phpinfo.php
 *
 * SECURITY WARNING: Remove this file from production environments!
 */

// Only show if logged in as admin (when WordPress is loaded)
if (file_exists('wp-load.php')) {
    require_once('wp-load.php');
    if (!current_user_can('manage_options')) {
        wp_die('You must be logged in as an administrator to view this page.');
    }
}

?>
<!DOCTYPE html>
<html>
<head>
    <title>PHP Configuration Info</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .info-section { background: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .warning { background: #fff3cd; padding: 10px; border: 1px solid #ffc107; border-radius: 3px; margin-bottom: 20px; }
        table { width: 100%; border-collapse: collapse; margin: 10px 0; }
        th, td { text-align: left; padding: 8px; border-bottom: 1px solid #ddd; }
        th { background: #e9ecef; font-weight: bold; }
        .success { color: #28a745; font-weight: bold; }
        .error { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <h1>PHP Configuration Info</h1>

    <div class="warning">
        ⚠️ <strong>Security Warning:</strong> This file should be removed from production environments!
    </div>

    <div class="info-section">
        <h2>Upload Configuration</h2>
        <table>
            <tr>
                <th>Setting</th>
                <th>Value</th>
                <th>Status</th>
            </tr>
            <tr>
                <td>upload_max_filesize</td>
                <td><?php echo ini_get('upload_max_filesize'); ?></td>
                <td class="<?php echo (intval(ini_get('upload_max_filesize')) >= 512) ? 'success' : 'error'; ?>">
                    <?php echo (intval(ini_get('upload_max_filesize')) >= 512) ? '✓ Good' : '✗ Too Small'; ?>
                </td>
            </tr>
            <tr>
                <td>post_max_size</td>
                <td><?php echo ini_get('post_max_size'); ?></td>
                <td class="<?php echo (intval(ini_get('post_max_size')) >= 512) ? 'success' : 'error'; ?>">
                    <?php echo (intval(ini_get('post_max_size')) >= 512) ? '✓ Good' : '✗ Too Small'; ?>
                </td>
            </tr>
            <tr>
                <td>memory_limit</td>
                <td><?php echo ini_get('memory_limit'); ?></td>
                <td class="<?php echo (intval(ini_get('memory_limit')) >= 512) ? 'success' : 'error'; ?>">
                    <?php echo (intval(ini_get('memory_limit')) >= 512) ? '✓ Good' : '✗ Too Small'; ?>
                </td>
            </tr>
            <tr>
                <td>max_execution_time</td>
                <td><?php echo ini_get('max_execution_time'); ?> seconds</td>
                <td class="<?php echo (intval(ini_get('max_execution_time')) >= 300) ? 'success' : 'error'; ?>">
                    <?php echo (intval(ini_get('max_execution_time')) >= 300) ? '✓ Good' : '✗ Too Short'; ?>
                </td>
            </tr>
            <tr>
                <td>max_input_time</td>
                <td><?php echo ini_get('max_input_time'); ?> seconds</td>
                <td class="<?php echo (intval(ini_get('max_input_time')) >= 300) ? 'success' : 'error'; ?>">
                    <?php echo (intval(ini_get('max_input_time')) >= 300) ? '✓ Good' : '✗ Too Short'; ?>
                </td>
            </tr>
            <tr>
                <td>max_input_vars</td>
                <td><?php echo ini_get('max_input_vars'); ?></td>
                <td class="success">✓</td>
            </tr>
        </table>
    </div>

    <div class="info-section">
        <h2>WordPress Constants</h2>
        <table>
            <tr>
                <th>Constant</th>
                <th>Value</th>
            </tr>
            <?php if (defined('WP_MEMORY_LIMIT')): ?>
            <tr>
                <td>WP_MEMORY_LIMIT</td>
                <td><?php echo WP_MEMORY_LIMIT; ?></td>
            </tr>
            <?php endif; ?>
            <?php if (defined('WP_MAX_MEMORY_LIMIT')): ?>
            <tr>
                <td>WP_MAX_MEMORY_LIMIT</td>
                <td><?php echo WP_MAX_MEMORY_LIMIT; ?></td>
            </tr>
            <?php endif; ?>
            <?php if (defined('WP_DEBUG')): ?>
            <tr>
                <td>WP_DEBUG</td>
                <td><?php echo WP_DEBUG ? 'true' : 'false'; ?></td>
            </tr>
            <?php endif; ?>
        </table>
    </div>

    <div class="info-section">
        <h2>Server Information</h2>
        <table>
            <tr>
                <td>PHP Version</td>
                <td><?php echo phpversion(); ?></td>
            </tr>
            <tr>
                <td>Server Software</td>
                <td><?php echo $_SERVER['SERVER_SOFTWARE']; ?></td>
            </tr>
            <tr>
                <td>Server Name</td>
                <td><?php echo $_SERVER['SERVER_NAME']; ?></td>
            </tr>
            <tr>
                <td>Document Root</td>
                <td><?php echo $_SERVER['DOCUMENT_ROOT']; ?></td>
            </tr>
        </table>
    </div>

    <div class="info-section">
        <h2>Full PHP Info</h2>
        <p><a href="?full=1">Show Full PHP Info</a></p>
        <?php
        if (isset($_GET['full']) && $_GET['full'] == '1') {
            phpinfo();
        }
        ?>
    </div>

</body>
</html>