--优化sql一般步骤

--通过show status 命令了解各种sql的执行频率


--定位低效的sql
  --1 慢查询日志
  --2 show processlist 查看当前mysql在进行的线程，包含线程的状态和是否锁表，实时查看sql的执行情况
  


--explain 各个列的详细解释
  select_type: 表示 select 的类型。 常见的有
    SIMPLE:(简单表 不只是用表连接或者子查询)
    PRIMARY:(主查询，即外层的查询)
    UNION:(UNION 中的第二个或者后面的查询语句)
    SUBQUERY:(子查询中的第一个 select)
    
  table: 输出结果集的表

  type: 表示 mysql在表中找到所需的行的方式， 或者叫访问类型
        all     全表扫描,mysql 遍历全表来找到匹配的行
        index   索引全扫描,mysql遍历整个索引来查询匹配的行
        range   《索引》查询查询，常见于 < <= > >= between 操作
        ref     使用非唯一索引扫描，或 唯一索引的前缀扫描， 返回匹配某个单独值得记录行
        eq_ref  使用唯一索引扫描, 对于每个索引的键值，表中只有一条记录匹配， 简单来说，就是多表链接中使用了 primary key 或者 unique index 作为关联条件
        const,system  单表中最多有一个匹配行，查询起来非常迅速, 所以这个匹配行中的其他列的值可以被优化器在当前查询中当做常亮来处理， 
                      例如: 根据主键 primary key， 或者 unique index 进行的查询 
        null    mysql 不用访问表或者索引 直接就能够得到结果
        ref_or_null: 和 ref 类似，区别在于条件中包含对 NULL 的查询
        index_merge: (索引合并优化) 
        unique_subquery: in 的后面是一个查询主键字段的子查询，
        index_subquery:  跟（unique_subquery）类似，区别在于 in 的后面是查询费唯一索引字段的子查询 等
        
  possible_keys: 表示查询的时候，可能使用的索引
  key: 表示实际使用的索引
  key_len: 使用到索引字段的长度
  rows: 扫描行的数量
  extra: 执行情况的说明和描述， 包含不适合在其他列中显示但是对执行计划非常重要的信息



--explain extended 展示额外额字段


--show profiles  show profile 可以更加清楚的了解sql的执行过程

--select @@profiling;
--set profilng = 1; //
--show profiles;
show profiles;
+----------+------------+------------------------------+
| Query_ID | Duration   | Query                        |
+----------+------------+------------------------------+
|        1 | 0.00251200 | select count(*) form payment |
|        2 | 0.00831500 | select count(*) from payment |
+----------+------------+------------------------------+
2 rows in set, 1 warning (0.00 sec)

mysql> show profile for query 2;
+----------------------+----------+
| Status               | Duration |
+----------------------+----------+
| starting             | 0.000073 |
| checking permissions | 0.000014 |
| Opening tables       | 0.000022 |
| init                 | 0.002484 |
| System lock          | 0.000050 |
| optimizing           | 0.000011 |
| statistics           | 0.000019 |
| preparing            | 0.000018 |
| executing            | 0.000007 | =====执行语句
| Sending data         | 0.005510 | =====时间大部分都花在这个上面了
| end                  | 0.000027 |
| query end            | 0.000014 |
| closing tables       | 0.000014 |
| freeing items        | 0.000034 |
| cleaning up          | 0.000018 |
+----------------------+----------+
15 rows in set, 1 warning (0.00 sec)


sending data : 状态表示 mysql 线程开始访问数据并把结果返回给客户端，而不仅仅是返回结果给客户端， 
                由于在sending data 的状态下， mysql 线程往往需要做大量的磁盘读取操作，
                所以经常是整个查询中耗时最长的状态


--在获取到最消耗时间的线程状态后， mysql进一步支持选择 all, cpu， block io, context, switch, page faults 等明细类型来查看 mysql 在使用什么资源上消耗了过高的时间
--例如查看 cpu 时间

--show profile cpu for query 2;                


--相同的表 用myisam 引擎试一下

-- craete table payment_myisam like payment;
-- alert table paymengt_myisam engine = myisam;
-- insert into payment_myisam select * from payment;

-- 分析过程如下
mysql> show profile for query 3;
+----------------------+----------+
| Status               | Duration |
+----------------------+----------+
| starting             | 0.000101 |
| checking permissions | 0.000013 |
| Opening tables       | 0.000350 |
| init                 | 0.000022 |
| System lock          | 0.000012 |
| optimizing           | 0.000012 |
| executing            | 0.000013 |  ==== 执行语句
| end                  | 0.000007 |
| query end            | 0.000008 |
| closing tables       | 0.000053 |
| freeing items        | 0.000030 |
| cleaning up          | 0.000038 |
+----------------------+----------+
12 rows in set, 1 warning (0.00 sec)

--可以看到， 
-- myisam 在执行语句后 executing 之后就直接借宿查询，完全不需要访问数据
-- innodb 在count(*) 时经历了 sending data 状态，存在访问数据的过程- 时间消耗在这方面了

--- mysql 5.6之后 可以利用 trace 文件进一步向我们展示了优化器是如何选择执行计划的
---  通过trace 分析优化器是如何选择执行计划的

