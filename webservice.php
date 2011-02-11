<?php

/* connect to the db */
$link = mysql_connect('184.168.226.56','neighborme','Tucson85719@') or die('Cannot connect to the DB');
mysql_select_db('neighborme',$link) or die('Cannot select the DB');
	
/* require the user as the parameter */
if(isset($_GET['user'])) {

	/* soak in the passed variable or set our own */
	$number_of_posts = isset($_GET['num']) ? intval($_GET['num']) : 10; //10 is the default
	$format = strtolower($_GET['format']) == 'json' ? 'json' : 'xml'; //xml is the default
	$user_id = strtolower($_GET['user']); //no default

	/* grab the posts from the db */
	if ($user_id == 'all'){
		$query = "SELECT * FROM USER ORDER BY UID";
		$result = mysql_query($query,$link) or die('Errant query:  '.$query);
		$users = array();
	    if(mysql_num_rows($result)) {
		   while($user = mysql_fetch_assoc($result)) {
			$users[] = array('user'=>$user);
		 }
		}
	}
	else{
		$query = "SELECT * FROM USER WHERE UID = " . intval($_GET['user']);
		$result = mysql_query($query,$link) or die('Errant query:  '.$query);
		//echo mysql_num_rows($result);
		$users = mysql_fetch_assoc($result);
	}

	/* create one master array of the records */
	

	/* output in necessary format */
	if($format == 'json') {
		header('Content-type: application/json');
		//echo json_encode(array('users'=>$users));
		echo json_encode($users);
	}
	else {
		header('Content-type: text/xml');
		echo '<users>';
		foreach($users as $index => $user) {
			if(is_array($user)) {
				foreach($user as $key => $value) {
					echo '<',$key,'>';
					if(is_array($value)) {
						foreach($value as $tag => $val) {
							echo '<',$tag,'>',htmlentities($val),'</',$tag,'>';
						}
					}
					echo '</',$key,'>';
				}
			}
		}
		echo '</users>';
	}
}

else if (isset($_POST['submit'])){

  $latitude = $_POST['latitude'];
  $longitude = $_POST['longitude'];
  $uid = $_POST['uid'];
  //$pic = $_POST['pic'];
  //$family = $_POST['family'];
  //$pet = $_POST['pet'];

  $query = "UPDATE USER SET LATITUDE = $latitude, LONGITUDE = $longitude WHERE UID = $uid";
  //$query = "INSERT INTO USER (NAME, LATITUDE, LONGITUDE, PROF_PIC, PET, FAMILY_MEMBER) VALUES ('Ashton Kutcher', $latitude, $longitude, '$pic', '$pet', $family)";
  error_log($query, 3, "my-errors.log");
  $result = mysql_query($query,$link);
  
  if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    echo $message;
  }
 
}

/* disconnect from the db */
	@mysql_close($link);
?>