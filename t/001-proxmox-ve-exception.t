#!/usr/bin/env perl
# vim: softtabstop=4 tabstop=4 shiftwidth=4 ft=perl expandtab smarttab

use strict;
use warnings;

use Test::More import => [qw( BAIL_OUT done_testing is isa_ok like ok require_ok subtest )];
use Test::Exception;

require_ok('Net::Proxmox::VE::Exception')
  or BAIL_OUT( "# Net::Proxmox::VE::Exception not available\n" );

my $file = $0;

# Test object creation
subtest 'Object creation' => sub {
    my $line = 42;
    my $exception = Net::Proxmox::VE::Exception->_new(
        message => 'Test error',
        file    => 'test.pl',
        line    => $line
    );

    isa_ok( $exception, 'Net::Proxmox::VE::Exception',
        'Object is of correct class' );
    is( $exception->message, 'Test error', 'Message is set correctly' );
    is( $exception->file,    'test.pl',    'File is set correctly' );
    is( $exception->line,    $line,         'Line is set correctly' );
};

# Test as_string method
subtest 'as_string method' => sub {
    my $exception = Net::Proxmox::VE::Exception->_new(
        message => 'Test error',
        file    => 'test.pl',
        line    => 42
    );

    is(
        $exception->as_string,
        'Test error at test.pl line 42.',
        'as_string formats correctly'
    );
};

# Test accessor methods
subtest 'Accessor methods' => sub {
    my $line = 99;
    my $exception = Net::Proxmox::VE::Exception->_new(
        message => 'Test error',
        file    => 'test.pl',
        line    => $line
    );

    is( $exception->message, 'Test error', 'message accessor' );
    is( $exception->file,    'test.pl',    'file accessor' );
    is( $exception->line,    $line,        'line accessor' );
};

# Test throw method with string argument
subtest 'Throw with string argument' => sub {
    dies_ok {
        Net::Proxmox::VE::Exception->throw('Test error')
    }
    'Throws exception with string argument';

    my $exception;
    throws_ok(
        sub {
            Net::Proxmox::VE::Exception->throw('Test error');
        },
        'Net::Proxmox::VE::Exception',
        'Thrown object is correct class'
    );
    $exception = $@;

    is( $exception->message, 'Test error', 'Message is set correctly' );
    like( $exception->file, qr/\.t$/, 'File is set from caller' );
    ok( $exception->line > 0, 'Line number is set' );
};

# Test throw method with hashref argument
subtest 'Throw with hashref argument' => sub {
    dies_ok {
        Net::Proxmox::VE::Exception->throw(
            {
                message => 'Test error',
            }
        )
    }
    'Throws exception with hashref argument';

    my ($line, $exception);
    throws_ok(
        sub {
            $line = __LINE__; Net::Proxmox::VE::Exception->throw(
                {
                    message => 'Test error',
                }
            );
        },
        'Net::Proxmox::VE::Exception',
        'Thrown object is correct class'
    );
    $exception = $@;

    is( $exception->message, 'Test error', 'Message is set correctly' );
    is( $exception->file,    $file,        'File is set correctly' );
    is( $exception->line,    $line,        'Line is set correctly' );
};

done_testing();

1;
