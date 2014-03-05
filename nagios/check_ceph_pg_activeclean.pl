#!/usr/bin/perl

use strict;

open(CEPH, "/usr/bin/ceph pg stat|");
my $pg_stat = <CEPH>;
close(CEPH);
my ($total_pgs, $active_pgs) = $pg_stat =~ /([0-9]+) pgs: ([0-9]+) active\+clean/;

if ( $total_pgs == $active_pgs ) {
  print "All active+clean\n";
  exit(0);
}
elsif ( $total_pgs > $active_pgs ) {
  print "Some non-clean PGs exist!\n";
  exit(2);
}
else {
  print "Things are weird!\n";
  exit(-1);
}
