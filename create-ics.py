import csv
from ics import Calendar, Event

c = Calendar()
with open('events.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in spamreader:
        e = Event()
        e.name = row[1]
        e.begin = row[0]
        # e.duration = {"hours": 24}
        e.make_all_day()
        c.events.add(e)
        print(', '.join(row))

print(c.events)

with open('rwth_calendar.ics', 'w') as my_file:
    my_file.writelines(c)
