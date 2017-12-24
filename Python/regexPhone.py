# Extract phone number in a string
import re

phoneNumRegex = re.compile(r'\d\d\d-\d\d\d-\d\d\d\d)
print(phoneNumRegex.finall('Call me 415-555-1011 tomorrow, or 415-555-999'))
