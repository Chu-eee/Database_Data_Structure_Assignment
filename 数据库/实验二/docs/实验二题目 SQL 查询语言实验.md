
**一、实验目的**
掌握各种形式的查询语句，加深对 SQL 查询语句的理解。

**二、实验环境**
硬件：PC 机
软件：SQL Server 2019 及以上

**三、实验原理**
1. SQL-92 查询命令
语法：
$$
\begin{aligned}
&\text{Select [All | Distinct] <目标列表达式> [,...n]} \\
&\text{From <表名或视图名> [,...n]} \\
&\text{[Where <条件表达式>]} \\
&\text{[Group By <分组表达式> [Having <条件表达式>] ]} \\
&\text{[Order By <排序表达式> [ASC | DESC]]}
\end{aligned}
$$

2. T-SQL 查询命令
从数据库中检索行，并允许从一个或多个表中选择一个或多个行或列。
(1) 基本语法
$$
\begin{aligned}
&\text{SELECT 查询列表} \\
&\text{[ INTO 新表名 ]} \\
&\text{FROM <源表>} \\
&\text{[ WHERE 条件表达式 ]} \\
&\text{[ GROUP BY 分组表达式} \\
&\text{  [HAVING 组内数据条件表达式 ] ]} \\
&\text{[ ORDER BY 排序表达式 [ASC | DESC] ]}
\end{aligned}
$$
可以在查询之间使用 UNION 等运算符，以将查询的结果组合成单个结果集。

(2) SELECT 子句
指定由查询返回的列。
语法：
$$
\begin{aligned}
&\text{SELECT [ALL | DISTINCT]} \\
&\text{  [TOP n [PERCENT] [WITH TIES] ]} \\
&\text{  <select\_list>}
\end{aligned}
$$

$$
\begin{aligned}
&\text{<select\_list> ::=} \\
&\text{  \{ *} \\
&\text{  | \{ 表名 | 视图名 | 表别名 \}.*} \\
&\text{  | \{ 列名 | 表达式 | \$IDENTITY | \$ROWGUID \} [[AS] 列别名]} \\
&\text{  | 列别名 = 表达式} \\
&\text{  \} [,...n]}
\end{aligned}
$$

(3) INTO 子句
创建新表并将结果行从查询插入新表中。
语法：
`[INTO 新表名]`
说明：
用户若要执行带 INTO 子句的 SELECT 语句，必须在目的数据库内具有 CREATE TABLE 权限。
通过在 WHERE 子句中包含 FALSE 条件，可以使用 SELECT...INTO 创建没有数据的相同表定义。

(4) FROM 子句
指定从中检索行的表。需要 FROM 子句，除非选择列表只包含常量、变量和算术表达式。
语法：
$$
\begin{aligned}
&\text{FROM \{<源表>\} [,...n]} \\
&\text{<源表> ::=} \\
&\text{  表名 [[AS] 别名] [WITH(<表更新选项>[,...n])]} \\
&\text{  | 视图名 [[AS] 别名]} \\
&\text{  | 派生表 [[AS] 别名] [(列名[,...n])]} \\
&\text{  | 行集函数 [[AS] 别名] [(列名[,...n])]} \\
&\text{  | 表值函数 [[AS] 别名]}
\end{aligned}
$$

$$
\begin{aligned}
&\text{<表连接> ::=} \\
&\text{  <源表1> <连接类型> <源表2> ON <条件表达式>} \\
&\text{  | <源表1> CROSS JOIN <源表2>} \\
&\text{  | (<表连接>)}
\end{aligned}
$$

$$
\begin{aligned}
&\text{<连接类型> ::=} \\
&\text{  [INNER | \{ \{LEFT | RIGHT | FULL \} [OUTER] \} ] JOIN}
\end{aligned}
$$

(5) WHERE 子句
指定用于限制返回的行的搜索条件。
语法：
`[ WHERE <条件表达式> ]`
条件表达式中，可以使用各种比较运算符，如 `>`、`<`、`>=`、`<=`、`=`、`!=` 等关系运算符、“AND、OR、NOT”等逻辑运算符、“LIKE、NOT LIKE、IN、NOT IN、Between...and...、Not Between...and...、IS NULL、IS NOT NULL、SOME|ANY、ALL、EXISTS、NOT EXISTS”等特殊运算符。

(5) 聚集函数
用于对数据集合进行统计，如求总和、平均值、最大值、最小值和行数等。一般在 SELECT 子句、HAVING 子句和 ORDER BY 子句中。

| 函数形式 | 函数功能 |
| :--- | :--- |
| COUNT (DISTINCT \| ALL 表达式) | 返回非空表达式值的行数 |
| COUNT (*) | 返回结果的行数，含 NULL 值和重复值 |
| MAX (DISTINCT \| ALL 表达式) | 返回非空表达式值的最大值 |
| MIN (DISTINCT \| ALL 表达式) | 返回非空表达式值的最小值 |
| SUM (DISTINCT \| ALL 表达式) | 返回非空表达式值的总和 |
| AVG (DISTINCT \| ALL 表达式) | 返回非空表达式值的平均值 |

