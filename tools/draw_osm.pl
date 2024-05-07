use GD;
use Geo::Coordinates::GMap;

$map=GD::Image->newFromPng("back.png",1);

@datasets=qw/place-all.txt.gz medical-all.txt.gz seamark-all.txt.gz/;
@colors=(0x00FF00, 0xFF0000, 0x00FFFF);
@datasets=qw/medical-all.txt.gz/;

for($q=0;$q<@datasets;$q++){
drawOsmFile($datasets[$q],$colors[$q]);


}


open(oo,">map-".time().".png");
binmode(oo);
print oo $map->png(0);
close(oo);



sub drawOsmFile{
my $filename=shift;
my $color=shift;
print STDERR "Processing $filename, len ".(-s($filename))." bytes\n";
open(dd,"cat \"$filename\" | gzip -d |");
while(<dd>){

if(/^lat\/lon ([\d\-]+)\/([\d\-]+): ([^\n]+)/s){
$lat=$1/1000000000;
$lon=$2/1000000000;
$tags=$3;
if($lat>85 || $lat<-85){next;}
#print "$lat,$lon\n";

($px,$py)=map{int($_*2048)}coord_to_gmap_tile($lat,$lon,0);
$map->setPixel($px,$py,$color);

}
}
close(dd);
}


