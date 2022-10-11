<?php

$customer = $_GET["customer"];

if ($customer == 'AAA') {
$a = imagecreatefrompng('aaa.png');
$groupids = array('11', '12', '13', '14');
}
if ($customer == 'BBB') {
$a = imagecreatefrompng('bbb.png');
$groupids = array('21', '22', '23');
}
elseif ($customer == 'VDOO') {
$a = imagecreatefrompng('zzz.png');
$groupids = array('91', '92');
}


//Call ZabbixApi
require_once("ZabbixApi.php");
$zabUrl ='https://ZABBIXURL/zabbix/';

//Read only zabbix API User (from zabbix 6.0 you can also use permanent RO API key, script is not prepared for this use)
$zabUser = 'ZABBIX_API_USER';
$zabPassword = 'ZABBIX_ZPI_PASS';

$zbx = new ZabbixApi();
try {
        // default is to verify certificate and hostname
        $options = array('sslVerifyPeer' => false, 'sslVerifyHost' => false);
        $zbx->login($zabUrl, $zabUser, $zabPassword, $options);
        //this is similar to: $result = $zbx->call('apiinfo.version');
        // Get number of host available to this useraccount
        $params = array(
                "groupids" => $groupids,
                "selectFunctions" => "extend",
                "monitored" => 1,
                "countOutput" => true,
                "min_severity" => 2,
                "filter" => array(
                        "value" => 1
                ),
        );
        $result = $zbx->call('trigger.get',$params);
        $params = array(
                "groupids" => $groupids,
                "countOutput" => true
                );
        $result1 = $zbx->call('item.get',$params);

} catch (Exception $e) {
        print "==== Exception ===\n";
        print 'Errorcode: '.$e->getCode()."\n";
        print 'ErrorMessage: '.$e->getMessage()."\n";
        exit;
}
//print_r($result);


            //define the width and height of our images
            define("WIDTH", 220);
            define("HEIGHT", 200);
            $dest_image = imagecreatetruecolor(WIDTH, HEIGHT);
            //make sure the transparency information is saved
            imagesavealpha($dest_image, true);

//Set background color
if ($result > 0){
        //Background red
        $background = imagecolorallocatealpha($dest_image, 252, 71, 71, 0);
        }
else{
        //Background green
        $background = imagecolorallocatealpha($dest_image, 184, 196, 24, 0);
        }
            //fill the image with the background color (if statement)
            imagefill($dest_image, 0, 0, $background);

            $b = imagecreatefrompng('red.png');
            $c = imagecreatefrompng('green.png');

            //Set text
            $textok = $result1;
            $textwarn = $result;

            //copy each png file on top of the destination (result) png
            imagecopy($dest_image, $a, 10, -40, 0, 0, 200, HEIGHT);
            imagecopy($dest_image, $b, 120, 160, 0, 0, 33, 33);
            imagecopy($dest_image, $c, 20, 160, 0, 0, 33, 33);
            $textcolor = imagecolorallocate($dest_image, 255, 255, 255);
            $textshadow = imagecolorallocate($dest_image, 127, 127, 127);
            $font = '/var/www/html/tiles/arial.ttf';
            imagettftext($dest_image, 15, 0-2, 85-2, 150, $textshadow, $font, $customer);
            imagettftext($dest_image, 15, 0, 85, 150, $textcolor, $font, $customer);
            imagettftext($dest_image, 15, 0-2, 55-2, 183, $textshadow, $font, $textok);
            imagettftext($dest_image, 15, 0, 55, 183, $textcolor, $font, $textok);
            imagettftext($dest_image, 15, 0-2, 160-2, 183, $textshadow, $font, $textwarn);
            imagettftext($dest_image, 15, 0, 160, 183, $textcolor, $font, $textwarn);
            //send the appropriate headers and output the image in the browser
            header('Content-Type: image/png');
            imagepng($dest_image);

            //destroy all the image resources to free up memory
            imagedestroy($a);
            imagedestroy($b);
            imagedestroy($c);
            imagedestroy($dest_image);
    ?>
