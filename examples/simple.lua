--[[
CREATE TABLE `test_table` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `c1` varchar(45)  DEFAULT NULL,
  `c2` char(45)  DEFAULT NULL,
  `c3` varchar(45)  DEFAULT NULL,
  `c4` int(11) DEFAULT NULL,
  `c7` bigint(12) DEFAULT NULL,
  `c8` double DEFAULT NULL,
  `c9` float DEFAULT NULL,
  `c10` mediumint(24) DEFAULT NULL,
  `c11` smallint(5) DEFAULT NULL,
  `c12` tinyint(8) DEFAULT NULL,
  `t1` datetime DEFAULT NULL,
  `t2` date DEFAULT NULL,
  `t3` time(6) DEFAULT NULL,
  `t4` timestamp(6) NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
)
]]--

package.path="../?.lua;;";


local mysql=require("mysql")

--initialize
local db=mysql:new()
db:connect({host="192.168.200.5", user="test", passwd="test",db="test"})
db:set_character_set("utf8")

--insert data,return id if id is auto incrment
local id=db:insert("insert into test_table(c1,c2,c3,c4,c7,c8,c9,c10,c11,c12,t1,t2,t3,t4) values('test','test','test',12333,1334,4455.94,334.01,33344,32766,127,'2016-10-14 10:24:14','2016-10-14','10:24:14.000000','2016-10-14 10:24:14.000000')")
print(id)

local rows=db:query("select * from test_table")

print(string.format('find  %d records', #rows))
print()
for i,record in ipairs(rows) do
	print(string.format("%d recrod data is:",i))
	for k,v in pairs(record) do
		print(k,v)
	end
end

db:close()
