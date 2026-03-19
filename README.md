You know how old people keep time in an arcane system of double
base-12 and base-60 handed down from Babylonians and Sumerians? And
you know how they try to get you to use that same system in the gol'
dang 21st century? Gross.

Welcome to a better way of doing things.

This app offers an easy way to transition to metric time. It allows
you to learn the metric system of time while keeping track and syncing
with the old Gregorian system.

Some basics about metric time:

For ease of transition, much of the metric calendar is exactly the
same as the old system - Years start and end at the same time, leap
years are calculated in the Gregorian system, and local Time Zones and
Daylight Savings customs will be accounted for.

The day, however, is divided differently. Each rotation of the earth
has 100,000 seconds (from 0 to 99,999), and is represented as H:MM:SS,
which is a straightforward metric number that increases by 1 each
second of the day, from 0:00:00 to 9:99:99 at which point the day
increments upwards.

Likewise, the 'weeks' and 'months' are just further 0-indexed digits
on the accumulating totals of seconds, So a date like 0:1:2.3:45:67,
is the 1,234,567th second of the year. Note, though, that unlike the
old system which uses 1-index for days, and months, (but not hours,
minutes and seconds), this system stays 0-index throughout.

Because the earth rotates 365.256363 times every orbit around the sun,
that's where the year ends, and the seconds reset to 0 as the year
increases 1. --we petitioned to have this changed to 1000 rotations 
per orbit but have yet to hear back from anyone

The current year \(year) is derived as 5000 years (the approximate
length of recorded human history) before the dawn of the computer era
of time, UNIX time (Jan. 1, 1970).
