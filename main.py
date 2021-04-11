import os
import mysql.connector
from mysql.connector import errorcode
from dotenv import load_dotenv
import datetime
import csv

load_dotenv()

def help(): 
  print("These are the functions")

def showRole(): 
  print("You are an administrator")

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
    if options[i] == "-a": 
      queryString += " * from ((((flow inner join flowbytes on flow.id = flowbytes.flow_id) inner join flowflags on flow.id = flowflags.flow_id) inner join flowiat on flow.id = flowiat.flow_id) inner join flowinfo on flow.id = flowinfo.flow_id) inner join flowpackets on flow.id = flowpackets.flow_id"
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
  if "-limit" not in options: 
    queryString += " limit 50"
  #apply our default output csv file name if it wasn't specified
  if fileName == "": 
    fileName = "out.csv"
  #if we didn't specify the all option then add that to the query string

  tableString = ""
  for table in tables: 
    if tableString == "": 
      tableString = "flow inner join " + table + " on flow.id = " + table + ".flow_id"
    else: 
      tableString = "(" + tableString + ") " + "inner join " + table + " on flow.id = " + table + ".flow_id"

  queryString = "select * from " + tableString + queryString
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

