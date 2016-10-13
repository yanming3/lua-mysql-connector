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
