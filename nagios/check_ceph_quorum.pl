#!/usr/bin/perl

use strict;
use JSON;
use Data::Dumper;

my $warn = shift || "0"; ## By default, let's alarm if *any* elections happen
my $crit = shift || "0";

my $last_state;
my $cur_epoch;
my $return = 0;

sub get_last_status {
  if ( open(LOG, "/tmp/nagios_last_mon_status") ) {
    $last_state = <LOG>;
    my ($stamp, $epoch) = split(/\s+/, $last_state);
    close(LOG);
    return ($stamp, $epoch);
  }
  else {
    return undef;
  }
}

sub get_cur_status {
  open(CEPH, "/usr/bin/ceph mon_status|");
  my $status_json = <CEPH>;
  close(CEPH);
  my $json = JSON->new->allow_nonref;
  my $status = $json->decode( $status_json );
  my $epoch = $status->{'election_epoch'};
  return $epoch;
}

sub save_status {
  my $epoch = shift;
  open(LOG, ">/tmp/nagios_last_mon_status");
  print LOG time() . " " . $epoch;
  close(LOG);
}

my $epoch = get_cur_status();

my ($last_stamp, $last_epoch) = get_last_status();
if ( $last_stamp ) {
  my $t_since = time() - $last_stamp;
  my $changes = $epoch - $last_epoch;
  my $rate = ($changes == 0) ? 0 : ($t_since / $changes);
  if ( $rate >= $crit ) {
    print "CRITICAL: rate=$rate\n";
    $return = 2;
  }
  elsif ( $rate >= $warn ) {
    print "WARNING: rate=$rate\n";
    $return = 1;
  }
  else {
    print "OK: rate=$rate\n";
  }
}

save_status($epoch);
exit($return);
