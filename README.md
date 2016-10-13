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
 通过luajit的ffi调用mysql官方的c connector实现，因此需要先安装好[c connector](http://dev.mysql.com/downloads/connector/c/)之后才能运行；
 
## 代码样例
 
```lua
package.path="../?.lua;;";
local mysql=require("mysql")

local db=mysql:new()

db:connect({host="10.36.40.42", user="f_test", passwd="f_test_2015",db="market_platform"})
db:set_character_set("utf8")

db:prepare_stmt("insert into test_table(name,total,distance,create_time) values(?,?,?,?)")
local d=os.date("*t")
db:set_string(0,"test3")
db:set_long(1,999)
db:set_double(2,3.45)
db:set_timestamp(3,d.year,d.month,d.day,d.hour,d.min,d.sec,0)
local num=db:execute_update()
print(string.format("affected data count is %d",num))
]]
db:prepare_stmt("select  * from  test_table where name=?")
db:set_string(0,"test3")

local rows=db:execute_query()
print(string.format("found %d records",#rows))

for i,record in ipairs(rows) do
	for k,v in pairs(record) do
		print(k,v)
	end
end

db:close()

```


```lua
package.path="../?.lua;;";


local mysql=require("mysql")

--initialize
local db=mysql:new()
db:connect({host="10.36.40.42", user="f_test", passwd="f_test_2015",db="market_platform"})
db:set_character_set("utf8")

--insert data,return id if id is auto incrment
local id=db:insert("insert into test_table(name,total,distance,create_time) values('测试',999,0.5,'2016-10-13 14:26:26')")
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

