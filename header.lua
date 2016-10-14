local ffi=require("ffi")
ffi.cdef([[
typedef char my_bool;
typedef int my_socket;
typedef char **MYSQL_ROW;		
typedef unsigned int MYSQL_FIELD_OFFSET; 
typedef unsigned long long my_ulonglong;

typedef void MYSQL_PARAMETERS;
typedef void MYSQL_RES;
typedef void MYSQL;
typedef void MYSQL_ROW_OFFSET;
typedef void MY_CHARSET_INFO;
typedef void MYSQL_STMT;
typedef void NET;

enum {
  MYSQL_NO_DATA = 100,
  MYSQL_DATA_TRUNCATED = 101
};

enum {
  MYSQL_NOT_NULL_FLAG = 1,     /* Field can't be NULL */
  MYSQL_PRI_KEY_FLAG = 2,      /* Field is part of a primary key */
  MYSQL_UNIQUE_KEY_FLAG = 4,   /* Field is part of a unique key */
  MYSQL_MULTIPLE_KEY_FLAG = 8, /* Field is part of a key */
  MYSQL_BLOB_FLAG = 16,        /* Field is a blob */
  MYSQL_UNSIGNED_FLAG = 32,    /* Field is unsigned */
  MYSQL_ZEROFILL_FLAG = 64,    /* Field is zerofill */
  MYSQL_BINARY_FLAG = 128,     /* Field is binary   */
  /* The following are only sent to new clients */
  MYSQL_ENUM_FLAG = 256,              /* field is an enum */
  MYSQL_AUTO_INCREMENT_FLAG = 512,    /* field is a autoincrement field */
  MYSQL_TIMESTAMP_FLAG = 1024,        /* Field is a timestamp */
  MYSQL_SET_FLAG = 2048,              /* field is a set */
  MYSQL_NO_DEFAULT_VALUE_FLAG = 4096, /* Field doesn't have default value */
  MYSQL_ON_UPDATE_NOW_FLAG = 8192,    /* Field is set to NOW on UPDATE */
  MYSQL_NUM_FLAG = 32768,             /* Field is num (for clients) */
  MYSQL_PART_KEY_FLAG = 16384,        /* Intern; Part of some key */
  MYSQL_GROUP_FLAG = 32768,           /* Intern: Group field */
  MYSQL_UNIQUE_FLAG = 65536,          /* Intern: Used by sql_yacc */
  MYSQL_BINCMP_FLAG = 131072,         /* Intern: Used by sql_yacc */
  MYSQL_GET_FIXED_FIELDS_FLAG = (1 << 18),  /* Used to get fields in item tree */
  MYSQL_FIELD_IN_PART_FUNC_FLAG = (1 << 19) /* Field part of partition func */
};

enum enum_mysql_timestamp_type
{
  MYSQL_TIMESTAMP_NONE= -2, MYSQL_TIMESTAMP_ERROR= -1,
  MYSQL_TIMESTAMP_DATE= 0, MYSQL_TIMESTAMP_DATETIME= 1, MYSQL_TIMESTAMP_TIME= 2
};
typedef struct st_mysql_time
{
  unsigned int  year, month, day, hour, minute, second;
  unsigned long second_part;  /**< microseconds */
  my_bool       neg;
  enum enum_mysql_timestamp_type time_type;
} MYSQL_TIME;

enum enum_field_types { 
	  MYSQL_TYPE_DECIMAL, 
	  MYSQL_TYPE_TINY,
    MYSQL_TYPE_SHORT,  
    MYSQL_TYPE_LONG,
    MYSQL_TYPE_FLOAT,  
    MYSQL_TYPE_DOUBLE,
    MYSQL_TYPE_NULL,   
    MYSQL_TYPE_TIMESTAMP,
    MYSQL_TYPE_LONGLONG,
    MYSQL_TYPE_INT24,
    MYSQL_TYPE_DATE,   
    MYSQL_TYPE_TIME,
    MYSQL_TYPE_DATETIME, 
    MYSQL_TYPE_YEAR,
    MYSQL_TYPE_NEWDATE, 
    MYSQL_TYPE_VARCHAR,
    MYSQL_TYPE_BIT,
    MYSQL_TYPE_TIMESTAMP2,
    MYSQL_TYPE_DATETIME2,
    MYSQL_TYPE_TIME2,
    MYSQL_TYPE_NEWDECIMAL=246,
    MYSQL_TYPE_ENUM=247,
    MYSQL_TYPE_SET=248,
    MYSQL_TYPE_TINY_BLOB=249,
    MYSQL_TYPE_MEDIUM_BLOB=250,
    MYSQL_TYPE_LONG_BLOB=251,
    MYSQL_TYPE_BLOB=252,
    MYSQL_TYPE_VAR_STRING=253,
    MYSQL_TYPE_STRING=254,
    MYSQL_TYPE_GEOMETRY=255
};
typedef struct st_mysql_field {
	char *name;
	char *org_name;
	char *table;
	char *org_table;
	char *db;
	char *catalog;
	char *def;
	unsigned long length;
	unsigned long max_length;
	unsigned int name_length;
	unsigned int org_name_length;
	unsigned int table_length;
	unsigned int org_table_length;
	unsigned int db_length;
	unsigned int catalog_length;
	unsigned int def_length;
	unsigned int flags;
	unsigned int decimals;
	unsigned int charsetnr;
	enum enum_field_types type;
	void *extension;
} MYSQL_FIELD;

typedef struct st_mysql_bind
{
  unsigned long	*length;
  my_bool   *is_null;
  void		*buffer;
  my_bool       *error;
  unsigned char *row_ptr;
  void (*store_param_func)(NET *net, struct st_mysql_bind *param);
  void (*fetch_result)(struct st_mysql_bind *, MYSQL_FIELD *,unsigned char **row);
  void (*skip_result)(struct st_mysql_bind *, MYSQL_FIELD *,unsigned char **row);
  unsigned long buffer_length;
  unsigned long offset;
  unsigned long	length_value;
  unsigned int	param_number;
  unsigned int  pack_length;
  enum enum_field_types buffer_type;
  my_bool       error_value;
  my_bool       is_unsigned;
  my_bool	long_data_used;
  my_bool	is_null_value;
  void *extension;
} MYSQL_BIND;


MYSQL*	mysql_init(MYSQL *mysql);
my_bool	mysql_change_user(MYSQL *mysql, const char *user, const char *passwd, const char *db);
MYSQL*	mysql_real_connect(MYSQL *mysql, const char *host, const char *user,const char *passwd,const char *db,unsigned int port,const char *unix_socket,unsigned long clientflag);
int	mysql_select_db(MYSQL *mysql, const char *db);
int	mysql_query(MYSQL *mysql, const char *q);
int	mysql_send_query(MYSQL *mysql, const char *q,unsigned long length);
int	mysql_real_query(MYSQL *mysql, const char *q,unsigned long length);
MYSQL_RES*    mysql_store_result(MYSQL *mysql);
MYSQL_RES*    mysql_use_result(MYSQL *mysql);
my_ulonglong  mysql_num_rows(MYSQL_RES *res);
unsigned int  mysql_num_fields(MYSQL_RES *res);
my_bool  mysql_eof(MYSQL_RES *res);
void		 mysql_free_result(MYSQL_RES *result);
MYSQL_FIELD* mysql_fetch_field_direct(MYSQL_RES *res,unsigned int fieldnr);
MYSQL_FIELD*  mysql_fetch_fields(MYSQL_RES *res);
MYSQL_ROW_OFFSET  mysql_row_tell(MYSQL_RES *res);
MYSQL_FIELD_OFFSET  mysql_field_tell(MYSQL_RES *res);
unsigned int  mysql_field_count(MYSQL *mysql);
my_ulonglong  mysql_affected_rows(MYSQL *mysql);
my_ulonglong  mysql_insert_id(MYSQL *mysql);
unsigned int  mysql_errno(MYSQL *mysql);
const char *  mysql_error(MYSQL *mysql);
const char * mysql_sqlstate(MYSQL *mysql);


void mysql_data_seek(MYSQL_RES *result,	my_ulonglong offset);
MYSQL_ROW_OFFSET  mysql_row_seek(MYSQL_RES *result,MYSQL_ROW_OFFSET offset);
MYSQL_FIELD_OFFSET  mysql_field_seek(MYSQL_RES *result, MYSQL_FIELD_OFFSET offset);
MYSQL_ROW	 mysql_fetch_row(MYSQL_RES *result);
unsigned long *  mysql_fetch_lengths(MYSQL_RES *result);
MYSQL_FIELD *	 mysql_fetch_field(MYSQL_RES *result);
MYSQL_RES *      mysql_list_fields(MYSQL *mysql, const char *table, const char *wild);
unsigned long	mysql_escape_string(char *to,const char *from,unsigned long from_length);
unsigned long	mysql_hex_string(char *to,const char *from, unsigned long from_length);
unsigned long  mysql_real_escape_string(MYSQL *mysql,char *to,const char *from,unsigned long length);

my_bool    mysql_read_query_result(MYSQL *mysql);

MYSQL_STMT *  mysql_stmt_init(MYSQL *mysql);
int  mysql_stmt_prepare(MYSQL_STMT *stmt, const char *query, unsigned long length);
int  mysql_stmt_execute(MYSQL_STMT *stmt);
int  mysql_stmt_fetch(MYSQL_STMT *stmt);
int  mysql_stmt_fetch_column(MYSQL_STMT *stmt, MYSQL_BIND *bind_arg, unsigned int column,unsigned long offset);
int  mysql_stmt_store_result(MYSQL_STMT *stmt);
unsigned long  mysql_stmt_param_count(MYSQL_STMT * stmt);
my_bool  mysql_stmt_attr_set(MYSQL_STMT *stmt,enum enum_stmt_attr_type attr_type, const void *attr);
my_bool  mysql_stmt_attr_get(MYSQL_STMT *stmt,enum enum_stmt_attr_type attr_type,void *attr);
my_bool  mysql_stmt_bind_param(MYSQL_STMT * stmt, MYSQL_BIND * bnd);
my_bool  mysql_stmt_bind_result(MYSQL_STMT * stmt, MYSQL_BIND * bnd);
my_bool  mysql_stmt_close(MYSQL_STMT * stmt);
my_bool  mysql_stmt_reset(MYSQL_STMT * stmt);
my_bool  mysql_stmt_free_result(MYSQL_STMT *stmt);
my_bool  mysql_stmt_send_long_data(MYSQL_STMT *stmt,  unsigned int param_number,const char *data,  unsigned long length);
MYSQL_RES * mysql_stmt_result_metadata(MYSQL_STMT *stmt);
MYSQL_RES * mysql_stmt_param_metadata(MYSQL_STMT *stmt);
unsigned int  mysql_stmt_errno(MYSQL_STMT * stmt);
const char * mysql_stmt_error(MYSQL_STMT * stmt);
const char * mysql_stmt_sqlstate(MYSQL_STMT * stmt);
MYSQL_ROW_OFFSET  mysql_stmt_row_seek(MYSQL_STMT *stmt, MYSQL_ROW_OFFSET offset);
MYSQL_ROW_OFFSET  mysql_stmt_row_tell(MYSQL_STMT *stmt);
void  mysql_stmt_data_seek(MYSQL_STMT *stmt, my_ulonglong offset);
my_ulonglong  mysql_stmt_num_rows(MYSQL_STMT *stmt);
my_ulonglong  mysql_stmt_affected_rows(MYSQL_STMT *stmt);
my_ulonglong  mysql_stmt_insert_id(MYSQL_STMT *stmt);
unsigned int  mysql_stmt_field_count(MYSQL_STMT *stmt);

my_bool  mysql_commit(MYSQL * mysql);
my_bool  mysql_rollback(MYSQL * mysql);
my_bool  mysql_autocommit(MYSQL * mysql, my_bool auto_mode);
my_bool  mysql_more_results(MYSQL *mysql);
int  mysql_next_result(MYSQL *mysql);
int  mysql_stmt_next_result(MYSQL_STMT *stmt);
void  mysql_close(MYSQL *sock);

void mysql_set_local_infile_default(MYSQL *mysql);
MYSQL_PARAMETERS * mysql_get_parameters(void);
void  mysql_get_character_set_info(MYSQL *mysql, MY_CHARSET_INFO *charset);
my_bool	mysql_ssl_set(MYSQL *mysql, const char *key,const char *cert, const char *ca,const char *capath, const char *cipher);
const char *     mysql_get_ssl_cipher(MYSQL *mysql);
my_bool  mysql_thread_init(void);
void  mysql_thread_end(void);
unsigned long  mysql_thread_id(MYSQL *mysql);
int  mysql_server_init(int argc, char **argv, char **groups);
void  mysql_server_end(void);
int	mysql_shutdown(MYSQL *mysql, enum mysql_enum_shutdown_level shutdown_level);
int	mysql_dump_debug_info(MYSQL *mysql);
int	mysql_refresh(MYSQL *mysql,  unsigned int refresh_options);
int	mysql_kill(MYSQL *mysql,unsigned long pid);
int	mysql_set_server_option(MYSQL *mysql,enum enum_mysql_set_option	option);
unsigned int  mysql_warning_count(MYSQL *mysql);
const char *  mysql_info(MYSQL *mysql);
const char *  mysql_character_set_name(MYSQL *mysql);
int   mysql_set_character_set(MYSQL *mysql, const char *csname);
int	mysql_ping(MYSQL *mysql);
const char *	 mysql_stat(MYSQL *mysql);
const char *	 mysql_get_server_info(MYSQL *mysql);
const char *	 mysql_get_client_info(void);
unsigned long	 mysql_get_client_version(void);
const char *	 mysql_get_host_info(MYSQL *mysql);
unsigned long	 mysql_get_server_version(MYSQL *mysql);
unsigned int	 mysql_get_proto_info(MYSQL *mysql);
MYSQL_RES *	 mysql_list_dbs(MYSQL *mysql,const char *wild);
MYSQL_RES *	 mysql_list_tables(MYSQL *mysql,const char *wild);
MYSQL_RES *	 mysql_list_processes(MYSQL *mysql);
int		 mysql_options(MYSQL *mysql,enum mysql_option option, const void *arg);
int		 mysql_options4(MYSQL *mysql,enum mysql_option option,
                                       const void *arg1, const void *arg2);
void		 mysql_debug(const char *debug);
void 		 myodbc_remove_escape(MYSQL *mysql,char *name);
unsigned int	 mysql_thread_safe(void);
my_bool		 mysql_embedded(void);
]])