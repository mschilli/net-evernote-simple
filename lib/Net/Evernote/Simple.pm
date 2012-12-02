###########################################
package Net::Evernote::Simple;
###########################################

use strict;
use warnings;

use Net::Evernote::Simple::EDAMUserStore::Constants;
use Net::Evernote::Simple::EDAMUserStore::Types;
use Net::Evernote::Simple::EDAMUserStore::UserStore;
use Net::Evernote::Simple::EDAMNoteStore::NoteStore;
use Net::Evernote::Simple::EDAMNoteStore::Types;
use Net::Evernote::Simple::EDAMErrors::Types;
use Net::Evernote::Simple::EDAMTypes::Types;
use Log::Log4perl qw(:easy);
use YAML qw( LoadFile );
use File::Basename;
use File::Temp qw( tempfile );

our $VERSION = "0.01";

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        %options,
    };

    bless $self, $class;
}

1;

__END__

=head1 NAME

Net::Evernote::Simple - Simple interface to the Evernote API

=head1 SYNOPSIS

    use Net::Evernote::Simple;

    my $evernote = Net::Evernote::Simple->new();

=head1 DESCRIPTION

Net::Evernote::Simple blah blah blah.

=head1 LEGALESE

Copyright 2012 by Mike Schilli, all rights reserved.
This program is free software, you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

2012, Mike Schilli <cpan@perlmeister.com>
