USE master;
GO
DROP DATABASE IF EXISTS pay_lab1;
GO
DROP DATABASE IF EXISTS Education;
GO
/*shiyan1 说明：
   本机已存在实验八使用的 pay 库，为避免覆盖，实验库命名为 pay_lab1；
      题目原名 pay，本文件中把所有 pay 替换为 pay_lab1 */
/*
   一：创建 / 修改 / 删除数据库
*/
USE master;
GO

-- 1.1 创建 pay_lab1
CREATE DATABASE pay_lab1
    ON
      ( NAME       = pay1,
        FILENAME   = 'C:\Code\Softwares\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\paydata1.mdf',
        SIZE       = 10MB,
        MAXSIZE    = 100MB,
        FILEGROWTH = 5% )
    LOG ON
      ( NAME       = pay3,
        FILENAME   = 'C:\Code\Softwares\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\paylog.ldf',
        SIZE       = 5MB,
        MAXSIZE    = 25MB,
        FILEGROWTH = 10MB )
    COLLATE Chinese_PRC_CI_AS;   -- 保证中文正常存取
GO

-- 1.2 修改数据库：增加第二个数据文件 paydata2.ndf
ALTER DATABASE pay_lab1
    ADD FILE
      ( NAME       = pay2,
        FILENAME   = 'C:\Code\Softwares\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\paydata2.ndf',
        SIZE       = 5MB,
        MAXSIZE    = 20MB,
        FILEGROWTH = 2MB );
GO

-- 1.3 查看数据库信息
EXEC sp_helpdb 'pay_lab1';
GO

-- 1.4 删除数据库（演示用，放在全部实验完成后执行）
-- DROP DATABASE pay_lab1;
-- GO


/*
   二、创建 dept、person、pay 三张表
 */
USE pay_lab1;
GO

-- 表 1-1 dept
CREATE TABLE dbo.dept
    ( DeptNo   VARCHAR(10) NOT NULL
               CONSTRAINT UQ_dept_no UNIQUE,
      DeptName VARCHAR(20) NOT NULL
    );
GO

-- 表 1-2 person
CREATE TABLE dbo.person
    ( No        CHAR(6)     NOT NULL,
      Name      CHAR(10)    NOT NULL,
      Sex       CHAR(2)     NOT NULL,
      Birthday  DATETIME    NULL,
      Professor VARCHAR(12) NULL,
      DeptNo    VARCHAR(10) NOT NULL,
      CONSTRAINT PK_person PRIMARY KEY (No),
      CONSTRAINT FK_person_dept FOREIGN KEY (DeptNo)
                 REFERENCES dbo.dept(DeptNo)
    );
GO

-- 表 1-3 pay
-- Fact 为计算列：实发 = 基本工资 + 奖金 - 扣除
-- 主键声明为 NONCLUSTERED，为步骤 4 的聚簇索引 sort_no 留位置
CREATE TABLE dbo.pay
    ( No      CHAR(6)  NOT NULL,
      [Year]  INT      NOT NULL,
      [Month] INT      NOT NULL,
      Base    DEC(5,1) NULL,
      Bonus   DEC(5,1) NULL,
      Deduct  DEC(5,1) NULL,
      Fact    AS (Base + Bonus - Deduct),
      CONSTRAINT PK_pay PRIMARY KEY NONCLUSTERED (No, [Year], [Month]),
      CONSTRAINT FK_pay_person FOREIGN KEY (No)
                 REFERENCES dbo.person(No)
    );
GO

EXEC sp_help 'dbo.dept';
EXEC sp_help 'dbo.person';
EXEC sp_help 'dbo.pay';
GO


/*
   三、输入数据
   题目要求用集成管理器录入；这里改用 INSERT，便于重复执行和核对。
   Fact 是计算列，INSERT 的列清单里不能出现 Fact。
*/
USE pay_lab1;
GO

