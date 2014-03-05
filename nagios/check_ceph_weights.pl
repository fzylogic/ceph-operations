#!/usr/bin/perl

use strict;

my (%cumul, %assigned, $row, $rack, $host, $critical);

open(CEPH, "/usr/bin/ceph osd tree|");
while(my $out = <CEPH>) {
  next if $out =~ /^\#/;
  my ($type, $name, $updown, $reweight);
  my ($id, $weight, $col_c, $col_d, $col_e) = split(/\s+/, $out);
  if ( grep { $col_c eq $_ } ('row','rack','host','root') ) {
    $name = $col_d;
    $type = $col_c;
  }
  elsif ( $col_c =~ /^osd\./ ) {
    $name = $col_c;
    $updown = $col_d;
    $reweight = $col_e;
    $type = 'osd';
    $cumul{$host} += $weight;
    $cumul{$rack} += $weight;
    $cumul{$row} += $weight;
  }
  if ( $type eq 'rack' ) {
    $rack = $name;
  }
  elsif ( $type eq 'row' ) {
    $row = $name;
  }
  elsif ( $type eq 'host' ) {
    $host = $name;
  }
  $assigned{$type}{$name} = $weight;
}
close(CEPH);
  
foreach my $host (keys %{$assigned{'host'}}) {
  if ( $assigned{'host'}{$host} != $cumul{$host} ) {
    print $host . " a=" . $assigned{'host'}{$host} . " c=" . $cumul{$host} . "\n";
    $critical = 1;
  }
}
foreach my $rack (keys %{$assigned{'rack'}}) {
  if ( $assigned{'rack'}{$rack} != $cumul{$rack} ) {
    print $rack . " a=" . $assigned{'rack'}{$rack} . " c=" . $cumul{$rack} . "\n";
    $critical = 1;
  }
}
foreach my $row (keys %{$assigned{'row'}}) {
  if ( $assigned{'row'}{$row} != $cumul{$row} ) {
    print $row . " a=" . $assigned{'row'}{$row} . " c=" . $cumul{$row} . "\n";
    $critical = 1;
  }
}


if ( $critical = 1 ) {
  exit(2);
}
exit(0);
