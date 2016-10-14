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
