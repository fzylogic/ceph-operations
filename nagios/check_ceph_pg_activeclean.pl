#!/usr/bin/perl

use strict;

open(CEPH, "/usr/bin/ceph pg stat|");
my $pg_stat = <CEPH>;
close(CEPH);
my ($total_pgs) = $pg_stat =~ /([0-9]+) pgs:/;
my (@active_pgs) = $pg_stat =~ /([0-9]+) active\+clean/g;
my $active;
foreach my $a (@active_pgs) {
  $active += $a;
}

if ( $total_pgs == $active ) {
  print 'OK: ' . $pg_stat;
  exit(0);
}
elsif ( $total_pgs > $active ) {
  print 'CRIT: ' . $pg_stat;
  exit(2);
}
else {
  print "Things are weird!\n";
  exit(-1);
}
