import random
import csv
from datetime import datetime,timedelta

agents = [
    (1, "Rahul", "Payments"),
    (2, "Aisha", "Login"),
    (3, "Neha", "Technical"),
    (4, "Arjun", "Payments"),
    (5, "Kiran", "Login"),
    (6, "Meera", "Technical"),
    (7, "Sahil", "Payments"),
    (8, "Pooja", "Login")
]

with open("agents.csv","w",newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["agent_id","agent_name","team"])
    writer.writerows(agents)

num_tickets = 3000
priorities = ['High','Medium','Low']
categories = ['Payment','Bug','Login','Other']

start_date = datetime(2025,5,1)
tickets = []

for i in range(1001, 1001 + num_tickets):
    created_at = start_date + timedelta(
        days=random.randint(0, 60),
        hours=random.randint(0, 23),
        minutes=random.randint(0, 59)
    )

    priority = random.choices(
        priorities, weights=[0.2, 0.4, 0.4], k=1
    )[0]

    category = random.choice(categories)

    # Resolution time logic (hours)
    if priority == "High":
        resolution_hours = random.randint(1, 6)
    elif priority == "Medium":
        resolution_hours = random.randint(6, 15)
    else:
        resolution_hours = random.randint(12, 36)

    closed_at = created_at + timedelta(hours=resolution_hours)

    tickets.append([
        i,
        created_at.strftime("%Y-%m-%d %H:%M:%S"),
        closed_at.strftime("%Y-%m-%d %H:%M:%S"),
        priority,
        category
    ])

with open("tickets.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["ticket_id", "created_at", "closed_at", "priority", "category"])
    writer.writerows(tickets)

assignments = []

for ticket in tickets:
    ticket_id = ticket[0]
    agent_id = random.randint(1, 8)
    assignments.append([ticket_id, agent_id])

with open("ticket_assignments.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["ticket_id", "agent_id"])
    writer.writerows(assignments)
