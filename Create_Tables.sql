drop table if exists TrafficSource;
drop table if exists TrafficDestination;
drop table if exists TrafficFlows;
drop table if exists Protocol;
drop table if exists Services;

select '----------------------------------------------------------------' as '';
select 'Create TrafficSource' as '';

CREATE TABLE TrafficSource(
    Flow.ID char unique not null, 
    Source.IP char not null,
    Source.Port int not null,

    primary key(Flow_ID)
);
-- need to add check constriants to check for flow id atomlicity

load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table TrafficSource
    fileds terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ingore 1 lines
    (Flow.ID, Source.IP, Source.Port);

select '----------------------------------------------------------------' as '';
select 'Create TrafficDestination' as '';

CREATE TABLE TrafficDestination(
    Flow.ID char unique not null, 
    Destination.IP char not null,
    Destination.Port int not null,

    primary key(Flow_ID)
);
-- need to add check constriants to check for flow id atomlicity

load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table TrafficDestination
    fileds terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ingore 1 lines
    (Flow.ID, Destination.IP, Destination.Port);

select '----------------------------------------------------------------' as '';
select 'Create TrafficFlows' as '';

CREATE TABLE TrafficFlows(
    Flow.ID char unique not null, 
    Protocol int not null,
    Timestamp datetime not null,
    Flow.Duration int not null,
    Total.Fwd.Packets int not null,
    Total.Backward.Packets int not null, 

    primary key(Flow_ID)
    foreign key (Protocol) references Protocol(Protocol)
);
-- need to add check constriants to check for flow id atomlicity

load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table TrafficFlows
    fileds terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ingore 1 lines
    (Flow.ID, Protocol, Timestamp, Flow.Duration, Total.Fwd.Packets, Total.Backward.Packets);

select '----------------------------------------------------------------' as '';
select 'Create Protocol' as '';

CREATE TABLE Protocol(
    Flow.ID char unique not null, 
    Protocol int not null,
    primary key(Flow_ID)
);
-- need to add check constriants to check for flow id atomlicity

load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table Protocol
    fileds terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ingore 1 lines
    (Flow.ID, Protocol);

select '----------------------------------------------------------------' as '';
select 'Create Services' as '';

CREATE TABLE Services(
    Flow.ID char unique not null, 
    Protocol int not null,
    primary key(Flow_ID)
);
-- need to add check constriants to check for flow id atomlicity

load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table Services
    fileds terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ingore 1 lines
    (Flow.ID, Protocol);





