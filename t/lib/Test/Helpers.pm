#!/bin/false
# vim: softtabstop=4 tabstop=4 shiftwidth=4 ft=perl expandtab smarttab

use strict;
use warnings;

package Test::Helpers;

use Exporter 'import';
use IO::Socket::SSL qw( SSL_VERIFY_NONE );

our @EXPORT_OK = qw(get_test_creds $SSL_OPTS);

our $SSL_OPTS = {
    SSL_verify_mode => SSL_VERIFY_NONE,
    verify_hostname => 0,
};

sub get_test_creds {

    if ( $ENV{PROXMOX_APITOKEN_TEST_URI} ) {
        my $res = _parse_apitoken( $ENV{PROXMOX_APITOKEN_TEST_URI} );
                die 'PROXMOX_APITOKEN_TEST_URI did not match expected format'
          unless $res;
        return $res;

    }    if ( $ENV{PROXMOX_USERPASS_TEST_URI} ) {
        my $res = _parse_userpass( $ENV{PROXMOX_USERPASS_TEST_URI} );
                die 'PROXMOX_USERPASS_TEST_URI did not match expected format'
          unless $res;
        return $res;
    }

    die 'No PROXMOX test URI provided';
}

sub _parse_userpass {
    my ($uri) = @_;
    return unless defined $uri;
    if ( $uri =~ m{^(\w+):(\w+)\@([\w\.]+):([0-9]+)/([\w-]+)$} ) {
        my ( $user, $pass, $host, $port, $realm ) = ( $1, $2, $3, $4, $5 );
        return {
            host     => $host,
            password => $pass,
            username => $user,
            port     => $port,
            realm    => $realm,
            ssl_opts => $SSL_OPTS,
        };
    }
    return;
}

sub _parse_apitoken {
    my ($uri) = @_;
    return unless defined $uri;
    if ( $uri =~ m{^(\w+):(\w+)=([A-Za-z0-9\-]+)\@([\w\.]+):([0-9]+)/([\w-]+)$} ) {
        my ( $user, $tokenid, $secret, $host, $port, $realm ) = ( $1, $2, $3, $4, $5, $6 );
        return {
            host     => $host,
            port     => $port,
            realm    => $realm,
            secret   => $secret,
            tokenid  => $tokenid,
            username => $user,
            ssl_opts => $SSL_OPTS,
        };
    }
    return;
}

1;
