#!/bin/false
# vim: softtabstop=4 tabstop=4 shiftwidth=4 ft=perl expandtab smarttab
# PODNAME: Net::Proxmox::VE::Pools
# ABSTRACT: Presents a pool object

use strict;
use warnings;

package Net::Proxmox::VE::Pools;

use parent 'Exporter';

use Net::Proxmox::VE::Exception;

=encoding utf8

=head1 SYNOPSIS

  @pools = $obj->pools();
  $pool  = $obj->get_pool( $poolid );

  $ok = $obj->create_pool(%args);
  $ok = $obj->create_pool(\%args);

  $ok = $obj->delete_pool( $poolid );

  $ok = $obj->update_pool( $poolid, %args);
  $ok = $obj->update_pool( $poolid, \%args);

=head1 DESCRIPTION

This module implements the 'pools' section of the Proxmox API for L<Net::Proxmox::VE>,
you should use the API via that module. This documentation is for detailed reference.

To be clear, this module isn't useful as a stand alone piece of software.

Pools can be used to group a set of virtual machines and datastores. You can then simply
set permissions on pools, which are inherited by all pool members. This is a great way
to simplify access control.

=head1 NOTE

String formats that are mentioned herein are done so for convenience and
are defined in detail in the Proxmox API documents on the Proxmox project website.

This module doesn't enforce them, it will send whatever garbage you provide
straight to the server API. So garbage-in, garbage-out!

=head1 METHODS

=cut

our @EXPORT = qw(
  pools
  get_pool
  create_pool
  delete_pool
  update_pool
);

my $BASEPATH = '/pools';

=head2 pools

Gets a list of pools or get a single pool configuration..

Accepts optional query parameters (hashref or key/value list) to filter results.

Examples:

  # list all pools
  @pools = $obj->pools();

  # retrieve a single pool via query parameter (preferred; replaces deprecated get_pool())
  @one = $obj->pools({ poolid => 'mypool' });

  # filter by pool id and type
  @filtered = $obj->pools( poolid => 'mypool', type => 'qemu' );

Available types (at time of writing) are: qemu, lxc, storage

=cut

sub pools {

    my $self = shift or return;
    my @p = @_;

    # optional query parameters
    if (@p) {
        my %args;
        if ( @p == 1 ) {
            Net::Proxmox::VE::Exception->throw(
                'Single argument not a hash for pools()')
              unless ref $p[0] eq 'HASH';
            %args = %{ $p[0] };
        }
        else {
            Net::Proxmox::VE::Exception->throw(
                'Odd number of arguments for pools()')
              if ( scalar @p % 2 != 0 );
            %args = @p;
        }
        return $self->get( $BASEPATH, \%args );
    }

    return $self->get($BASEPATH);

}

=head2 get_pool
DEPRECATED IN API: The Proxmox API marks the per-pool endpoint as deprecated (no support for nested pools).

This module retains `get_pool()` for backward compatibility and will continue to provide it
until the Proxmox API removes the endpoint. New code should use `pools()` with the
`poolid` query parameter (preferred),

Retrieves a single storage pool

  $pool = $obj->get_pool( $poolid );

Where $poolid is a string in pve-poolid format

=cut

sub get_pool {

    my $self = shift or return;

    my $poolid = shift
      or Net::Proxmox::VE::Exception->throw('No poolid for get_pool()');
    Net::Proxmox::VE::Exception->throw('poolid must be a scalar for get_pool()')
      if ref $poolid;

    return $self->get( $BASEPATH, $poolid );

}

=head2 create_pool

Creates a new pool

  $ok = $obj->create_pool( %args );
  $ok = $obj->create_pool( \%args );

I<%args> may items contain from the following list

=over 4

=item poolid

String. The id of the pool you wish to access, in pve-poolid format. This is required.

=item comment

String. This is a comment associated with the new pool, this is optional

=back

=cut

sub create_pool {

    my $self = shift or return;
    my @p    = @_;

    Net::Proxmox::VE::Exception->throw('No arguments for create_pool()')
      unless @p;
    my %args;

    if ( @p == 1 ) {
        Net::Proxmox::VE::Exception->throw(
            'Single argument not a hash for create_pool()')
          unless ref $p[0] eq 'HASH';
        %args = %{ $p[0] };
    }
    else {
        Net::Proxmox::VE::Exception->throw(
            'Odd number of arguments for create_pool()')
          if ( scalar @p % 2 != 0 );
        %args = @p;
    }

    # enforce required poolid
    Net::Proxmox::VE::Exception->throw('poolid is required for create_pool()')
      unless exists $args{poolid} && defined $args{poolid};
    Net::Proxmox::VE::Exception->throw('poolid must be a scalar for create_pool()')
      if ref $args{poolid};

    return $self->post( $BASEPATH, \%args );

}

=head2 delete_pool
DEPRECATED IN API: The Proxmox API marks the per-pool delete endpoint as deprecated (no support for nested pools).

This module keeps `update_pool()` for backward compatibility and will remove the
subroutine when the API no longer exposes the per-pool endpoint.

Deletes a single pool

  $ok = $obj->delete_pool( $poolid )

Where $poolid is a string in pve-poolid format

=cut

sub delete_pool {

    my $self   = shift or return;
    my $poolid = shift
      or
      Net::Proxmox::VE::Exception->throw('No argument given for delete_pool()');

    return $self->delete( $BASEPATH, $poolid );

}

=head2 update_pool
DEPRECATED IN API: The Proxmox API marks the per-pool update endpoint as deprecated (no support for nested pools).

This module keeps `update_pool()` for backward compatibility and will remove the
subroutine when the API no longer exposes the per-pool endpoint.

Updates (sets) a pool's data

  $ok = $obj->update_pool( $poolid, %args );
  $ok = $obj->update_pool( $poolid, \%args );

Where $poolid is a string in pve-poolid format

I<%args> may items contain from the following list

=over 4

=item comment

String. This is a comment associated with the new pool, this is optional

=item delete

Boolean. Removes the vms/storage rather than adding it.

=item storage

String. List of storage ids (in pve-storage-id-list format)

=item vms

String. List of virtual machines in pve-vmid-list format.

=back

=cut

sub update_pool {

    my $self   = shift or return;
    my $poolid = shift
      or Net::Proxmox::VE::Exception->throw(
        'No poolid provided for update_pool()');
    Net::Proxmox::VE::Exception->throw(
        'poolid must be a scalar for update_pool()')
      if ref $poolid;
    my @p = @_;

    Net::Proxmox::VE::Exception->throw('No arguments for update_pool()')
      unless @p;
    my %args;

    if ( @p == 1 ) {
        Net::Proxmox::VE::Exception->throw(
            'Single argument not a hash for update_pool()')
          unless ref $p[0] eq 'HASH';
        %args = %{ $p[0] };
    }
    else {
        Net::Proxmox::VE::Exception->throw(
            'Odd number of arguments for update_pool()')
          if ( scalar @p % 2 != 0 );
        %args = @p;
    }

    return $self->put( $BASEPATH, $poolid, \%args );

}

=head1 SEE ALSO

L<Net::Proxmox::VE>

=cut

1;

__END__
