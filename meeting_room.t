#!/usr/bin/env perl

use warnings;
use strict;

use Test::More;
use Tie::IxHash;

my %input_to_expected;
tie %input_to_expected, 'Tie::IxHash';
%input_to_expected = (
  # team_size, floor, start, end => floor, room_id

  # default test case
  '5,8,10:30,11:30' => '8.43',

  # team is too big for any room
  '20,8,10:30,11:30' => '',

  # found two rooms on same floor, but we will only show one
  '5,8,8:00,9:00' => '8.23',

  # 8 hours, unimplemented for lack of a* room-to-room scheduling
  '5,8,9:00,17:00' => '',
);

foreach my $input (keys %input_to_expected) {
  my $expected = $input_to_expected{$input};
  my $got = qx{echo $input | ./meeting_room.pl rooms.txt};
  chomp $got;
  is ($got, $expected, "echo $input | ./meeting_room.pl rooms.txt");
}


done_testing();
