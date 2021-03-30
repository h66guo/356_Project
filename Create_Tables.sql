drop table if exists temp;
drop table if exists Flow;
drop table if exists FlowStats;
drop table if exists Source;
drop table if exists Destination;

select '----------------------------------------------------------------' as '';
select 'Create temporary table temp' as '';

create TEMPORARY TABLE temp(
    FlowID varchar(50) unique not null, 
    SourceIP varchar(30) not null,
    SourcePort int not null,
    DestinationIP varchar(30) not null,
    DestinationPort varchar(30) not null,
    Protocol int not null,
    Timestamp datetime not null,
    FlowDuration int not null,
    TotalFwdPackets int not null,
    TotalBackwardPackets int not null,
    TotalLengthFwdPackets int not null,
    TotalLengthBwdPackets int not null,
    FwdPacketLengthMax int not null,
    FwdPacketLengthMin int not null,
    FwdPacketLengthMean int not null,
    FwdPacketLengthStd int not null, 
    BwdPacketLengthMax int not null, 
    BwdPacketLengthMin int not null, 
    BwdPacketLengthMean int not null, 
    BwdPacketLengthStd int not null, 
    FlowBytess int not null,
    FlowPacketss int not null,
    FlowIATMean int not null, 
    FlowIATStd int not null, 
    FlowIATMax int not null,
    FlowIATMin int not null, 
    FwdIATTotal int not null, 
    FwdIATMean int not null, 
    FwdIATStd int not null,
    FwdIATMax int not null, 
    FwdIATMin int not null,
    BwdIATTotal int not null, 
    BwdIATMean int not null,
    BwdIATStd int not null,
    BwdIATMax int not null, 
    BwdIATMin int not null, 
    FwdPSHFlags int not null,
    BwdPSHFlags int not null, 
    FwdURGFlags int not null, 
    BwdURGFlags int not null,
    FwdHeaderLength int not null, 
    BwdHeaderLength int not null, 
    FwdPacketss int not null, 
    BwdPacketss int not null,
    MinPacketLength int not null,
    MaxPacketLength int not null, 
    PacketLengthMean int not null, 
    PacketLengthStd int not null, 
    PacketLengthVariance int not null, 
    FINFlagCount int not null, 
    SYNFlagCount int not null,
    RSTFlagCount int not null,
    PSHFlagCount int not null,
    ACKFlagCount int not null,
    URGFlagCount int not null,
    CWEFlagCount int not null, 
    ECEFlagCount int not null, 
    DownUpRatio int not null, 
    AveragePacketSize int not null,
    AvgFwdSegmentSize int not null,
    AvgBwdSegmentSize int not null, 
    FwdHeaderLength1 int not null, 
    FwdAvgBytesBulk int not null, 
    FwdAvgPacketsBulk int not null, 
    FwdAvgBulkRate int not null, 
    BwdAvgBytesBulk int not null, 
    BwdAvgPacketsBulk int not null, 
    BwdAvgBulkRate int not null, 
    SubflowFwdPackets int not null, 
    SubflowFwdBytes int not null, 
    SubflowBwdPackets int not null, 
    SubflowBwdBytes int not null, 
    InitWinbytesforward int not null, 
    InitWinbytesbackward int not null,
    actdatapktfwd int not null, 
    minsegsizeforward int not null, 
    ActiveMean int not null,
    ActiveStd int not null, 
    ActiveMax int not null, 
    ActiveMin int not null,
    IdleMean int not null, 
    IdleStd int not null, 
    IdleMax int not null, 
    IdleMin int not null, 
    Label int not null, 
    L7Protocol int not null, 
    ProtocolName int not null,

    primary key(SourceIP, SourcePort, DestinationIP, DestinationPort,Protocol, FlowDuration)
);

