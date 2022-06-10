#!/usr/bin/perl
use strict;
my $str;
my @arr;
my @arr2;
my $out;

my %functions= ('memset' => '((void(*)(void *, u8, u16))',
                'memcpy' => '((void(*)(void *, void *, u16))',
                'border' => '((void(*)(u8))',
                'vsync' => '((void(*)(void))',
                'joystick' => '((u8(*)(void))',
                'draw_tile_key' => '((void(*)(u8,u8,u16))',
                'draw_tile' => '((void(*)(u8,u8,u16))',
                'keyboard' => '((void(*)(u8*))',
                'mouse_pos' => '((u8(*)(u8*,u8*))',
                'mouse_set' => '((void(*)(u8,u8))',
                'mouse_clip' => '((void(*)(u8,u8,u8,u8))',
                'mouse_delta' => '((u8(*)(i8*,i8*))',
                'sfx_play' => '((void(*)(u8,u8))',
                'sfx_stop' => '((void(*)(void))',
                'music_play' => '((void(*)(u8))',
                'music_stop' => '((void(*)(void))',
                'sample_play' => '((void(*)(u8))',
                'rand16' => '((u16(*)(void))',
                'pal_clear' => '((void(*)(void))',
                'pal_select' => '((void(*)(u8))',
                'pal_bright' => '((void(*)(u8))',
                'pal_col' => '((void(*)(u8,u8))',
                'pal_copy' => '((void(*)(u8,u8*))',
                'pal_custom' => '((void(*)(u8*))',
                'draw_image' => '((void(*)(u8,u8,u8))',
                'draw_image_extra' => '((void(*)(u8,u8,u8,u8,u8))',
                'clear_screen' => '((void(*)(u8))',
                'swap_screen' => '((void(*)(void))',
                'select_image' => '((void(*)(u8))',
                'color_key' => '((void(*)(u8))',
                'set_sprite' => '((void(*)(u8,u8,u8,u16))',
                'sprites_start' => '((void(*)(void))',
                'sprites_stop' => '((void(*)(void))',
                'time' => '((u32(*)(void))',
                'delay' => '((void(*)(u16))',
                'texfilename' => '((void(*)(u16))',
                'changescrpg' => '((void(*)(u16))');




open FIL,$ARGV[0];
open OUT,">functions.h";

while($str=<FIL>){
	chomp $str;
	if(length($str)<5){ 
		next;
	}
	@arr = split(/:/, $str);
	if($#arr+1!=2){
		print $str." WRONG FORMAT\n";
		next;
	}
	@arr2 = split(/ /, $arr[1]);
	if($#arr2+1!=3){
		print $str." WRONG FORMAT\n";
		next;
	}
	if(exists($functions{$arr[0]})){
		$out="#define ".$arr[0]." ".$functions{$arr[0]}." ".$arr2[2].")\n";
	} else {
		$out="#define ".uc($arr[0])." ".$arr2[2]."\n";
	}
	print OUT $out;
}
