package Simpy;

use 5.008007;
use strict;
use warnings;
use XML::Parser;

require Exporter;
use AutoLoader qw(AUTOLOAD);

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Simpy ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = "0.00_" . ( (qw$Revision: 1.15 $)[1]/10 );
$VERSION = eval $VERSION;


# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

###########################################################
#
# File    : Simpy.pm
# History : 5/30/06 (beads) initiated alpha development
#
###########################################################

=head1 NAME

Simpy - Perl interface to Simpy social bookmarking service

=head1 SYNOPSIS

  use Simpy;

  my $user = "jack";
  my $pass = "upth3h1ll";

  my $book = Simpy->new($user, $pass);
  my $tags = $book->GetTags();

  print $tags->xml;


=head1 DESCRIPTION

This module provides a Perl interface to the Simpy social bookmarking
service.  See http://www.simpy.com/simpy/service/api/rest/

THIS IS AN ALPHA RELEASE.  This module should not be relied on for any
purpose, beyond serving as an indication that a reliable version will be
forthcoming at some point the future.

This module is being developed as part of the "tagged wiki" component of
the Transpartisan Meshworks project ( http://www.transpartisanmeshworks.org ).
The "tagged wiki" will integrate social bookmarking and collaborative 
content development in a single application.

=head2 EXPORT

None by default.

=cut

use constant API_BASE => "http://www.simpy.com/simpy/api/rest/";
use LWP::UserAgent;

=head1 METHODS

=head2 new

Object construction method.

  my $book = Simpy->new;

  my $book = Simpy->new($user);

=cut

sub new {
  my ($class, $user) = @_;
  my $self = {
    _ua => LWP::UserAgent->new,
    _user => $user,
    _tags => undef,
    _status => undef
  };
  my $agent = $self->{_ua}->agent;
  $self->{_ua}->agent("Simpy::API $VERSION ($agent)");
  bless $self, $class;
  return $self;
}

=head2 API Methods

Simpy API methods follow the naming conventions established as part of 
the Simpy REST API.

=head3 GetTags

Return a list of tags.

Currently, all this does is spit out the XML...

=cut
use Data::Dumper;

sub GetTags {
  my ($self, $pass, $refresh) = @_;

  if (!defined($self->{_tags}) || $refresh) {

    my $req = HTTP::Request->new(GET => API_BASE . "GetTags.do");
    $req->authorization_basic($self->{_user}, $pass);
    my $response = $self->{_ua}->request($req);

    if ($response->is_success) {
      my $p = new XML::Parser(Style => 'Tree');      
      my $parse = $p->parse($response->content);
      my @tree = @{@{$parse}[1]};
      my %hash;

      @tree = splice(@tree,1,$#tree);        # force pop of user element

      while ($#tree > 2) {
         @tree = splice(@tree,3,$#tree);   # 0, '  ', 'tag'

         my $t = shift @tree;
         last if !defined($t);
         my ($n, $c) = ($t->[0]->{'name'}, $t->[0]->{'count'});
         $hash{$n} = $c;
      }

      $self->{_tags} = \%hash;
    } else {
      $self->{_status} = $response->status_line;
      warn($response->status_line);
    }
  }

  return $self->{_tags};
}

sub get_status {
  my ($self, $user) = @_;
  return $self->{_status};
}

=head2 Accessor Methods

=head3 user

Set and get Simpy username.

   my $user = $book->user;

   $book->user($user);

=cut

sub user {
  my ($self, $user) = @_;
  $self->{_user} = $user if defined($user);
  return $self->{_user};
}

=head1 CAVEATS

This is an early alpha release.  Not all methods of the API are 
implemented, nor have the sub-modules defining data types for those API 
methods been developed.

=head1 SEE ALSO

http://simpyapi.sourceforge.net

http://www.transpartisanmeshworks.org

=head1 AUTHOR

Beads Land, <lt>beads@beadsland.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 by Beads Land

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut

1;

