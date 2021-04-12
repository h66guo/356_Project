import os
import mysql.connector
from mysql.connector import errorcode
from dotenv import load_dotenv
import datetime
import csv

load_dotenv()

#table arrays for finding table to update 
flowColumns = [
  "id",
  "source_ip",
  "source_port",
  "destination_ip", 
  "destination_port", 
  "protocol_id",
  "timestamp", 
  "duration", 
  "label"
]

flowbytesColumns = [
  "flow_id", 
  "bytes_per_second", 
  "fwd_bytes_bulk_avg",
  "bwd_bytes_bulk_avg", 
  "fwd_subflow_bytes_avg", 
  "bwd_subflow_bytes_avg", 
  "fwd_init_win_bytes", 
  "bwd_init_win_bytes"
]

flowflagsColumns = [
  "flow_id",
  "fwd_psh_flags", 
  "bwd_psh_flags", 
  "fwd_urg_flags", 
  "bwd_urg_flags", 
  "fin_flag_count", 
  "syn_flag_count",
  "rst_flag_count",
  "psh_flag_count",
  "ack_flag_count",
  "urg_flag_count",
  "cwe_flag_count",
  "ece_flag_count"
]

flowiatColumns = [
  "flow_id",
  "fwd_header_length",
  "bwd_header_length",
  "down_up_ratio",
  "fwd_segment_size_avg",
  "bwd_segment_size_avg",
  "fwd_header_length_1",
  "fwd_bulk_rate_avg",
  "bwd_bulk_rate_avg",
  "fwd_segment_size_min",
  "active_time_mean",
  "active_time_std", 
  "active_time_max",
  "active_time_min",
  "idle_time_mean",
  "idle_time_std",
  "idle_time_max",
  "idle_time_min"
]

flowinfoColumns = [
  "flow_id",
  "fwd_header_length",
  "bwd_header_length",
  "down_up_ratio", 
  "fwd_segment_size_avg",
  "bwd_segment_size_avg",
  "fwd_header_length_1",
  "fwd_bulk_rate_avg",
  "bwd_bulk_rate_avg",
  "fwd_segment_size_min",
  "active_time_mean",
  "active_time_std",
  "active_time_max",
  "active_time_min",
  "idle_time_mean",
  "idle_time_std", 
  "idle_time_max",
  "idle_time_min"
]

flowpacketsColumns = [
  "flow_id",
  "fwd_packets",
  "bwd_packets",
  "fwd_packets_bytes",
  "bwd_packets_bytes",
  "fwd_packets_bytes_max",
  "fwd_packets_bytes_min",
  "fwd_packets_bytes_mean",
  "fwd_packets_bytes_std",
  "bwd_packets_bytes_max",
  "bwd_packets_bytes_min",
  "bwd_packets_bytes_mean",
  "bwd_packets_bytes_std",
  "packets_per_second", 
  "fwd_packets_per_second",
  "bwd_packets_per_second",
  "packet_length_min",
  "packet_length_max",
  "packet_length_mean",
  "packet_length_std",
  "packet_length_variance", 
  "packet_size_avg",
  "fwd_packets_bulk_avg",
  "bwd_packets_bulk_avg",
  "fwd_subflow_packets_avg",
  "bwd_subflow_packets_avg",
  "fwd_act_data_packets"
]

def findTable(column): 
  if column[1:] in flowColumns: 
    return "flow"
  elif column[1:] in flowbytesColumns: 
    return "flowbytes"
  elif column[1:] in flowflagsColumns:
    return "flowflags"
  elif column[1:] in flowiatColumns:
    return "flowiat"
  elif column[1:] in flowinfoColumns:
    return "flowinfo"
  elif column[1:] in flowpacketsColumns:
    return "flowpackets"




