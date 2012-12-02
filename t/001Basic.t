######################################################################
# Test suite for Net::Evernote::Simple
# by Mike Schilli <cpan@perlmeister.com>
######################################################################
use warnings;
use strict;

use Test::More;

plan tests => 1;

use Net::Evernote::Simple;

my $en = Net::Evernote::Simple->new(
);

is $en->version_check(), 1, "version check";

my $note_store = $en->note_store();

my $notebooks =
  $note_store->listNotebooks( $en->dev_token() );

for my $notebook (@$notebooks) {
    print $notebook->name(), "\n";
}
