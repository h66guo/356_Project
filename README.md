# Group 19 
Topic: Internet Traffic

### Loading Data

There are two scripts for loading the data, both of which are under the `load/` directory. They expect the two CSV files [(1)](https://www.kaggle.com/jsrojas/ip-network-traffic-flows-labeled-with-87-apps?select=Dataset-Unicauca-Version2-87Atts.csv) and [(2)](https://www.kaggle.com/akshat4112/networkanamolydetection?select=Friday-WorkingHours-Afternoon-DDos.pcap_ISCX.csv) to be located at `/var/lib/mysql-files`.

To load the data, first create a database (i.e. `CREATE DATABASE InternetTraffic;` followed by `USE InternetTraffic;`). Then, run the script `load_base_tables.sql` first and finally, run `load_specialized_tables.sql`. 

For example:

`CREATE DATABASE InternetTraffic;`

`USE InternetTraffic;`

`SOURCE load_base_tables.sql;`

`SOURCE load_specialized_tables.sql;`

and the data should be loaded without errors or warnings.