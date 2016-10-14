--LD_LIBRARY_PATH=/Users/allan/Downloads/mysql-connector-c-6.1.6-osx10.8-x86_64/lib/:$LD_LIBRARY_PATH  
--export LD_LIBRARY_PATH
local ffi=require("ffi")
local bit = require'bit'
require("header")
local clib=ffi.load(ffi.abi'win' and 'libmysql' or 'mysqlclient')
local C=ffi.C
--local clib=ffi.load(ffi.abi'win' and 'libmariadb' or 'mariadb')
local _M = { _VERSION = '0.16' }
local mt = { __index = _M }

local types_mapping = {
    [C.MYSQL_TYPE_VAR_STRING]= 'uint8_t[?]',
    [C.MYSQL_TYPE_STRING]    = 'uint8_t[?]',
	[C.MYSQL_TYPE_VARCHAR]   = 'uint8_t[?]',
	[C.MYSQL_TYPE_TINY]      = 'int8_t[1]',
	[C.MYSQL_TYPE_SHORT]     = 'int16_t[1]',
	[C.MYSQL_TYPE_LONG]      = 'int32_t[1]',
	[C.MYSQL_TYPE_INT24]       = 'int32_t[1]',
	[C.MYSQL_TYPE_LONGLONG]  = 'int64_t[1]',
	[C.MYSQL_TYPE_FLOAT]     = 'float[1]',
	[C.MYSQL_TYPE_DOUBLE]    = 'double[1]',
	[C.MYSQL_TYPE_NEWDECIMAL]= 'uint8_t[?]',
	[C.MYSQL_TYPE_BIT]       = 'uint8_t[8]',
	[C.MYSQL_TYPE_TIME]  = 'MYSQL_TIME',
	[C.MYSQL_TYPE_DATE]  = 'MYSQL_TIME',
	[C.MYSQL_TYPE_TIMESTAMP]  = 'MYSQL_TIME',
	[C.MYSQL_TYPE_DATETIME]  = 'MYSQL_TIME',
}

local function checkNull(obj)
	assert(obj,"please initialize before use!")
end

local function datetime(t)
	return setmetatable(t, {__tostring = function(t)
							local date, time
							if t.year then
								date= string.format('%04d-%02d-%02d', t.year, t.month, t.day)
							end
							if t.sec then
								if t.frac and t.frac ~= 0 then
								time= string.format('%02d:%02d:%02d.%d', t.hour, t.min, t.sec, t.frac)
							else
								time= string.format('%02d:%02d:%02d', t.hour, t.min, t.sec)
							end
							end
							if date and time then
								return date .. ' ' .. time
							else
								return assert(date or time)
							end
						end
	})
end

local function is_string(c_type)
	if c_type==C.MYSQL_TYPE_VARCHAR or c_type==C.MYSQL_TYPE_VAR_STRING or c_type==C.MYSQL_TYPE_STRING 
		or c_type==C.MYSQL_TYPE_NEWDECIMAL then
		return true
	else
		return false
	end
end


local function is_number(c_type)
	if c_type==C.MYSQL_TYPE_DOUBLE or c_type==C.MYSQL_TYPE_FLOAT 
		or c_type==C.MYSQL_TYPE_LONG or c_type==C.MYSQL_TYPE_LONGLONG
		or c_type==C.MYSQL_TYPE_TINY or c_type==C.MYSQL_TYPE_INT24 
		or c_type==C.MYSQL_TYPE_SHORT then
		return true
	else
		return false
	end
end

local function is_datetime(c_type)
	if c_type==C.MYSQL_TYPE_TIME or c_type==C.MYSQL_TYPE_DATE
		or c_type==C.MYSQL_TYPE_TIMESTAMP or c_type==C.MYSQL_TYPE_DATETIME then
		return true
	else
		return false
	end
end

local function is_date(c_type)
	if c_type==C.MYSQL_TYPE_DATE or c_type==C.MYSQL_TYPE_TIMESTAMP 
		or c_type==C.MYSQL_TYPE_DATETIME then
		return true
	else
		return false
	end
end

local function is_time(c_type)
	if c_type==C.MYSQL_TYPE_TIME
		or c_type==C.MYSQL_TYPE_TIMESTAMP or c_type==C.MYSQL_TYPE_DATETIME then
		return true
	else
		return false
	end
