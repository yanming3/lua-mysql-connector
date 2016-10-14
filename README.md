#简介
lua-mysql-connector是一个访问lua语言版本的mysql客户端访问类库,目前还在开发中；

## 实现特性
1. 增、删、改、查;
2. 支持Prepared Statement

## 待实现特性
1. 支持TEXT,BLOB数据类型；
2. 支持存储过程调用;
3. 支持嵌入式服务器

## 实现思路
 通过luajit的ffi调用mysql官方的c connector实现，因此需要先安装好[c connector](http://dev.mysql.com/downloads/connector/c/)之后才能运行；通常情况下，mysql c connector类库位于/usr/lib64/mysql/，需要修改环境变量：
 
 ```bash
 LD_LIBRARY_PATH=/usr/lib64/mysql/:$LD_LIBRARY_PATH  
 ```

export LD_LIBRARY_PATH
## 代码样例
 
```lua
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

```


```lua
package.path="../?.lua;;";
local mysql=require("mysql")

local db=mysql:new()

db:connect({host="192.168.200.5", user="test", passwd="test",db="test"})
db:set_character_set("utf8")

db:prepare_stmt("insert into test_table(c1,c2,c3,c4,c7,c8,c9,c10,c11,c12,t1,t2,t3,t4) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
db:set_string(0,'测试')
db:set_string(1,'测试')
db:set_string(2,'测试')
db:set_int(3,1111)
db:set_long(4,122223)
db:set_double(5,3344433.03)
db:set_float(6,333.02)
db:set_long(7,333444)
db:set_short(8,333)
db:set_byte(9,23)
db:set_timestamp(10,2016,10,14,10,38,12)
db:set_date(11,2016,10,14)
db:set_time(12,10,38,12)
db:set_timestamp(13,2016,10,14,10,38,12,223)
local num=db:execute_update()
print(string.format("affected data count is %d",num))

db:prepare_stmt("select * from  test_table where c1=?")
db:set_string(0,"测试")


local rows=db:execute_query()
print(string.format("found %d records",#rows))

for i,record in ipairs(rows) do
	for k,v in pairs(record) do
		print(k,v)
	end
end
db:close()

```

