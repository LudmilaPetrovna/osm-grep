use Data::Dumper;

#not interest
$skip=join("|",map{"$_"}split(/\n/,<<AAA));
addr:
alt_name=
brand=
comment=
contact:
created_by=
description=
email=
emergency:phone=
facebook
fax
fixme
fixme:phone
full_name
mapillary
name
opening_hours
operator
operator_name
owner
ref
ref:
source
source:
AAA


%count=();

while(<>){
#lat/lon 764414541/54619644700: man_made=beacon;; seamark=beacon;;.
if(/^lat\/lon [\-\d]+\/[\-\d]+: ([^\n]+)/s){
@tags=split(/;; /,$1);
map{
$count{$_}++;
}grep{!/addr:|alt_name=|brand=|comment=|contact:|created_by=|description=|email=|emergency:phone=|facebook|fax|fixme|fixme:phone|full_name|mapillary|name|opening_hours|operator|operator_name|owner|ref|ref:|source|source:/}@tags;

#print "@tags\n";

}


}




# remove various values
%vals=();
map{
($nn,$vv)=split(/=/);$vals{lc($nn)}{$vv}=1;
}grep{/=/}keys %count;

@bad=grep{scalar keys %{$vals{$_}}>25}keys %vals;

print map{"$_ ($count{$_})\n"} sort{$count{$b} <=> $count{$a}} grep{$count{$_}>2}keys %count;

#print Dumper(\%vals);