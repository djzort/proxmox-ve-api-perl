#!/usr/bin/env perl

use strict;
use warnings;

use Test::More import => [ qw( BAIL_OUT ok plan require_ok ) ]; my $tests = 2; # used later
use Test::Trap;

if ( not $ENV{PROXMOX_USERPASS_TEST_URI} ) {
    my $msg = 'This test sucks.  Set $ENV{PROXMOX_USERPASS_TEST_URI} to a real running proxmox to run.';
    plan( skip_all => $msg );
}
else {
    plan tests => $tests
}

require_ok('Net::Proxmox::VE')
    or BAIL_OUT( "# Net::Proxmox::VE not available\n" );

ok(1, 'stub!');

1