end

local function handle_stmt_error(ok,stmt)
	if not ok then
	    local errmsg=ffi.string(clib.mysql_stmt_error(stmt))
		local errno=tonumber(clib.mysql_stmt_errno(stmt))
		error("Error Code:"..errno.."."..errmsg)
	end
end

local function handle_error(ok,sock)
	if not ok then
	    local errmsg=ffi.string(clib.mysql_error(sock))
		local errno=tonumber(clib.mysql_errno(sock))
		error("Error Code:"..errno.."."..errmsg)
	end
end

local function fill_parameter(param,t,v,need_size)
	local c_type=types_mapping[t]

	local buffer
	local buffer_size

	if is_string(t) then--special for string
		buffer_size=v~=nil and #v or 0
		buffer=ffi.new(c_type,buffer_size)
		ffi.copy(buffer,v,buffer_size)
	else
		buffer=ffi.new(c_type);
		buffer_size=ffi.sizeof(buffer)
		buffer[0]=v
	end
	
	param.buffer_type=t
	param.buffer_length=buffer_size
	param.buffer=buffer
	if need_size then
		param.length=ffi.new('unsigned long[1]',{buffer_size})
	end
	param.is_null=ffi.new('my_bool[1]',{v==nil})
end

function _M.new(self)
	local sock=ffi.gc(clib.mysql_init(nil),clib.mysql_close)
	return setmetatable({sock=sock,status="init"},mt)
end

function _M.connect(self,opts)
	checkNull(self.sock)
	if self.status~="init" then
		if self.status=="connected" then
			error("repeated invoke connect method")
		else
			error("please init by invoke new() method")
		end 
		return
	end
	local host=opts.host or 'localhost'
	local user=opts.user
	local passwd=opts.passwd
	local db=opts.db
	local port=opts.port or 3306
	clib.mysql_real_connect(self.sock,host, user, passwd,db, port, nil, 0)
	self.status="connected"
end

