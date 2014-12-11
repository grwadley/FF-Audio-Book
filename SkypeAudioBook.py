#!usr/bin/python

import re
import os
from subprocess import call

book = open("sample", "r");
pattern = re.compile(r'(\[.*\]\s)(.*):\s(.*)', re.MULTILINE)

for (timestamp, name, message) in re.findall(pattern, book.read()):
	m = "then " + name + " said " + message;
	#m = re.sub(r'[\W|\s]+', '', m, flags=re.UNICODE);
	print m;
	call(["say", m]);
	#os.system("say " + m);