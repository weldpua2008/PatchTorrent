#!/usr/bin/perl -w
#
#
use warnings;
use strict;
use Net::BitTorrent::File;
#/usr/ports/net-p2p/p5-Net-BitTorrent-File
# /usr/ports/sysutils/p5-Unix-Syslog
my $DEBUG   = 1;
my $TIMEOUT = 4;

if ($DEBUG) {
    use Unix::Syslog qw(:subs :macros);
    use Data::Dumper;
    $SIG{__WARN__} = sub {
        syslog( LOG_EMERG, "%s", join( "", @_ ) );
        exit(0);
      }
}

$SIG{INT} = sub {
    syslog( LOG_EMERG, "INT" );
    exit(0);
};    #'IGNORE';
$SIG{ALRM} = sub {
    syslog( LOG_EMERG, "ALARM" );
    CORE::kill( -2, 0 );
};

#Start timer of execute time;
alarm( int($TIMEOUT) );

my @retrackers = ( "http://retracker.local/announce",
    "http://retracker.skm.net.ua/announce" );
my $in_file = $ARGV[0];

my $torrent       = new Net::BitTorrent::File($in_file);
my $announce_list = $torrent->announce_list();             # [ [] [] [] ]
my ( $http_host, $http_file );

&get_http_host;
&get_http_filename;
&prepare_announce_list;
&put_announce_list;
&save;

sub get_http_host {
    $http_host = $ENV{'HTTP_HOST'} || "";

    #syslog(LOG_EMERG,Dumper(%ENV)) if $DEBUG;
    $http_host =~ s/\:\d+$//g;
    return $http_host;
}

sub get_http_filename {
    $http_file = $ENV{'SERVER_CONTENT_TYPE'} || "";
    if ( $http_file =~ /.+name\=\"(.+)\"$/ && $1 !~ /[\?|\&|\=]/ ) {
        $http_file = $1;
    }
    else {
        $http_file = $ENV{'SERVER_CONTENT_DISPOSITION'} || "";
        if ( $http_file =~ /filename\=\"(.+)\"/ ) {
            $http_file = $1;
        }
        else {
            $http_file = $ENV{'HTTP_FILE'} || "";
            $http_file =~ s/^.+\/(.+)$/$1/g;
        }
    }
    return $http_file;
}

sub hash2filename {
    return $torrent->{'info_hash'};
}

sub prepare_announce_list {

#If there is no one tracker address in announce_list, copy it from announce and continue...
    if ( $#$announce_list eq -1 ) {
        push( @$announce_list, [ $torrent->announce ] );
    }

    #Sanitize announce_list
    foreach my $r (@retrackers) {
        foreach ( 0 .. $#$announce_list ) {
            next
              if ( !defined( $announce_list->[$_] )
                || !defined( $announce_list->[$_][0] ) );
            if ( $announce_list->[$_][0] =~ /\.local\//i ) {

#Remove announced trackers with domain name '.local' since it's doesn't meet RFC Draft "Multicast DNS" (Yep, torrents.ru :-K )
                splice( @$announce_list, $_ );
            }
            elsif ( $announce_list->[$_][0] eq $r ) {

#Remove already added retrackers, if they were...a little bit dummy procedure :(
                splice( @$announce_list, $_ );
            }
        }
    }
    return $announce_list;
}

sub put_announce_list {
    foreach (@retrackers) {
        ####
        # For register in re-tracker.ru tracker, may be safely comment out
        ####
        my $isp = "1+6";    # Registered in re-tracker.ru database
        my $size = $torrent->length() || 0;
        if ( $size == 0 ) {
            foreach my $file ( @{ $torrent->files() } ) {
                $size += $file->{'length'};
            }
        }
        my $comment = $torrent->{'data'}->{'comment'} || "";
        my $name = $torrent->{'data'}->{'info'}->{'name'} || &get_http_filename;
        my $info_hash = $torrent->{'info_hash'};

        #URL encode
        foreach ( $name, $size, $comment ) {
            s/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg;
        }

        #print Dumper($_) if $DEBUG;
        $_ .= "?name=$name&size=$size&comment=$comment&isp=$isp";
        ####
        #
        ###
        push( @$announce_list, [$_] );
    }
    return $announce_list;
}

sub save {
    $torrent->announce_list($announce_list);
    my $http_host = get_http_host();
    my $http_file = get_http_filename();
    my $out_file  = "/home/torrents/patched/" . $http_host;
    mkdir("$out_file") unless -d "$out_file";
    $out_file .= "/" . $http_file;
    $torrent->save($out_file);
    alarm(0);
    exec( '/bin/cat', $out_file );
}