load data local infile 'D:/3b/ECE356/Dataset-Unicauca-Version2-87Atts/Dataset-Unicauca-Version2-87Atts.csv' ignore into table temp
    fields terminated by ','
    enclosed by '"'
    lines terminated by '\n'
    ignore 1 lines
    (FlowID, SourceIP, DestinationIP, DestinationPort, Protocol,
    Timestamp, FlowDuration, TotalFwdPackets ,
    TotalBackwardPackets ,
    TotalLengthFwdPackets ,
    TotalLengthBwdPackets ,
    FwdPacketLengthMax ,
    FwdPacketLengthMin ,
    FwdPacketLengthMean ,
    FwdPacketLengthStd , 
    BwdPacketLengthMax , 
    BwdPacketLengthMin , 
    BwdPacketLengthMean , 
    BwdPacketLengthStd , 
    FlowBytess ,
    FlowPacketss ,
    FlowIATMean , 
    FlowIATStd , 
    FlowIATMax ,
    FlowIATMin , 
    FwdIATTotal , 
    FwdIATMean , 
    FwdIATStd ,
    FwdIATMax , 
    FwdIATMin ,
    BwdIATTotal , 
    BwdIATMean ,
    BwdIATStd ,
    BwdIATMax , 
    BwdIATMin , 
    FwdPSHFlags ,
    BwdPSHFlags , 
    FwdURGFlags , 
    BwdURGFlags ,
    FwdHeaderLength , 
    BwdHeaderLength , 
    FwdPacketss , 
    BwdPacketss ,
    MinPacketLength ,
    MaxPacketLength , 
    PacketLengthMean , 
    PacketLengthStd , 
    PacketLengthVariance , 
    FINFlagCount , 
    SYNFlagCount ,
    RSTFlagCount ,
    PSHFlagCount ,
    ACKFlagCount ,
    URGFlagCount ,
    CWEFlagCount , 
    ECEFlagCount , 
    DownUpRatio , 
    AveragePacketSize ,
    AvgFwdSegmentSize ,
    AvgBwdSegmentSize , 
    FwdHeaderLength1 , 
    FwdAvgBytesBulk , 
    FwdAvgPacketsBulk , 
    FwdAvgBulkRate , 
    BwdAvgBytesBulk , 
    BwdAvgPacketsBulk , 
    BwdAvgBulkRate , 
    SubflowFwdPackets , 
    SubflowFwdBytes , 
    SubflowBwdPackets , 
    SubflowBwdBytes , 
    InitWinbytesforward , 
    InitWinbytesbackward ,
    actdatapktfwd , 
    minsegsizeforward , 
    ActiveMean ,
    ActiveStd , 
    ActiveMax , 
    ActiveMin ,
    IdleMean , 
    IdleStd , 
    IdleMax , 
    IdleMin , 
    Label , 
    L7Protocol , 
    ProtocolName );

select '----------------------------------------------------------------' as '';
select 'Create Flow' as '';

CREATE TABLE Flow(
    FlowID varchar(50) unique not null, 
    SourceIP varchar(30) not null,
    SourcePort int not null,
    DestinationIP varchar(30) not null,
    DestinationPort varchar(30) not null,
    Protocol int not null,
    Timestamp datetime not null,
    FlowDuration int not null,
    Label varchar(10) not null,
    L7Protocol int not null,
    ProtocolName varchar(10) not null,



    primary key(SourceIP, SourcePort, DestinationIP, DestinationPort,Protocol, FlowDuration)
);
-- need to add check constriants to check for flow id atomlicity
insert into Flow select FlowID, SourceIP, DestinationIP, DestinationPort, Protocol,
    Timestamp, FlowDuration, Label, L7Protocol, ProtocolName from temp;
-- load data local infile 'D:/3b/ECE356/Dataset-Unicauca-Version2-87Atts/Dataset-Unicauca-Version2-87Atts.csv' ignore into table Flow
--     fields terminated by ','
--     enclosed by '"'
--     lines terminated by '\n'
--     ignore 1 lines
--     (FlowID, SourceIP, DestinationIP, DestinationPort, Protocol,
--     Timestamp, FlowDuration, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip, @skip,
--      Label, L7Protocol, ProtocolName)
--     ;

select '----------------------------------------------------------------' as '';
select 'Create FlowStats' as '';

CREATE TABLE FlowStats(
    FlowID varchar(50) unique not null, 
    TotalFwdPackets int not null,
    TotalBackwardPackets int not null,
    TotalLengthFwdPackets int not null,
    TotalLengthBwdPackets int not null,
    FwdPacketLengthMax int not null,
    FwdPacketLengthMin int not null,
    FwdPacketLengthMean int not null,
    FwdPacketLengthStd int not null, 
    BwdPacketLengthMax int not null, 
    BwdPacketLengthMin int not null, 
    BwdPacketLengthMean int not null, 
    BwdPacketLengthStd int not null, 
    FlowBytess int not null,
    FlowPacketss int not null,
    FlowIATMean int not null, 
    FlowIATStd int not null, 
    FlowIATMax int not null,
    FlowIATMin int not null, 
    FwdIATTotal int not null, 
    FwdIATMean int not null, 
    FwdIATStd int not null,
    FwdIATMax int not null, 
    FwdIATMin int not null,
    BwdIATTotal int not null, 
    BwdIATMean int not null,
    BwdIATStd int not null,
    BwdIATMax int not null, 
    BwdIATMin int not null, 
    FwdPSHFlags int not null,
    BwdPSHFlags int not null, 
    FwdURGFlags int not null, 
    BwdURGFlags int not null,
    FwdHeaderLength int not null, 
    BwdHeaderLength int not null, 
    FwdPacketss int not null, 
    BwdPacketss int not null,
    MinPacketLength int not null,
    MaxPacketLength int not null, 
    PacketLengthMean int not null, 
    PacketLengthStd int not null, 
    PacketLengthVariance int not null, 
    FINFlagCount int not null, 
    SYNFlagCount int not null,
    RSTFlagCount int not null,
    PSHFlagCount int not null,
    ACKFlagCount int not null,
    URGFlagCount int not null,
    CWEFlagCount int not null, 
    ECEFlagCount int not null, 
    DownUpRatio int not null, 
    AveragePacketSize int not null,
    AvgFwdSegmentSize int not null,
    AvgBwdSegmentSize int not null, 
    FwdHeaderLength1 int not null, 
    FwdAvgBytesBulk int not null, 
    FwdAvgPacketsBulk int not null, 
    FwdAvgBulkRate int not null, 
    BwdAvgBytesBulk int not null, 
    BwdAvgPacketsBulk int not null, 
    BwdAvgBulkRate int not null, 
    SubflowFwdPackets int not null, 
    SubflowFwdBytes int not null, 
    SubflowBwdPackets int not null, 
    SubflowBwdBytes int not null, 
    InitWinbytesforward int not null, 
    InitWinbytesbackward int not null,
    actdatapktfwd int not null, 
    minsegsizeforward int not null, 
    ActiveMean int not null,
    ActiveStd int not null, 
    ActiveMax int not null, 
    ActiveMin int not null,
    IdleMean int not null, 
    IdleStd int not null, 
    IdleMax int not null, 
    IdleMin int not null, 


    primary key(Flow_ID)
);

