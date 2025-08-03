#!/bin/false
# vim: softtabstop=4 tabstop=4 shiftwidth=4 ft=perl expandtab smarttab
# PODNAME: Net::Proxmox::VE::Exception
# ABSTRACT: Functions for the 'cluster' portion of the API

use strict;
use warnings;

package Net::Proxmox::VE::Exception;

=encoding utf8

=head1 SYNOPSIS

    use Net::Proxmox::VE::Exception;
    Net::Proxmox::VE::Exception->throw( "What went wrong" )

=head1 INTERNAL METHODS

=head2 _new

This is a standard new() interface, but is intended for internal usage
rather than as the public interface.

Any argument will be included in the object.

=cut

sub _new {

    my $c     = shift;
    my %args  = @_;
    my $class = ref($c) || $c;
    my $self  = \%args;

    return bless $self, $class;
}

=head1 PUBLIC METHODS

=head2 as_string

The exception details as human readable string

    $obj->as_string()

=cut

sub as_string {
    my $self = shift;
    sprintf '%s at %s line %s.', $self->message, $self->file, $self->line;
}

=head2 file

File that called the function

    $obj->file()

=cut

sub file { return shift->{file} }

=head2 line

Line in the file that called the function

    $obj->line()

=cut

sub line { return shift->{line} }

=head2 message

Message why the exception occured

    $obj->message()

=cut

sub message { return shift->{message} }

=head2 throw

This is intended as the public interface.

To be used like this

    use Net::Proxmox::VE::Exception;
    Net::Proxmox::VE::Exception->throw( "message")
    Net::Proxmox::VE::Exception->throw( { message => "message" } )

=cut

sub throw {

    my ($class, $arg) = @_;
    $class = ref $class || $class;

    my %args;
    if ( ref $arg ) {
        %args = %$arg;
    }
    else {
        $args{message} = $arg;
    }

    ( $args{package}, $args{file}, $args{line} ) = caller(0);
    $args{subroutine} = ( caller(1) )[3];

    die $class->_new(%args);

}

=head1 SEE ALSO

L<Net::Proxmox::VE>

=cut

1;

__END__
