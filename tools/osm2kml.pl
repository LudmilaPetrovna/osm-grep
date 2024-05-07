use Data::Dumper;

$now=time();

open(out_point,">points-$now.kml");

print out_point '<?xml version="1.0" encoding="UTF-8"?>';
print out_point '<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">';
print out_point "<Document><name>$now</name>\n";


$num=0;
while(<>){
#lat/lon 3705541/52240834000: amenity=doctors;; healthcare=doctor;;
if(/^lat\/lon ([\d\-]+)\/([\d\-]+): ([^\n]+)/s){
$lat=$1/1000000000;
$lon=$2/1000000000;
$tags=$3;

if($tags=~/pharmacy/){next;}

@tags=split(/;; /,$tags);
%tags=map{($nn,$vv)=split(/=/,$_,2);($nn,$vv)}@tags;


$title=$tags{'name:ru'};
if(!$title){$title=$tags{'name'};}
if(!$title){$title=$tags{'alt_name'};}





print out_point "<Placemark>";
print out_point "<Region><LatLonAltBox><north>".($lat+0.1)."</north><south>".($lat-0.1)."</south><east>".($lon+0.1)."</east><west>".($lon-0.1)."</west></LatLonAltBox>";
print out_point "<Lod><minLodPixels>5000</minLodPixels></Lod></Region>";

if($title){
print out_point "<name><![CDATA[$title]]></name>";
}
print out_point "<description><![CDATA[$tags]]></description>";
print out_point "<Point><coordinates>$lon,$lat</coordinates></Point></Placemark>\n";


$num++;
if($num>150000){last;}

}



}


print out_point "</Document></kml>";
