# Group 19 
Internet Traffic

# Setting Up Database
### Loading Data

There are two scripts for loading the data, both of which are under the `load/` directory. They expect the two CSV files [(1)](https://www.kaggle.com/jsrojas/ip-network-traffic-flows-labeled-with-87-apps?select=Dataset-Unicauca-Version2-87Atts.csv) and [(2)](https://www.kaggle.com/akshat4112/networkanamolydetection?select=Friday-WorkingHours-Afternoon-DDos.pcap_ISCX.csv) to be located at `/var/lib/mysql-files`. However if you are running this on windows then by default the csv files must be in `C:\ProgramData\MySQL\MySQL Server 8.0\Uploads`.

To load the data, first create a database (i.e. `CREATE DATABASE InternetTraffic;` followed by `USE InternetTraffic;`). Then, run the script `load_base_tables.sql` first and finally, run `load_specialized_tables.sql`. 

For example:

`CREATE DATABASE InternetTraffic;`

`USE InternetTraffic;`

`SOURCE load_base_tables.sql;`

`SOURCE load_specialized_tables.sql;`

and the data should be loaded without errors or warnings.

# Client Application
The client application was created using Python and the MySQL Python connector library.
  Documentation for the library can be found [here](https://dev.mysql.com/doc/connector-python/en/). Furthermore, this application requires that you have setup the     database previously discussed and that it is running on 'localhost'. All the source code can be found in the "main.py" file. Lastly, the certain libraries must be installed for the application to run. Please use the following commands to do so:

```
pip install mysql-connector-python
pip install csv
pip install datetime
```

Note that if there are anymore libraries required to be installed it is likely that you can do so by running "pip install <library name>"

## User Types
After getting the database setup and install the libraries you can begin to start using the application. By default your MySql server should have a root user. When you run the application for the first time the application will prompt you for your username and password. You must enter "root" for the username and the corresponding password when it asks for it. Once you have done so you can proceed to using the application as an admin because the "root" user by default has unrestricted access to all of the database. There are two user types in this application and we will discuss them in the following. 

### Admin
Admins are able to use all the features of this application. They can create new users (admin or regular users), query, update, insert, and delete data and edit permissions of regular users. These commands will be discussed later in the documentation. 

### Users
Users are regular users who cannot create new users. When they are first created by an admin, they do not have any privilege to access the database. The admin must manually grant these permissions. However, if given the permission to do so, regular users may query, update, insert, and delete data from the database. 

## Commands
In this section we will outline all the different commands that are available in this application. 

### show
The show command is used to display network statistics to the user. In addition, a csv file will be generated containing the results. 

#### Required Parameters 
**-a:** show all data 
**-flowbytes:** show flow bytes data (cannot be used with -a) <br>
**-flowflags:** show flow flags data (cannot be used with -a)<br>
**-flowiat:** show inter-arrival times (cannot be used with -a)<br>
**-flowinfo:** show additional flow info such as time active, time idle, etc (cannot be used with -a)<br>
**-flowpackets:** show flow packets info (cannot be used with -a)<br>
**-protocol:** show flow protocol info (cannot be used with -a)<br>
**-clients:** show all clients (cannot be used with any other options)<br>

### Optional Parameters 
**-limit \<int> :** specifiy the limit on the number of results returned (default set to 50)<br>
**-filename: \<string>** specifies the limit on the output filename (defaulted to out.csv)<br>
**-d \<start date> \<end date>:** show network data between a specified start date and end date<br>
**-sortasc \<sort parameter>:** sort data in ascending order based on sort parameter (one of 'timestamp', 'protocol_id', 'label', 'bytes_per_second', 'syn_flag_count', 'duration')<br>
**NOTE:** you can only use bytes_per_second when used in conjuction with -a or -flowbytes<br>
**NOTE:** you can only use syn_flag_count when used in conjuction with -a or -flowflags<br>
**-sortdesc \<sort parameter>:** sort data in descending order based on sort parameter (one of 'timestamp', 'protocol_id', 'label', 'bytes_per_second', 'syn_flag_count','duration')<br>
**NOTE:** you can only use bytes_per_second when used in conjuction with -a or -flowbytes<br>
**NOTE:** you can only use syn_flag_count when used in conjuction with -a or -flowflags<br>
**-ddos:** show network data that corresponded to a DDOS attack<br>
**-source \<source ip>:** show network data corresponding to a particular source <br>
**-dest \<destination ip>:** show network data corresponding to a particlar destination<br>

```python
#Here are some example show commands 
show -a -limit 100 -filename test.csv #shows the earliest 100 flow entries in the database
show -clients #shows all the clients 
show -flowbytes -flowflags -sortasc timestamp -d 2017-04-26 11:11:11 2017-04-27 11:11:11 #shows flow byte and flag data between two dates sorted in ascending order based on timestamp
```

### update
The update command is used to update the information for a pre-existing flow. 
#### Required Parameters
**flowid:** the id for the flow you are trying to update

Following the flowid are the series of attributes followed by the update values. 

##### Basic Flow Information (flow)
-----------------------
**-source_ip <string>:** update the source ip for the given flow<br>
**-source_port <integer>:** update that source port for the given flow <br>
**-destination_ip <string>:** update the destination ip for the given flow <br>
**-destination_port <integer>:** update the destination port for the given flow <br>
**-protocol_id <integer>:** update the protocol id for the given flow <br>
**-timestamp <datetime>:** update the timestamp (eg datetime 2017-04-26 11:11:11) for the given flow <br>
**-duration <integer>:** update the duration for the given flow <br>
**-label <string>:** update the label for the given flow <br>

##### Flow Byte Information (flowbytes)
----------------------
**-bytes_per_second <int>:** update the bytes per second for the given flow <br>
**-fwd_bytes_bulk_avg <decimal>:** update the average bytes bulk rate in the forward direction for the given flow <br>
**-bwd_bytes_bulk_avg <decimal>:** update the average bytes bulk rate in the backward direction for the given flow <br>
**-fwd_subflow_bytes_avg <decimal>:** update the average bytes in a subflow in the forward direction for the given flow <br>
**-bwd_subflow_bytes_avg <decimal>:** update the average byutes in a subflow in the backward direction for the given flow <br>
**-fwd_init_win_bytes <decimal>:** update the total bytes sent in the initial window in the forward direction for the given flow <br>
**-bwd_init_win_bytes <decimal>:** update the total bytes sent in the initial window in the backward direction for the given flow <br>

##### Flow Flag Info (flowflags)
---------------
**-fwd_psh_flags <int>:** update the number of packets sent in the forward direction that had the PSH flag set to 1 for the given flow <br>
**-bwd_psh_flags <int>:** update the number of packets sent in the backward direction that had the PSH flag set to 1 for the given flow <br>
**-fwd_urg_flags <int>:** update the number of packets sent in the forward direction that had the URG flag set to 1 for the given flow<br>
**-bwd_urg_flags <int>:** update the number of packets sent in the backward direction that had the URG flag set to 1 for the given flow<br>
**-fin_flag_count <int>:** update the number of packets sent in the flow that had the FIN flag set to 1 for the given flow<br>
**-syn_flag_count <int>:** update the number of packets sent in the flow that had the SYN flag set to 1 for the given flow<br>
**-rst_flag_count <int>:** update the number of packets sent in the flow that had the RST flag set to 1 for the given flow<br>
**-psh_flag_count <int>:** update the number of packets sent in the flow that had the PSH flag set to 1 for the given flow<br>
**-ack_flag_count <int>:** update the number of packets sent in the flow that had the ACK flag set to 1 for the given flow<br>
**-urg_flag_count <int>:** update the number of packets sent in the flow that had the URG flag set to 1 for the given flow<br>
**-cwe_flag_count <int>:** update the number of packets sent in the flow that had the CWE flag set to 1 for the given flow<br>
**-ece_flag_count <int>:** update the number of packets sent in the flow that had the ECE flag set to 1 for the given flow<br>

##### IAT Info (flowiat)
---------
**-iat_mean <decimal>:** update the mean inter-arrival time of the flow<br>
**-iat_std <decimal>:** update the standard inter-arrival time of the flow <br>
**-iat_max <decimal>:** update the maximum inter-arrival time of the flow <br>
**-iat_min <decimal>:** update the minimum inter-arrival time of the flow <br>
**-fwd_iat_total <decimal>:** update the total inter-arrival time in the forward direction of the flow<br>
**-bwd_iat_total <decimal>:** update the total inter-arrival time in the backward direction of the flow<br>
**-fwd_iat_mean <decimal>:** update the mean inter-arrival time in the forward direction of the flow<br>
**-bwd_iat_mean <decimal>:** update the mean inter-arrival time in the backward direction of the flow<br>
**-fwd_iat_std <decimal>:** update the standard inter-arrival time in the forward direction of the flow<br>
**-bwd_iat_std <decimal>:** update the standard inter-arrival time in the backward direction of the flow<br>
**-fwd_iat_max <decimal>:** update the maximum inter-arrival time in the forward direction of the flow<br>
**-bwd_iat_max <decimal>:** update the maximum inter-arrival time in the backward direction of the flow<br>
**-fwd_iat_min <decimal>:** update the minimum inter-arrival time in the forward direction of the flow<br>
**-bwd_iat_min <decimal>:** update the minimum inter-arrival time in the backward direction of the flow<br>
**-fwd_header_length <decimal>:** update the forward header length for the given flow<br>
**-bwd_header_length <decimal>:** update the backward header length for the given flow<br>
**-down_up_ratio <decimal>:** update the download/upload ration for the given flow <br>
**-fwd_segment_size_avg <decimal>:** update the average segment size in the forward direction for the given flow <br>
**-bwd_segment_size_avg <decimal>:** update the average segment size in the backward direction for the given flow <br>

##### Additional Flow Info (flowinfo)
---------------------
**-fwd_bulk_rate_avg <decimal>:** update the average number of bulk rate in the forward
direction for the given flow<br>
**-bwd_bulk_rate_avg <decimal>:** update the average number of bulk rate in the backward
direction for the given flow<br>
**-fwd_segment_size_min <decimal>:** update the minimum segment size in the forward direction for the given flow<br>
**-active_time_mean <decimal>:** update the mean time the flow was active before becoming idle for the given flow <br>
**-active_time_std <decimal>:** update the standard time the flow was active before becoming idle for the given flow <br>
**-active_time_max <decimal>:** update the maximum time the flow was active before becoming idle for the given flow <br>
**-active_time_min <decimal>:** update the minimum time the flow was active before becoming idle for the given flow <br>
**-idle_time_mean <decimal>:** update the mean time the flow was idle for the given flow <br>
**-idle_time_std <decimal>:** update the standard time the flow was idle for the given flow <br>
**-idle_time_max <decimal>:** update the maximum time the flow was idle for the given flow <br>
**-idle_time_min <decimal>:** update the minimum time the flow was idle for the given flow <br>

##### Packet Info (flowpackets)
------------
**-fwd_packets <decimal>:** update the number of packets in the forward direction for the given flow <br>
**-bwd_packets <decimal>:** update the number of packets in the backward direction for the given flow<br>
**-fwd_packets_bytes <decimal>:** update the number of packets in the forward direction in bytes for the given flow<br>
**-bwd_packets_bytes <decimal>:**  update the number of packets in the backward direction in bytes for the given flow<br>
**-fwd_packets_bytes_max <decimal>:** update the maximum value in bytes of a packet in the forward direction for the given flow<br>
**-fwd_packets_bytes_min <decimal>:** update the minimum value in bytes of a packet in the forward direction for the given flow<br>
**-fwd_packets_bytes_mean <decimal>:** update the mean value in bytes of a packet in the forward direction for the given flow<br>
**-fwd_packets_bytes_std <decimal>:** update the standard value in bytes of a packet in the forward direction for the given flow<br>
**-bwd_packets_bytes_max <decimal>:** update the maximum value in bytes of a packet in the backward direction for the given flow<br>
**-bwd_packets_bytes_min <decimal>:** update the minimum value in bytes of a packet in the backward direction for the given flow<br>
**-bwd_packets_bytes_mean <decimal>:** update the mean value in bytes of a packet in the backward direction for the given flow<br>
**-bwd_packets_bytes_std <decimal>:** update the standard value in bytes of a packet in the backward direction for the given flow<br>
**-packets_per_second <decimal>:** update the packets per second for the given flow<br>
**-fwd_packets_per_second <decimal>:** update the packets per second in the forward direction for the given flow<br>
**-bwd_packets_per_second <decimal>:** update the packets per second in the backward direction for the given flow<br>
**-packet_length_min <decimal>:** update the minimum packet length for the given flow <br>
**-packet_length_max <decimal>:** update the maximum packet length for the given flow<br>
**-packet_length_mean <decimal>:** update the mean packet length for the given flow<br>
**-packet_length_std <decimal>:** update the standard packet length for the given flow <br>
**-packet_length_variance <decimal>:** update the packet length variance for the given flow <br>
**-packet_size_avg <decimal>:** update the average packet size for the given flow<br>
**-fwd_packets_bulk_avg <decimal>:** update the average packets bulk in the forward direction for the given flow<br>
**-bwd_packets_bulk_avg <decimal>:** update the average packets bulk in the backward direction for the given flow<br>
**-fwd_subflow_packets_avg <decimal>:** update the average packets in subflow in the forward direction for the given flow<br>
**-bwd_subflow_packets_avg <decimal>:** update the average packets in subflow in the backward direction for the given flow<br>
**-fwd_act_data_packets <decimal>:** update the number of packets in the forward direction with at lease one byte of TCP data payload for the given flow<br>

```python
#Here are some sample update commands 
update 420 -duration 9000 #updates the duration for flow 420 with 9000
update 888 -fwd_psh_flags 2 -bwd_psh_flags 2 -psh_flag_count 4 #updates fwd_psh_flags, bwd_psh_flags, and psh_flag_count with 2, 2, and 4 respectively
```

### delete
The delete command deletes all data pertaining to a particular flow id
#### Required Parameters 
**flowid:** the id for the flow you are trying to delete

```python
#Here are example delete commands 
delete 333 #delete flow with id 333
```

### insert 
The insert command is used to insert new information into the database 
#### Required Parameters 
**infoType:** specify the type of data being inserted (one of "flow", "flowbytes", "flowflags", "flowiat", "flowinfo", "flowpackets") <br>
**flowdata:** depending on the information type that is being inserted, the arguments following the infoType must include all of the information pertaining to the information  type (see the update section for the parameters required and note that they must follow the same order)

```python
#Here are example insert commands 
insert flow 10.200.7.7 6969 172.19.1.46 42069 1 2017-04-26 11:11:11 4234444 BENIGN #inserts a new flow
insert flowbytes 3830175 12000000.0000000000000000 0.0000 0.0000 12.0000000000000000 0.0000000000000000 490 -1 #inserts information for flow with id 3830175
```

### createuser
The createuser command is used to create a new regular user 
#### Required Parameters 
**username:** the username of the new user (must be unique) <br>
**password:** the password of the new user 

```python
#example createuser command 
createuser martinguo iloveECE356EvenMoreThanECE240 #creates a new user
```

### createadmin 
The createadmin command is the same as createuser but instead creates an admin

#### Required Parameters 
**username:** the username of the new admin (must be unique)<br>
**password:** the password of the new admin 

```python
#example createuser command 
createadmin Huanyi best356TA2021 #creates a new admin
```

### grantuserpermission
The grantuserpermission command grants permissions to a regular user (must be an admin to use this command)

#### Required Parameters 
**privilege type:** one of 'select' (allows viewing), 'update' (allows use of update command), 'insert' (allows use of insert command), and 'delete' (allows use of delete command) <br>
**information types:** type of information that permission pertains to (one or more of <br> 'flow', 'flowbytes', 'flowflags', 'flowiat', 'flowinfo', 'flowpackets', 'source', 'protocol')
**username:** username of the user that you are granting permission to

```python
#example grantuserpermission command
grantuserpermission select flow flowbytes MartiniGuo #should allow MartiniGuo to query on flowbytes and flow given the user exists
```

### revokeuserpermission
The revokeuserpermission command works the same way as the grantuserpermission command but instead it revokes permission for that user
#### Required Parameters 
**privilege type:** one of 'select' (revokes viewing), 'update' (revokes use of update command), 'insert' (revokes use of insert command), and 'delete' (revokes use of delete command) <br>
**information types:** type of information that permission pertains to (one or more of <br> 'flow', 'flowbytes', 'flowflags', 'flowiat', 'flowinfo', 'flowpackets', 'source', 'protocol') <br>
**username:** username of the user that you are revoking permission from
```python
#example revokeuserpermission command
revokeuserpermission select flow flowbytes MartiniGuo #should remove MartiniGuo's permissions to view flow and flowbytes
```
