/* ============================================================
   实验二 SQL 查询语言实验
   数据库：pay_lab1（实验内容 1~3） / Education（练习、拓展）

   使用说明：
   1. HeidiSQL 不认 GO，本文件不使用 GO
   2. 每道题单独选中后按 F9 执行，不要整份全选
   3. 视图题（3(1)、3(2)、练习视图）必须单独执行
   4. TODO 后面留空，自己写；写完后把 TODO 改成 已完成
   ============================================================ */

USE pay_lab1;


/* ============================================================
   四、实验内容
   ============================================================ */

/* ---------------- 1. 条件查询 ---------------- */

-- 1(1) 查询 person 表中所有不重复的职称（题目已给语句）
select distinct professor
    from person;


-- 1(2) 查询 person 表中男员工的信息
select *
    from person
    where sex = '男';


-- 1(3) 查询 person 表中 00102 部门的女员工的信息
select *
    from person
    where sex = '女' and deptno = '00102';


-- 1(4) 查询 000001 员工的基本工资增长为 1.5 倍后的实际收入
-- 只放大 Base，奖金和扣除不变，所以不能用 Fact * 1.5
select no, base * 1.5 + bonus - deduct as 实际收入
    from pay
    where no = '000001';


-- 1(5) 查询 00102 部门已发工资的员工的基本信息和工资情况，按实发工资降序排列
-- “已发工资”理解为 pay 表中有该员工的工资记录（Fact 非空）
select p.no, p.name, p.sex, p.professor, p.deptno,
       py.[year], py.[month], py.base, py.bonus, py.deduct, py.fact
    from person as p join pay as py on p.no = py.no
    where p.deptno = '00102' and py.fact is not null
    order by py.fact desc;


-- 1(6) 查询各部门 2005 年实发工资总数（题目已给语句）
select deptno as 部门, sum(fact) as 总额
    from pay, person
    where pay.no = person.no and year = 2005
    group by deptno;


-- 1(7) 查询 2005 年 1 月平均奖金不小于 400 的部门，按平均奖金升序排列
-- 难点：HAVING。先 GROUP BY deptno 求 AVG(bonus)，再用 HAVING 筛分组
-- TODO:


-- 1(8) 查询市场部所有员工姓名和 2005 年 1 月工资明细
-- 三表连接：person -> pay 取工资，person -> dept 取部门名
-- 注：内连接只返回有工资记录的员工；若“所有员工”要求没有工资记录的也列出，改用 LEFT JOIN
select p.name, y.[year], y.[month], y.base, y.bonus, y.deduct, y.fact
    from person as p
         join pay as y on p.no = y.no
         join dept as d on d.deptno = p.deptno
    where d.deptname = '市场部' and y.[year] = 2005 and y.[month] = 1;



/* ---------------- 2. 嵌套查询 ---------------- */

-- 2(1) 查询 2005 年 1 月比同月 000001 员工实发工资高的所有员工的基本信息（题目已给语句）
select *
    from person
    where no in (select no from pay
                 where year = 2005 and month = 1 and
                       fact > (select fact from pay
                               where year = 2005 and month = 1 and no = '000001'
                               )
                 );


-- 2(2) 查询 2005 年 1 月比同月 00103 部门的所有员工实发工资都高的员工基本信息
-- 难点：“比所有…都高”对应 > ALL (子查询)，子查询要拿到 00103 部门 2005-01 的全部 Fact
-- TODO:


-- 2(3) 查询 2005 年 1 月比同月所有员工平均实发工资都高的员工基本信息和工资明细
-- 子查询先求 2005-01 全体平均 Fact，外层再 fact > 该平均值；需要 person 和 pay 两张表的信息
-- TODO:



/* ---------------- 3. 创建视图 ---------------- */

-- 3(1) 在基表 person 上创建员工视图 view_person，
--      包括工号、姓名、性别、职称、部门代码字段（题目已给语句）
Create View dbo.view_person (No, Name, Sex, Professor, DeptNo)
    AS
        Select No, Name, Sex, Professor, DeptNo
        From dbo.person;


-- 3(2) 在基表 person、pay、dept 上创建员工工资视图 view_pay，
--      包括年份、月份、工号、姓名、性别、职称、部门名称、
--      基本工资、奖金、扣除、实发工资字段
-- 思路：先写三表连接查询，Results 对得上之后，再套 Create View ... As
-- TODO:



/* ============================================================
   五、练习（Education 数据库）
   ============================================================ */

USE Education;

-- 练习(1) 检索学分等于 4 的所有课程的课程号和课程名
-- TODO:


-- 练习(2) 检索年龄在 20 和 23 岁之间的学生的学号与姓名
-- TODO:


-- 练习(3) 检索刘晨同学不学的课程的课程号
-- TODO:


-- 练习(4) 检索所有姓刘的学生基本信息
-- TODO:


-- 练习(5) 检索所有选修了课程的学生基本信息和选课情况
-- TODO:


-- 练习(6) 检索所有学生基本信息及其选课情况
-- TODO:


-- 练习(7) 检索成绩为空值的学生姓名和课程名
-- TODO:


-- 练习(8) 统计有学生选修的课程门数
-- TODO:


-- 练习(9) 检索至少选修 3 门课程的学生学号和姓名
-- TODO:


-- 练习(10) 查询选修了课程名为“数据库原理”课程的学生的平均年龄
-- TODO:


-- 练习视图 为“计算机”系创建一个视图：CS_S (sno, sname, cname, grade)
-- TODO:



/* ============================================================
   六、拓展（Education 数据库）
   ============================================================ */

-- 拓展(1) 查询选修人数大于等于 3 的课程的课程名称和学生人数，
--        结果按人数降序排列，若人数相同，按课程名称升序排列
-- TODO:


-- 拓展(2) 查询课程号为“0809023501”课程考试成绩排名为 2-3 名的学生的学号和成绩
-- TODO:
