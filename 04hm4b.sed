#ITM0417
# Huy Le, homework4b
# sed -f hm4b.sed datebook

# Insert above the first line the title PERSONNEL FILE.
1i/PERSONNEL FILE

# Remove the salaries ending in 500. 
/500$/d  

# Print the contents of the file with the last names and first names reversed.
s/\(^[A-Za-z]*\)\([ \t]*\)\([A-Za-z]*\):\(.*\)$/\3\2\1:\4/g

# Append at the end of the file THE END.
$a/THE END