Insert into FlowStats select FlowID,TotalFwdPackets ,
    TotalBackwardPackets ,
    TotalLengthFwdPackets ,
    TotalLengthBwdPackets ,
    FwdPacketLengthMax ,
    FwdPacketLengthMin ,
    FwdPacketLengthMean ,
    FwdPacketLengthStd , 
    BwdPacketLengthMax , 
    BwdPacketLengthMin , 
    BwdPacketLengthMean , 
    BwdPacketLengthStd , 
    FlowBytess ,
    FlowPacketss ,
    FlowIATMean , 
    FlowIATStd , 
    FlowIATMax ,
    FlowIATMin , 
    FwdIATTotal , 
    FwdIATMean , 
    FwdIATStd ,
    FwdIATMax , 
    FwdIATMin ,
    BwdIATTotal , 
    BwdIATMean ,
    BwdIATStd ,
    BwdIATMax , 
    BwdIATMin , 
    FwdPSHFlags ,
    BwdPSHFlags , 
    FwdURGFlags , 
    BwdURGFlags ,
    FwdHeaderLength , 
    BwdHeaderLength , 
    FwdPacketss , 
    BwdPacketss ,
    MinPacketLength ,
    MaxPacketLength , 
    PacketLengthMean , 
    PacketLengthStd , 
    PacketLengthVariance , 
    FINFlagCount , 
    SYNFlagCount ,
    RSTFlagCount ,
    PSHFlagCount ,
    ACKFlagCount ,
    URGFlagCount ,
    CWEFlagCount , 
    ECEFlagCount , 
    DownUpRatio , 
    AveragePacketSize ,
    AvgFwdSegmentSize ,
    AvgBwdSegmentSize , 
    FwdHeaderLength1 , 
    FwdAvgBytesBulk , 
    FwdAvgPacketsBulk , 
    FwdAvgBulkRate , 
    BwdAvgBytesBulk , 
    BwdAvgPacketsBulk , 
    BwdAvgBulkRate , 
    SubflowFwdPackets , 
    SubflowFwdBytes , 
    SubflowBwdPackets , 
    SubflowBwdBytes , 
    InitWinbytesforward , 
    InitWinbytesbackward ,
    actdatapktfwd , 
    minsegsizeforward , 
    ActiveMean ,
    ActiveStd , 
    ActiveMax , 
    ActiveMin ,
    IdleMean , 
    IdleStd , 
    IdleMax , 
    IdleMin  FROM temp; 
-- need to add check constriants to check for flow id atomlicity

-- load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table FlowStats
--     fields terminated by ','
--     enclosed by '"'
--     lines terminated by '\n'
--     ignore 1 lines
--     (Flow.ID, Destination.IP, Destination.Port);

select '----------------------------------------------------------------' as '';
select 'Create Source' as '';

CREATE TABLE Source(
    SourceIP varchar(30) not null,
    SourcePort int not null,

    primary key(SourceIP, SourcePort)
);
-- need to add check constriants to check for flow id atomlicity
Insert into Source select SourceIP, SourcePort from temp; 
-- load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table Source
--     fields terminated by ','
--     enclosed by '"'
--     lines terminated by '\n'
--     ignore 1 lines
--     (Source.IP, Source.Port);

select '----------------------------------------------------------------' as '';
select 'Create Destination' as '';

CREATE TABLE Destination(
    destinationIP varchar(30) not null,
    destinationPort varchar(30) not null,
    primary key(destinationIP, destinationPort)
);
-- need to add check constriants to check for flow id atomlicity
Insert into Destination select DestinationIP, DestinationPort from temp;
-- load data infile 'D:\3b\ECE356\Dataset-Unicauca-Version2-87Atts\Dataset-Unicauca-Version2-87Atts.csv' ignore into table Destination
--     fields terminated by ','
--     enclosed by '"'
--     lines terminated by '\n'
--     ignore 1 lines
--     (Destination.IP, Destination.Port);







