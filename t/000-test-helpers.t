#!/usr/bin/env perl
# vim: softtabstop=4 tabstop=4 shiftwidth=4 ft=perl expandtab smarttab

use strict;
use warnings;

use Test::More import => [qw( is is_deeply subtest done_testing )];
use lib 't/lib';
use Test::Helpers qw(get_test_creds $SSL_OPTS);

subtest 'userpass parsing' => sub {

    my $up = 'alice:pass123@proxmox1.local:8006/pam';
    local $ENV{PROXMOX_USERPASS_TEST_URI} = $up;
    local $ENV{PROXMOX_APITOKEN_TEST_URI} = undef;
    my $creds = get_test_creds();
    is_deeply( $creds, {
        username => 'alice',
        password => 'pass123',
        host     => 'proxmox1.local',
        port     => 8006,
        realm    => 'pam',
        ssl_opts => $SSL_OPTS,
    }, 'parsed creds from userpass' );

};

subtest 'apitoken parsing' => sub {

    my $tk = 'bob:tokid=016e0357-d64c-4ed4-968e-f68633ce38f0@proxmox2.local:8111/pam';
    local $ENV{PROXMOX_APITOKEN_TEST_URI} = $tk;
    local $ENV{PROXMOX_USERPASS_TEST_URI} = undef;
    my $creds2 = get_test_creds();
    is_deeply( $creds2, {
        username => 'bob',
        tokenid  => 'tokid',
        secret   => '016e0357-d64c-4ed4-968e-f68633ce38f0',
        host     => 'proxmox2.local',
        port     => 8111,
        realm    => 'pam',
        ssl_opts => $SSL_OPTS,
    }, 'parsed creds from token uri' );

};

done_testing();

1;
