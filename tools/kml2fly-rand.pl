

open(ii,"med.kml");

@coords=();
while(<ii>){
#<coordinates>-0.4138011,52.1180585</coordinates>
if(/<coordinates>([\d\.\-]+),([\d\.\-]+)/){
($lon,$lat)=($1,$2);
push(@coords,[$lat,$lon]);
}
}
close(ii);

sub get_kml_head{
return <<AAA;
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
    <Document id="new_tour$now">
AAA
}

sub get_kml_end{
return "</Document></kml>";
}




$now=time();
$date=localtime();

open(outt,">tour-rand-$now.kml");
print outt get_kml_head();

print outt <<AAA;
        <name>New Tour $date</name>
        <gx:Tour>
            <name>New Tour $date</name>
            <gx:Playlist>
AAA

for($q=0;$q<5000;$q++){

$pos=int(rand()*@coords);
($lat,$lon)=@{$coords[$pos]};
$dur=10+int(rand()*5);
$heading=rand()*360;
$heading2=$heading+180;
if($heading2>360){$heading2-=360;}
$tilt=rand()*20;
$tilt2=20+rand()*20;
$alt=500+rand()*1000;
$alt2=2500+rand()*1000;
$fov=60+rand()*30;

#<gx:flyToMode>smooth</gx:flyToMode>

print outt <<AAA;

                <gx:FlyTo>
<gx:duration>$dur</gx:duration>
<LookAt>
<longitude>$lon</longitude>
<latitude>$lat</latitude>
<heading>$heading</heading>
<tilt>$tilt</tilt>
<range>$alt</range>
<gx:fovy>$fov</gx:fovy>
                    </LookAt>

                </gx:FlyTo>
<gx:Wait>
    <gx:duration>0.1</gx:duration>
</gx:Wait>

                <gx:FlyTo>
<gx:duration>3</gx:duration>
<LookAt>
<longitude>$lon</longitude>
<latitude>$lat</latitude>
<heading>$heading2</heading>
<tilt>$tilt2</tilt>
<range>$alt2</range>
<gx:fovy>$fov</gx:fovy>
                    </LookAt>

                </gx:FlyTo>
<gx:Wait>
    <gx:duration>0.15</gx:duration>
</gx:Wait>


AAA


}

print outt <<AAA;
            </gx:Playlist>
        </gx:Tour>
AAA


print outt get_kml_end();