function _M.query(self,sql)
	checkNull(self.sock)
	local ok=tonumber(clib.mysql_real_query(self.sock, sql,#sql))
	handle_error(ok==0,self.sock)


	local res=ffi.gc(clib.mysql_store_result(self.sock),clib.mysql_free_result)
    local fields = clib.mysql_fetch_fields(res)
    local fieldCount = clib.mysql_num_fields(res)
   
    local result={}
	local row=clib.mysql_fetch_row(res)
	while(row~=nil) do
		local record={}
		for i=0,fieldCount-1 do
			local v=''
			if(row[i]~=nil) then
	    		v=ffi.string(row[i])
	    	end
	    	local k=ffi.string(fields[i].name, fields[i].name_length)
	    	record[k]=v
    	end
		table.insert(result,record)
		row=clib.mysql_fetch_row(res)
	end

	res=nil
	return result
end 

function _M.insert(self,sql)
	checkNull(self.sock)
	local ok=tonumber(clib.mysql_real_query(self.sock, sql,#sql))
	handle_error(ok==0,self.sock)

	local id=clib.mysql_insert_id(self.sock)
	local affected=clib.mysql_affected_rows(self.sock)
	return tonumber(id),tonumber(affected)
end 

function _M.update(self,sql)
	checkNull(self.sock)
	local ok=tonumber(clib.mysql_real_query(self.sock, sql,#sql))
	handle_error(ok==0,self.sock)

	local affected=clib.mysql_affected_rows(self.sock)
	return tonumber(affected)
end 
function _M.set_character_set(self,charset_name)
	checkNull(self.sock)
	local charset_para=ffi.cast("const char *",charset_name)
	local ok=tonumber(clib.mysql_set_character_set(self.sock,charset_para))
	handle_error(ok==0,self.sock)
end


function _M.prepare_stmt(self,sql)
	local stmt=ffi.gc(clib.mysql_stmt_init(self.sock),clib.mysql_stmt_close)
	
	local prepared_sql=ffi.new("uint8_t[?]",#sql)
	ffi.copy(prepared_sql,sql,#sql)
	local ok=tonumber(clib.mysql_stmt_prepare(stmt,prepared_sql,ffi.sizeof(prepared_sql)))
	handle_error(ok==0,self.sock)

	local param_count=tonumber(clib.mysql_stmt_param_count(stmt))
	local bind_param=ffi.new("MYSQL_BIND[?]",param_count)
	self.stmt=stmt
	self.bind_param=bind_param
	self.param_total=param_count
end

function _M.set_boolean(self,param_index,val)
   assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_BIT,val)
end

function _M.set_byte(self,param_index,val)
   assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_TINY,val)
end

function _M.set_short(self,param_index,val)
   assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_SHORT,val)
end


function _M.set_int(self,param_index,val)
   assert(param_index<self.param_total)
   local param=self.bind_param[param_index]
   fill_parameter(param,ffi.C.MYSQL_TYPE_LONG,val)
end

function _M.set_long(self,param_index,val)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_LONG,val)
end

function _M.set_double(self,param_index,val)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_DOUBLE,val)
end

function _M.set_float(self,param_index,val)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_FLOAT,val)
end

function _M.set_string(self,param_index,val)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    fill_parameter(param,ffi.C.MYSQL_TYPE_STRING,val,true)
end

function _M.set_date(self,param_index,year, month, day)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    local tm=ffi.new('MYSQL_TIME')
    tm.year        = math.max(0, math.min(year  or 0, 9999)) or 0
	tm.month       = math.max(1, math.min(month or 0, 12)) or 0
	tm.day         = math.max(1, math.min(day   or 0, 31)) or 0
    tm.time_type=C.MYSQL_TIMESTAMP_DATE
	param.buffer_type=C.MYSQL_TYPE_DATE;
	param.buffer=tm
	param.is_null=ffi.new('my_bool[1]',{false})
	param.length=ffi.new('unsigned long[1]',{0})
end

function _M.set_time(self,param_index,hour, min, sec,frac)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    local tm=ffi.new('MYSQL_TIME')

	tm.hour        = math.max(0, math.min(hour  or 0, 59)) or 0
	tm.minute      = math.max(0, math.min(min   or 0, 59)) or 0
	tm.second      = math.max(0, math.min(sec   or 0, 59)) or 0
	tm.second_part = math.max(0, math.min(frac  or 0, 999999)) or 0
	tm.time_type=C.MYSQL_TIMESTAMP_TIME
    param.buffer_type=C.MYSQL_TYPE_TIME;
	param.buffer=tm
	param.is_null=ffi.new('my_bool[1]',{false})
	param.length=ffi.new('unsigned long[1]',{0})
end

function _M.set_timestamp(self,param_index,year, month, day, hour, min, sec, frac)
	assert(param_index<self.param_total)
    local param=self.bind_param[param_index]
    local tm=ffi.new('MYSQL_TIME')
    
    tm.year        = math.max(0, math.min(year  or 0, 9999)) or 0
	tm.month       = math.max(1, math.min(month or 0, 12)) or 0
	tm.day         = math.max(1, math.min(day   or 0, 31)) or 0
	tm.hour        = math.max(0, math.min(hour  or 0, 59)) or 0
	tm.minute      = math.max(0, math.min(min   or 0, 59)) or 0
	tm.second      = math.max(0, math.min(sec   or 0, 59)) or 0
	tm.second_part = math.max(0, math.min(frac  or 0, 999999)) or 0
	tm.time_type=C.MYSQL_TIMESTAMP_DATETIME
	param.buffer_type=C.MYSQL_TYPE_TIMESTAMP;
	param.buffer=tm
	param.is_null=ffi.new('my_bool[1]',{false})
	param.length=ffi.new('unsigned long[1]',{0})
end	

function _M.execute_update(self)
	clib.mysql_stmt_bind_param(self.stmt,self.bind_param)
	clib.mysql_stmt_execute(self.stmt)
	local affected=tonumber(clib.mysql_stmt_affected_rows(self.stmt))
	self.stmt=nil
	self.bind_param=nil
	self.param_total=nil
	return affected
end

local function _bind_result(stmt)
	local res=ffi.gc(clib.mysql_stmt_result_metadata(stmt),clib.mysql_free_result)
	local field_nums=tonumber(clib.mysql_num_fields(res))

	local bind_result=ffi.new("MYSQL_BIND[?]",field_nums)
	local null_flags=ffi.new("my_bool[?]",field_nums)
	local error_flags=ffi.new("my_bool[?]",field_nums)
	local lengths = ffi.new('unsigned long[?]', field_nums) 
	local data={}
    local field_lists={}
 
    
	for i=0,field_nums-1,1 do
		local info = clib.mysql_fetch_field_direct(res, i)

		local enum_info_type=tonumber(info.type)
		local info_type=types_mapping[enum_info_type]
		local field_length=tonumber(info.length)
        
       
		local buffer
        if is_string(enum_info_type) then
        	bind_result[i].buffer_type=C.MYSQL_TYPE_STRING
        	buffer=ffi.new(info_type,field_length)
			bind_result[i].buffer=buffer
			bind_result[i].buffer_length=field_length
		elseif is_number(enum_info_type) then
			bind_result[i].buffer_type=enum_info_type
			buffer=ffi.new(info_type)
			bind_result[i].buffer=buffer
			bind_result[i].buffer_length=ffi.sizeof(buffer)
		elseif is_datetime(enum_info_type) then
			buffer=ffi.new(info_type)
			bind_result[i].buffer_type=enum_info_type
			bind_result[i].buffer=buffer
			bind_result[i].buffer_length=ffi.sizeof(bind_result[i].buffer)
        end
       
		bind_result[i].is_null=null_flags+i
		bind_result[i].error=error_flags+i
		bind_result[i].length=lengths+i
		data[i]=buffer
		field_lists[i+1]={type=enum_info_type,name=ffi.string(info.name, info.name_length)}
	end
	--clib.mysql_free_result(res);通过ffi.gc创建，不需要再次调用
	res=nil
	
	return bind_result,field_lists,null_flags,lengths,data
end

function _M.execute_query(self)
	clib.mysql_stmt_bind_param(self.stmt,self.bind_param)
	
	local bind_result,field_lists,null_flags,lengths,data=_bind_result(self.stmt)
    
	local ok=clib.mysql_stmt_bind_result(self.stmt,bind_result)
	handle_stmt_error(ok==0,self.stmt)

	ok=clib.mysql_stmt_execute(self.stmt)
	handle_stmt_error(ok==0,self.stmt)
   
	ok=clib.mysql_stmt_store_result(self.stmt)
 	handle_stmt_error(ok==0,self.stmt)
  

	local result={}
	while(true) do 
		ok=clib.mysql_stmt_fetch(self.stmt)
		if(ok==C.MYSQL_DATA_TRUNCATED or ok==1) then
			print("MYSQL_DATA_TRUNCATED")
			handle_stmt_error(false,self.stmt)
			break
		elseif(ok==C.MYSQL_NO_DATA) then
			print("MYSQL_NO_DATA")
			break
		elseif(ok~=0) then
			print("ERROR")
			handle_stmt_error(false,self.stmt)
			break
		end

		local row={}
        
		for i=0,#field_lists-1 do
			local field=field_lists[i+1]
          
			if null_flags[i] ~= 1 then 
               
				if is_string(field.type) then
					row[field.name]=ffi.string(data[i],tonumber(lengths[i]))
				elseif is_number(field.type) then
					row[field.name]=tonumber(data[i][0])
				elseif is_datetime(field.type) then
					local tm=data[i]
			
                    local date=is_date(field.type)
                    local time=is_time(field.type)
					row[field.name]=datetime({
							year=date and tm.year or nil,
							month=date and tm.month or nil,
							day=date and tm.day or nil,
							hour=time and tm.hour or nil,
							min=time and tm.minute or nil,
							sec=time and tm.second or nil,
							frac=time and tonumber(tm.second_part) or nil
						})
				end
			end
		end
		table.insert(result,row)
	end
  
	self.stmt=nil
	self.bind_param=nil
	self.param_total=nil
	return result;
end


function _M.is_connected(self)
	checkNull(self.sock)
	local ok=tonumber(clib.mysql_ping(self.sock))
	if ok==0 then
		return true
	else
		return false
	end
end


function _M.close(self)
	self.sock=nil
end
return _M

