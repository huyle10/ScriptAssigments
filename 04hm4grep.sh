#!/bin/bash
# ITMO417 Shell Scripting
# Author Huy Le
# A series of grep command

echo '1 Print all lines that contain a phone number with an extension the letter x or X followed by four digits.'
grep -o '[0-9]\{3\}\-[0-9]\{3\}\-[0-9]\{4\}\s[xX][0-9]\{4\}' grepDatafile.txt 

echo '2 Print all lines that begin with three digits followed by a blank.'
grep -P '^\d{3} .*$' grepDatafile.txt

echo '3 Print all lines that contain a date. Hint: this is a very simple pattern. It does not have to work for any year before 2000.'
grep -P '(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\. [1-3]*[0-9]+\, 2\d{3}' grepDatafile.txt 

echo '4 Print all lines containing a vowel (a, e, i, o, or u) followed by a single character followed by the same vowel again. Thus, it will find “eve” or “adam” but not “vera”. Hint: \( and \)'
grep -P '([aeiou]).\1' grepDatafile.txt

echo '5 Print all lines that do not begin with a capital S.'
grep -v '^S.*$' grepDatafile.txt

echo '6 Print all lines that contain CA in either uppercase or lowercase.'
grep -i 'ca' grepDatafile.txt

echo '7 Print all lines that contain an email address (they have an @ in them), preceded by the line number.'
grep -n '@' grepDatafile.txt

echo '8 Print all lines that do not contain the word Sep. (including the period).'
grep -v 'Sep\.' grepDatafile.txt

echo '9 Print all lines that contain the word de as a whole word.'
 grep -w '\<de\>' grepDatafile.txt
