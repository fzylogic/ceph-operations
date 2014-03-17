#!/usr/bin/perl

use strict;
my @broken;

sub critical {
  my $error = shift;
  print $error;
  exit(2);
}
sub ok {
  my $msg = shift;
  print $msg;
  exit(0);
}

opendir(OSDS, "/var/lib/ceph/osd") || critical("can't find OSDs at /var/lib/ceph/osd");
while ( my $osd = readdir(OSDS) ) {
  next if $osd =~ /^\./;
  my ($osd_num) = $osd =~ /ceph-([0-9]+)/;
  next unless $osd_num =~ /^\d+$/;
  open(ADMIN, "/usr/bin/ceph --admin-daemon /var/run/ceph/ceph-osd.$osd_num.asok version 2>&1|");
  close(ADMIN);
  if ( $? != 0 ) {
    push(@broken, $osd_num);
  }
}
closedir(OSDS);
if ( scalar(@broken) ) {
  critical("Broken OSDs: " . join(',', @broken));
}
ok("All OSDs responding");
