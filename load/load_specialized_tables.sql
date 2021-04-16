-- ********************************************************************
-- *** This script assumes the existence of the base table BaseFlow ***
-- ********************************************************************

-- Show warnings after every statement
warnings;

DROP TABLE IF EXISTS FlowIAT;
DROP TABLE IF EXISTS FlowPackets;
DROP TABLE IF EXISTS FlowInfo;
DROP TABLE IF EXISTS FlowBytes;
DROP TABLE IF EXISTS FlowFlags;
DROP TABLE IF EXISTS Flow;
DROP TABLE IF EXISTS Source;
DROP TABLE IF EXISTS Destination;
DROP TABLE IF EXISTS Protocol;

-- *********************
-- *** Create Source ***
-- *********************
SELECT 'Create Source' AS '';

CREATE TABLE Source (
  ip                    VARCHAR(15)     NOT NULL,
  port                  DECIMAL(5, 0)   NOT NULL,
  PRIMARY KEY (ip, port),
  CHECK (ip REGEXP '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$'),
  CHECK (port >= 0 AND port <= 65535)
);

INSERT INTO Source
SELECT DISTINCT source_ip, source_port
FROM BaseFlow;

-- **************************
-- *** Create Destination ***
-- **************************
SELECT 'Create Destination' AS '';

CREATE TABLE Destination (
  ip                    VARCHAR(15)     NOT NULL,
  port                  DECIMAL(5, 0)   NOT NULL,
  PRIMARY KEY (ip, port),
  CHECK (ip REGEXP '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$'),
  CHECK (port >= 0 AND port <= 65535)
);

INSERT INTO Destination
SELECT DISTINCT destination_ip, destination_port
FROM BaseFlow;


-- ***********************
-- *** Create Protocol ***
-- ***********************
SELECT 'Create Protocol' AS '';

CREATE TABLE Protocol (
  id                    INT             NOT NULL AUTO_INCREMENT,
  number                DECIMAL(2, 0)   NOT NULL,
  l7_number             DECIMAL(4, 0),
  name                  VARCHAR(32),
  PRIMARY KEY (id),
  CHECK (number >= 0),
  CHECK (l7_number >= 0)
);

INSERT INTO Protocol
SELECT NULL, temp.number, temp.l7_number, temp.name FROM
(
  SELECT DISTINCT protocol AS number, l7_protocol AS l7_number, protocol_name AS name
  FROM BaseFlow
) temp;

-- *******************
-- *** Create Flow ***
-- *******************
SELECT 'Create Flow' AS '';

CREATE TABLE Flow (
  id                    INT             NOT NULL AUTO_INCREMENT,
  source_ip             VARCHAR(15)     NOT NULL,
  source_port           DECIMAL(5, 0)   NOT NULL,
  destination_ip        VARCHAR(15)     NOT NULL,
  destination_port      DECIMAL(5, 0)   NOT NULL,
  protocol_id           INT,
  timestamp             DATETIME,
  duration              DECIMAL(16, 0),
  label                 VARCHAR(32),
  PRIMARY KEY (id),
  FOREIGN KEY (source_ip, source_port) REFERENCES Source(ip, port),
  FOREIGN KEY (destination_ip, destination_port) REFERENCES Destination(ip, port),
  FOREIGN KEY (protocol_id) REFERENCES Protocol(id),
  CHECK (duration >= 0)
);

INSERT INTO Flow
SELECT 
  b.id, 
  b.source_ip, 
  b.source_port, 
  b.destination_ip, 
  b.destination_port, 
  (
    SELECT p.id FROM Protocol p 
    WHERE 
      p.number = b.protocol 
      AND ((b.l7_protocol IS NULL AND p.l7_number IS NULL) OR p.l7_number = b.l7_protocol) 
      AND ((b.protocol_name IS NULL AND p.name IS NULL) OR p.name = b.protocol_name)
  ), 
  b.timestamp, 
  IF(b.duration >= 0, b.duration, NULL),
  b.label
FROM BaseFlow b;

-- **********************
-- *** Create FlowIAT ***
-- **********************
SELECT 'Create FlowIAT' AS '';

