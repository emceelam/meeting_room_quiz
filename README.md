# meeting_room_quiz

## How to run
```bash
# team_size:  5
# floor:      8
# start_time: 10:30
# end_time:   11:30
echo '5,8,10:30,11:30' | ./quiz.pl rooms.txt
```
## Running the test script

```bash
perl meeting_room.t
```

## how you solved the problem

We scan the list of rooms, ignoring any which collide with the start/end times we wish to schedule. Also we ignore any rooms that are too small for the team. The remaining rooms are valid for scheduling, but to differentiate we score them based on how many floors we need to walk to get to the room. Sometimes, we get two rooms that are equally good, in which case, we pick one based on lexical sorting of the room id.


## how it would behave based on the different parameters:

### number of team members

For team members, we check room size vs team size

### longer meeting times
For longer meeting times, we check if a room's start/end time occurs within a team's start/end time span.

### many rooms with random booking times
For many rooms, we simply scan all of them.

## How would you test the program to ensure it always produced the correct results?

We write a test script, meeting_room.t, that tests for various edge cases, e.g. large teams, long meetings, before office-hour meetings, after-hour meetings, meetings which force people to walk up/down stairs

## For extra credit, can you improve the solution to split the meeting across more than one room

Unfortunately, I ran out of time. This scenario is quite a bit more tricky, as you need to an understanding of A* algorithm to pick the nearest room as the team leaves one room to seek the next room. It would be a lot easier to pick rooms based on a team's home floor, but that's not possible when a team is continuously moving and needs to find the next nearest available room from whichever room they are currently at.
