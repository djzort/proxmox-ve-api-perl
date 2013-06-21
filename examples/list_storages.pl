#!/usr/bin/perl

#####################################################
#
#    List all storages of the cluster
#
#####################################################

use strict;
use warnings;

use lib './lib';
use Net::Proxmox::VE;
use Data::Dumper;
use Getopt::Long;

my $host     = 'host';
my $username = 'user';
my $password = 'pass';
my $debug    =  undef;
my $realm    = 'pve'; # 'pve' or 'pam'

GetOptions (
    'host=s'     => \$host,
    'username=s' => \$username,
    'password=s' => \$password,
    'debug'      => \$debug,
    'realm'      => \$realm,
);

my $pve = Net::Proxmox::VE->new(
    host     => $host,
    username => $username,
    password => $password,
    debug    => $debug,
    realm    => $realm,
);

die "login failed\n"          unless $pve->login;
die "invalid login ticket\n"  unless $pve->check_login_ticket;
die "unsupport api version\n" unless $pve->api_version_check;

# list nodes in cluster
my $resources = $pve->get('/cluster/resources');

foreach my $item( @$resources ) { 
    next unless $item->{type} eq 'storage';

    print "id: " .      $item->{id} . "\n"; 
    print "disk: " .    $item->{disk} . "\n";
    print "maxdisk: " . $item->{maxdisk} . "\n";
    print "node: " .    $item->{node} . "\n";
    print "type: " .    $item->{type} . "\n";
    print "storage: ".  $item->{storage} . "\n";
}
