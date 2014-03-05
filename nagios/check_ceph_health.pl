#!/usr/bin/perl


open(CEPH, "/usr/bin/ceph health");
my $health = <CEPH>;
close(CEPH);
print $health;
if ( $health =~ /HEALTH_OK/ ) {
  exit(0);
}
else {
  exit(2);
}
