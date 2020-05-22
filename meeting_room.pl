#!/usr/bin/env perl

=begin comment

Programming Test 2:
Conference room scheduling. Find the nearest open conference room for a team in which a team can hold its meeting. Given n team members with the floor on which they work and the time they want to meet, and a list of conference rooms identified by their floor and room number as a decimal number, maximum number of people it fits and pairs of times they are open - find the best place for the team to have their meeting. If there is more than one room available that fits the team at the chosen time then the best place is on the floor the closest to where the team works.
E.g.
rooms.txt
7.11,8,9:00,9:15,14:30,15:00
8.23,6,10:00,11:00,14:00,15:00
8.43,7,11:30,12:30,17:00,17:30
9.511,9,9:30,10:30,12:00,12:15,15:15,16:15
9.527,4,9:00,11:00,14:00,16:00
9.547,8,10;30,11:30,13:30,15:30,16:30,17:30
Input:
5,8,10:30,11:30 # 5 team members, located on the 8th floor, meeting time 10:30 - 11:30
Output:
9.547
Please explain: how you solved the problem and how it would behave based on the different parameters (number of team members, longer meeting times, many rooms with random booking times). How would you test the program to ensure it always produced the correct results?
For extra credit, can you improve the solution to split the meeting across more than one room if say only one room is available for a fraction of the meeting and another room is free later to hold the remainder of the meeting during the set time. If you want to make this more powerful - assume that the number of room splits can happen in proportion to the length of the meeting so that say if a meeting is 8 hrs long then the algorithm could schedule it across say up to 4 rooms if a single room was not available for the whole time.

=end comment
=cut

use warnings;
use strict;

use Data::Dumper;
use File::Slurp qw(read_file);
use List::Util qw(min pairs);
use POSIX qw(strftime);
use Readonly;
use Time::Local qw( timelocal_posix );

die "Usage: echo '5,8,10:30,11:30' | $0 rooms.txt\n" if !@ARGV;

my $room_file = $ARGV[0];

# for epoch time conversions
my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);

# process rooms.txt
my %catalog;
my @lines = read_file($room_file);
foreach my $line (@lines) {
  chomp $line;

  my ($floor, $room_id, $size, @times) = split m{[.,]}, $line;

  # convert to epoch time
  @times = map {
    ($hour, $min) = split m{:}, $_;
    timelocal_posix( $sec, $min, $hour, $mday, $mon, $year );
  } @times;

  # create two-element arrayref of start_time, end_time;
  my @time_spans = pairs @times;

  # catalog the room
  @{$catalog{$room_id}}{qw/floor size time_spans/}
    = ($floor, $size, \@time_spans);
}

# read the input line
my $input_line = <STDIN>;
#print "$input_line\n";
my ($team_size, $team_floor, @times) = split m{,}, $input_line;

# convert to epoch time
my ($team_start, $team_end) = map {
  ($hour, $min) = split m{:}, $_;
  timelocal_posix( $sec, $min, $hour, $mday, $mon, $year );
} @times;

# Score eligible rooms based on proximity to team location
my %room_score;
ROOM:
foreach my $room_id (keys %catalog) {
  my $room = $catalog{$room_id};
  my ($room_floor, $room_size, $time_spans)
    = @{$room}{qw/floor size time_spans/};

  # room too small
  next ROOM if $team_size > $room_size;

  foreach my $time_span (@$time_spans) {
    my ($span_start, $span_end) = @$time_span;

    # kick out if team's start/end occurs in a room's schedule
    next ROOM if $team_start > $span_start && $team_start < $span_end;
    next ROOM if $team_end   > $span_start && $team_end   < $span_end;

    # kick out if room's start/end occurs in a team's schedule
    next ROOM if $span_start > $team_start && $span_start < $team_end;
    next ROOM if $span_end   > $team_start && $span_end   < $team_end;
  }

  # score the eligible room
  my $score = abs($team_floor - $room_floor);  # distance traveled
  $room_score{$room_id} = $score;
}

# least distance travelled determines best room
my $best_score = min(values %room_score);
my @best_rooms
  = grep { $room_score{$_} == $best_score }
    sort { $a <=> $b }
    keys %room_score;

# quit if no rooms are available
exit(0) if !@best_rooms;

# sometimes we have two equally good rooms
# we have to pick one
my $room_id = $best_rooms[0];
print join('.', $catalog{$room_id}{floor}, $room_id) . "\n";
