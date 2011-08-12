<?php

/**
 * @file 
 * Provides an option to select patterns to be executed during the site installation 
 */
 
/**
* Return an array of the modules to be enabled when this profile is installed.
*
* @return
*   An array of modules to enable.
*/
function patterns_profile_profile_modules() {
	// Take the opportunity to check a few requirements before the DB is installed
	$path = conf_path() .'/files';
	if (!is_dir($path)) {
		drupal_maintenance_theme();
		drupal_set_message(st('Files directory !dir does not exist. Please create and ensure it is writable before continuing.', array('!dir' => $path)), 'error');
	
		drupal_set_title(st('Incompatible environment'));
		print theme('install_page', '');
		exit;
	}
	else if (!is_writable($path)) {
		drupal_maintenance_theme();
		drupal_set_message(st('Files directory !dir is not writable. Please ensure it is writable by the web processes before continuing.', array('!dir' => $path)), 'error');
	
		drupal_set_title(st('Incompatible environment'));
		print theme('install_page', '');
		exit;
	}

    return array(
      // default core modules
      'color', 'comment', 'help', 'menu', 'taxonomy', 'dblog',

      // modules required by patterns
      'patterns', 'token', 'libraries',

    );
}


/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 *   An array with keys 'name' and 'description' describing this profile,
 *   and optional 'language' to override the language selection for
 *   language-specific profiles.
 */
function patterns_profile_profile_detailTODO() {
  return array(
    'name' => 'Patterns Profile',
    'description' => 'Configure the site by using patterns'
  );
}

/**
 * Return a list of tasks that this profile supports.
 *
 * @return
 *   A keyed array of tasks the profile will perform during
 *   the final stage. The keys of the array will be used internally,
 *   while the values will be displayed to the user in the installer
 *   task list.
 */
function patterns_profile_profile_task_listTODO() {
  $tasks = array(
    'select-patterns' => st('Select patterns'),
    'patterns-status' => st('Patterns status'),
  );
  return $tasks;
}

/**
* Implements hook_install_tasks().
*/
function patterns_profile_install_tasks() {
  $tasks = array();

  // Add a page for selecting patterns
  $tasks['patterns_profile_form'] = array(
   'display_name' => st('Select Pattern'),
   'type' => 'form',
  );

  return $tasks;
}
/**
 * Perform any final installation tasks for this profile.
 *
 * The installer goes through the profile-select -> locale-select
 * -> requirements -> database -> profile-install-batch
 * -> locale-initial-batch -> configure -> locale-remaining-batch
 * -> finished -> done tasks, in this order, if you don't implement
 * this function in your profile.
 *
 * If this function is implemented, you can have any number of
 * custom tasks to perform after 'configure', implementing a state
 * machine here to walk the user through those tasks. First time,
 * this function gets called with $task set to 'profile', and you
 * can advance to further tasks by setting $task to your tasks'
 * identifiers, used as array keys in the hook_profile_task_list()
 * above. You must avoid the reserved tasks listed in
 * install_reserved_tasks(). If you implement your custom tasks,
 * this function will get called in every HTTP request (for form
 * processing, printing your information screens and so on) until
 * you advance to the 'profile-finished' task, with which you
 * hand control back to the installer. Each custom page you
 * return needs to provide a way to continue, such as a form
 * submission or a link. You should also set custom page titles.
 *
 * You should define the list of custom tasks you implement by
 * returning an array of them in hook_profile_task_list(), as these
 * show up in the list of tasks on the installer user interface.
 *
 * Remember that the user will be able to reload the pages multiple
 * times, so you might want to use variable_set() and variable_get()
 * to remember your data and control further processing, if $task
 * is insufficient. Should a profile want to display a form here,
 * it can; the form should set '#redirect' to FALSE, and rely on
 * an action in the submit handler, such as variable_set(), to
 * detect submission and proceed to further tasks. See the configuration
 * form handling code in install_tasks() for an example.
 *
 * Important: Any temporary variables should be removed using
 * variable_del() before advancing to the 'profile-finished' phase.
 *
 * @param $task
 *   The current $task of the install system. When hook_profile_tasks()
 *   is first called, this is 'profile'.
 * @param $url
 *   Complete URL to be used for a link or form action on a custom page,
 *   if providing any, to allow the user to proceed with the installation.
 *
 * @return
 *   An optional HTML string to display to the user. Only used if you
 *   modify the $task, otherwise discarded.
 */
