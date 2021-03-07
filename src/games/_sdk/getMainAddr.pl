#!/usr/bin/perl
use strict;
my $str;
my @arr;
my $hex_val;
#open FIL,"_temp_\\out.map";
#open ADDR, ">addr.bin";
open FIL,$ARGV[0];
open ADDR, ">".$ARGV[1];
while($str=<FIL>)
{
    chomp $str;
    $str=~s/\s*//; 
    if(length($str)>0)
    {
        @arr=split(/ /,$str);
        if(substr($arr[2],0,1) eq "_")
        {
			if($arr[2]=~m/_main/){
				$hex_val = hex("0x".$arr[0]);
				print ADDR pack("V",$hex_val); 
			}
        }
    }
}
close FIL;