(6) GROUP BY 子句和 HAVING 子句
GROUP BY 子句，用于对查询的结果数据集合进行分组或分组统计，如对各个分组求总和、最大值、最小值、平均值、行数等。一般与聚集函数一起使用。
HAVING 子句，用于对分组数据集合再筛选。与 GROUP BY 子句一起使用。
语法：
$$
\begin{aligned}
&\text{[ GROUP BY 分组表达式 [,...n]} \\
&\text{  [HAVING 组内数据条件表达式 ]} \\
&\text{]}
\end{aligned}
$$
注意：指定 GROUP BY 时，选择列表中任一非聚集表达式内的所有列都应包含在 GROUP BY 列表中。

(7) ORDER BY 子句
指定结果集的排序。
语法：
$$
\text{[ ORDER BY \{排序表达式 [ASC | DESC]\} [,...n] ]}
$$
注意：除非同时指定了 TOP，否则 ORDER BY 子句在视图、内嵌函数、派生表和子查询中无效。

3. 创建视图
创建一个虚拟表，该表以另一种方式表示一个或多个表中的数据。
语法：
$$
\begin{aligned}
&\text{Create View [模式名.] 视图名 [(列名 [,...n])]} \\
&\text{  AS} \\
&\text{    SQL 查询语句} \\
&\text{  [WITH CHECK OPTION]}
\end{aligned}
$$

4. 删除视图
从当前数据库中删除一个或多个视图。
语法：
`Drop View [模式名.] 视图名 [,...n]`


**四、实验内容**
1. 利用 SQL 语句条件查询
要求：
(1) 查询 person 表中所有不重复的职称。
语句：
```sql
select distinct professor
    from person
```
(2) 查询 person 表中男员工的信息。
(3) 查询 person 表中 00102 部门的女员工的信息。
(4) 查询 000001 员工的基本工资增长为 1.5 倍后实际收入。
(5) 查询 00102 部门已发工资的员工的基本信息和工资情况，按实发工资降序排列。
(6) 查询各部门 2005 年实发工资总数。
语句：
```sql
select deptno  as  部门, sum(fact)  as  总额
    from pay,person
    where pay.no=person.no and year=2005
    group by deptno
```
(7) 查询 2005 年 1 月平均奖金不小于 400 的部门，按平均奖金升序排列。
(8) 查询市场部所有员工姓名和 2005 年 1 月工资明细。

2. 利用 SQL 语句嵌套查询
要求：
(1) 查询 2005 年 1 月比同月 000001 员工实发工资高的所有员工的基本信息。
语句：
```sql
select *
    from person
    where no in (select no from pay
                 where year=2005 and month=1 and
                       fact > (select fact from pay
                               where year=2005 and month=1 and no='000001'
                               )
                 )
```
(2) 查询 2005 年 1 月比同月 00103 部门的所有员工实发工资都高的员工基本信息。
(3) 查询 2005 年 1 月比同月所有员工平均实发工资都高的员工基本信息和工资明细。

3. 利用 SQL 语句创建视图
要求：
(1) 在基表 person 基础上创建员工视图 view_person，其中包括工号、姓名、性别、职称、部门代码字段。
语句：
```sql
Create View dbo.view_person (No, Name, Sex, Professor, DeptNo)
    AS
        Select No, Name, Sex, Professor, DeptNo
        From dbo.person
```
(2) 在基表 person、pay、dept 基础上创建员工工资视图 view_pay，其中包括年份、月份、工号、姓名、性别、职称、部门名称、基本工资、奖金、扣除、实发工资字段。

**五、练习**
对 Education 数据库进行以下查询操作：
(1) 检索学分等于 4 的所有课程的课程号和课程名。
(2) 检索年龄在 20 和 23 岁之间的学生的学号与姓名。
(3) 检索刘晨同学不学的课程的课程号。
(4) 检索所有姓刘的学生基本信息。
(5) 检索所有选修了课程的学生基本信息和选课情况。
(6) 检索所有学生基本信息及其选课情况。
(7) 检索成绩为空值的学生姓名和课程名。
(8) 统计有学生选修的课程门数。
(9) 检索至少选修 3 门课程的学生学号和姓名。
(10) 查询选修了课程名为“数据库原理”课程的学生的平均年龄。

(1) 为“计算机”系创建一个视图：`CS_S (sno, sname, cname, grade)`。

**六、拓展**
试对 Education 数据库进行以下查询操作：
(1) 查询选修人数大于等于 3 的课程的课程名称和学生人数。查询结果按人数降序排列，若人数相同，按课程名称升序排列。
(2) 查询课程号为“0809023501”课程考试成绩排名为 2-3 名的学生的学号和成绩。