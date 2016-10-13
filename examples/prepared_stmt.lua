package.path="../?.lua;;";
local mysql=require("mysql")

local db=mysql:new()

db:connect({host="10.36.40.42", user="f_test", passwd="f_test_2015",db="market_platform"})
db:set_character_set("utf8")

--[[db:prepare_stmt("insert into test_table(name,total,distance,create_time) values(?,?,?,?)")
local d=os.date("*t")
db:set_string(0,"test3")
db:set_long(1,999)
db:set_double(2,3.45)
db:set_timestamp(3,d.year,d.month,d.day,d.hour,d.min,d.sec,0)
local num=db:execute_update()
print(string.format("affected data count is %d",num))
]]--
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