CREATE TABLE FlowIAT (
  flow_id               INT               NOT NULL AUTO_INCREMENT,
  iat_mean              DECIMAL(32, 16),
  iat_std               DECIMAL(32, 16),
  iat_max               DECIMAL(16, 0),
  iat_min               DECIMAL(16, 0),
  fwd_iat_total         DECIMAL(16, 0),
  fwd_iat_mean          DECIMAL(32, 16),
  fwd_iat_std           DECIMAl(32, 16),
  fwd_iat_max           DECIMAL(16, 0),
  fwd_iat_min           DECIMAL(16, 0),
  bwd_iat_total         DECIMAL(16, 0),
  bwd_iat_mean          DECIMAL(32, 16),
  bwd_iat_std           DECIMAl(32, 16),
  bwd_iat_max           DECIMAL(16, 0),
  bwd_iat_min           DECIMAL(16, 0),
  PRIMARY KEY (flow_id),
  FOREIGN KEY (flow_id) REFERENCES Flow(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (iat_mean       >= 0),
  CHECK (iat_std        >= 0),
  CHECK (iat_max        >= 0),
  CHECK (iat_min        >= 0),
  CHECK (fwd_iat_total  >= 0),
  CHECK (fwd_iat_mean   >= 0),
  CHECK (fwd_iat_std    >= 0),
  CHECK (fwd_iat_max    >= 0),
  CHECK (fwd_iat_min    >= 0),
  CHECK (bwd_iat_total  >= 0),
  CHECK (bwd_iat_mean   >= 0),
  CHECK (bwd_iat_std    >= 0),
  CHECK (bwd_iat_max    >= 0),
  CHECK (bwd_iat_min    >= 0)
);

INSERT INTO FlowIAT
SELECT
  id,
  IF(iat_mean      >= 0, iat_mean,      NULL),
  IF(iat_std       >= 0, iat_std,       NULL),
  IF(iat_max       >= 0, iat_max,       NULL),
  IF(iat_min       >= 0, iat_min,       NULL),
  IF(fwd_iat_total >= 0, fwd_iat_total, NULL),
  IF(fwd_iat_mean  >= 0, fwd_iat_mean,  NULL),
  IF(fwd_iat_std   >= 0, fwd_iat_std,   NULL),
  IF(fwd_iat_max   >= 0, fwd_iat_max,   NULL),
  IF(fwd_iat_min   >= 0, fwd_iat_min,   NULL),
  IF(bwd_iat_total >= 0, bwd_iat_total, NULL),
  IF(bwd_iat_mean  >= 0, bwd_iat_mean,  NULL),
  IF(bwd_iat_std   >= 0, bwd_iat_std,   NULL),
  IF(bwd_iat_max   >= 0, bwd_iat_max,   NULL),
  IF(bwd_iat_min   >= 0, bwd_iat_min,   NULL)
FROM BaseFlow;

-- **************************
-- *** Create FlowPackets ***
-- **************************
SELECT 'Create FlowPackets' AS '';

CREATE TABLE FlowPackets (
  flow_id                 INT               NOT NULL AUTO_INCREMENT,
  fwd_packets             DECIMAL(8, 0),
  bwd_packets             DECIMAL(8, 0),
  fwd_packets_bytes       DECIMAL(16, 0),
  bwd_packets_bytes       DECIMAL(16, 0),
  fwd_packets_bytes_max   DECIMAL(8, 0),
  fwd_packets_bytes_min   DECIMAL(8, 0),
  fwd_packets_bytes_mean  DECIMAL(24, 16),
  fwd_packets_bytes_std   DECIMAL(24, 16),
  bwd_packets_bytes_max   DECIMAL(8, 0),
  bwd_packets_bytes_min   DECIMAL(8, 0),
  bwd_packets_bytes_mean  DECIMAL(24, 16),
  bwd_packets_bytes_std   DECIMAL(24, 16),
  packets_per_second      DECIMAL(32, 16),
  fwd_packets_per_second  DECIMAL(40, 24),
  bwd_packets_per_second  DECIMAL(40, 24),
  packet_length_min       DECIMAL(8, 0),
  packet_length_max       DECIMAL(8, 0),
  packet_length_mean      DECIMAL(24, 16),
  packet_length_std       DECIMAL(24, 16),
  packet_length_variance  DECIMAL(32, 16),
  packet_size_avg         DECIMAL(24, 16),
  fwd_packets_bulk_avg    DECIMAL(8, 4),
  bwd_packets_bulk_avg    DECIMAL(8, 4),
  fwd_subflow_packets_avg DECIMAL(24, 16),
  bwd_subflow_packets_avg DECIMAL(24, 16),
  fwd_act_data_packets    DECIMAL(8, 0),
  PRIMARY KEY (flow_id),
  FOREIGN KEY (flow_id) REFERENCES Flow(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (fwd_packets              >= 0),  
  CHECK (bwd_packets              >= 0), 
  CHECK (fwd_packets_bytes        >= 0), 
  CHECK (bwd_packets_bytes        >= 0), 
  CHECK (fwd_packets_bytes_max    >= 0), 
  CHECK (fwd_packets_bytes_min    >= 0), 
  CHECK (fwd_packets_bytes_mean   >= 0), 
  CHECK (fwd_packets_bytes_std    >= 0), 
  CHECK (bwd_packets_bytes_max    >= 0), 
  CHECK (bwd_packets_bytes_min    >= 0), 
  CHECK (bwd_packets_bytes_mean   >= 0), 
  CHECK (bwd_packets_bytes_std    >= 0), 
  CHECK (packets_per_second       >= 0), 
  CHECK (fwd_packets_per_second   >= 0), 
  CHECK (bwd_packets_per_second   >= 0), 
  CHECK (packet_length_min        >= 0), 
  CHECK (packet_length_max        >= 0), 
  CHECK (packet_length_mean       >= 0), 
  CHECK (packet_length_std        >= 0), 
  CHECK (packet_length_variance   >= 0), 
  CHECK (packet_size_avg          >= 0), 
  CHECK (fwd_packets_bulk_avg     >= 0), 
  CHECK (bwd_packets_bulk_avg     >= 0), 
  CHECK (fwd_subflow_packets_avg  >= 0),
  CHECK (bwd_subflow_packets_avg  >= 0),
  CHECK (fwd_act_data_packets     >= 0)  
);

INSERT INTO FlowPackets
SELECT
  id                      ,
  fwd_packets             ,
  bwd_packets             ,
  fwd_packets_bytes       ,
  bwd_packets_bytes       ,
  fwd_packets_bytes_max   ,
  fwd_packets_bytes_min   ,
  fwd_packets_bytes_mean  ,
  fwd_packets_bytes_std   ,
  bwd_packets_bytes_max   ,
  bwd_packets_bytes_min   ,
  bwd_packets_bytes_mean  ,
  bwd_packets_bytes_std   ,
  IF(packets_per_second >= 0, packets_per_second, NULL),
  fwd_packets_per_second  ,
  bwd_packets_per_second  ,
  packet_length_min       ,
  packet_length_max       ,
  packet_length_mean      ,
  packet_length_std       ,
  packet_length_variance  ,
  packet_size_avg         ,
  fwd_packets_bulk_avg    ,
  bwd_packets_bulk_avg    ,
  fwd_subflow_packets_avg ,
  bwd_subflow_packets_avg ,
  fwd_act_data_packets
FROM BaseFlow;

-- ***********************
-- *** Create FlowInfo ***
-- ***********************
SELECT 'Create FlowInfo' AS '';

CREATE TABLE FlowInfo (
  flow_id                 INT               NOT NULL AUTO_INCREMENT,
  fwd_header_length       DECIMAL(16, 0),
  bwd_header_length       DECIMAL(16, 0),
  down_up_ratio           DECIMAL(4, 0),
  fwd_segment_size_avg    DECIMAL(24, 16),
  bwd_segment_size_avg    DECIMAL(24, 16),
  fwd_header_length_1     DECIMAL(16, 0),
  fwd_bulk_rate_avg       DECIMAL(8, 4),
  bwd_bulk_rate_avg       DECIMAL(8, 4),
  fwd_segment_size_min    DECIMAL(8, 0),
  active_time_mean        DECIMAL(32, 16),
  active_time_std         DECIMAL(24, 16),
  active_time_max         DECIMAL(16, 0),
  active_time_min         DECIMAL(16, 0),
  idle_time_mean          DECIMAL(32, 16),
  idle_time_std           DECIMAL(24, 16),
  idle_time_max           DECIMAL(16, 0),
  idle_time_min           DECIMAL(16, 0),
  PRIMARY KEY (flow_id),
  FOREIGN KEY (flow_id) REFERENCES Flow(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (fwd_header_length      >= 0), 
  CHECK (bwd_header_length      >= 0), 
  CHECK (down_up_ratio          >= 0), 
  CHECK (fwd_segment_size_avg   >= 0), 
  CHECK (bwd_segment_size_avg   >= 0), 
  CHECK (fwd_header_length_1    >= 0), 
  CHECK (fwd_bulk_rate_avg      >= 0), 
  CHECK (bwd_bulk_rate_avg      >= 0), 
  CHECK (fwd_segment_size_min   >= 0), 
  CHECK (active_time_mean       >= 0), 
  CHECK (active_time_std        >= 0), 
  CHECK (active_time_max        >= 0), 
  CHECK (active_time_min        >= 0), 
  CHECK (idle_time_mean         >= 0), 
  CHECK (idle_time_std          >= 0), 
  CHECK (idle_time_max          >= 0), 
  CHECK (idle_time_min          >= 0)
);

INSERT INTO FlowInfo
SELECT
  id                      ,
  fwd_header_length       ,
  bwd_header_length       ,
  down_up_ratio           ,
  fwd_segment_size_avg    ,
  bwd_segment_size_avg    ,
  fwd_header_length_1     ,
  fwd_bulk_rate_avg       ,
  bwd_bulk_rate_avg       ,
  IF(fwd_segment_size_min >= 0, fwd_segment_size_min, NULL),
  active_time_mean        ,
  active_time_std         ,
  active_time_max         ,
  active_time_min         ,
  idle_time_mean          ,
  idle_time_std           ,
  idle_time_max           ,
  idle_time_min
FROM BaseFlow;

-- ************************
-- *** Create FlowBytes ***
-- ************************
SELECT 'Create FlowBytes' AS '';

CREATE TABLE FlowBytes (
  flow_id                 INT               NOT NULL AUTO_INCREMENT,
  bytes_per_second        DECIMAL(32, 16),
  fwd_bytes_bulk_avg      DECIMAL(8, 4),
  bwd_bytes_bulk_avg      DECIMAL(8, 4),
  fwd_subflow_bytes_avg   DECIMAL(32, 16),
  bwd_subflow_bytes_avg   DECIMAL(32, 16),
  fwd_init_win_bytes      DECIMAL(8, 0),
  bwd_init_win_bytes      DECIMAL(8, 0),
  PRIMARY KEY (flow_id),
  FOREIGN KEY (flow_id) REFERENCES Flow(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK (bytes_per_second         >= 0),
  CHECK (fwd_bytes_bulk_avg       >= 0),
  CHECK (bwd_bytes_bulk_avg       >= 0),
  CHECK (fwd_subflow_bytes_avg    >= 0),
  CHECK (bwd_subflow_bytes_avg    >= 0),
  CHECK (fwd_init_win_bytes       >= 0),
  CHECK (bwd_init_win_bytes       >= 0)
);

INSERT INTO FlowBytes
SELECT
  id                      ,
  IF(bytes_per_second >= 0, bytes_per_second, NULL),
  fwd_bytes_bulk_avg      ,
  bwd_bytes_bulk_avg      ,
  fwd_subflow_bytes_avg   ,
  bwd_subflow_bytes_avg   ,
  IF(fwd_init_win_bytes >= 0, fwd_init_win_bytes, NULL),
  IF(bwd_init_win_bytes >= 0, bwd_init_win_bytes, NULL)
FROM BaseFlow;

-- ************************
-- *** Create FlowFlags ***
-- ************************
SELECT 'Create FlowFlags' AS '';

CREATE TABLE FlowFlags (
  flow_id                 INT               NOT NULL AUTO_INCREMENT,
  fwd_psh_flags           DECIMAL(2, 0),
  bwd_psh_flags           DECIMAL(2, 0),
  fwd_urg_flags           DECIMAL(2, 0),
  bwd_urg_flags           DECIMAL(2, 0),
  fin_flag_count          DECIMAL(2, 0),
  syn_flag_count          DECIMAL(2, 0),
  rst_flag_count          DECIMAL(2, 0),
  psh_flag_count          DECIMAL(2, 0),
  ack_flag_count          DECIMAL(2, 0),
  urg_flag_count          DECIMAL(2, 0),
  cwe_flag_count          DECIMAL(2, 0),
  ece_flag_count          DECIMAL(2, 0),
  PRIMARY KEY (flow_id),
  FOREIGN KEY (flow_id) REFERENCES Flow(id) ON UPDATE CASCADE ON DELETE CASCADE,
  CHECK(fwd_psh_flags           >= 0),
  CHECK(bwd_psh_flags           >= 0),
  CHECK(fwd_urg_flags           >= 0),
  CHECK(bwd_urg_flags           >= 0),
  CHECK(fin_flag_count          >= 0),
  CHECK(syn_flag_count          >= 0),
  CHECK(rst_flag_count          >= 0),
  CHECK(psh_flag_count          >= 0),
  CHECK(ack_flag_count          >= 0),
  CHECK(urg_flag_count          >= 0),
  CHECK(cwe_flag_count          >= 0),
  CHECK(ece_flag_count          >= 0)
);

INSERT INTO FlowFlags
SELECT
  id                      ,
  fwd_psh_flags           ,
  bwd_psh_flags           ,
  fwd_urg_flags           ,
  bwd_urg_flags           ,
  fin_flag_count          ,
  syn_flag_count          ,
  rst_flag_count          ,
  psh_flag_count          ,
  ack_flag_count          ,
  urg_flag_count          ,
  cwe_flag_count          ,
  ece_flag_count          
FROM BaseFlow;