-- mysql 5.6 之后提供了 trace 这个工具来进一步了解为什么查询优化器 执行A计划 而不执行 B 计划,帮助我们更好的理解优化器的行为
-- 下面来进行这个行为
-- 这是打开， 格式为json, 设置最大内存为 1000000
-- set optimizer_trace="enabled=on", end_markers_in_json=on;  //
-- set optimizer_trace_max_mem_size = 1000000;

--sql 
-- select rental_id from rental where 1=1 and rental_date >= '2005-05-25 04:00:00' and rental_date <= '2005-05-25 05:00:00' and inventory_id=4466;

-- select * from information_schema.optimizer_trace;

--分析过程 查看 mysql-trace-分析过程的文件


--确定问题并采取相应的优化措施
--在 customer.email 字段上建立索引， 结果会理想 
--1	SIMPLE	a		ref	PRIMARY,idx_email	idx_email	153	const	1	100.00	Using index
--1	SIMPLE	b		ref	idx_fk_customer_id	idx_fk_customer_id	2	sakila.a.customer_id	26	100.00	





-- 简单的优化操作
-- 大批量插入数据   用load
-- 大批量插入       使用多个值得插入insert语句， 大大较少服务端和数据库之间的链接， 关闭等消耗， insert into test values (1,1),(2,2),(3,3);
-- 优化 order by 语句
   mysql order by 排序的2种方式
   1： 第一个种通过有序索引顺序扫描直接返回有序数据，这种方式在使用 explain 分析查询的时候，显示为 using index, 不需要额外的排序，操作效率高
   -- explain select customer_id from customer order by store_id;
  mysql> explain select customer_id from customer order by store_id;
+----+-------------+----------+------------+-------+---------------+-----------------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type  | possible_keys | key             | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+-------+---------------+-----------------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | customer | NULL       | index | NULL          | idx_fk_store_id | 1       | NULL |  599 |   100.00 | Using index |
+----+-------------+----------+------------+-------+---------------+-----------------+---------+------+------+----------+-------------+

  2：通过返回数据 进行排序，也就是通常说的 filesort 排序，所有不是通过索引直接返回排序结果的 ，都叫 filesort 排序，
    filesort 并不代表通过磁盘文件进行排序， 而只是说明进行了一个排序操作，至于排序操作是否使用了磁盘文件或者临时表， 取决于 mysql 服务器对排序参数的设置和需要排序数据的大小
  mysql> explain select * from customer order by store_id;
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+----------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra          |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+----------------+
|  1 | SIMPLE      | customer | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  599 |   100.00 | Using filesort |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+----------------+

  filesort 是通过相应的排序算法，将取得的数据在 sort_buffer_size 系统变量设置的内存排序中进行排序， 如果内存装不下，他就会将磁盘的数据进行分块，在对各个数据块进行排序
  然后将各个数据块合并成有序的结果集
  sort_buffer_size 是每个mysql 线程独占的， 所以， 同一个时刻 mysql中存在多个 sort buffer 排序区
  
  --- 了解了 mysql 的排序方式，那么优化目标就清晰了 ： 尽量减少额外的排序， 通过索引直接返回有序数据， 
  --where 和 order by 使用相同的索引 ，并且 orderby 的顺序和索引顺序相同  ， 并且 order by 的字段都是升序 或者 降序 
  -- 否则 肯定需要额外的排序操作，这样就会出现 filesort 



  -- 在不可避免的 filesrot 中， 我们可以加快 filesort排序
    
  两次扫描算法: (two passes)
    先根据条件 取出排序字段和指针信息， 之后再排序去 sort buffer 排序， -- 一次访问 ；sort buffer 不够就在临时表中处理
    排序后，根据指针回表查询数据，  -- 第二次访问
    --总结： 第二次读取操作 可能会导致大量随机 I/0 操作, 优点是排序的时候 内存开销比较小
  一次扫描算法: (single pass)
    一次性取出满足条件的所有字段，然后在排序去 sort buffer 中排序后直接输出结果集， 排序的时候内存开销比较大， 但是排序效率比2次扫描算法高
    
  --总结:  适当加大 sort_buffer_size 排序区， 尽量让排序在内存中完成， 而不是创建临时表放在文件中排序
  --      也不是无限加大 sort_buffer ，因为每个线程独占 sort_buffer , 设置太大 会导致服务器 swap 严重
  --      尽量只使用必要的字段， select 具体的字段名称， 而不是 select * ， 这样会减少排序区的使用， 提高sql性能

  
        
  --优化 group by 
  -- 默认情况下， mysql 对所有的 group col1,col2,col3 的字段进行排序，如果显式包含一个相同列的 order by 子句， 则对mysql 的实际操作没什么影响
  

  --子查询的效率 没有 关联查询 高

  --or 操作， 需要在 or 的每个条件列 都有索引，如果想用到索引的话
  -- sql  select * from tabel where a = 1 or b = 2;
  -- or 分别对  a = 1 ,b =2 查询， 查询出结果在 union 操作，

  -- 优化分页
  -- 一般查询分页的时候， 通过创建 覆盖索引 能够比较好的提高性能， 
  --一个常见而又非常头痛的分页场景， limit 1000,20, 此时 mysql 排序前1020条数据有 仅仅需要返回 1001-1020条记录，前1000 就这么浪费了， 查询和排序非常浪费性能

    思路1：
      在索引上完成排序后的分页操作，最后根据主键关联回原表查询所需要的其他列内容
      eq: explain select a.file_id, a.desc from film a inner join (select film_id from film order by title limit 50,5) b on a.film_id = b.film_id;
      
      

  

