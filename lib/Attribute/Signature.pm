package Attribute::Signature;

use strict;
use warnings::register;

use Carp;
use Scalar::Util qw ( blessed );

use Data::Dumper;
use Attribute::Handlers;

our $VERSION    = '1.00';
my  $SIGNATURES = {};

sub UNIVERSAL::with : ATTR(CODE,INIT) {
  my ($package, $symbol, $referent, $attr, $data) = @_;
 
  my $large   = *{$symbol}{NAME};
  my $subname = substr($large, rindex($large, ':') + 1);

  no warnings qw( redefine );

  ## make sure we have an array ref, so its easier
  if (!ref($data)) {
    $data = [ $data ];
  }
  
  ## save this for later use
  $SIGNATURES->{$package}->{$subname} = $data;

  my $attributes = { map { ($_, 1) } attributes::get( $referent ) };

  if ($attributes->{method}) {
    print "Signature on sub $subname is for a method\n" if $::AS_DEBUG;
    unshift @$data, $package;  ## put a placeholder in the front
  }

  *{$symbol} = sub {
    my $i = 0;
    my $count = scalar(@_);

    if ($attributes->{method}) {
      $i = 1;
    }

    if ($count != scalar(@$data)) {
      if ($attributes->{method}) {
	croak("invalid number of arguments passed to method $subname");
      } else {
	croak("invalid number of arguments passed to subroutine $subname");
      }
    }

    my $m = 0;
    print "Comparisons\n" if $::AS_DEBUG;
    print "\tSignature\tValue\n" if $::AS_DEBUG;
    while($i <= $count) {
      print "\t$data->[$i]\t\t$_[$i]\n" if $::AS_DEBUG;
      last unless $data->[$i];
      if (lc($data->[$i]) eq $data->[$i]) {
	## here we are checking for little types
	my $type = $data->[$i];
	if (Attribute::Signature->can( $type )) {
	  if (Attribute::Signature->$type( $_[$i] )) {
	    $m++;
	  }
	}
      } elsif (blessed($_[$i]) && $_[$i]->isa( $data->[$i]) ) {
	$m++;
      } elsif (!blessed($_[$i]) && ref($_[$i]) eq $data->[$i]) {
	$m++;
      }
      $i++;
    }

    if ($attributes->{method}) { $m++; }

    print "Out of band:\n\tCount\tMatched\n\t$count\t$m\n" if $::AS_DEBUG;
    
    if ($m != $count) {
      croak("call to $subname does not match signature");
    } else {
      $referent->( @_ );
    }
  };
}

sub getSignature  {
  my $class = shift;
  my $fqsn  = shift;

  ## this is my sub && package
  my $subname = substr($fqsn, rindex($fqsn, ':') + 1);
  my $package = substr($fqsn, 0, rindex($fqsn, '::'));

  return $SIGNATURES->{$package}->{$subname};
}

sub string {
  return 1 unless ref($_[0]);
  return 0;
}

sub number {
  return 1 if (float($_[0]) || int($_[0]));
}

sub float {
  my $class = shift;
  return 1 if $_[0] =~ /^\d*\.\d*$/;
  return 0;
}

sub int {
  my $class = shift;
  return 1 if $_[0] =~ /^\d+$/;
  return 0;
}

1;

__END__

=head1 NAME

Attribute::Signature - allows you to define a call signature for subroutines

=head1 SYNOPSIS

  package Some::Package;
  use Attribute::Signature;

  sub somesub : with(float, string, Some::Other::Class) {
    # .. do something ..
  }

  package main;
  my $array = Attribute::Signature->getSignature( 'Some::Package::somesub' );

=head1 DESCRIPTION

This module allows you to declare a calling signature for a method.  As yet it
does not provide multimethod type functionality, but it does prevent you from
writing lots of annoying code to check argument types inside your subroutine.
C<Attribute::Signature> takes two forms, the first is attributes on standard
subroutines, in which it examines every parameter passed to the subroutine.  However,
if the subroutine is marked with the method attribute, then Attribute::Signature
will not examine the first argument, which can be either the class or the instance.

C<Attribute::Signature> checks for the following types:

=over 4

=item HASH

=item ARRAY

=item GLOB

=item CODE

=item REF

=back

as well as, in the case of classes, that the object's class inherits from the named class.
For example:

  sub test : (Some::Class) {
    # .. do something ..
  }

would check to make sure that whatever was passed as the argument was blessed into a class
which returned 1 when the C<isa> method was called on it.

Finally C<Attribute::Signature> allows for some measure of type testing.  Any type that is
all in lower case is tested by calling a function having the same name in the Attribute::Signature
namespace.  Attribute::Signature comes with the following type tests:

=over 4

=item float

=item int

=item string

=item number

=back

You can define more tests by declaring subs in the Attribute::Signature namespace.

=head1 OTHER FUNCTIONS

=item getSignature( string )

C<Attribute::Signature> also allows you to call the getSignature method.  The string
should be the complete namespace and subroutine.
This returns the attribute signature for the function as an array reference.

=head1 AUTHOR

James A. Duncan <jduncan@fotango.com>

=head1 SEE ALSO

perl(1) UNIVERSAL(3)

=cut

