BEGIN {
  package main;
  use warnings;
  use Attribute::Signature;
  $^W = 0;
}

package main;

print "1..6\n";

my $total = 0;

sub that : method with(string) {
  print "ok 6\n";
}

sub this : with(float, string) {
  my $float  = shift;
  my $string = shift;
  $total++;
}

eval { this(); };
if ($total) {
  print "not ok 1\n";
} else {
  print "ok 1\n";
}

$total = 0;
eval { this("test", 1.1); };
if ($total) {
  print "not ok 2\n";
} else {
  print "ok 2\n";
}

$total = 0;
eval { this(1.1, "test") };
if ($total) {
  print "ok 3\n";
} else {
  print "not ok 3\n";
}

my $sig = Attribute::Signature->getSignature( 'main::this' );
if ($sig->[0] eq 'float') {
  print "ok 4\n";
} else {
  print "not ok 4\n";
}

eval {
  main->that();
};
if ($@) {
  print "ok 5\n";
} else {
  print "not ok 5\n";
}
eval {
  main->that("this");
};
if ($@) {
  print "not ok 6\n";
}