INSERT INTO dbo.dept (DeptNo, DeptName) VALUES
    ('00101', '人事部'),
    ('00102', '财务部'),
    ('00103', '市场部');
GO

INSERT INTO dbo.person (No, Name, Sex, Birthday, Professor, DeptNo) VALUES
    ('000001', '李芸', '女', '1974-04-05', '高级', '00102'),
    ('000002', '李鹏', '男', '1965-07-24', '中级', '00102'),
    ('000003', '张华', '男', '1978-02-14', '中级', '00103'),
    ('000004', '罗玮', '男', '1973-09-23', '中级', '00101'),
    ('000005', '章琼', '女', '1964-12-21', '高级', '00101'),
    ('000006', '廖勇', '男', '1985-08-03', '初级', '00103'),
    ('000007', '赵辉', '男', '1980-06-13', '初级', '00103');
GO

INSERT INTO dbo.pay (No, [Year], [Month], Base, Bonus, Deduct) VALUES
    ('000001', 2005, 1,  2800, 500, 203.2),
    ('000002', 2005, 1,  2200, 380, 160.5),
    ('000003', 2005, 1,  2200, 300, 162.5),
    ('000004', 2005, 1,  2200, 300, 162.5),
    ('000005', 2005, 1,  2800, 550, 206.3),
    ('000006', 2005, 1,  1800, 200, 140.1),
    ('000006', 2004, 12, 1800, 100, 120.0);
GO

SELECT * FROM dbo.dept;
SELECT * FROM dbo.person;
SELECT * FROM dbo.pay ORDER BY No, [Year] DESC, [Month];
GO


/*
   四、创建索引
   一张表只能有一个聚簇索引。pay 的主键已声明为
   NONCLUSTERED，因此这里可以再建聚簇索引 sort_no。
*/
USE pay_lab1;
GO

-- (1) person 姓名列上的单列索引
CREATE INDEX sort_name ON dbo.person(Name);
GO

-- (2) pay 年份、月份上的组合索引
CREATE INDEX sort_yearmonth ON dbo.pay([Year], [Month]);
GO

-- (3) dept 部门名称上的唯一索引
CREATE UNIQUE INDEX sort_deptname ON dbo.dept(DeptName);
GO

-- (4) pay 工号上的聚簇索引
CREATE CLUSTERED INDEX sort_no ON dbo.pay(No);
GO

EXEC sp_helpindex 'dbo.person';
EXEC sp_helpindex 'dbo.pay';
EXEC sp_helpindex 'dbo.dept';
GO


/*
   五、删除索引
   注意：DROP INDEX 第一种写法中，索引名前的表名不能省略。
   由 PRIMARY KEY / UNIQUE 约束自动创建的索引不能这样删除。
*/
USE pay_lab1;
GO

DROP INDEX pay.sort_no;
GO

-- 等价写法：
-- DROP INDEX sort_no ON dbo.pay;

SELECT i.name        AS 索引名,
       i.type_desc   AS 索引类型,
       i.is_unique   AS 是否唯一,
       i.is_primary_key AS 是否主键
FROM sys.indexes AS i
WHERE i.object_id = OBJECT_ID('dbo.pay');
GO


/*
   六、练习：Education 数据库 + student / course / sc
   要点：
   1. course.Cpno 是自参照外键，插入时先修课必须先存在。
   2. sc 的主键是 (Sno, Cno) 复合主键，不是单独的 Sno。
   3. student 主键声明为 NONCLUSTERED，才能再建聚簇索引 sort_sdept。
*/
USE master;
GO

CREATE DATABASE Education
    ON
      ( NAME       = Education,
        FILENAME   = 'C:\Code\Softwares\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\Education.mdf',
        SIZE       = 20MB,
        MAXSIZE    = UNLIMITED,
        FILEGROWTH = 10MB )
    LOG ON
      ( NAME       = Education_log,
        FILENAME   = 'C:\Code\Softwares\SQLServer\MSSQL17.MSSQLSERVER\MSSQL\DATA\Education_log.ldf',
        SIZE       = 10MB,
        MAXSIZE    = UNLIMITED,
        FILEGROWTH = 10% )
    COLLATE Chinese_PRC_CI_AS;