/* TODO: how to get this function called? */
function patterns_profile_profile_tasks(&$task, $url) {
  variable_set('patterns_profile_redirect_url', $url);

  if ($task == 'profile') {
    // Insert default user-defined node types into the database. For a complete
    // list of available node type attributes, refer to the node type API
    // documentation at: http://api.drupal.org/api/HEAD/function/hook_node_info.
    $types = array(
      array(
        'type' => 'page',
        'name' => st('Page'),
        'module' => 'node',
        'description' => st("A <em>page</em>, similar in form to a <em>story</em>, is a simple method for creating and displaying information that rarely changes, such as an \"About us\" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site's initial home page."),
        'custom' => TRUE,
        'modified' => TRUE,
        'locked' => FALSE,
        'help' => '',
        'min_word_count' => '',
      ),
      array(
        'type' => 'story',
        'name' => st('Story'),
        'module' => 'node',
        'description' => st("A <em>story</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with a <em>story</em> entry. By default, a <em>story</em> entry is automatically featured on the site's initial home page, and provides the ability to post comments."),
        'custom' => TRUE,
        'modified' => TRUE,
        'locked' => FALSE,
        'help' => '',
        'min_word_count' => '',
      ),
    );
  
    foreach ($types as $type) {
      $type = (object) _node_type_set_defaults($type);
      node_type_save($type);
    }
  
    // Default page to not be promoted and have comments disabled.
    variable_set('node_options_page', array('status'));
    variable_set('comment_page', COMMENT_NODE_DISABLED);
  
    // Don't display date and author information for page nodes by default.
    $theme_settings = variable_get('theme_settings', array());
    $theme_settings['toggle_node_info_page'] = FALSE;
    variable_set('theme_settings', $theme_settings);
  
    // Update the menu router information.
    menu_rebuild();
    
    $task = 'select-patterns';
  }
  
  if ($task == 'select-patterns') {
    if (variable_get('patterns_profile_executed', FALSE)) {
      $patterns = variable_get('patterns_profile_selected', array());
      $failed = array();
      foreach ($patterns as $name) {
        $pattern = patterns_get_pattern($name);
        if (!$pattern->status) {
          $failed[] = $pattern->title;
        }
      }
      if (empty($failed)) {
        $task = 'profile-finished';  
      }
      else {
        $task = 'patterns-status';
        drupal_set_title(t('Patterns Execution Failed!'));  
        $message = t('An error occurred while executing following @pattern:', array('@pattern' => format_plural(count($failed), 'pattern', 'patterns')));
        $message .= theme('item_list', $failed);
        $message .= '<p>'. t('After the installation is complete, you can run patterns again from the patterns administration page.') . '</p>';
        $message .= '<strong>'. l(t('Proceed with the installation.'), variable_get('patterns_profile_redirect_url', '')) .'</strong>';
        return $message;
      }
    }
    else {
      drupal_set_title(t('Select Patterns'));
      return drupal_get_form('patterns_profile_form', $url);      
    }
  }
  
  if ($task == 'patterns-status') {
    $task = 'profile-finished';
    variable_del('patterns_profile_executed');
    variable_del('patterns_profile_selected');
    variable_del('patterns_profile_redirect_url');
  }
}

/**
 * Implementation of hook_form_alter().
 *
 * Allows the profile to alter the site-configuration form. This is
 * called through custom invocation, so $form_state is not populated.
 */
function patterns_profile_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {    
    // Set default for site name field.
    $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
  }
}
function patterns_profile_form_alter_old(&$form, $form_state, $form_id) {
	if ($form_id == 'install_configure') {
		// Set default for site name field.
		$form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
	}
}

function patterns_profile_form($form, &$form_state, $url) {

  $patterns = patterns_get_patterns(true);
  foreach($patterns as $pattern) {
    $options[$pattern->name] = $pattern->title .'<div class="description">'. $pattern->description .'</description>'; 
  }

  $form['description'] = array(
    '#type' => 'markup',
    '#value' => t("Patterns provide additional features and functionality to Drupal sites and save your time by setting them up automatically for you. Please choose the patterns that you would like to setup on your new site."),
  );

  $form['patterns'] = array(
    '#type' => 'checkboxes',
    '#title' => t('Select which patterns to run'),
    '#options' => $options,
  );

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save and Continue'),
  );

//  $form['#action'] = $url;
//  $form['#redirect'] = variable_get('patterns_profile_redirect_url', '');
  return $form;
}
function patterns_profile_form_old($form, &$form_state, $url) {

	$patterns = patterns_get_patterns(true);
	foreach($patterns as $pattern) {
		$options[$pattern->name] = $pattern->title .'<div class="description">'. $pattern->description .'</description>';
	}

	$form['description'] = array(
    '#type' => 'markup',
    '#value' => t("Patterns provide additional features and functionality to Drupal sites and save your time by setting them up automatically for you. Please choose the patterns that you would like to setup on your new site."),
	);

	$form['patterns'] = array(
    '#type' => 'checkboxes',
    '#title' => t('Select which patterns to run'),
    '#options' => $options,
	);

	$form['submit'] = array(
    '#type' => 'submit',
    '#value' => t('Save and Continue'),
	);

	$form['#action'] = $url;
	$form['#redirect'] = variable_get('patterns_profile_redirect_url', '');
	return $form;
}

function patterns_profile_form_submit($form, &$form_state) {

  $patterns = array_filter($form_state['values']['patterns']);
  variable_set('patterns_profile_selected', $patterns);
  
  // combine all patterns into one in order to avoid problems
  // with batch operations
  $pattern = patterns_get_pattern(array_shift($patterns));
  foreach($patterns as $p) {
    $pattern->pattern['actions'][] = array('tag' => 'pattern', 'value' => $p);
  }
  //include (drupal_get_path('module', 'patterns') . '/patterns.module');
  patterns_start_engine($pattern);
  //patterns_execute_pattern($pattern);
  variable_set('patterns_profile_executed', TRUE);
  $form_state['redirect'] = variable_get('patterns_profile_redirect_url', '');
}

function patterns_profile_form_submit_old($form, &$form_state) {
	$patterns = array_filter($form_state['values']['patterns']);
	variable_set('patterns_profile_selected', $patterns);

	// combine all patterns into one in order to avoid problems
	// with batch operations
	$pattern = patterns_get_pattern(array_shift($patterns));
	foreach($patterns as $p) {
		$pattern->pattern['actions'][] = array('tag' => 'pattern', 'value' => $p);
	}
	patterns_execute_pattern($pattern);
	variable_set('patterns_profile_executed', TRUE);
	$form_state['redirect'] = variable_get('patterns_profile_redirect_url', '');
}
