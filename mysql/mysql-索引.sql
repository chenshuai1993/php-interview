-- mysql 索引知识分析

-- mysql 索引的分类、存储、使用方法

-- 索引分类
    -- B-Tree索引：最常见的索引，大部分引擎都支持B树索引
    -- HASH索引：只有memory 支持，使用场景简单
    -- R-tree索引：（空间索引）地理位置信息
    -- Full-text索引: myisam的一个特殊的索引类型，全文索引，   innodb从mysql 5.6之后开始支持全文索引
    -- 没有函数所以，有前缀索引


    索引        myisam      innodb      memory
    b-tree      支持        支持         支持
    hash        不支持      不支持        支持
    r-tree      支持        不支持        不支持
    full-text   支持        >5.6支持     不支持


--hash 索引比b-tree 快，但是不支持 范围查询，> < 

-- 重点是b-tree b== blanced 平衡树


--mysql 中能够使用索引的典型场景

1:匹配全值（match the full value）
    对索引中的列都指定具体值，即是对索引中的所有列都有等值匹配的条件
    eq: 联合索引 idx_abc （a,b,c）
    select * from table where a=1 and b=2 and c=3
    explain:
        type：const
        key： idx_abc
        extra: 

2:匹配值得范围 ( match a range of values)
    对索引的值能够进行范围查询
    eq: 主键 id 
    select * from table where id > 10 and id < 20 ;
    explain:
        type: range
        key: id 
        extra: using where  --表示 优化器除了利用索引加速访问之外，还需要根据索引会表查询数据
        

3:  匹配最左原则 (match a leftmost prefix) 
    仅仅使用索引中的最左列进行查找
    eq: 联合索引 idx_abc (a,b,c) == (a) (a,b) (a,b,c) 
    
    select * from table where a = 1 and c = 3; //这个根据最左原则用使用这个联合索引 （a）
    eq: 联合索引 (a,b,c)
    explain:
        type:ref
        ref:const
        extra: using where --表示 优化器出来利用索引加速访问之外，还需要根据索引回表查询数据

    最左匹配原则: 是 mysql 

4： 仅仅对索引进行查询 （index only query）
    当查询的列都在索引的字段中，查询的效率更高；
    eq: 对用户的手机号进行唯一索引  un_idx UNIQUE(mobile)
    select moblie from table where moblie = 'xxx';
    explain：
        type:ref
        ref: const,
        extra： using index -- 意味着现在直接范文索引就足够获取所需要的数据，不需要通过索引回表，

        -- using index 也就是说覆盖索引扫描，只访问必须访问的数据，在一般情况下，减少不必要的数据访问能提升效率

5： 匹配列前缀（match a column prefix）
    仅仅使用索引中的第一列，并且只包含索引第一列的开头一部分进行查找
    现在查询出标题是以 abc 开头的电影信息，从执行计划来看，用到了索引
    create index idx_title_desc on film_text(titile(10),desc(20));
    explain：
        type；range
        key：idx_title_desc
        extra: using where   -- 表示需要遍历玩索引之后，需要回表查询数据

6： 能够实现索引匹配部分精确 而其他部分进行范围查询 （macth ont part exactly and match a range on another part）
    eq： 找出出租日期 rantal_data 为指定日期，客户编号 cusromer_id为指定范围的库存
    explain select incentory_id from rental where rental_data="2006-02-14 15:16:03" and customer_id >300 and customer_id < 400;
    explain:
        type：ref --表示非唯一索引 或者 唯一索引的前缀索引        
        ref：const --常数级别的数据
        extra: using where;using index 询优化器使用索引 index 帮助查询， 同时由于只查询 incentory_id 字段，所有extra 能看到using index， 表示使用了覆盖索引扫描

7： 如果列名是 索引列，那么使用 column_name is null 会使用索引
    eq: explain seelct * from payment where rental_id is null; 
    explain:
        type:ref
        ref：const
        extra: using where 
        
8:  mysql 5.6 引入了 index condition pushdown (icp) 的特性， 进一步优化了查询，pushdown 表示操作下放， 某些情况下 条件过滤可以下方到存储引擎
    -- icp 这个很重要  百度一下
    -- explain select * from rental where rental_date = '2006-02-14 15:16:03' and customer_id >=300 and customer_id < 400;
    -- mysql 5.1/5.5 的执行计划
    explain:
        type:ref
        key: inx_rental_data
        ref:const
        extra: using where 
    -- 执行计划表明，优化器首先使用复合索引 inx_rantal_data 的首选字段 rental_data 过滤出符合条件 rental_data='2006-02-14 15:16:03' 的记录，
    -- 执行计划中的key  inx_rental_data ，然后根据 复合索引 index_rantal_date 会表查询记录后， 最终根据条件 customer_id >=300 and customer_id < 400
    -- 过滤出最后的查询结果，（执行计划中 extra 字段值显示为 using where）

    -- 此处有个图

    -- mysql 5.6 的执行计划
    +----+-------------+--------+------------+------+--------------------------------+-------------+---------+-------+------+----------+-----------------------+
