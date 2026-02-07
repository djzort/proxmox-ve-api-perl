#!/usr/bin/env perl
# vim: softtabstop=4 tabstop=4 shiftwidth=4 ft=perl expandtab smarttab

use strict;
use warnings;

use Test::More import => [qw( BAIL_OUT ok plan require_ok )]; my $tests = 4; # used later
use Test::Trap;
use lib 't/lib';
use Test::Helpers qw(get_test_creds);

if ( not $ENV{PROXMOX_USERPASS_TEST_URI} and not $ENV{PROXMOX_APITOKEN_TEST_URI} ) {
    my $msg = 'Set $ENV{PROXMOX_USERPASS_TEST_URI} or $ENV{PROXMOX_APITOKEN_TEST_URI} to a real running proxmox to run.';
    plan( skip_all => $msg );
}
else {
    plan tests => $tests
}

require_ok('Net::Proxmox::VE')
  or BAIL_OUT( "# Net::Proxmox::VE not available\n" );


my $obj;

=head2 new() works with good values

This relies on either $ENV{PROXMOX_USERPASS_TEST_URI} or $ENV{PROXMOX_APITOKEN_TEST_URI}.

Try something like...

   PROXMOX_USERPASS_TEST_URI="user:password@192.0.2.28:8006/pam" prove ...

=cut

{

    my $creds = get_test_creds();

    trap { $obj = Net::Proxmox::VE->new(%$creds) };
    ok( !$trap->die, 'doesnt die with good arguments' );

}

=head2 login() connects to the server

After the object is created, we should be able to log in ok

=cut

my $env_uri = $ENV{PROXMOX_USERPASS_TEST_URI} || $ENV{PROXMOX_APITOKEN_TEST_URI};
ok( $obj->login(), 'logged in to ' . $env_uri );

=head2 pools

checks  pools stuff

=cut

{

    my @index = $obj->pools();
    ok(1, 'retrieved pools');

}

1;