def help(): 
  print('''
These are the commands
show
write
update
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
  elif command == "update": 
    print(
'''
update: used to update a flow (using a known flow id)

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

def insert(options): 
  table = options[0]
  cnx = mysql.connector.connect(user='root',
                                password= os.getenv('MySQLPassword'),
                                host='localhost',
                                database='internet_traffic')
  cursor = cnx.cursor(dictionary=True)
  if table == "flow":
    print("Here")
    cursor.execute(
                    'insert into flow (source_ip, source_port, destination_ip, destination_port, protocol_id, timestamp, duration, label) values(%s, %s,%s,%s,%s,%s,%s,%s)',
                    options[1:]
                  )
  elif table == "flowbytes":
      cursor.execute(
                    'insert into flowbytes (flow_id, bytes_per_second, fwd_bytes_bulk_avg, bwd_bytes_bulk_avg, fwd_subflow_bytes_avg, bwd_subflow_bytes_avg, fwd_init_win_bytes, bwd_init_win_bytes) values(%s, %s,%s,%s,%s,%s,%s,%s)',
                    options[1:]
                  )
  elif table == "flowflags": 
      cursor.execute(
                    'insert into flowflags (flow_id,fwd_psh_flags, bwd_psh_flags, fwd_urg_flags, bwd_urg_flags, fin_flag_count, syn_flag_count, rst_flag_count, psh_flag_count, ack_flag_count, urg_flag_count, cwe_flag_count, ece_flag_count) values(%s, %s,%s,%s,%s,%s,%s,%s, %s, %s, %s, %s, %s)',
                    options[1:]
                  )
  elif table == "flowiat": 
      cursor.execute(
                    'insert into flowiat (flow_id, iat_mean, iat_std, iat_max, iat_min, fwd_iat_total, fwd_iat_mean, fwd_iat_std, fwd_iat_max, fwd_iat_min, bwd_iat_total, bwd_iat_mean, bwd_iat_std, bwd_iat_max, bwd_iat_min) values(%s, %s,%s,%s,%s,%s,%s,%s, %s, %s, %s, %s, %s, %s, %s)',
                    options[1:]
                  )
  elif table == "flowinfo": 
      cursor.execute(
                    'insert into flowinfo (flow_id, fwd_header_length, bwd_header_length, down_up_ratio, fwd_segment_size_avg, bwd_segment_size_avg, fwd_header_length_1, fwd_bulk_rate_avg, bwd_bulk_rate_avg, fwd_segment_size_min, active_time_mean, active_time_std, active_time_max, active_time_min, idle_time_mean, idle_time_std, idle_time_max, idle_time_min) values(%s, %s,%s,%s,%s,%s,%s,%s, %s, %s, %s, %s, %s, %s, %s,%s, %s, %s)',
                    options[1:]
                  )
  elif table == "flowpackets":
      cursor.execute(
                    'insert into flowinfo (flow_id,fwd_packets,bwd_packets,fwd_packets_bytes,bwd_packets_bytes,fwd_packets_bytes_max,fwd_packets_bytes_min,fwd_packets_bytes_mean,fwd_packets_bytes_std,bwd_packets_bytes_max,bwd_packets_bytes_min,bwd_packets_bytes_mean,bwd_packets_bytes_std,packets_per_second,fwd_packets_per_second,bwd_packets_per_second,packet_length_min,packet_length_max,packet_length_mean,packet_length_std,packet_length_variance,packet_size_avg	fwd_packets_bulk_avg,bwd_packets_bulk_avg,fwd_subflow_packets_avg,bwd_subflow_packets_avg,fwd_act_data_packets) values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',
                    options[1:]
                  )
  cnx.commit()
  cursor.close()
  cnx.close()
  print("Insertion Successfully Completed")

def update(options):
  try:
    flowid = options[0] 
    options = options[1:]
    commands = {}
    cnx = mysql.connector.connect(user='root',
                                password= os.getenv('MySQLPassword'),
                                host='localhost',
                                database='internet_traffic')
    cursor = cnx.cursor(dictionary=True)
    for i in range(0, len(options), 2):
      table = findTable(options[i])
      if table in commands: 
        commands[table] = commands[table] + ", " + options[i][1:] + " = " + options[i+1]
      else: 
        print(options)
        commands[table] = "update " + table + " set " + options[i][1:] + " = " + options[i+1]

    for key in commands.keys(): 
      print("Command:")
      if key == "flow": 
        command = commands[key] + " where id = " + flowid
      else: 
        command = commands[key] + " where flow_id = " + flowid
      print(command)
      cursor.execute(command)
      print(cursor)      
    
    cnx.commit()
    cnx.close()
    cursor.close()
    print("Update Complete")
  except mysql.connector.Error as err:
    print(err) 
    print("Error in update command, please check command options or use help to get additional information")

def delete(flowid): 
  try:
    cnx = mysql.connector.connect(user='root',
                                password= os.getenv('MySQLPassword'),
                                host='localhost',
                                database='internet_traffic')
    cursor = cnx.cursor(dictionary=True)
    cursor.execute('delete from flow where id = {}'.format(flowid))
    cursor.execute('delete from flowbytes where flow_id = {}'.format(flowid))
    cursor.execute('delete from flowflags where flow_id = {}'.format(flowid))
    cursor.execute('delete from flowiat where flow_id = {}'.format(flowid))
    cursor.execute('delete from flowinfo where flow_id = {}'.format(flowid))
    cursor.execute('delete from flowpackets where flow_id = {}'.format(flowid))
    cnx.commit()
    cnx.close()
    cursor.close()
    print("Deletion Complete")
  except mysql.connector.Error as err:
    print(err) 
    print("Error in update command, please check command options or use help to get additional information")

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
  elif options[0] == "update": 
    if "-timestamp" in options: 
      timestampIndex = options.index("-timestamp")
      options[timestampIndex + 1] = options[timestampIndex + 1] + " " + options[timestampIndex + 2]
      options.pop(timestampIndex + 2)
    update(options[1:]) 
  elif options[0] == "delete":
    delete(options[1])
  elif options[0] == "insert": 
    if options[1] == "flow": 
      options[7] = options[7] + " " + options[8]
      options.pop(8)
    insert(options[1:])
    

