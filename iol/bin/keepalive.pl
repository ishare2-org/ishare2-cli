#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use IO::Socket;
use threads;

my $uid;
my $iou_instance;
my $pseudo_instance;
my $iou_interface;
my $pseudo_instance_interface;
my $iou_linkstate_sock;
my $t1;
my $ls_header;
my $ls_base;
my $inteface_name;

GetOptions(
    'i=i'  => \$iou_instance,
    'p=i'  => \$iou_interface,
    'n=s'  => \$inteface_name,
);

$pseudo_instance = $iou_instance + 512;
$pseudo_instance_interface = $iou_interface;

$uid         = $ENV{SUDO_UID};
$uid         = $< unless ( defined $uid );    # apparently not started with sudo
print "UID: $uid\n";
$ls_base = "/tmp/netl1$uid"; 
    # linkstate headers are the same as the IOU header above, 
    # except for the delimiter which is always 0x0003
	
# provide a clean exit
$SIG{INT} = \&caught_sigint;

$ls_header = pack( "nnCCH4",
        $iou_instance, 
        $pseudo_instance, 
        $iou_interface,
        $pseudo_instance_interface,
        "0300" );

##connect to socket  iol linkstate socket
$iou_linkstate_sock = IO::Socket::UNIX->new(
	Type => SOCK_DGRAM,
	Peer => "$ls_base/L1$iou_instance"
) or die "Can't connect to IOU socket at $ls_base/L1$iou_instance\n";
print "Attached to real IOU Linkstate socket at $ls_base/L1$iou_instance\n" ;
$t1 = threads->create( \&linkstate_thread );
$t1->join();

sub linkstate_thread {
	print "Send";
    # prepare for exitting later
    $SIG{'KILL'} = sub { threads->exit(); };

    # packet capture between 2 IOU shows that the linkstate packets 
    # are fired every second
    while (1) {
		print "Send";
        $iou_linkstate_sock->send(
            pack( "a*", $ls_header ) );
        sleep(1);
    }
}

sub caught_sigint {
    print "\n...stopped.\n";
    print "Cleaning up.\n";
    $t1->kill('KILL')->detach();
}


 

