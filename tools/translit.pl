use utf8;
use Encode;
binmode(STDOUT,":utf8");

$shizo=1;


use Data::Dumper;

%dict=map{@v=split(/\s/,$_,2);($v[0],[split(/\s/,$v[1])]),(uc $v[0],[split(/\s/,uc $v[1])])}split(/\n/,<<zzzzz);
а a
б b
в v w
г g
д d
е e ye y ey
ё e ye yo eo
ж j je zh
з z
и i ee e y
й j y
к k c q qu que
л l
м m
н n
о o
п p
р r
с s
т t
у u oo
ф f
х h kh
ц c ts
ч c ch
ш sh
щ shch sch
ъ " '' '
ы y ye yi
ь ' "
э e
ю u eu yu
я ya ja a ea
zzzzz
#"

#%dictlet=map{$_,[@{$dict{$_}}]}keys %dict;


$root=["",[]];
$storage="";

train(decode_utf8($ARGV[0]));
#train("Пирожки");
#train("Пирожкичный");
#train("Пирожочек");
#train("Збоншинек");
#train("Збоншинь");
#train("Огонек");

sub train{
my $word=shift;
$word=lc($word);
my $spos=index($storage,$word);
if($spos<0){
$spos=length($storage);
$storage.=$word;
}
my $slen=length($word);
my $sid=($spos<<6) | $slen;
if($slen>32){
die "too long word: $slen";
}
if($spos<<6 > 0xFFFFFFF){
die "Storage too big: ".length($storage);
}

my @pointers=($root);
my @letters=split(//,$word);
foreach(@letters){
print "Adding letter $_\n";
@subst=@{$dict{$_}};

@pointers=map{
$r=$r2=$_;
map{
if(!$shizo){
$r=$r2;

}
@slet=split(//,$_);
map{$n=[$_,[],$sid];push(@{$r->[1]},$n);$r=$n;$r}@slet;

}@subst;
}@pointers;

}
}

print translit("Pirog");

sub translit{
my $word=shift;
my @letters=split(//,lc($word));
my $pointer=$root;
my $accum="";

foreach $let(@letters){
$found=grep{$_->[0] eq $let}@{$pointer->[1]};
#die(ruDumper(\$found));

}


}


printNext("",$root);
#print ruDumper(\$root);

sub printNext{
my $path=shift;
my $node=shift;
$path.=$node->[0];
if(@{$node->[1]}==0){
$sid=$node->[2];
$string=substr($storage,$sid>>6,$sid&0x3F);
print $path."=".$string."\n";# ($sid -> ".($sid>>6)." size: ".($sid&0x3F).")\n";
}
map{printNext($path,$_)}@{$node->[1]};
}


sub ruDumper{
my $res=Dumper(\@_);
$res=~s/\\x\{([^\}]+)\}/chr(hex($1))/eg;
print $res;


}

