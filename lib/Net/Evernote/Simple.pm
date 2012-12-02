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
use Thrift;
use Thrift::HttpClient;
use Thrift::BinaryProtocol;
use Data::Dumper;

our $VERSION = "0.01";

our $EN_DEV_TOKEN_PAGE = 
    "http://dev.evernote.com/documentation/cloud/chapters/" .
    "Authentication.php#devtoken";

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        evernote_host => "www.evernote.com",
        dev_token     => undef,
        config_file   => undef,
        consumer_key  => undef,
        %options,
    };

    if( !defined $self->{ consumer_key } ) {
        ( my $dashed_pkg = __PACKAGE__ ) =~ s/::/-/g;
        $self->{ consumer_key } = lc $dashed_pkg;
    }

    if( ! defined $self->{ config_file } ) {
        my( $home ) = glob "~";
        $self->{ config_file } = "$home/.evernote.yml";
    }

    if( !defined $self->{ dev_token } ) {
        if( -f $self->{ config_file } ) {
            my $data = LoadFile $self->{ config_file };
            if( exists $data->{ dev_token } ) {
                $self->{ dev_token } = $data->{ dev_token };
            }
        }
    }

    my $user_store_uri =
        "https://$self->{ evernote_host }/edam/user";

    my $http_client = 
        Thrift::HttpClient->new( $user_store_uri );

    my $protocol =
        Thrift::BinaryProtocol->new( $http_client );

    $self->{ client } =
        Net::Evernote::Simple::EDAMUserStore::UserStoreClient->new( $protocol );

    bless $self, $class;
}

###########################################
sub init {
###########################################
    my( $self ) = @_;

    if( $self->{ init_done } ) {
        return 1;
    }

    if( !defined $self->{ dev_token } ) {
        LOGDIE "Developer token argument 'dev_token' missing. ", 
            "Check $EN_DEV_TOKEN_PAGE on how to obtain one.";
    }
    
    if( ! $self->version_check() ) {
        LOGDIE "Version check failed";
    }

    $self->{ init_done } = 1;
}

###########################################
sub dev_token {
###########################################
    my( $self ) = @_;

    return $self->{ dev_token };
}

###########################################
sub note_store {
###########################################
    my( $self ) = @_;

    $self->init();

    my $note_store_uri;

    eval {
        $note_store_uri = 
          $self->{ client }->getNoteStoreUrl( $self->{ dev_token } );
    };

    if( $@ ) {
        ERROR Dumper( $@ );
        return undef;
    }

    my $note_store_client = Thrift::HttpClient->new( $note_store_uri );

    my $note_store_protocol = Thrift::BinaryProtocol->new(
       $note_store_client );

    my $note_store = 
      Net::Evernote::Simple::EDAMNoteStore::NoteStoreClient->new(
        $note_store_protocol );

    return $note_store;
}

###########################################
sub version_check {
###########################################
    my( $self ) = @_;

    eval {
      my $version_ok =
        $self->{ client }->checkVersion( $self->{ consumer_key },
          Net::Evernote::Simple::EDAMUserStore::Constants::EDAM_VERSION_MAJOR,
          Net::Evernote::Simple::EDAMUserStore::Constants::EDAM_VERSION_MINOR,
        );
  
      INFO "Version check returned: $version_ok";
    };

    if( $@ ) {
        ERROR Dumper( $@ );
        return 0;
    }

    return 1;
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