| id | select_type | table  | partitions | type | possible_keys                  | key         | key_len | ref   | rows | filtered | Extra                 |
+----+-------------+--------+------------+------+--------------------------------+-------------+---------+-------+------+----------+-----------------------+
|  1 | SIMPLE      | rental | NULL       | ref  | rental_date,idx_fk_customer_id | rental_date | 5       | const |  182 |    16.68 | Using index condition |
+----+-------------+--------+------------+------+--------------------------------+-------------+---------+-------+------+----------+-----------------------+
    explain:
        type：ref
        key:rental_date
        ref:rental_date
        extra: using idnex condition
    -- using index condition 表示 mysql 使用了 ICP来 进一步 优化查询， 在检索的时候，把条件 customer_id 的过滤操作下推到存储引擎层来完成，
    -- 这样能够降低不必要的 I0 访问，
    -- 此处有个图

    


-------------------------------------------

-- 存在索引但不能使用索引的典型场景
-- 有些时候 虽然有索引，但是并不能被查询优化器选择使用，下面是例子

1：以 % 开头的like查询不能够使用B-Tree 的索引，执行计划中 key 显示为 null
    eq: select * from actor where last_name like '%ni%';
    explain：
        type: all  -- 表示全表扫描
        key: NULL  -- 表示没用到索引
        extra: using where  -- where 
    -- 因为B-tree的结构， 索引 % 开头的根本无法使用索引，
    -- 替代方案为 全文索引，myisam  或者 mysql>5.6 ninodb 才支持
    -- 因为 innodb 是 聚簇结构（敲黑板 划重点，记得百度）的特点，采取一种轻量级的方式，

    -- 思路： 一般情况下 索引都会比表小， 扫描索引要比扫描表更快，而且 innodb 表上的耳机索引 idx_last_name 实际上存储的字段 last_name 还有 actor_id 
    -- 那么理想的访问方式是 首先扫描耳机索引 idx_last_name 或者满足条件 last_name like '%an%' 的主键 actor_id, 之后根据主键回表去检索记录
    -- 这样就避开了全表扫描actor 产生大量的 IO
    
    mysql> explain select * from actor where last_name like '%NI%';
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | actor | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  200 |    11.11 | Using where |
+----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0.02 sec)

mysql> explain select * from (select actor_id from actor where last_name like '%NI%') a, actor b where a.actor_id = b.actor_id;
+----+-------------+-------+------------+--------+---------------+---------------------+---------+-----------------------+------+----------+--------------------------+
| id | select_type | table | partitions | type   | possible_keys | key                 | key_len | ref                   | rows | filtered | Extra                    |
+----+-------------+-------+------------+--------+---------------+---------------------+---------+-----------------------+------+----------+--------------------------+
|  1 | SIMPLE      | actor | NULL       | index  | PRIMARY       | idx_actor_last_name | 137     | NULL                  |  200 |    11.11 | Using where; Using index |
|  1 | SIMPLE      | b     | NULL       | eq_ref | PRIMARY       | PRIMARY             | 2       | sakila.actor.actor_id |    1 |   100.00 | NULL                     |
+----+-------------+-------+------------+--------+---------------+---------------------+---------+-----------------------+------+----------+--------------------------+
    
    -- 优化后的查询  使用了使用覆盖扫描， 然后通过主键join 去演员表中获取数据， 理论上会比全表扫描快

    -- 敲黑板，show profile 即将弃用 | Warning | 1287 | 'SHOW PROFILE' is deprecated and will be removed in a future release. Please use Performance Schema instead

            
2：数据类型出现隐式转换的时候也不会使用索引， 特别是当前列是 字符串类型， 那么一定要 where 条件中 把字符串用 ‘’ 引起来，
    eq: last_name 字符串类型  并且有索引
    --select * from actor where last_name = 1;   不会用到索引
    --select * from actor where last_name = ‘1’;   会用到索引

3：复合索引 如果不符合最左原则，那么用不到索引  
    --idx  （a,b,c）  == (a),(a,b),(a,b,c) 
    --(b,c) 是用不到索引的

4：如果mysql 估计使用索引比全表扫描更慢，那么久不会用索引，  
    --可以使用查询优化器分析过程
    -- 可以使用trace 查看分析过程

5:  用 or 关键字分割的条件，如果 or 前的条件有索引，但是 or 后的条件没有索引， 那么涉及到的索引不用被使用
    --  explain select * from payment where customer_id = 203 or amout = 3.96;
    mysql> explain select * from payment where customer_id = 203 or amount = 3.96;
+----+-------------+---------+------------+------+--------------------+------+---------+------+-------+----------+-------------+
| id | select_type | table   | partitions | type | possible_keys      | key  | key_len | ref  | rows  | filtered | Extra       |
+----+-------------+---------+------------+------+--------------------+------+---------+------+-------+----------+-------------+
|  1 | SIMPLE      | payment | NULL       | ALL  | idx_fk_customer_id | NULL | NULL    | NULL | 16086 |    10.15 | Using where |
+----+-------------+---------+------------+------+--------------------+------+---------+------+-------+----------+-------------+
    -- 分析
    -- 因为 OR 后面的条件没有索引，那么后面的查询肯定要走全表扫描，在存在全表扫描的情况下，就没有必要再多一次索引查扫描来增加 I/0访问，一次全表扫描就够了




------------------------
查看索引使用情况

-- show status like 'Handler_read%';
+-----------------------+-------+
| Variable_name         | Value |
+-----------------------+-------+
| Handler_read_first    | 3     |
| Handler_read_key      | 4     |
| Handler_read_last     | 0     |
| Handler_read_next     | 16059 |
| Handler_read_prev     | 0     |
| Handler_read_rnd      | 0     |
| Handler_read_rnd_next | 1167  |
+-----------------------+-------+



-- 简单的优化方法
1：定期分析表 和 检查表
2：定期优化表
    