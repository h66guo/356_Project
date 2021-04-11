import os
import mysql.connector
from mysql.connector import errorcode
from dotenv import load_dotenv
import datetime
import csv

load_dotenv()

def help(): 
  print('''
These are the commands
show
write
To find details about a commands use help -<command>
        '''
        )
def commandInfo(command): 
  if command == "-show": 
    print(
'''
show: used to show network statistics 

Data Selector Options (at lease one of these following options must be used)
-----------------------------------------------------------------------------
-a -> show all data 
-flowbytes -> show flow bytes data (cannot be used with -a)
-flowflags -> show flow flags data (cannot be used with -a)
-flowiat -> show inter-arrival times (cannot be used with -a)
-flowinfo -> show additional flow info such as time active, time idle, etc (cannot be used with -a)
-flowpackets -> show flow packets info (cannot be used with -a)
-protocol -> show flow protocol info (cannot be used with -a)
-clients -> show all clients (cannot be used with any other options)

Filtering Options
------------------
-d <start date> <end date> -> show network data between a specified start date and end date
-sortasc <sort parameter> -> sort data in ascending order based on sort parameter ('timestamp')
-sortdesc <sort parameter> -> sort data in descending order based on sort parameter ('timestamp')
-ddos -> show network data that corresponded to a DDOS attack
-source <source ip> -> show network data corresponding to a particular source 
-dest <destination ip> -> show network data corresponding to a particlar destination
'''    
    )

def query(options): 
  cnx = mysql.connector.connect(user='root',
                              password= os.getenv('MySQLPassword'),
                              host='localhost',
                              database='internet_traffic')
  cursor = cnx.cursor(dictionary=True)
  queryString = ""
  queryParams = ()
  fileName = ""
  tables = []
  #go through the options specified
  for i in range(len(options)): 
    #data selection options
    if options[i] == "-a": 
      queryString += " * from ((((flow inner join flowbytes on flow.id = flowbytes.flow_id) inner join flowflags on flow.id = flowflags.flow_id) inner join flowiat on flow.id = flowiat.flow_id) inner join flowinfo on flow.id = flowinfo.flow_id) inner join flowpackets on flow.id = flowpackets.flow_id"
    elif options[i] == "-clients": 
      queryString = "select * from source union select * from destination"
    elif options[i] == "-flowbytes": 
      tables.append("flowbytes")
    elif options[i] == "-flowflags": 
      tables.append("flowflags")
    elif options[i] == "-flowiat":
      tables.append("flowiat")
    elif options[i] == "-flowinfo": 
      tables.append("flowinfo")
    elif options[i] == "-flowpackets": 
      tables.append("flowpackets")
    elif options[i] == "-protocol": 
      tables.append("protocol")
    #filter options
    elif options[i] =="-d": 
      try: 
        startDate = datetime.date(int(options[i+1][:4]), int(options[i+1][4:6]), int(options[i+1][6:]))
        endDate = datetime.date(int(options[i+2][:4]), int(options[i+2][4:6]), int(options[i+2][6:]))
        queryString += " where timestamp BETWEEN %s AND %s"
        queryParams += (startDate, endDate)
      except: 
        return
    elif options[i] == "-sortasc":
      queryString = queryString + " order by " + options[i+1] + " asc"
    elif options[i] == "-sortdesc":
      queryString = queryString + " order by " + options[i+1] + " desc"
    elif options[i] == "-limit": 
      queryString = queryString + " limit " + options[i+1] 
    elif options[i] == "-filename": 
      fileName = options[i+1]
    elif options[i] == "-ddos": 
      if "where" not in queryString: 
        queryString += " where"
        queryString += " label = 'DDos'"
      else: 
        queryString += " and label = 'DDos'"
  #apply our default limit if it wasn't specified      
  if "-limit" not in options and options[0] != "-clients": 
    queryString += " limit 50"
  #apply our default output csv file name if it wasn't specified
  if fileName == "": 
    fileName = "out.csv"
  #if we didn't specify the all option then add that to the query string

  tableString = ""
  for table in tables: 
    if tableString == "": 
      if table == "protocol": 
        tableString = "flow inner join " + table + " on flow.protocol_id = " + table + ".id"
      else:
        tableString = "flow inner join " + table + " on flow.id = " + table + ".flow_id"
    else: 
      if table == "protocol": 
        tableString = "(" + tableString + ") " + "inner join " + table + " on flow.protocol_id = " + table + ".id"
      else:
        tableString = "(" + tableString + ") " + "inner join " + table + " on flow.id = " + table + ".flow_id"

  queryString = "select * from " + tableString + queryString if options[0] != "-clients" else queryString
  cursor.execute(queryString, queryParams)
  print(cursor.column_names)
  rows = []
  for i in cursor: 
    print(i)
    rows.append(i)
  with open(fileName, 'w', newline='') as f:
    fieldnames = []
    for i in cursor.column_names:
      fieldnames.append(i)
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)
  cnx.close()
  print("Command successfully ran")
def write(): 
  print("This is the write function")


while True: 
  userInput = input()
  #show all info between two dates
  options = userInput.split()
  if options[0] == "show": 
    query(options[1:])
  elif options[0] == "help": 
    if len(options) > 1: 
      commandInfo(options[1])
    else: 
      help()

