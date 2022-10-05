#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import datetime
import json
import sys

import requests
import wsse.client.requests.auth

# arguments are given as a JSON object piped to this script
args = json.loads(sys.stdin.read())

POSITIONS = {
    args["tigeruhr_position"]: args["roster_position"],
}

TIGERUHR_USERNAME = args["tigeruhr_api_username"]
TIGERUHR_PASSWORD = args["tigeruhr_api_password"]


positions_rows = dict()

# get all hired positions
resources = requests.get(
    url="https://www.tigeruhr.io/api/v1/resources/",
    auth=wsse.client.requests.auth.WSSEAuth(
        TIGERUHR_USERNAME,
        TIGERUHR_PASSWORD
    )
).json()

for res in resources:
    
    first, last = res.get("full_name").split(" ", 1)
    email_computed = "{netid}@princeton.edu".format(**res)

    positions = res.get("positions", list())
    
    for pos in positions:
        positions_rows[pos] = positions_rows.get(pos, list())
        positions_rows[pos].append(
            (first, last, email_computed)
        )

for position, position_hires in positions_rows.items():
    if position not in POSITIONS:
        continue
    
    posfn = POSITIONS.get(position, position)
    csv_str = ("\n".join(["first,last,email,memo"] + list(map(lambda p: ",".join(p) + ',""', position_hires))))

    filename = "input/{filename}.csv".format(
        filename=posfn,
        today=datetime.date.today()
    )
    open(filename, "w").write(csv_str)
    