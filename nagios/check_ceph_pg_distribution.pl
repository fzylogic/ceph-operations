#!/usr/bin/perl
#
use strict;

my $low_threshold = shift || 0.5;
my $high_threshold = shift || 1.5;

my (%pg_count, %osds, $tot_pg_pairing, $tot_osds);

open(CEPH, '/usr/bin/ceph pg dump|');
while ( my $dist = <CEPH> ) {
  my @dump = split(/\s+/, $dist);
  next unless $dump[0] =~ /^\w+\.\w+$/; 
  foreach my $osd ( split(',', $dump[13])) {
    $osd =~ s/\D//g;
    $pg_count{$osd}++;
    $tot_pg_pairing++;
    $osds{$osd} = 1;
  }
}
close(CEPH);

my $tot_osds = scalar(keys %osds);
my $average = $tot_pg_pairing / $tot_osds;

my @low_outliers = grep { ($pg_count{$_} / $average) <= $low_threshold } keys %pg_count;
my @high_outliers = grep { ($pg_count{$_} / $average) >= $high_threshold } keys %pg_count;
if ( scalar(@low_outliers) || scalar(@low_outliers) ) {
  print scalar(@low_outliers) . " below, " . scalar(@high_outliers) . " above thresholds\n";
  exit(2);
}
else {
  print "Everything within limits\n";
  exit(0);
}
