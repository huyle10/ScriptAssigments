#!/usr/bin/perl

# Author: Huy Le

# Perl4: Format and Write

open(PW, "./passwd") or die "How did you get logged in?";
while (<PW>) {
 ($user,$uid,$gcos) = (split /:/)[0,2,4];
 ($real) = split /,/,$gcos;
 write;
}
format STDOUT =
@<<<<<<< @>>>>>> @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$user, $uid, $real
.
