#!/usr/bin/perl -w
#
# MP3 M3U Sorted Playlist Generator version .0.2 
#
# V0.80 - 2005-02-06
#
# modified by:
# 	fachi <fachi@aon.at>
#	changes:
#	 - playlist entry format: ARTIST -  TITEL [ALBUM NR/ALBUMNAME] 
#	 - script isn't case sensitive
#	 	
#	
# original by:
# 	("Bob") December 2 +001
# 	<xunker@pyxidis.org>
#
use strict;

use File::Find;
use MP3::Info;

my $Debug = 0;
my $usage = "listmaker.pl <source dir> <output file> [<verbose>]\n";

# File Extentions which will be in the playlist
# all in UPPER case!
my $extentions = "MP3 OGG WAV WMA"; 


my ($source_path, $output_filename, $verbose) = @ARGV;
die $usage unless (($source_path) && ($output_filename));

die "that path doesn't exist, hombre" unless (-e $source_path);

unlink $output_filename if (-e $output_filename);

my @files; my %shortname;

sub addFile {
    $shortname{$File::Find::name} = $_;
    return unless -f;
    
    if($_ =~ m/\.(\w+$)/) {
	my $ext = uc($1);
       	return unless ($extentions =~ /.*?$ext.*?/);
	}

    push @files, $File::Find::name;
    print '.' if $verbose;
}
print "\n" if $verbose;

find (\&addFile, $source_path);

@files = sort {uc($a) cmp uc($b)} @files;

open FILE, ">$output_filename"
    or die "could not open $output_filename for writing: $!";
    
print FILE "#EXTM3U\n";
my $counter = 1;  my $max = scalar (@files);
foreach my $file (@files) {
    my $tag = get_mp3tag($file);
    my $info = get_mp3info($file);
    my $pair;

    if (($tag->{ARTIST}) && ($tag->{TITLE})) {
        $pair = $tag->{ARTIST} . ' - ' . $tag->{TITLE};
    } else {
        $pair = $shortname{$file};
    }


    if ($tag->{ALBUM}) {
	$pair .= ' [';
        if ($tag->{TRACKNUM}){
    	$pair .= $tag->{TRACKNUM} .'/';
	}
	$pair .= $tag->{ALBUM} .']';
    }


    print FILE "#EXTINF:"
        . int ($info->{SECS})
        . ","
        . $pair
        . "\n";
      
    # $file =~ s/\//\\/g; # this is for WinAMP/MS-DOS;
                            # by default, File::Find returns
                            # filenames with the forward
                            # (proper) slash
    
    print FILE "$file\n";
    
    print "$counter of $max: $pair\n" if $verbose;
    $counter++;
}

close FILE;