GO

USE Education;
GO

-- 表 1-7 student
CREATE TABLE dbo.student
    ( Sno     CHAR(9)  NOT NULL,
      Sname   CHAR(20) NOT NULL,
      Ssex    CHAR(2)  NULL
              CONSTRAINT CK_student_sex CHECK (Ssex IN ('男', '女')),
      Sage    SMALLINT NULL
              CONSTRAINT DF_student_sage DEFAULT 18,
      Sdept   CHAR(30) NULL,
      CONSTRAINT PK_student PRIMARY KEY NONCLUSTERED (Sno)
    );
GO

-- 表 1-8 course
CREATE TABLE dbo.course
    ( Cno     CHAR(10) NOT NULL,
      Cname   CHAR(40) NOT NULL,
      Cpno    CHAR(10) NULL,
      Ccredit DEC(3,1) NULL
              CONSTRAINT DF_course_credit DEFAULT 1.0,
      CONSTRAINT PK_course PRIMARY KEY (Cno),
      CONSTRAINT UQ_course_cname UNIQUE (Cname),
      CONSTRAINT FK_course_cpno FOREIGN KEY (Cpno)
                 REFERENCES dbo.course(Cno)
    );
GO

-- 表 1-9 sc
CREATE TABLE dbo.sc
    ( Sno   CHAR(9)  NOT NULL,
      Cno   CHAR(10) NOT NULL,
      Grade DEC(4,1) NULL,
      CONSTRAINT PK_sc PRIMARY KEY (Sno, Cno),
      CONSTRAINT FK_sc_student FOREIGN KEY (Sno)
                 REFERENCES dbo.student(Sno),
      CONSTRAINT FK_sc_course FOREIGN KEY (Cno)
                 REFERENCES dbo.course(Cno)
    );
GO

-- 表 1-10 student 数据
INSERT INTO dbo.student (Sno, Sname, Ssex, Sage, Sdept) VALUES
    ('202131401', '李勇', '男', 20, '计算机'),
    ('202131402', '刘晨', '女', 19, '计算机'),
    ('205151201', '王敏', '女', 18, '电力'),
    ('205151204', '刘力', '男', 21, '电力'),
    ('206130228', '张民', '男', 20, '数学');
GO

-- 表 1-11 course 数据（先插没有先修课的课程）
INSERT INTO dbo.course (Cno, Cname, Cpno, Ccredit) VALUES
    ('0809102001', '大学计算机基础', NULL,         2),
    ('0809023501', '数据结构',       '0809102001', 4),
    ('0809023506', '数据库原理',     '0809023501', 4),
    ('0712302021', '模拟电子技术',   '0809102001', 3.5),
    ('0501202002', '《红楼梦》欣赏', NULL,         2);
GO

-- 表 1-12 sc 数据
INSERT INTO dbo.sc (Sno, Cno, Grade) VALUES
    ('202131401', '0809102001', 90),
    ('202131401', '0809023501', 65),
    ('202131401', '0809023506', 60),
    ('202131402', '0809102001', 85),
    ('202131402', '0809023501', 70),
    ('202131402', '0809023506', 50),
    ('205151201', '0809023501', NULL),
    ('205151201', '0501202002', 75),
    ('205151204', '0809102001', 80),
    ('205151204', '0809023501', 0);
GO

-- 练习 4：在 student 的院系列上创建聚簇索引
CREATE CLUSTERED INDEX sort_sdept ON dbo.student(Sdept);
GO

SELECT * FROM dbo.student;
SELECT * FROM dbo.course;
SELECT * FROM dbo.sc ORDER BY Sno, Cno;
EXEC sp_helpindex 'dbo.student';
GO
