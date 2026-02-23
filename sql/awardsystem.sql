/*
Navicat MySQL Data Transfer

Source Server         : localhost_3306
Source Server Version : 80044
Source Host           : localhost:3306
Source Database       : awardsystem

Target Server Type    : MYSQL
Target Server Version : 80044
File Encoding         : 65001

Date: 2026-02-10 19:57:01
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `application_file`
-- ----------------------------
DROP TABLE IF EXISTS `application_file`;
CREATE TABLE `application_file` (
  `file_id` int NOT NULL AUTO_INCREMENT COMMENT '文件ID（主键）',
  `application_id` int NOT NULL COMMENT '关联奖项申请表ID',
  `file_name` varchar(255) NOT NULL COMMENT '文件原始名称（如获奖证书.pdf）',
  `file_path` varchar(512) NOT NULL COMMENT '文件存储路径（服务器/OSS路径）',
  `file_type` varchar(50) NOT NULL COMMENT '文件类型（如pdf/jpg/png/docx）',
  `file_size` int NOT NULL COMMENT '文件大小（单位：字节）',
  `upload_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '文件上传时间',
  PRIMARY KEY (`file_id`),
  KEY `idx_application_id` (`application_id`),
  CONSTRAINT `application_file_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `award_application` (`application_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='奖项申请的资料证明文件表（支持多文件）';

-- ----------------------------
-- Records of application_file
-- ----------------------------
INSERT INTO `application_file` VALUES ('6', '4', '3.Mysql使用指南.pdf', 'E:\\IDEAJavakaifa\\Award\\SAIMS/uploads/applications/4/47b3a41d-fab3-458e-9d46-28cb81f245ce.pdf', '.pdf', '1505274', '2026-02-10 15:32:00');
INSERT INTO `application_file` VALUES ('7', '5', 'bug.jpg', 'E:\\IDEAJavakaifa\\Award\\SAIMS/uploads/applications/5/9c494cdb-d363-4a99-b162-6ad0394fb1c4.jpg', '.jpg', '500972', '2026-02-10 15:34:42');
INSERT INTO `application_file` VALUES ('8', '5', 'bug集成.docx', 'E:\\IDEAJavakaifa\\Award\\SAIMS/uploads/applications/5/62deb2d0-d888-49fb-b3c2-af5edbf1ff7d.docx', '.docx', '62101', '2026-02-10 15:34:42');

-- ----------------------------
-- Table structure for `application_teacher`
-- ----------------------------
DROP TABLE IF EXISTS `application_teacher`;
CREATE TABLE `application_teacher` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '关联ID（主键）',
  `teacher_name` varchar(50) NOT NULL COMMENT '指导老师姓名（与mentor表无关）',
  `teacher_department` varchar(50) NOT NULL DEFAULT '' COMMENT '指导老师所在学院（与mentor表无关）',
  `teacher_no` varchar(20) NOT NULL DEFAULT '' COMMENT '指导老师工号（与mentor表无关）',
  `application_id` int NOT NULL COMMENT '关联申请表ID',
  PRIMARY KEY (`id`),
  KEY `application_id` (`application_id`),
  CONSTRAINT `application_teacher_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `award_application` (`application_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='申请的指导老师关联表（支持多个指导老师，与mentor表无关）';

-- ----------------------------
-- Records of application_teacher
-- ----------------------------
INSERT INTO `application_teacher` VALUES ('4', '魏邱霞', '生物医学工程学院', '12345678', '4');
INSERT INTO `application_teacher` VALUES ('5', '成波', '生物医学工程学院', '12365498', '5');
INSERT INTO `application_teacher` VALUES ('6', '罗媛媛', '生物医学工程学院', '9874562', '5');

-- ----------------------------
-- Table structure for `award_application`
-- ----------------------------
DROP TABLE IF EXISTS `award_application`;
CREATE TABLE `award_application` (
  `application_id` int NOT NULL AUTO_INCREMENT COMMENT '申请ID（主键）',
  `competition_id` int NOT NULL COMMENT '关联竞赛表ID',
  `team_id` int DEFAULT NULL COMMENT '关联团队ID（团队申请时非空，个人申请时为NULL）',
  `student_id` int NOT NULL COMMENT '申请人ID（关联学生表）',
  `project_name` varchar(100) NOT NULL COMMENT '项目名称（获奖项目的具体名称）',
  `award_quantity` int NOT NULL DEFAULT '1' COMMENT '获奖数量（学生无需填写，导师统计维护，团体赛默认1）',
  `award_person_count` int NOT NULL DEFAULT '0' COMMENT '获奖人数（学生无需填写，按团队成员数自动统计/导师复核）',
  `contact` varchar(50) NOT NULL COMMENT '负责人联系方式',
  `competition_level` varchar(20) NOT NULL COMMENT '竞赛级别',
  `award_rank` varchar(20) NOT NULL COMMENT '获奖等次（A/B/C/D）',
  `award_level` varchar(20) NOT NULL COMMENT '获奖等级（如一等奖/金奖）',
  `award_time` date NOT NULL COMMENT '获奖时间',
  `application_status` varchar(50) NOT NULL COMMENT '申请状态（pending-待审核, approved-已通过, rejected-已拒绝, returned-已打回）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请提交时间',
  `application_number` varchar(20) DEFAULT NULL COMMENT '申请编号（格式：SJ+日期，如SJ20251129）',
  PRIMARY KEY (`application_id`),
  UNIQUE KEY `application_number` (`application_number`),
  KEY `competition_id` (`competition_id`),
  KEY `team_id` (`team_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `award_application_ibfk_1` FOREIGN KEY (`competition_id`) REFERENCES `competition` (`competition_id`) ON DELETE CASCADE,
  CONSTRAINT `award_application_ibfk_2` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE SET NULL,
  CONSTRAINT `award_application_ibfk_3` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_application_status` CHECK ((`application_status` in (_utf8mb3'pending',_utf8mb3'approved',_utf8mb3'rejected',_utf8mb3'returned')))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='奖项申请表（含项目名称，支持团队/个人申请）';

-- ----------------------------
-- Records of award_application
-- ----------------------------
INSERT INTO `award_application` VALUES ('4', '12', null, '1', '无', '1', '1', '17865445632', '校级', '二等奖', 'B', '2026-02-04', 'rejected', '2026-02-10 15:32:00', 'AP202602100700');
INSERT INTO `award_application` VALUES ('5', '6', '2', '1', '智能小车', '1', '2', '17865988988', '国家级', '二等奖', 'B', '2026-02-06', 'pending', '2026-02-10 15:34:42', 'AP202602106994');

-- ----------------------------
-- Table structure for `competition`
-- ----------------------------
DROP TABLE IF EXISTS `competition`;
CREATE TABLE `competition` (
  `competition_id` int NOT NULL AUTO_INCREMENT COMMENT '竞赛ID（主键）',
  `competition_name` varchar(50) NOT NULL COMMENT '竞赛名称',
  `award_rank` varchar(100) NOT NULL COMMENT '获奖等次（A/B/C/D）',
  PRIMARY KEY (`competition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=343 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='竞赛信息表';

-- ----------------------------
-- Records of competition
-- ----------------------------
INSERT INTO `competition` VALUES ('1', '“挑战杯”全国大学生课外学术科技作品竞赛', 'A');
INSERT INTO `competition` VALUES ('2', '“挑战杯”中国大学生创业计划大赛', 'A');
INSERT INTO `competition` VALUES ('3', '全国大学生创新创业训练计划年会展示', 'A');
INSERT INTO `competition` VALUES ('4', 'ACM-ICPC国际大学生程序设计竞赛', 'B');
INSERT INTO `competition` VALUES ('5', '全国大学生数学建模竞赛', 'B');
INSERT INTO `competition` VALUES ('6', '全国大学生电子设计竞赛', 'B');
INSERT INTO `competition` VALUES ('7', '全国大学生机械创新设计大赛', 'B');
INSERT INTO `competition` VALUES ('8', '全国大学生广告艺术大赛', 'B');
INSERT INTO `competition` VALUES ('9', '全国大学生智能汽车竞赛', 'B');
INSERT INTO `competition` VALUES ('10', '全国大学生电子商务“创新、创意及创业”挑战赛', 'B');
INSERT INTO `competition` VALUES ('11', '中国大学生工程实践与创新能力大赛', 'B');
INSERT INTO `competition` VALUES ('12', '外研社·国才杯全国大学生外语能力大赛系列赛事 （英语组、多语种组、国际中文组）', 'B');
INSERT INTO `competition` VALUES ('13', '全国大学生化工设计竞赛', 'B');
INSERT INTO `competition` VALUES ('14', '全国大学生市场调查与分析大赛', 'B');
INSERT INTO `competition` VALUES ('15', '中国大学生计算机设计大赛', 'B');
INSERT INTO `competition` VALUES ('16', '未来设计师·全国高校数字艺术设计大赛（含未来设计师·国际创新设计大赛）', 'B');
INSERT INTO `competition` VALUES ('17', '全国大学生生命科学竞赛（CULSC）', 'B');
INSERT INTO `competition` VALUES ('18', '“学创杯”全国大学生创业综合模拟大赛', 'B');
INSERT INTO `competition` VALUES ('19', '全国大学生节能减排社会实践与科技竞赛', 'B');
INSERT INTO `competition` VALUES ('20', 'iCAN大学生创新创业大赛', 'B');
INSERT INTO `competition` VALUES ('21', '中华经典诵写讲大赛', 'B');
INSERT INTO `competition` VALUES ('22', '全国大学生统计建模大赛', 'B');
INSERT INTO `competition` VALUES ('23', '“华为杯”中国研究生数学建模竞赛', 'B');
INSERT INTO `competition` VALUES ('24', '研究生“文化中国”两创大赛', 'B');
INSERT INTO `competition` VALUES ('25', '全国大学生结构设计竞赛', 'C');
INSERT INTO `competition` VALUES ('26', '全国大学生物流设计大赛', 'C');
INSERT INTO `competition` VALUES ('27', '两岸新锐设计竞赛·华灿奖', 'C');
INSERT INTO `competition` VALUES ('28', '全国大学生机器人大赛(CURC)（原全国大学生机器人大赛①RoboMaster、②RoboCon）', 'C');
INSERT INTO `competition` VALUES ('29', '全国大学生先进成图技术与产品信息建模创新大赛', 'C');
INSERT INTO `competition` VALUES ('30', '全国三维数字化创新设计大赛', 'C');
INSERT INTO `competition` VALUES ('31', '“西门子杯”中国智能制造挑战赛', 'C');
INSERT INTO `competition` VALUES ('32', '中国大学生服务外包创新创业大赛', 'C');
INSERT INTO `competition` VALUES ('33', '“蓝桥杯”全国软件和信息技术专业人才大赛', 'C');
INSERT INTO `competition` VALUES ('34', '米兰设计周-中国高校设计学科师生优秀作品展', 'C');
INSERT INTO `competition` VALUES ('35', '全国大学生地质技能竞赛', 'C');
INSERT INTO `competition` VALUES ('36', '全国大学生光电设计竞赛', 'C');
INSERT INTO `competition` VALUES ('37', '全国大学生集成电路创新创业大赛', 'C');
INSERT INTO `competition` VALUES ('38', '全国大学生金相技能大赛', 'C');
INSERT INTO `competition` VALUES ('39', '全国大学生信息安全竞赛', 'C');
INSERT INTO `competition` VALUES ('40', '全国周培源大学生力学竞赛', 'C');
INSERT INTO `competition` VALUES ('41', '中国大学生机械工程创新创意大赛', 'C');
INSERT INTO `competition` VALUES ('42', '中国机器人大赛暨RoboCup机器人世界杯中国赛', 'C');
INSERT INTO `competition` VALUES ('43', '“中国软件杯”大学生软件设计大赛', 'C');
INSERT INTO `competition` VALUES ('44', '中美青年创客大赛', 'C');
INSERT INTO `competition` VALUES ('45', '睿抗机器人开发者大赛 (RAICOM)', 'C');
INSERT INTO `competition` VALUES ('46', '“大唐杯”全国大学生新一代信息通信技术大赛', 'C');
INSERT INTO `competition` VALUES ('47', '华为ICT大赛', 'C');
INSERT INTO `competition` VALUES ('48', '全国大学生嵌入式芯片与系统设计竞赛', 'C');
INSERT INTO `competition` VALUES ('49', '全国大学生物理实验竞赛', 'C');
INSERT INTO `competition` VALUES ('50', '全国高校BIM毕业设计创新大赛', 'C');
INSERT INTO `competition` VALUES ('51', '中国高校智能机器人创意大赛', 'C');
INSERT INTO `competition` VALUES ('52', '中国好创意暨全国数字艺术设计大赛', 'C');
INSERT INTO `competition` VALUES ('53', '中国机器人暨人工智能大赛', 'C');
INSERT INTO `competition` VALUES ('54', '“21世纪杯”英语演讲比赛', 'C');
INSERT INTO `competition` VALUES ('55', '“工行杯”全国大学生金融科技创新大赛', 'C');
INSERT INTO `competition` VALUES ('56', '“外教社杯”全国高校学生跨文化能力大赛', 'C');
INSERT INTO `competition` VALUES ('57', '百度之星·程序设计大赛', 'C');
INSERT INTO `competition` VALUES ('58', '全国大学生工业设计大赛', 'C');
INSERT INTO `competition` VALUES ('59', '全国大学生水利创新设计大赛', 'C');
INSERT INTO `competition` VALUES ('60', '全国大学生化工实验大赛', 'C');
INSERT INTO `competition` VALUES ('61', '全国大学生化学实验创新设计大赛', 'C');
INSERT INTO `competition` VALUES ('62', '全国大学生计算机系统能力大赛', 'C');
INSERT INTO `competition` VALUES ('63', '全国大学生花园设计建造竞赛', 'C');
INSERT INTO `competition` VALUES ('64', '全国大学生物联网设计竞赛', 'C');
INSERT INTO `competition` VALUES ('65', '全国大学生信息安全与对抗技术竞赛', 'C');
INSERT INTO `competition` VALUES ('66', '全国大学生测绘学科创新创业智能大赛', 'C');
INSERT INTO `competition` VALUES ('67', '全国大学生能源经济学术创意大赛', 'C');
INSERT INTO `competition` VALUES ('68', '全国大学生基础医学创新研究暨实验设计论坛 (大赛)', 'C');
INSERT INTO `competition` VALUES ('69', '全国大学生数字媒体科技作品及创意竞赛', 'C');
INSERT INTO `competition` VALUES ('70', '全国本科院校税收风险管控案例大赛', 'C');
INSERT INTO `competition` VALUES ('71', '全国企业竞争模拟大赛', 'C');
INSERT INTO `competition` VALUES ('72', '全国高等院校数智化企业经营沙盘大赛（原全国大学生数智化企业经营沙盘大赛）', 'C');
INSERT INTO `competition` VALUES ('73', '全国数字建筑创新应用大赛', 'C');
INSERT INTO `competition` VALUES ('74', '全球校园人工智能算法精英大赛', 'C');
INSERT INTO `competition` VALUES ('75', '国际大学生智能农业装备创新大赛', 'C');
INSERT INTO `competition` VALUES ('76', '“科云杯”全国大学生财会职业能力大赛', 'C');
INSERT INTO `competition` VALUES ('77', '全国大学生化学实验邀请赛', 'C');
INSERT INTO `competition` VALUES ('78', '全国大学生交通科技大赛', 'C');
INSERT INTO `competition` VALUES ('79', '“泰迪杯”全国数据挖掘挑战赛', 'C');
INSERT INTO `competition` VALUES ('80', 'iTeach全国大学生数字化教育应用创新大赛', 'C');
INSERT INTO `competition` VALUES ('81', '微软“创新杯”全球学生大赛', 'C');
INSERT INTO `competition` VALUES ('82', 'ALTERA亚洲创新设计大赛', 'C');
INSERT INTO `competition` VALUES ('83', '全国大学生软件创新大赛', 'C');
INSERT INTO `competition` VALUES ('84', 'CCPC中国大学生程序设计竞赛（湖北省大学生程序设计竞赛HBCPC为其省级赛事）', 'C');
INSERT INTO `competition` VALUES ('85', '全国大学生过程控制仿真挑战赛', 'C');
INSERT INTO `competition` VALUES ('86', '“欧姆龙杯”自动化控制应用设计大赛', 'C');
INSERT INTO `competition` VALUES ('87', '中国高校计算机大赛--微信小程序应用开发赛', 'C');
INSERT INTO `competition` VALUES ('88', '全国计算机仿真大奖赛', 'C');
INSERT INTO `competition` VALUES ('89', 'ASC世界大学生超级计算机竞赛', 'C');
INSERT INTO `competition` VALUES ('90', '世界机器人大赛机器人格斗大赛', 'C');
INSERT INTO `competition` VALUES ('91', '中国工程机器人大赛暨国际公开赛', 'C');
INSERT INTO `competition` VALUES ('92', '美国（国际）大学生数学建模竞赛（MCM/ICM）', 'C');
INSERT INTO `competition` VALUES ('93', '全国高校密码数学挑战赛', 'C');
INSERT INTO `competition` VALUES ('94', '全国大学生生物医学工程创新设计竞赛', 'C');
INSERT INTO `competition` VALUES ('95', '全国大学生药苑论坛', 'C');
INSERT INTO `competition` VALUES ('96', '全国医药院校药学/中药学专业大学生实验技能展示活动', 'C');
INSERT INTO `competition` VALUES ('97', '全国高校市场营销大赛', 'C');
INSERT INTO `competition` VALUES ('98', '全国高校企业价值创造实战大赛', 'C');
INSERT INTO `competition` VALUES ('99', '全国科普讲解大赛', 'C');
INSERT INTO `competition` VALUES ('100', '“希望之星”英语风采大赛', 'C');
INSERT INTO `competition` VALUES ('101', '全国版权征文大赛', 'C');
INSERT INTO `competition` VALUES ('102', '“理律杯”全国高校模拟法庭竞赛', 'C');
INSERT INTO `competition` VALUES ('103', '全国大学生艺术展演', 'C');
INSERT INTO `competition` VALUES ('104', '全国“桃李杯”舞蹈教育教学成果展示活动', 'C');
INSERT INTO `competition` VALUES ('105', '长江钢琴·全国高校钢琴大赛', 'C');
INSERT INTO `competition` VALUES ('106', '全国青年歌手电视大奖赛', 'C');
INSERT INTO `competition` VALUES ('107', '全国美术作品展览', 'C');
INSERT INTO `competition` VALUES ('108', '“田家炳杯”全日制教育硕士专业学位研究生教学技能大赛', 'C');
INSERT INTO `competition` VALUES ('109', '全国大学生/研究生心理辅导课教学创新大赛', 'C');
INSERT INTO `competition` VALUES ('110', '中华人民共和国学生（青年）运动会', 'C');
INSERT INTO `competition` VALUES ('111', '高校创新创业创造教育精品成果展决赛', 'D');
INSERT INTO `competition` VALUES ('112', '“北斗杯”全国青少年科技创新大赛', 'D');
INSERT INTO `competition` VALUES ('113', '澜湄民族地区社会创业国际大赛', 'D');
INSERT INTO `competition` VALUES ('114', '国际机器人世界杯大赛', 'D');
INSERT INTO `competition` VALUES ('115', '全国机器人锦标赛暨国际仿人机器人奥林匹克大赛', 'D');
INSERT INTO `competition` VALUES ('116', '全国高校软件定义网络（SDN）应用创新开发大赛', 'D');
INSERT INTO `competition` VALUES ('117', '“博创杯”全国大学生嵌入式物联网设计大赛', 'D');
INSERT INTO `competition` VALUES ('118', '全国大学生电子信息实践创新作品竞赛', 'D');
INSERT INTO `competition` VALUES ('119', '菲尼克斯智能技术创新与应用大赛', 'D');
INSERT INTO `competition` VALUES ('120', '“台达杯”国际高校绿色智造大赛', 'D');
INSERT INTO `competition` VALUES ('121', '全国大学生等离子体科技创新竞赛', 'D');
INSERT INTO `competition` VALUES ('122', 'CCF大学生计算机系统与程序设计竞赛', 'D');
INSERT INTO `competition` VALUES ('123', '“兴智杯”全国人工智能创新应用大赛', 'D');
INSERT INTO `competition` VALUES ('124', '全国大学生市政环境类创新实践能力大赛“北控水务杯”', 'D');
INSERT INTO `competition` VALUES ('125', '中国大学生高分子材料创新创业大赛', 'D');
INSERT INTO `competition` VALUES ('126', '全国大学生冶金科技竞赛', 'D');
INSERT INTO `competition` VALUES ('127', '全国医药院校药学/中药学大学生创新创业实验教学改革大赛', 'D');
INSERT INTO `competition` VALUES ('128', '全国大学生标准化奥林匹克竞赛', 'D');
INSERT INTO `competition` VALUES ('129', '国际企业管理挑战赛（GMC)', 'D');
INSERT INTO `competition` VALUES ('130', '全国密码技术竞赛', 'D');
INSERT INTO `competition` VALUES ('131', '全国大学生数学竞赛', 'D');
INSERT INTO `competition` VALUES ('132', '全国大学生英语竞赛', 'D');
INSERT INTO `competition` VALUES ('133', 'BETT全国商务英语翻译大赛', 'D');
INSERT INTO `competition` VALUES ('134', '全国高校大学生外语水平能力大赛', 'D');
INSERT INTO `competition` VALUES ('135', '全国口译大赛', 'D');
INSERT INTO `competition` VALUES ('136', '全国高校创新英语挑战赛（综合能力赛、词汇赛、阅读赛）', 'D');
INSERT INTO `competition` VALUES ('137', '全国大学生英语翻译大赛', 'D');
INSERT INTO `competition` VALUES ('138', '中国大学生韩语演讲比赛', 'D');
INSERT INTO `competition` VALUES ('139', '全国高校博物馆优秀讲解案例推介大赛', 'D');
INSERT INTO `competition` VALUES ('140', '中国大学生广告艺术节学院奖', 'D');
INSERT INTO `competition` VALUES ('141', '全国大学生大型校园文艺演出', 'D');
INSERT INTO `competition` VALUES ('142', '全国高校DV作品大赛', 'D');
INSERT INTO `competition` VALUES ('143', 'CGDA平面设计学院奖', 'D');
INSERT INTO `competition` VALUES ('144', '全国大学生运动会', 'D');
INSERT INTO `competition` VALUES ('145', '少数民族体育运动会', 'D');
INSERT INTO `competition` VALUES ('146', '全国全民健身操舞大赛', 'D');
INSERT INTO `competition` VALUES ('147', '世界跳绳锦标赛', 'D');
INSERT INTO `competition` VALUES ('148', '中国大学生跆拳道（竞技）锦标赛', 'D');
INSERT INTO `competition` VALUES ('149', '全国青少年校园足球联赛', 'D');
INSERT INTO `competition` VALUES ('150', '中国大学生篮球联赛', 'D');
INSERT INTO `competition` VALUES ('151', '中国大学生飞镖联赛', 'D');
INSERT INTO `competition` VALUES ('152', '中国大学生毽球锦标赛', 'D');
INSERT INTO `competition` VALUES ('153', '中国大学生空手道锦标赛', 'D');
INSERT INTO `competition` VALUES ('154', '中国大学生沙滩排球锦标赛', 'D');
INSERT INTO `competition` VALUES ('155', '全国舞龙舞狮锦标赛', 'D');
INSERT INTO `competition` VALUES ('156', '全国导游大赛', 'D');
INSERT INTO `competition` VALUES ('157', '城市水环境与水生态科普创意大赛', 'D');
INSERT INTO `competition` VALUES ('158', '金山办公杯WPS办公软件能力大赛', 'D');
INSERT INTO `competition` VALUES ('159', '“国韵杯”民族器乐艺术展演', 'D');
INSERT INTO `competition` VALUES ('160', '高校声乐论文评选', 'D');
INSERT INTO `competition` VALUES ('161', '孔雀杯全国高等艺术院校声乐展演', 'D');
INSERT INTO `competition` VALUES ('162', '中国大学生羽毛球锦标赛', 'D');
INSERT INTO `competition` VALUES ('163', '全国桨板锦标赛', 'D');
INSERT INTO `competition` VALUES ('164', '青田国际桨板公开赛', 'D');
INSERT INTO `competition` VALUES ('165', '中国桨板超级联赛', 'D');
INSERT INTO `competition` VALUES ('166', '未来之星全国大学生视觉设计作品展览', 'D');
INSERT INTO `competition` VALUES ('167', 'KTK设计奖·全球华人设计比赛', 'D');
INSERT INTO `competition` VALUES ('168', '中国国际广告节——黄河奖', 'D');
INSERT INTO `competition` VALUES ('169', '全国高校大学生讲思政课公开课展示活动', 'D');
INSERT INTO `competition` VALUES ('170', '“汇川杯”全国智能自动化创新大赛', 'D');
INSERT INTO `competition` VALUES ('171', '全国大学生电化学测量技术竞赛', 'D');
INSERT INTO `competition` VALUES ('172', '“百子尖杯”全国大学生化工过程数字创新竞赛', 'D');
INSERT INTO `competition` VALUES ('173', '大学生数据要素素质大赛', 'D');
INSERT INTO `competition` VALUES ('174', '全国高校计算机能力挑战赛', 'D');
INSERT INTO `competition` VALUES ('175', '鲲鹏应用创新大赛', 'D');
INSERT INTO `competition` VALUES ('176', '大学生实验技能暨创新创业大赛', 'A');
INSERT INTO `competition` VALUES ('177', '长江钢琴杯青少年音乐比赛', 'A');
INSERT INTO `competition` VALUES ('178', '“田家炳杯”全日制教育硕士小学教育领域教学技能大赛', 'A');
INSERT INTO `competition` VALUES ('179', '悲鸿风度·油画双年展', 'A');
INSERT INTO `competition` VALUES ('180', '湖北省大学生文化创意作品大赛', 'A');
INSERT INTO `competition` VALUES ('181', '“BETT杯”全国大学生英语词汇大赛', 'A');
INSERT INTO `competition` VALUES ('182', '湖北省高校美术与艺术设计大展', 'A');
INSERT INTO `competition` VALUES ('183', '东方设计奖·全国高校创新设计大赛', 'A');
INSERT INTO `competition` VALUES ('184', '湖北省大学生艺术节', 'A');
INSERT INTO `competition` VALUES ('185', '全国大学生英语作文大赛', 'A');
INSERT INTO `competition` VALUES ('186', '湖北省楚天杯公益广告征集推广活动', 'A');
INSERT INTO `competition` VALUES ('187', '“良渚杯”全国大学生廉洁文化艺术大赛', 'A');
INSERT INTO `competition` VALUES ('188', '全国大学生网络评论大赛', 'A');
INSERT INTO `competition` VALUES ('189', '“燕园杯”百校百题应用型创新课题大赛', 'B');
INSERT INTO `competition` VALUES ('190', '中国大学生保险责任行寒假社会实践活动', 'B');
INSERT INTO `competition` VALUES ('191', '湖北省大学生新闻传播教育创新实践技能竞赛', 'B');
INSERT INTO `competition` VALUES ('192', '国家民委系统科普讲解大赛', 'B');
INSERT INTO `competition` VALUES ('193', '湖北省科普讲解大赛', 'B');
INSERT INTO `competition` VALUES ('194', '韩素音国际翻译大赛', 'B');
INSERT INTO `competition` VALUES ('195', '时报金犊奖', 'B');
INSERT INTO `competition` VALUES ('196', '湖北高校税务精英挑战赛', 'B');
INSERT INTO `competition` VALUES ('197', '全国大学生数智化业财融合竞赛（原名全国应用型本科会计技能竞赛）', 'B');
INSERT INTO `competition` VALUES ('198', '“育知联杯”全国大学生智慧商务大数据创新应用大赛', 'B');
INSERT INTO `competition` VALUES ('199', '“正保会计网校杯”全国校园财会大赛', 'B');
INSERT INTO `competition` VALUES ('200', '湖北省大学生物理实验创新设计竞赛', 'B');
INSERT INTO `competition` VALUES ('201', '湖北省高等学校大学生生物实验技能竞赛', 'B');
INSERT INTO `competition` VALUES ('202', '湖北省普通高校大学生化学实验技能竞赛', 'B');
INSERT INTO `competition` VALUES ('203', '湖北省高校“与绿同行”微公益环保创意大赛', 'B');
INSERT INTO `competition` VALUES ('204', '湖北省网络空间安全实践能力竞赛', 'B');
INSERT INTO `competition` VALUES ('205', '全国大学生大数据技能竞赛', 'B');
INSERT INTO `competition` VALUES ('206', '全国大学生电工数学建模竞赛', 'B');
INSERT INTO `competition` VALUES ('207', '“华数杯”全国大学生数学建模竞赛', 'B');
INSERT INTO `competition` VALUES ('208', '“华中杯”大学生数学建模挑战赛', 'B');
INSERT INTO `competition` VALUES ('209', '“学院空间”青年美术作品展览', 'B');
INSERT INTO `competition` VALUES ('210', '“楚风杯”大学生书画大赛暨全国大学生樱花笔会', 'B');
INSERT INTO `competition` VALUES ('211', '北京竹笛展演', 'B');
INSERT INTO `competition` VALUES ('212', '湖北金凤杯舞蹈比赛', 'B');
INSERT INTO `competition` VALUES ('213', '湖北音乐金编钟奖', 'B');
INSERT INTO `competition` VALUES ('214', '“辽源杯”艺术展演活动', 'B');
INSERT INTO `competition` VALUES ('215', '“敦煌杯”艺术菁英展演', 'B');
INSERT INTO `competition` VALUES ('216', '盛世华筝国际古筝音乐节', 'B');
INSERT INTO `competition` VALUES ('217', '中国大学生跳绳联赛', 'B');
INSERT INTO `competition` VALUES ('218', '中国大学生健康活力大赛暨中国大学生健身健美锦标赛', 'B');
INSERT INTO `competition` VALUES ('219', '湖北省小学教育专业学生技能竞赛', 'B');
INSERT INTO `competition` VALUES ('220', '全国高校商务英语竞赛', 'B');
INSERT INTO `competition` VALUES ('221', '湖北省科学实验展演汇演活动', 'B');
INSERT INTO `competition` VALUES ('222', '“东方财富杯”全国大学生金融精英挑战赛', 'B');
INSERT INTO `competition` VALUES ('223', '中国包装创意设计大赛', 'B');
INSERT INTO `competition` VALUES ('224', '湖北省优秀科普微视频', 'B');
INSERT INTO `competition` VALUES ('225', '全国法科学生模拟立法大赛', 'B');
INSERT INTO `competition` VALUES ('226', '大学生教育信息化创新创业奖', 'C');
INSERT INTO `competition` VALUES ('227', '“安恒杯”全国高校网络信息安全挑战赛', 'C');
INSERT INTO `competition` VALUES ('228', '中青杯全国大学生数学建模', 'C');
INSERT INTO `competition` VALUES ('229', '湖北省大学生化学（化工）学术创新成果报告会', 'C');
INSERT INTO `competition` VALUES ('230', '全国高校学生商业案例分析大赛', 'C');
INSERT INTO `competition` VALUES ('231', '“创光谷杯”湖北大学生金融投资大赛', 'C');
INSERT INTO `competition` VALUES ('232', '湖北省大学生金融知识竞赛', 'C');
INSERT INTO `competition` VALUES ('233', '“致同杯”全国会计技能（会计扑克）挑战赛', 'C');
INSERT INTO `competition` VALUES ('234', '湖北省MPAcc学生案例大赛', 'C');
INSERT INTO `competition` VALUES ('235', '全国大学生生态环境管理科研创新大赛', 'C');
INSERT INTO `competition` VALUES ('236', '武汉市科普讲解大赛', 'C');
INSERT INTO `competition` VALUES ('237', '湖北省文博系统“讲好中国故事”推介大赛', 'C');
INSERT INTO `competition` VALUES ('238', '“普译奖”全国大学生英语大赛', 'C');
INSERT INTO `competition` VALUES ('239', '湖北省翻译大赛', 'C');
INSERT INTO `competition` VALUES ('240', '中西部翻译大赛', 'C');
INSERT INTO `competition` VALUES ('241', '湖北省大学生日语作文大赛', 'C');
INSERT INTO `competition` VALUES ('242', '湖北省大学生文化创意设计大赛', 'C');
INSERT INTO `competition` VALUES ('243', '全国大学生少数民族题材影视作品大赛', 'C');
INSERT INTO `competition` VALUES ('244', '湖北省优秀广告作品评选', 'C');
INSERT INTO `competition` VALUES ('245', '紫金奖·建筑及环境设计大赛', 'C');
INSERT INTO `competition` VALUES ('246', 'BICC中英国际创意大赛', 'C');
INSERT INTO `competition` VALUES ('247', 'G-CROSS AWARD创意奖', 'C');
INSERT INTO `competition` VALUES ('248', '上海青少年钢琴大赛', 'C');
INSERT INTO `competition` VALUES ('249', '中国青少年艺术盛典湖北赛区--古筝', 'C');
INSERT INTO `competition` VALUES ('250', '湖北省古筝艺术活动古筝分级大赛', 'C');
INSERT INTO `competition` VALUES ('251', '湖北省大学生运动会', 'C');
INSERT INTO `competition` VALUES ('252', '民体杯体育比赛', 'C');
INSERT INTO `competition` VALUES ('253', '湖北省大学生排球比赛', 'C');
INSERT INTO `competition` VALUES ('254', '全国啦啦操竞赛', 'C');
INSERT INTO `competition` VALUES ('255', '武汉市科学实验展演汇演', 'C');
INSERT INTO `competition` VALUES ('256', '湖北省大学生营销大赛\n（公益助农创业大赛）', 'C');
INSERT INTO `competition` VALUES ('257', '湖北省微生物培养皿艺术设计大赛', 'C');
INSERT INTO `competition` VALUES ('258', '全国大学生数据分析技术技能大赛', 'C');
INSERT INTO `competition` VALUES ('259', '“泰迪杯”数据分析技能赛', 'C');
INSERT INTO `competition` VALUES ('260', '全国跳绳联赛', 'C');
INSERT INTO `competition` VALUES ('261', '东方创意之星设计大赛', 'C');
INSERT INTO `competition` VALUES ('262', '“写生湖北”——湖北省高校风景题材美术作品展览', 'C');
INSERT INTO `competition` VALUES ('263', '湖北省舞龙舞狮锦标赛', 'C');
INSERT INTO `competition` VALUES ('264', '“创新杯”全国大学生就业能力大赛——创业方案大赛', 'C');
INSERT INTO `competition` VALUES ('265', '红阳奖中日艺术设计大展', 'D');
INSERT INTO `competition` VALUES ('266', '微康益生菌杯“营养、健康、美味”酸奶DIY大学生创新竞赛', 'D');
INSERT INTO `competition` VALUES ('267', '“生态先锋，绿色挑战”全国大学生环保知识大赛', 'D');
INSERT INTO `competition` VALUES ('268', '全国大学生红色旅游创意策划大赛', 'D');
INSERT INTO `competition` VALUES ('269', '全国高等院校数智人力大赛', 'D');
INSERT INTO `competition` VALUES ('270', '“讲好中国故事”创意传播大赛', 'D');
INSERT INTO `competition` VALUES ('271', '新青年小说大赛', 'D');
INSERT INTO `competition` VALUES ('272', '“亿学杯”全国商务英语实践技能大赛', 'D');
INSERT INTO `competition` VALUES ('273', '“亿学杯”全国大学生英语词汇及综合能力大赛', 'D');
INSERT INTO `competition` VALUES ('274', '“发现杯”全国大学生互联网软件设计大奖赛', 'D');
INSERT INTO `competition` VALUES ('275', '环亚杯中日设计交流展', 'D');
INSERT INTO `competition` VALUES ('276', '全国漆艺邀请赛', 'D');
INSERT INTO `competition` VALUES ('277', 'CADA国际概念艺术设计奖', 'D');
INSERT INTO `competition` VALUES ('278', 'ITCD AWARD国际潮流文化设计大赛', 'D');
INSERT INTO `competition` VALUES ('279', '新加坡金沙艺术设计大赛', 'D');
INSERT INTO `competition` VALUES ('280', '台湾国际大学生年度艺术奖', 'D');
INSERT INTO `competition` VALUES ('281', '创意中国设计大奖', 'D');
INSERT INTO `competition` VALUES ('282', '国际环保公益设计大赛', 'D');
INSERT INTO `competition` VALUES ('283', '国艺杯两岸三地艺术设计邀请展', 'D');
INSERT INTO `competition` VALUES ('284', '远东艺术奖', 'D');
INSERT INTO `competition` VALUES ('285', '莫斯科国立柴可夫斯基音乐学院国际音乐大赛', 'D');
INSERT INTO `competition` VALUES ('286', '“央音”全国青少年艺术展演', 'D');
INSERT INTO `competition` VALUES ('287', '湖南省“灵声杯”竹笛、箫大赛', 'D');
INSERT INTO `competition` VALUES ('288', '“松庭奖”竹笛邀请赛', 'D');
INSERT INTO `competition` VALUES ('289', '湖北省普通高等学校羽毛球比赛', 'D');
INSERT INTO `competition` VALUES ('290', '湖北省普通高等学校大学生毽球比赛', 'D');
INSERT INTO `competition` VALUES ('291', '湖北省大学生游泳锦标赛', 'D');
INSERT INTO `competition` VALUES ('292', '湖北省大学生健美操艺术体操锦标赛', 'D');
INSERT INTO `competition` VALUES ('293', '湖北省健美操啦啦操锦标赛', 'D');
INSERT INTO `competition` VALUES ('294', '湖北省健身气功竞赛', 'D');
INSERT INTO `competition` VALUES ('295', '“中外传播杯”全国大学生英语翻译/阅读/写作/词汇/语法大赛', 'D');
INSERT INTO `competition` VALUES ('296', '全国行业+英语能力大赛', 'D');
INSERT INTO `competition` VALUES ('297', '“外教社·词达人杯”全国大学生英语词汇能力大赛', 'D');
INSERT INTO `competition` VALUES ('298', '《英语世界》杯全国大学生翻译/阅读/写作/语法/听力/词汇大赛', 'D');
INSERT INTO `competition` VALUES ('299', '全国高校商务翻译（英语）能力挑战赛', 'D');
INSERT INTO `competition` VALUES ('300', '“高教社杯”全国商务英语实践大赛', 'D');
INSERT INTO `competition` VALUES ('301', '全国大学生英语翻译能力竞赛', 'D');
INSERT INTO `competition` VALUES ('302', '全国大学生英语阅读竞赛', 'D');
INSERT INTO `competition` VALUES ('303', '全国大学生SKETCH原创手绘稿设计大赛', 'D');
INSERT INTO `competition` VALUES ('304', '湖北省大学生烘焙创意嘉年华', 'D');
INSERT INTO `competition` VALUES ('305', '“用英语讲中国故事”活动', 'D');
INSERT INTO `competition` VALUES ('306', '“CVTAAC杯”全国大学生英语词汇能力挑战赛', 'D');
INSERT INTO `competition` VALUES ('307', '“高教社杯”大学生“用外语讲好中国故事”优秀短视频作品征集活动', 'D');
INSERT INTO `competition` VALUES ('308', '“外文奖”全国大学生英语词汇大赛', 'D');
INSERT INTO `competition` VALUES ('309', '“读者杯”青少年文学大赛', 'D');
INSERT INTO `competition` VALUES ('310', '“联合国采购杯”全国大学生英语词汇/阅读大赛', 'D');
INSERT INTO `competition` VALUES ('311', '全国高校女子足球邀请赛', 'D');
INSERT INTO `competition` VALUES ('312', '湖北省青少年校园足球联赛', 'D');
INSERT INTO `competition` VALUES ('313', '全国大学生汉语言文字能力大赛', 'D');
INSERT INTO `competition` VALUES ('314', '全国大学生英语能力挑战赛（NCEPC）阅读能力挑战赛', 'D');
INSERT INTO `competition` VALUES ('315', '全国高校创新英语挑战赛翻译赛', 'D');
INSERT INTO `competition` VALUES ('316', '“旅投杯”全国大学生海南自贸港旅游产品创新大赛', 'D');
INSERT INTO `competition` VALUES ('317', '“湖北工匠杯”职业技能大赛', 'D');
INSERT INTO `competition` VALUES ('318', '“永创杯”全国高校创意设计作品展评', 'D');
INSERT INTO `competition` VALUES ('319', '中国高等院校设计作品大赛', 'D');
INSERT INTO `competition` VALUES ('320', '香港当代设计奖', 'D');
INSERT INTO `competition` VALUES ('321', '丁聪全国漫画插图大展', 'D');
INSERT INTO `competition` VALUES ('322', '湖北省高等学校大学生体育舞蹈、交谊舞锦标赛', 'D');
INSERT INTO `competition` VALUES ('323', '武汉市高校艺术节', 'D');
INSERT INTO `competition` VALUES ('324', '“BETT杯”全国大学生英语写作/语法大赛', 'D');
INSERT INTO `competition` VALUES ('325', '全国高校商务英语词汇大赛', 'D');
INSERT INTO `competition` VALUES ('326', '全国外语阅读大赛', 'D');
INSERT INTO `competition` VALUES ('327', '法国巴黎音乐大赛（武汉赛区）', 'D');
INSERT INTO `competition` VALUES ('328', '拉赫玛尼诺夫青少年钢琴大赛中国公开赛（武汉赛区）', 'D');
INSERT INTO `competition` VALUES ('329', '中国顶尖舞者成长计划', 'D');
INSERT INTO `competition` VALUES ('330', 'SIYPC新加坡国际钢琴比赛（湖北赛区）', 'D');
INSERT INTO `competition` VALUES ('331', '湖北省桨板公开赛', 'D');
INSERT INTO `competition` VALUES ('332', '长三角体育节桨板比赛', 'D');
INSERT INTO `competition` VALUES ('333', '湖北省普通高等学校乒乓球比赛', 'D');
INSERT INTO `competition` VALUES ('334', '“康富来杯”中国传统服饰三维数字复原与创新设计大赛', 'D');
INSERT INTO `competition` VALUES ('335', 'FA国际前沿创新艺术设计大赛（中国赛区）', 'D');
INSERT INTO `competition` VALUES ('336', 'HKDADC香港数字艺术设计大赛', 'D');
INSERT INTO `competition` VALUES ('337', '全国高校国产软件应用与设计创新大赛', 'D');
INSERT INTO `competition` VALUES ('338', '“礼赞新时代”——湖北国际潮玩艺术展', 'D');
INSERT INTO `competition` VALUES ('339', '知翰杯全国大学生现代企业数字化运营实践与创新挑战赛', 'D');
INSERT INTO `competition` VALUES ('340', '“中国故事大赛 双语中国”全国大学生写作大赛', 'D');
INSERT INTO `competition` VALUES ('341', '湖北省“我梦见-楚天创客”大赛', 'D');

-- ----------------------------
-- Table structure for `mentor`
-- ----------------------------
DROP TABLE IF EXISTS `mentor`;
CREATE TABLE `mentor` (
  `mentor_id` int NOT NULL AUTO_INCREMENT COMMENT '导师ID（主键）',
  `mentor_name` varchar(20) NOT NULL COMMENT '导师姓名',
  `department` varchar(50) NOT NULL DEFAULT '' COMMENT '所在学院',
  `mentor_no` varchar(20) NOT NULL COMMENT '导师工号（唯一）',
  PRIMARY KEY (`mentor_id`),
  UNIQUE KEY `uk_mentor_no` (`mentor_no`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='导师信息表';

-- ----------------------------
-- Records of mentor
-- ----------------------------
INSERT INTO `mentor` VALUES ('1', 'zz', '生物医学工程学院', '123456');

-- ----------------------------
-- Table structure for `student`
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `student_id` int NOT NULL AUTO_INCREMENT COMMENT '学生ID（主键）',
  `student_number` varchar(20) NOT NULL COMMENT '学生学号',
  `student_name` varchar(20) NOT NULL COMMENT '学生姓名',
  `grade` varchar(10) NOT NULL COMMENT '年级',
  `major` varchar(30) NOT NULL COMMENT '专业',
  `class_name` varchar(30) NOT NULL DEFAULT '' COMMENT '班级',
  `college` varchar(50) DEFAULT NULL COMMENT '所在学院',
  PRIMARY KEY (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1256 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='学生信息表';

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO `student` VALUES ('1', '202021121221', '张婷', '24级', '生物医学工程', '生医2002班', '生物医学工程学院');
INSERT INTO `student` VALUES ('2', '202121121073', '曹帅琦', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('3', '202121121181', '谭龙', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('4', '202121121218', '张洛', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('5', '202121121220', '刘昱潇', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('6', '202121121273', '王大锋', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('7', '202121121290', '格桑旺姆', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('8', '202121131023', '田逸静', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('9', '202221022045', '刘嘉颖', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('10', '202221022224', '徐银银', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('11', '202221073039', '刘果怡', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('12', '202221081009', '陶子健', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('13', '202221081106', '黄伟俊', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('14', '202221092030', '周宇柯', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('15', '202221121001', '刘鸿硕', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('16', '202221121002', '冯智灵', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('17', '202221121003', '张嘉婕', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('18', '202221121004', '马远航', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('19', '202221121005', '张越洋', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('20', '202221121006', '雷可欣', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('21', '202221121007', '戴至柔', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('22', '202221121009', '袁晓颖', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('23', '202221121010', '向欣彤', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('24', '202221121011', '王嘉馨', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('25', '202221121012', '黄木', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('26', '202221121013', '赵雅琳', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('27', '202221121014', '毕一天', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('28', '202221121015', '袁雅洁', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('29', '202221121016', '李晓玉', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('30', '202221121017', '杨文博', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('31', '202221121018', '杨睿哲', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('32', '202221121019', '刘三琳', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('33', '202221121020', '叶沁雅', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('34', '202221121021', '彭桦', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('35', '202221121022', '崔玉麒', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('36', '202221121023', '雷璧嘉', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('37', '202221121024', '海杨蓉', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('38', '202221121025', '黎淞菱', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('39', '202221121026', '黄思怡', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('40', '202221121027', '农玉兰', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('41', '202221121028', '邵先华', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('42', '202221121029', '郭笑言', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('43', '202221121030', '周洋', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('44', '202221121031', '卓玛拉姆', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('45', '202221121032', '陈宇超', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('46', '202221121033', '李岩', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('47', '202221121034', '王子轩', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('48', '202221121035', '万佳乐', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('49', '202221121036', '何家晨', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('50', '202221121037', '杨冰清', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('51', '202221121038', '熊仙剑', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('52', '202221121039', '刘舒琪', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('53', '202221121040', '李馨竹', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('54', '202221121041', '黄佳', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('55', '202221121042', '者皓', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('56', '202221121043', '尼哈塔', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('57', '202221121044', '程韬', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('58', '202221121045', '王芸', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('59', '202221121046', '黄山', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('60', '202221121047', '陈佳', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('61', '202221121048', '黄佳仪', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('62', '202221121049', '黄玉楠', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('63', '202221121050', '杨凯乐', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('64', '202221121051', '王震泽', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('65', '202221121052', '黄家敏', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('66', '202221121053', '谢春燕', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('67', '202221121055', '金磊', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('68', '202221121056', '巨敬云', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('69', '202221121057', '唐心怡', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('70', '202221121058', '何金玫', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('71', '202221121059', '罗丽娜', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('72', '202221121060', '茶珺蕊', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('73', '202221121061', '何静雯', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('74', '202221121062', '才雨田', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('75', '202221121063', '孟子祎', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('76', '202221121064', '张炫', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('77', '202221121065', '刘琪', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('78', '202221121066', '王勃', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('79', '202221121067', '钱文源', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('80', '202221121068', '刘景博', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('81', '202221121069', '马丽', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('82', '202221121070', '颜珺琪', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('83', '202221121071', '黎家铭', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('84', '202221121072', '谢雨津', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('85', '202221121073', '谭凯', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('86', '202221121074', '马正梅', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('87', '202221121075', '全宇', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('88', '202221121076', '赵梦瑶', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('89', '202221121078', '谢逸洁', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('90', '202221121079', '张晓霜', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('91', '202221121081', '蒙秋杏', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('92', '202221121082', '肖一娴', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('93', '202221121083', '司铭淇', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('94', '202221121084', '魏正麟', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('95', '202221121085', '邱以瀚', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('96', '202221121086', '韦贤', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('97', '202221121087', '王雅玲', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('98', '202221121088', '陈海燕', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('99', '202221121089', '蒋安华', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('100', '202221121090', '向阳', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('101', '202221121091', '陈雪琪', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('102', '202221121093', '管新美', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('103', '202221121094', '王语菲', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('104', '202221121095', '肖阳', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('105', '202221121096', '易欣玥', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('106', '202221121097', '张澍', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('107', '202221121098', '孙宇', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('108', '202221121099', '于少阳', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('109', '202221121100', '赖优', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('110', '202221121101', '曾思翔', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('111', '202221121102', '周宇轩', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('112', '202221121103', '卢璐', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('113', '202221121104', '王兴达', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('114', '202221121105', '鲁思雅', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('115', '202221121106', '崔云娇', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('116', '202221121107', '付文暄', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('117', '202221121108', '吴昀洁', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('118', '202221121109', '孟翔', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('119', '202221121110', '陈欣悦', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('120', '202221121111', '蒋浩扬', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('121', '202221121112', '黄燕', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('122', '202221121113', '周晶', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('123', '202221121114', '董昌臣', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('124', '202221121115', '王宇霜', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('125', '202221121116', '王丽敏', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('126', '202221121117', '覃焕杰', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('127', '202221121118', '马婷', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('128', '202221121119', '吴澂', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('129', '202221121120', '牟倩利', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('130', '202221121121', '苟先宇', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('131', '202221121122', '匡林玲', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('132', '202221121123', '黎巧虹', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('133', '202221121124', '韩昀伯', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('134', '202221121125', '郭松柏', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('135', '202221121126', '冉儒泉', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('136', '202221121127', '苏俊文', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('137', '202221121128', '杨莲', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('138', '202221121129', '郭远', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('139', '202221121130', '金沅昕', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('140', '202221121131', '张凯齐', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('141', '202221121132', '金晓妍', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('142', '202221121133', '朱嘉琪', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('143', '202221121134', '石方曦', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('144', '202221121135', '刘锦涛', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('145', '202221121136', '杨巧雨', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('146', '202221121137', '苏雪', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('147', '202221121138', '杨晶', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('148', '202221121139', '肖悦', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('149', '202221121140', '王梓涵', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('150', '202221121141', '王卓', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('151', '202221121142', '万入齐', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('152', '202221121143', '丁刘嘉', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('153', '202221121144', '李杨宁钰', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('154', '202221121145', '盛行乐', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('155', '202221121146', '赵梓伶', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('156', '202221121147', '余苹', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('157', '202221121149', '徐旖彤', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('158', '202221121150', '马贤', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('159', '202221121151', '强薇', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('160', '202221121152', '杨子怡', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('161', '202221121153', '龙双阳', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('162', '202221121154', '崔璨', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('163', '202221121155', '陈宇翔', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('164', '202221121156', '王渝', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('165', '202221121157', '冉涛', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('166', '202221121158', '李唯唯', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('167', '202221121159', '谭永康', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('168', '202221121160', '阿莲清', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('169', '202221121161', '何玉妮', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('170', '202221121162', '高悉闻', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('171', '202221121163', '李灏', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('172', '202221121164', '周沁茹', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('173', '202221121165', '王明洋', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('174', '202221121166', '童高阳', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('175', '202221121167', '王志康', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('176', '202221121168', '曹峻梓', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('177', '202221121169', '黄娟', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('178', '202221121170', '杨婷婷', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('179', '202221121171', '张华亚', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('180', '202221121173', '王胜阳', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('181', '202221121174', '蒲慧', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('182', '202221121175', '陕钱钱', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('183', '202221121176', '苏紫微', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('184', '202221121177', '杨政锐', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('185', '202221121178', '廖帆', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('186', '202221121179', '周子盈', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('187', '202221121180', '苏雨宁', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('188', '202221121181', '敬学芳', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('189', '202221121182', '马虎燕', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('190', '202221121183', '罗彦铭', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('191', '202221121184', '彭玉姣', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('192', '202221121185', '冯吉利', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('193', '202221121186', '蔡佳莹', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('194', '202221121187', '王成', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('195', '202221121188', '桂腾江', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('196', '202221121189', '朴智强', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('197', '202221121190', '彭海洋', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('198', '202221121191', '陈韵夙', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('199', '202221121192', '牟淼', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('200', '202221121193', '张艺潆', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('201', '202221121194', '李峰槿', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('202', '202221121195', '俞安娜', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('203', '202221121196', '夏权', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('204', '202221121197', '李嘉玉', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('205', '202221121198', '彭公博', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('206', '202221121200', '李明阳', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('207', '202221121201', '魏文芬', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('208', '202221121202', '冯钤', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('209', '202221121203', '唐涌斌', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('210', '202221121204', '袁国瑾', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('211', '202221121205', '龚岩', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('212', '202221121206', '夏昌', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('213', '202221121207', '郑雨昕', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('214', '202221121208', '张用明', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('215', '202221121209', '张贻涛', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('216', '202221121211', '夏金图克', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('217', '202221121212', '吴玉蓉', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('218', '202221121213', '奉清妹', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('219', '202221121214', '牟维茜', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('220', '202221121215', '阳杭', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('221', '202221121216', '田由申', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('222', '202221121217', '韩国电', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('223', '202221121218', '高紫英', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('224', '202221121219', '罗永松', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('225', '202221121220', '瓦年机', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('226', '202221121221', '张楚浛', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('227', '202221121222', '李雲风', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('228', '202221121223', '周开润', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('229', '202221121224', '李永辉', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('230', '202221121225', '刘芯羽', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('231', '202221121226', '朱再岳', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('232', '202221121227', '武宇星', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('233', '202221121228', '刘志', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('234', '202221121229', '李子禾', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('235', '202221121230', '郭爽明', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('236', '202221121231', '张晶', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('237', '202221121232', '杨皓天', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('238', '202221121233', '屠宇航', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('239', '202221121234', '陈学毓', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('240', '202221121235', '苑城玮', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('241', '202221121236', '王淏永', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('242', '202221121237', '田翊琳', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('243', '202221121238', '刘明婷', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('244', '202221121239', '张清琳', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('245', '202221121240', '李治林', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('246', '202221121241', '冯淑贤', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('247', '202221121242', '周臣', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('248', '202221121243', '曾瑞贤', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('249', '202221121244', '方向', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('250', '202221121245', '母广武', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('251', '202221121246', '孙义姗', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('252', '202221121247', '覃济海', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('253', '202221121248', '黄国云', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('254', '202221121250', '覃煜婷', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('255', '202221121251', '冯小碟', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('256', '202221121252', '龙晴', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('257', '202221121253', '黄彦智', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('258', '202221121254', '吴知非', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('259', '202221121255', '孔萍', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('260', '202221121256', '游文生', '22级', '医学信息工程', '医学信息2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('261', '202221141173', '曹书妍', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('262', '202221151118', '郑鸿泰', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('263', '202221151294', '盛家狄', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('264', '202221241011', '邓镁霖', '22级', '生物医学工程', '智能医学工程卓越工程师2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('265', '202221241067', '赵明斐', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('266', '202221241091', '于佳贝森', '22级', '生物医学工程', '生医2203班', '生物医学工程学院');
INSERT INTO `student` VALUES ('267', '202221241167', '李欣怡', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('268', '202221241193', '李茂蕾', '22级', '医学信息工程', '医学信息2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('269', '202221241211', '张艺馨', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('270', '202221241230', '李军扬', '22级', '生物医学工程', '生医2204班', '生物医学工程学院');
INSERT INTO `student` VALUES ('271', '202221241255', '蔡家伟', '22级', '生物医学工程', '生医2201班', '生物医学工程学院');
INSERT INTO `student` VALUES ('272', '202221241265', '罗炎琳', '22级', '生物医学工程', '生医2202班', '生物医学工程学院');
INSERT INTO `student` VALUES ('273', '202321031008', '严凤奇', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('274', '202321031022', '陶佳文', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('275', '202321031027', '黄秋雅', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('276', '202321031028', '潘良杰', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('277', '202321041075', '韦知行', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('278', '202321041119', '冯华利', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('279', '202321041126', '谢艳蓉', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('280', '202321041128', '刘香兰', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('281', '202321043006', '郝昱达', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('282', '202321051005', '贾玥彤', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('283', '202321052104', '王崇', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('284', '202321081076', '向少龙', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('285', '202321081143', '肖双凤', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('286', '202321121001', '王译伟', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('287', '202321121002', '翟怀发', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('288', '202321121003', '田政一', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('289', '202321121004', '罗雅琪', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('290', '202321121005', '刘桐', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('291', '202321121006', '陈雪', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('292', '202321121007', '阿木古楞', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('293', '202321121008', '朱恩泽', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('294', '202321121009', '张印涛', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('295', '202321121010', '熊楚豪', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('296', '202321121011', '覃湘', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('297', '202321121012', '苏力德', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('298', '202321121013', '孟昱梓', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('299', '202321121014', '许政', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('300', '202321121015', '裘草露', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('301', '202321121016', '王灵芝', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('302', '202321121017', '马峥', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('303', '202321121019', '孟星', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('304', '202321121020', '李珂', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('305', '202321121021', '罗佳钰', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('306', '202321121022', '夏星宇', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('307', '202321121023', '覃镜优', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('308', '202321121024', '郑羽', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('309', '202321121025', '何昱良', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('310', '202321121026', '甘骈臻', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('311', '202321121027', '郭立毅', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('312', '202321121028', '魏冉苒', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('313', '202321121029', '董诗洁', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('314', '202321121030', '张之楷', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('315', '202321121031', '盘文兰', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('316', '202321121032', '陈亚文', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('317', '202321121033', '刘宇天', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('318', '202321121034', '周洲', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('319', '202321121035', '邱佳豪', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('320', '202321121036', '吴峥', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('321', '202321121037', '袁雅琦', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('322', '202321121038', '陈波', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('323', '202321121039', '郭琪美', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('324', '202321121040', '江子杰', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('325', '202321121041', '戴依慧', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('326', '202321121042', '周子炜', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('327', '202321121044', '张文卓', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('328', '202321121045', '田树燊', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('329', '202321121046', '李柃蕙', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('330', '202321121047', '郭嘉丽', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('331', '202321121048', '顾文豪', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('332', '202321121049', '潘慧美', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('333', '202321121050', '郑鑫', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('334', '202321121051', '高敬艺', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('335', '202321121052', '龚子涵', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('336', '202321121053', '邹静怡', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('337', '202321121054', '刘俊鑫', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('338', '202321121055', '覃慧琳', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('339', '202321121056', '钟冰冰', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('340', '202321121057', '黄学文', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('341', '202321121058', '潘洁', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('342', '202321121059', '唐小汝', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('343', '202321121060', '贾子饶', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('344', '202321121061', '杨佳乐', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('345', '202321121062', '彭勃文', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('346', '202321121063', '文玉婷', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('347', '202321121064', '邱敏', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('348', '202321121065', '黎彩霞', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('349', '202321121066', '周郡宇', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('350', '202321121067', '方丽吹', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('351', '202321121068', '江旭', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('352', '202321121069', '杨欣睿', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('353', '202321121070', '高冕志', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('354', '202321121071', '周景丰', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('355', '202321121072', '蔡梁溢', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('356', '202321121073', '梁雪意', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('357', '202321121074', '宋婧茹', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('358', '202321121075', '周树林', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('359', '202321121076', '陈科伟', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('360', '202321121077', '段显吉', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('361', '202321121078', '袁炀', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('362', '202321121079', '熊湘玲', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('363', '202321121080', '张骏星', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('364', '202321121081', '罗梦', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('365', '202321121083', '杜玉雯', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('366', '202321121084', '黄镇宇', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('367', '202321121085', '范晨旭', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('368', '202321121086', '卢雅荷', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('369', '202321121087', '龚道庆', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('370', '202321121088', '周子俊', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('371', '202321121089', '郭福', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('372', '202321121090', '韩佳彤', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('373', '202321121091', '孟可心', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('374', '202321121092', '陈文茜', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('375', '202321121093', '葛瑞祺', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('376', '202321121094', '黄颖', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('377', '202321121095', '韦笑', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('378', '202321121096', '侯文杰', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('379', '202321121097', '孙李', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('380', '202321121098', '谢春玲', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('381', '202321121099', '龙湘粤', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('382', '202321121100', '黄结梅', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('383', '202321121101', '贾东', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('384', '202321121102', '刘忆昆', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('385', '202321121103', '王冰心', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('386', '202321121104', '贺瑶', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('387', '202321121106', '芮溪', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('388', '202321121107', '彭学良', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('389', '202321121108', '封政宇', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('390', '202321121109', '全燕京', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('391', '202321121110', '罗靖云', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('392', '202321121111', '张国凡', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('393', '202321121112', '倪珊', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('394', '202321121113', '朱佳音', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('395', '202321121114', '李敬一', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('396', '202321121115', '吴艾', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('397', '202321121116', '向玉琼', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('398', '202321121117', '唐妤晗', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('399', '202321121118', '代兴瑞', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('400', '202321121119', '龙玥', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('401', '202321121120', '周骞', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('402', '202321121121', '刘汪裕', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('403', '202321121122', '唐梦瑶', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('404', '202321121123', '李文秀', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('405', '202321121124', '魏雪丽', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('406', '202321121125', '徐通', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('407', '202321121126', '罗贤丽', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('408', '202321121127', '查方摇', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('409', '202321121128', '黄奕琳', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('410', '202321121129', '赵欣欣', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('411', '202321121130', '魏宇鑫', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('412', '202321121131', '刘懿文', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('413', '202321121132', '余德龙', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('414', '202321121133', '李梓涵', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('415', '202321121134', '吴佳芮', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('416', '202321121135', '金千祺', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('417', '202321121136', '李宇恒', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('418', '202321121137', '陈康', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('419', '202321121138', '娄启航', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('420', '202321121139', '王旌羽', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('421', '202321121140', '张楚唯', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('422', '202321121141', '张天琦', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('423', '202321121142', '陈靖盛', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('424', '202321121143', '刘昊宇', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('425', '202321121144', '陈梦晗', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('426', '202321121145', '潘婉宁', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('427', '202321121146', '杨天豪', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('428', '202321121147', '李秀珠', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('429', '202321121148', '伍经纬', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('430', '202321121149', '陈思君', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('431', '202321121150', '麦家智', '23级', '生物医学工程', '生医2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('432', '202321121151', '韦家祥', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('433', '202321121152', '贾浩', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('434', '202321121153', '熊哲宇', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('435', '202321121154', '刘宝琨', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('436', '202321121155', '严月杉', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('437', '202321121156', '董洁', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('438', '202321121157', '覃春香', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('439', '202321121158', '王婉婷', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('440', '202321121159', '谭卓凡', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('441', '202321121160', '刘璇', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('442', '202321121161', '杨博涯', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('443', '202321121162', '胡宇粲', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('444', '202321121163', '吴心桃', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('445', '202321121164', '周子喧', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('446', '202321121165', '张志坪', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('447', '202321121166', '夏子豪', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('448', '202321121167', '代劲焰', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('449', '202321121168', '谭苗苗', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('450', '202321121169', '刘乐炜', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('451', '202321121170', '石雅琪', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('452', '202321121171', '杨斌', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('453', '202321121172', '吴念涛', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('454', '202321121173', '张诗敏', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('455', '202321121174', '邹炎钰', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('456', '202321121175', '张瑜纾', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('457', '202321121176', '刘航', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('458', '202321121177', '柳洋熙', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('459', '202321121178', '黄云屏', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('460', '202321121179', '刚成瑞', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('461', '202321121180', '王佳琪', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('462', '202321121181', '希拉嘎尔', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('463', '202321121182', '赵禹衡', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('464', '202321121183', '尚鹏辉', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('465', '202321121184', '谭宇轩', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('466', '202321121185', '李斌', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('467', '202321121186', '史雅洁', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('468', '202321121187', '段龙飞', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('469', '202321121188', '周萌萌', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('470', '202321121189', '刘健', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('471', '202321121190', '张琳', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('472', '202321121191', '颜静宜', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('473', '202321121192', '王静怡', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('474', '202321121193', '曾令安', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('475', '202321121194', '谢柳颜', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('476', '202321121195', '黄世秋', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('477', '202321121196', '李姿', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('478', '202321121197', '查梦晗', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('479', '202321121198', '马皓政', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('480', '202321121199', '李静枫', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('481', '202321121200', '劳可', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('482', '202321121201', '唐佳慧', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('483', '202321121202', '谭申', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('484', '202321121203', '井乐怡', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('485', '202321121204', '吴函桦', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('486', '202321121205', '黄奇凤', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('487', '202321121206', '黎炳良', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('488', '202321121208', '余烜', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('489', '202321121209', '王睿锋', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('490', '202321121210', '牟领', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('491', '202321121211', '彭子能', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('492', '202321121212', '杨宇帆', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('493', '202321121213', '全雨添', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('494', '202321121214', '周蘂乾', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('495', '202321121215', '王宇杰', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('496', '202321121216', '李晓芬', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('497', '202321121217', '谭佳洛', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('498', '202321121218', '黎璇', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('499', '202321121219', '陆宇飞', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('500', '202321121220', '袁梦姿', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('501', '202321121221', '仇思宇', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('502', '202321121222', '胡太业', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('503', '202321121223', '晋美克珠', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('504', '202321121224', '关雨洁', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('505', '202321121225', '黄梓涵', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('506', '202321121226', '孟鸣鹤', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('507', '202321121227', '吴恩泽', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('508', '202321121228', '谢卓轩', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('509', '202321121229', '刘斌', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('510', '202321121230', '戴鸣阳', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('511', '202321121231', '王语凡', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('512', '202321121232', '邓广斌', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('513', '202321121233', '刘铭', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('514', '202321121234', '李智欣', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('515', '202321121235', '武莹莹', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('516', '202321121236', '邹泽', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('517', '202321121237', '芦妍霏', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('518', '202321121238', '贾广莹', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('519', '202321121239', '杨海鑫', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('520', '202321121240', '赵娜', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('521', '202321121241', '王佳欣', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('522', '202321121243', '杨添懋', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('523', '202321121244', '黄隽永', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('524', '202321121245', '黄姿娜', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('525', '202321121246', '吴俊怡', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('526', '202321121247', '李木子', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('527', '202321121249', '李丁丁', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('528', '202321121250', '岑潞', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('529', '202321121251', '徐宁', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('530', '202321121252', '郭晓岚', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('531', '202321121253', '明越', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('532', '202321121254', '杨婷', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('533', '202321121255', '杨安琪', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('534', '202321121256', '王颖', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('535', '202321121257', '李美妍', '23级', '生物医学工程', '生医2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('536', '202321121259', '肖嘉琦', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('537', '202321121260', '张雨晴', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('538', '202321121261', '吉史热古', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('539', '202321121263', '宋建霖', '23级', '生物医学工程', '智能医学工程卓越工程师2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('540', '202321121264', '白玛曲珍', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('541', '202321121265', '田佳慧', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('542', '202321141019', '肖海伶', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('543', '202321141082', '杨驰', '23级', '医学信息工程', '医学信息2301班', '生物医学工程学院');
INSERT INTO `student` VALUES ('544', '202321141208', '谭超', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('545', '202321141281', '唐斌', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('546', '202321241005', '宁唯楚', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('547', '202321241015', '马宇', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('548', '202321241042', '李丽明', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('549', '202321241043', '石美琪', '23级', '医学信息工程', '医学信息2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('550', '202321241066', '黄丹玲', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('551', '202321241110', '王雅洁', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('552', '202321241142', '谭豪', '23级', '医学信息工程', '医学信息2303班', '生物医学工程学院');
INSERT INTO `student` VALUES ('553', '202321241225', '韩林', '23级', '生物医学工程', '生医2302班', '生物医学工程学院');
INSERT INTO `student` VALUES ('554', '202421031010', '代宇轩', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('555', '202421121001', '程子熙', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('556', '202421121002', '黄城羲', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('557', '202421121003', '王铭泽', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('558', '202421121004', '赵淑环', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('559', '202421121005', '关鹏昆', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('560', '202421121006', '李宇', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('561', '202421121007', '郭思琪', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('562', '202421121008', '董雅迪', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('563', '202421121009', '陶薪宇', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('564', '202421121010', '李思丹', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('565', '202421121011', '上官博文', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('566', '202421121012', '赵娅琦', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('567', '202421121013', '陈佳炜', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('568', '202421121014', '孟鲁豫', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('569', '202421121015', '杨中原', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('570', '202421121016', '包占龙', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('571', '202421121017', '童一涵', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('572', '202421121018', '袁少英', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('573', '202421121019', '李可妍', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('574', '202421121021', '周子锐', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('575', '202421121022', '陈灵棂', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('576', '202421121023', '吉发欣', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('577', '202421121024', '赵一祥', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('578', '202421121025', '王嘉诚', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('579', '202421121026', '王一鸣', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('580', '202421121027', '万炳毅', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('581', '202421121029', '张国政', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('582', '202421121030', '张灿', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('583', '202421121031', '张磊', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('584', '202421121032', '王佳琪', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('585', '202421121033', '陈俊林', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('586', '202421121034', '赵俊杨', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('587', '202421121035', '赵晨昊', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('588', '202421121036', '黄港', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('589', '202421121037', '田岚欣', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('590', '202421121038', '赵凯歌', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('591', '202421121039', '杨爽', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('592', '202421121041', '肖宇辰', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('593', '202421121042', '李宇森', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('594', '202421121043', '胡峥', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('595', '202421121044', '杨帆', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('596', '202421121045', '刘欣甜', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('597', '202421121046', '雷雪亮', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('598', '202421121047', '任珂瑶', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('599', '202421121048', '周民贺', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('600', '202421121049', '纪苏耘', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('601', '202421121050', '杨若愚', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('602', '202421121051', '杨玉福', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('603', '202421121052', '张哲天', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('604', '202421121053', '刘思倩', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('605', '202421121054', '张珊', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('606', '202421121055', '邹尧顺', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('607', '202421121056', '熊艳霞', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('608', '202421121057', '曾荷丽', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('609', '202421121058', '周光泽', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('610', '202421121059', '魏冕兮', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('611', '202421121060', '王斌琪', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('612', '202421121061', '陈宇希', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('613', '202421121062', '刘庆', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('614', '202421121063', '孙汉璞', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('615', '202421121064', '李俊哲', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('616', '202421121065', '申思含', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('617', '202421121066', '王卓岩', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('618', '202421121067', '郭钰稀', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('619', '202421121068', '陈远航', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('620', '202421121070', '次仁玉珠', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('621', '202421121071', '邱俊杰', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('622', '202421121072', '杨爽', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('623', '202421121074', '赖超', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('624', '202421121075', '曾忻', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('625', '202421121076', '张婷钰', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('626', '202421121077', '王睿瑒', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('627', '202421121078', '保思彤', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('628', '202421121079', '李苗祯', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('629', '202421121080', '霍世豪', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('630', '202421121081', '聂胜果', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('631', '202421121082', '张佳运', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('632', '202421121083', '孙若涵', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('633', '202421121084', '撒春娜', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('634', '202421121085', '杨俊杰', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('635', '202421121086', '金梅', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('636', '202421121087', '谢文盛', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('637', '202421121088', '孙澋', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('638', '202421121089', '何宇恒', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('639', '202421121090', '鲁莹莹', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('640', '202421121091', '郑慧欣', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('641', '202421121092', '陈文康', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('642', '202421121093', '阳雯静', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('643', '202421121094', '王加辉', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('644', '202421121095', '曾远', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('645', '202421121096', '黄光域', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('646', '202421121097', '张怡', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('647', '202421121099', '李然', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('648', '202421121100', '叶科', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('649', '202421121101', '罗悦诗', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('650', '202421121102', '李永波', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('651', '202421121103', '覃纤画', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('652', '202421121104', '赵子怡', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('653', '202421121105', '马东', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('654', '202421121106', '冯冰洋', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('655', '202421121107', '祝岩', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('656', '202421121108', '张艳', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('657', '202421121109', '徐圣堃', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('658', '202421121110', '彭炜淇', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('659', '202421121111', '葛欣悦', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('660', '202421121112', '张浩', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('661', '202421121113', '余文涛', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('662', '202421121114', '田子娇', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('663', '202421121116', '巨铭凯', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('664', '202421121117', '姚煦铖', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('665', '202421121118', '相海萍', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('666', '202421121119', '郭志强', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('667', '202421121120', '扎西卓玛', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('668', '202421121121', '程逸菲', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('669', '202421121122', '覃允泓', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('670', '202421121123', '岑屹暄', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('671', '202421121124', '吕凌翰', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('672', '202421121125', '向真希', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('673', '202421121126', '向琴华', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('674', '202421121127', '彭怡美', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('675', '202421121128', '王芝艳', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('676', '202421121129', '赵然然', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('677', '202421121130', '柴士博', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('678', '202421121131', '张佳慧', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('679', '202421121132', '郑曦', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('680', '202421121133', '丁云天', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('681', '202421121134', '罗超奕', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('682', '202421121135', '王静娴', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('683', '202421121136', '王佳颖', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('684', '202421121137', '许然', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('685', '202421121138', '李亦弘', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('686', '202421121139', '左晓雪', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('687', '202421121140', '马小婷', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('688', '202421121141', '汤韵之', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('689', '202421121143', '熊韵涵', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('690', '202421121144', '邓杨涵', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('691', '202421121145', '黄伊琴', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('692', '202421121147', '朱昱章', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('693', '202421121148', '吴忻彤', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('694', '202421121149', '方思睿', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('695', '202421121150', '陈语嫣', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('696', '202421121151', '李京育', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('697', '202421121152', '王小宇', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('698', '202421121153', '李广', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('699', '202421121154', '高梦缘', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('700', '202421121155', '刘志枥', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('701', '202421121156', '游米琪', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('702', '202421121157', '陈玉萍', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('703', '202421121158', '左恩辉', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('704', '202421121159', '李泳欣', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('705', '202421121160', '冯瑞波', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('706', '202421121161', '华欣怡', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('707', '202421121162', '邹俊涛', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('708', '202421121163', '廖承松', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('709', '202421121164', '焦伟静', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('710', '202421121165', '潘继鑫', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('711', '202421121166', '黄国理', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('712', '202421121167', '程浩然', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('713', '202421121168', '洪靓', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('714', '202421121169', '毛大宽', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('715', '202421121170', '陈玥杉', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('716', '202421121171', '魏歆娱', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('717', '202421121172', '覃柱天', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('718', '202421121173', '刘昭驿', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('719', '202421121174', '马雯静', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('720', '202421121175', '刘洪希', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('721', '202421121176', '林益庆', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('722', '202421121177', '李嘉慧', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('723', '202421121178', '谢天翔', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('724', '202421121179', '陈芝美', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('725', '202421121180', '姜学', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('726', '202421121181', '朴俊宇', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('727', '202421121182', '刘怡', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('728', '202421121183', '徐梓恒', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('729', '202421121184', '吴睿妮', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('730', '202421121185', '吴洁', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('731', '202421121186', '张思晨', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('732', '202421121187', '陈子文', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('733', '202421121188', '姚茂易', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('734', '202421121189', '严文秀', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('735', '202421121190', '周欣婷', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('736', '202421121191', '黄忠谊', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('737', '202421121192', '甘素莲', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('738', '202421121193', '莫孔淼', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('739', '202421121194', '彭俊淇', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('740', '202421121195', '李柯江', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('741', '202421121196', '李一樊', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('742', '202421121197', '吴应凯', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('743', '202421121198', '卜彤彤', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('744', '202421121199', '涂诚乐', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('745', '202421121200', '黄品雄', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('746', '202421121201', '张桢', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('747', '202421121202', '徐晨阳', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('748', '202421121203', '谭玺', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('749', '202421121204', '胡永状', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('750', '202421121205', '肖婷婷', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('751', '202421121206', '姜思迪', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('752', '202421121207', '王盈盈', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('753', '202421121208', '约提库尔·阿布拉哈提', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('754', '202421121209', '曾榆净', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('755', '202421121210', '马翔宇', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('756', '202421121211', '唐筱', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('757', '202421121212', '翁会棋', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('758', '202421121213', '何晶', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('759', '202421121214', '吴增光', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('760', '202421121215', '姜惠潆', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('761', '202421121216', '黄苗苗', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('762', '202421121217', '王雅辉', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('763', '202421121218', '杨彤', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('764', '202421121219', '高妍', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('765', '202421121220', '王天姿', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('766', '202421121221', '付恒圳', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('767', '202421121222', '罗杰', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('768', '202421121223', '胡靖源', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('769', '202421121224', '贺汝林', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('770', '202421121225', '曾祥辉', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('771', '202421121226', '张莉', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('772', '202421121227', '黄敏珊', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('773', '202421121228', '曾子阳', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('774', '202421121229', '安雪', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('775', '202421121230', '焦晨曦', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('776', '202421121231', '梁策源', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('777', '202421121232', '王子轩', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('778', '202421121233', '周孝泉', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('779', '202421121234', '黄达颖', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('780', '202421121235', '陈心敖', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('781', '202421121236', '彭雨', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('782', '202421121237', '谭宋懿', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('783', '202421121238', '向尚', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('784', '202421121239', '谭小慧', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('785', '202421121240', '马狄雅', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('786', '202421121241', '谢阳雨日', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('787', '202421121242', '依力哈木·阿迪力', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('788', '202421121243', '马佳仪', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('789', '202421121244', '李佳妮', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('790', '202421121245', '于晚晴', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('791', '202421121246', '王浩然', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('792', '202421121247', '李媛媛', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('793', '202421121248', '黄薇竹', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('794', '202421121249', '国天奇', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('795', '202421121250', '彭陈', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('796', '202421121251', '谢馨菲', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('797', '202421121252', '芮博', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('798', '202421121253', '晏明杰', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('799', '202421121254', '阮诗涵', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('800', '202421121255', '李成洲', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('801', '202421121256', '张俊雯', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('802', '202421121257', '韩勇', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('803', '202421121258', '吴明洋', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('804', '202421121259', '杨鑫', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('805', '202421121260', '陈思羽', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('806', '202421121261', '利姿', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('807', '202421121262', '马驰贺', '24级', '生物医学工程', '生医2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('808', '202421121263', '王艺凯', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('809', '202421121264', '张之桥', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('810', '202421121265', '赵佳璐', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('811', '202421121266', '刘美子', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('812', '202421121267', '孟浩原', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('813', '202421121268', '梁怡佳', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('814', '202421121269', '贺诚', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('815', '202421121270', '张嘉琪', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('816', '202421121271', '方国兴', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('817', '202421121272', '杨欢', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('818', '202421121273', '尼玛扎西', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('819', '202421121274', '李江鈅', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('820', '202421121275', '赵世军', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('821', '202421121276', '杨佳易', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('822', '202421121277', '张婷', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('823', '202421121278', '李想', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('824', '202421121279', '王文学', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('825', '202421121280', '郭秘林', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('826', '202421121281', '夏贝宜', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('827', '202421121282', '武莉斯美', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('828', '202421121283', '布特格其', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('829', '202421121284', '赵家晨', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('830', '202421121285', '谢可', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('831', '202421121286', '朱梦戈', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('832', '202421121287', '吴相威', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('833', '202421121288', '蒋怡萧', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('834', '202421121289', '房永奇', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('835', '202421121290', '邓慧贞', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('836', '202421121291', '张美婷', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('837', '202421121292', '江彦妮', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('838', '202421121293', '李丹丹', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('839', '202421121294', '谈艺', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('840', '202421121295', '邝海璇', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('841', '202421121296', '兰杜娟', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('842', '202421121297', '刘梦园', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('843', '202421121298', '宋婉蓉', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('844', '202421121300', '佘江', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('845', '202421121301', '朱炫秋', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('846', '202421121302', '谢俊', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('847', '202421121303', '肖芷茜', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('848', '202421121304', '张伟', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('849', '202421121305', '张紫珍', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('850', '202421121307', '眭冰', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('851', '202421121308', '齐佳', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('852', '202421121309', '曹敏', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('853', '202421121310', '朱梓墨', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('854', '202421132090', '张浩', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('855', '202421132112', '黎尹睿', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('856', '202421141011', '陈创', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('857', '202421141100', '龙嘉成', '24级', '医学信息工程', '医学信息2403班', '生物医学工程学院');
INSERT INTO `student` VALUES ('858', '202421141258', '张文慧', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('859', '202421141344', '陈宗祺', '24级', '生物医学工程', '生医2404班', '生物医学工程学院');
INSERT INTO `student` VALUES ('860', '202421241091', '杨红星', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('861', '202421241108', '杨若佳', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('862', '202421241119', '黄馨儀', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('863', '202421241145', '王焙焙', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('864', '202421241148', '许莎', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('865', '202421241153', '张金金', '24级', '生物医学工程', '生医2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('866', '202421241155', '袁宇航', '24级', '医学信息工程', '医学信息2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('867', '202421241168', '郑菲燕', '24级', '生物医学工程', '生医2402班', '生物医学工程学院');
INSERT INTO `student` VALUES ('868', '202421241185', '杨金金', '24级', '生物医学工程', '智能医学卓越工程师2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('869', '202421241339', '杜雨彤', '24级', '医学信息工程', '医学信息2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('870', '202461122004', '陈家俊', '24级', '生物医学工程(第二学位)', '生医（第二学位）2401班', '生物医学工程学院');
INSERT INTO `student` VALUES ('871', '202521121001', '孙飞', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('872', '202521121002', '孙誉嘉', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('873', '202521121003', '张泽轩', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('874', '202521121004', '周庞婧', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('875', '202521121005', '王培淋', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('876', '202521121006', '李虎成', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('877', '202521121007', '郑铭', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('878', '202521121008', '彭修贤', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('879', '202521121009', '傅悦', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('880', '202521121010', '井雪颖', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('881', '202521121011', '关静柔', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('882', '202521121012', '唐梓浩', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('883', '202521121013', '管曹鑫', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('884', '202521121014', '刘立权', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('885', '202521121015', '黄子敬', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('886', '202521121016', '王安妮', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('887', '202521121017', '杨兰若', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('888', '202521121018', '马金铭', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('889', '202521121019', '莫柠卉', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('890', '202521121020', '蒙依灵', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('891', '202521121021', '陈召弟', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('892', '202521121022', '赵锐宇', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('893', '202521121023', '高海源', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('894', '202521121024', '李雨晴', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('895', '202521121025', '周欣恬', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('896', '202521121026', '袁馨愉', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('897', '202521121027', '汪祖银', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('898', '202521121028', '沈洋', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('899', '202521121029', '王子渊', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('900', '202521121030', '程丰', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('901', '202521121031', '杨茂果', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('902', '202521121032', '黄志均', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('903', '202521121033', '郭子豪', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('904', '202521121034', '马延科', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('905', '202521121035', '孔丽娜', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('906', '202521121036', '刘佳梦', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('907', '202521121037', '张航', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('908', '202521121038', '余宏杰', '25级', '生物医学工程类', '生医类2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('909', '202521121039', '权泓溪', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('910', '202521121040', '柳昕怡', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('911', '202521121041', '沈赞', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('912', '202521121042', '秦琨博', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('913', '202521121043', '赵家宏', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('914', '202521121044', '黄泳棋', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('915', '202521121045', '聂露', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('916', '202521121046', '蔡黄珏', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('917', '202521121047', '沈怡然', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('918', '202521121048', '张木子', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('919', '202521121049', '黄文乐', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('920', '202521121050', '戴成儒', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('921', '202521121051', '李子涵', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('922', '202521121052', '罗思雨', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('923', '202521121053', '李观澜', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('924', '202521121054', '胡紫妍', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('925', '202521121055', '李丹丹', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('926', '202521121056', '刘宁圆', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('927', '202521121057', '陈歆媛', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('928', '202521121058', '杨雅文', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('929', '202521121059', '郭政池', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('930', '202521121060', '袁凤玲', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('931', '202521121061', '薛诺雨', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('932', '202521121062', '贺冰心', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('933', '202521121063', '郑春霞', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('934', '202521121064', '石杰', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('935', '202521121065', '黄思淳', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('936', '202521121066', '胡昊', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('937', '202521121067', '汪玉霖', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('938', '202521121068', '刘希', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('939', '202521121069', '张炜鑫', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('940', '202521121070', '曾康', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('941', '202521121071', '钱彦文', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('942', '202521121072', '李好', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('943', '202521121073', '吴一帆', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('944', '202521121074', '向怡雯', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('945', '202521121075', '刘文璐', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('946', '202521121076', '张霖', '25级', '生物医学工程类', '生医类2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('947', '202521121077', '廖慧玲', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('948', '202521121078', '单彩琴', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('949', '202521121079', '吴哲欢', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('950', '202521121080', '禹文豪', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('951', '202521121081', '刘芳', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('952', '202521121082', '吴鑫雅', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('953', '202521121083', '陈爽', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('954', '202521121084', '匡玺源', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('955', '202521121085', '瞿梦茜', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('956', '202521121086', '张芳瑜', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('957', '202521121087', '张迈', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('958', '202521121088', '王闻悦', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('959', '202521121089', '苏凯', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('960', '202521121090', '谢昊', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('961', '202521121091', '许澜馨', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('962', '202521121092', '熊睿奇', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('963', '202521121093', '王婧', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('964', '202521121094', '蓝唯维', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('965', '202521121095', '雷姗妮', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('966', '202521121096', '李春霖', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('967', '202521121097', '辛世奇', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('968', '202521121098', '袁霄雅', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('969', '202521121099', '王钰雯', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('970', '202521121100', '肖紫涵', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('971', '202521121101', '姜宏伟', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('972', '202521121102', '辛怡', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('973', '202521121103', '赵良玉', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('974', '202521121105', '吴阅', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('975', '202521121106', '赖彦华', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('976', '202521121107', '熊振钦', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('977', '202521121108', '文慧娜', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('978', '202521121109', '周纳玺', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('979', '202521121110', '王嘉豪', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('980', '202521121111', '马昊宇', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('981', '202521121112', '郝一帆', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('982', '202521121113', '谭文雅', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('983', '202521121114', '孔李淼', '25级', '生物医学工程类', '生医类2503班', '生物医学工程学院');
INSERT INTO `student` VALUES ('984', '202521121115', '曹熙雯', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('985', '202521121116', '三郎旺姆', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('986', '202521121117', '汤志豪', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('987', '202521121118', '冉皓铭', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('988', '202521121119', '王文晰', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('989', '202521121121', '陈虹羽', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('990', '202521121122', '朱恩齐', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('991', '202521121123', '申硕', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('992', '202521121124', '赵娅齐', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('993', '202521121125', '马飞燕', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('994', '202521121126', '吕宗原', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('995', '202521121127', '潘振宇', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('996', '202521121128', '刘欣', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('997', '202521121129', '肖诗韵', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('998', '202521121130', '吕佳凝', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('999', '202521121131', '郭昊东', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1000', '202521121132', '马云涛', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1001', '202521121133', '杨晓楠', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1002', '202521121134', '韩丰阳', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1003', '202521121135', '丁疏可轲', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1004', '202521121136', '李彬', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1005', '202521121137', '胡思涵', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1006', '202521121138', '王雯涛', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1007', '202521121139', '陈钰', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1008', '202521121140', '章乐', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1009', '202521121141', '龚子宸', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1010', '202521121142', '周芳洁', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1011', '202521121143', '游翡翠', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1012', '202521121144', '潘石屹', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1013', '202521121145', '马玉婷', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1014', '202521121146', '陈羽宣', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1015', '202521121147', '黄莹莹', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1016', '202521121148', '刘苗', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1017', '202521121149', '田鑫', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1018', '202521121150', '王彦博', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1019', '202521121151', '齐宸仪', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1020', '202521121152', '殷嘉诚', '25级', '生物医学工程类', '生医类2504班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1021', '202521121153', '陈珑珠', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1022', '202521121154', '努尔扎提·阿迪力', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1023', '202521121155', '朱美桦', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1024', '202521121156', '吕玮晗', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1025', '202521121157', '罗睿骋', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1026', '202521121158', '陈煊文', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1027', '202521121159', '王茜', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1028', '202521121160', '马天奇', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1029', '202521121161', '唐钦兰', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1030', '202521121162', '吴慕瑶', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1031', '202521121163', '杨光梅', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1032', '202521121164', '贺英杰', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1033', '202521121165', '郭子徐', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1034', '202521121166', '汤宇涵', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1035', '202521121167', '黄美莹', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1036', '202521121168', '邹姻娇', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1037', '202521121169', '王芳', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1038', '202521121170', '赵一哲', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1039', '202521121171', '李可可', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1040', '202521121172', '汪云飞', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1041', '202521121173', '温晓菡', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1042', '202521121174', '杨启恒', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1043', '202521121175', '郭佳怡', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1044', '202521121176', '刘星毅', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1045', '202521121177', '许多', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1046', '202521121178', '包杰瑞', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1047', '202521121179', '李薇', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1048', '202521121180', '杨欣语', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1049', '202521121181', '傅冰艳', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1050', '202521121182', '宋涌波', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1051', '202521121183', '马琼', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1052', '202521121184', '黄麒樾', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1053', '202521121185', '刘晶晶', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1054', '202521121186', '吴思奇', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1055', '202521121187', '符佳瑜', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1056', '202521121188', '陈可', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1057', '202521121189', '卢静', '25级', '生物医学工程类', '生医类2505班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1058', '202521121190', '黄丹妮', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1059', '202521121191', '迪丽孜巴·吐尔逊江', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1060', '202521121192', '李诗涵', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1061', '202521121193', '韦叶红', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1062', '202521121194', '李文珊', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1063', '202521121195', '陈嬉霖', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1064', '202521121196', '陈蕾棂', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1065', '202521121197', '李昊添', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1066', '202521121198', '覃嘉美', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1067', '202521121199', '黄蕾', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1068', '202521121200', '杨精蕊', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1069', '202521121201', '艾小惜', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1070', '202521121202', '朱雅琪', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1071', '202521121203', '袁利群', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1072', '202521121204', '王芷萱', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1073', '202521121205', '覃一鑫', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1074', '202521121206', '后潇潇', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1075', '202521121207', '郑凯文', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1076', '202521121208', '王子轩', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1077', '202521121209', '金盈盈', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1078', '202521121210', '王艺笃', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1079', '202521121211', '石华柜', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1080', '202521121212', '郑浩南', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1081', '202521121213', '蔡韵湍', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1082', '202521121214', '王慧茹', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1083', '202521121215', '徐悦', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1084', '202521121216', '汪宇欣', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1085', '202521121217', '张轩宇', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1086', '202521121218', '陈银滢', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1087', '202521121219', '华摇摇', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1088', '202521121220', '诺日尖措', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1089', '202521121221', '王鑫禹', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1090', '202521121222', '张梦娇', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1091', '202521121223', '张欣悦', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1092', '202521121224', '彭斯锦', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1093', '202521121225', '王云庆', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1094', '202521121226', '苑欣妍', '25级', '生物医学工程类', '生医类2506班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1095', '202521121227', '唐培焜', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1096', '202521121228', '黄丹艺', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1097', '202521121229', '钟苾尹', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1098', '202521121230', '樊菲琳', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1099', '202521121231', '代晓熠', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1100', '202521121232', '梁森岚', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1101', '202521121233', '王雯萱', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1102', '202521121234', '俸子俊', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1103', '202521121235', '蔡泽丽', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1104', '202521121236', '郝瑾怡', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1105', '202521121237', '季芙名', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1106', '202521121238', '岳月', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1107', '202521121239', '董欣雨', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1108', '202521121240', '何彦锐', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1109', '202521121241', '梁韦诗竹', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1110', '202521121242', '覃雅姗', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1111', '202521121243', '于郑茗', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1112', '202521121244', '刘世宇', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1113', '202521121245', '胡志薪', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1114', '202521121246', '朱程铭', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1115', '202521121247', '勾宗懿', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1116', '202521121248', '余好', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1117', '202521121249', '谢宁怡', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1118', '202521121250', '姜晓菊', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1119', '202521121251', '周萱', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1120', '202521121252', '高晨', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1121', '202521121253', '姚铃林', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1122', '202521121254', '彭江龙', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1123', '202521121255', '夏新宇', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1124', '202521121256', '曲布登措', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1125', '202521121257', '王靖', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1126', '202521121258', '夏梓铭', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1127', '202521121259', '尹陈慧勤', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1128', '202521121260', '李怡萱', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1129', '202521121261', '王竹雨', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1130', '202521121262', '刘滢', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1131', '202521121263', '德吉央宗', '25级', '生物医学工程类', '生医类2507班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1132', '202521121264', '朱倩', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1133', '202521121265', '杨正洁', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1134', '202521121266', '陈彤', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1135', '202521121267', '刘陈凤', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1136', '202521121268', '龙星羽', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1137', '202521121269', '邓媛元', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1138', '202521121270', '卓涵', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1139', '202521121271', '赵云燕', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1140', '202521121272', '谢慧婕', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1141', '202521121273', '郑镓阳', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1142', '202521121274', '童浩泽', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1143', '202521121275', '周佳', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1144', '202521121276', '唐窈', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1145', '202521121277', '张开亮', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1146', '202521121278', '伍贝', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1147', '202521121279', '韦慧珊', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1148', '202521121280', '杨云舒', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1149', '202521121281', '史君皓', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1150', '202521121282', '苏昱硕', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1151', '202521121283', '陈紫妍', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1152', '202521121284', '刘家仪', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1153', '202521121285', '刘宏彬', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1154', '202521121286', '柳凯文', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1155', '202521121287', '于欢', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1156', '202521121288', '邵宇涵', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1157', '202521121289', '唐芯语', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1158', '202521121290', '杨承何美', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1159', '202521121291', '钟舒芳', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1160', '202521121292', '郑文浩', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1161', '202521121293', '陈冠齐', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1162', '202521121294', '彭思锦', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1163', '202521121295', '郭树言', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1164', '202521121296', '郑继昊', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1165', '202521121297', '薛可迪', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1166', '202521121298', '王亚茹', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1167', '202521121299', '索朗普赤', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1168', '202521121300', '白玛玉措', '25级', '生物医学工程类', '生医类2508班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1169', '202521124001', '殷佳慧', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1170', '202521124002', '王斌', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1171', '202521124003', '龚雅慧', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1172', '202521124004', '黄敏怡', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1173', '202521124005', '沈易方', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1174', '202521124006', '周宇琴', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1175', '202521124007', '杨东源', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1176', '202521124008', '金枥', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1177', '202521124009', '雀永辉', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1178', '202521124010', '黄俊钦', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1179', '202521124011', '章云翔', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1180', '202521124012', '邱婧瑜', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1181', '202521124013', '王珍宝', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1182', '202521124014', '刘伟祥', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1183', '202521124015', '林思帆', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1184', '202521124016', '曾立珺', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1185', '202521124017', '刘祥', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1186', '202521124018', '李媛', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1187', '202521124019', '吴子骞', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1188', '202521124020', '向洁', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1189', '202521124021', '黎柳清', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1190', '202521124022', '王江琪', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1191', '202521124023', '刀灿棠', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1192', '202521124024', '李子研', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1193', '202521124025', '卢玉', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1194', '202521124026', '陈美闲', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1195', '202521124027', '蒋礼丞', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1196', '202521124028', '陈蹬宇', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1197', '202521124029', '刘竞博', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1198', '202521124030', '阙辰镥', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1199', '202521124031', '李尊', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1200', '202521124032', '朱欣悦', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1201', '202521124033', '陈祖耀', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1202', '202521124034', '张书尘', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1203', '202521124035', '黄学强', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1204', '202521124036', '张凝辉', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1205', '202521124037', '张永强', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1206', '202521124038', '谢佳真', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1207', '202521124039', '李琳', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1208', '202521124040', '马尚勋', '25级', '智能医学工程', '智医2501班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1209', '202521124041', '蒋飞翔', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1210', '202521124042', '李文煊', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1211', '202521124043', '彭权蓉', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1212', '202521124044', '莫文菲', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1213', '202521124045', '韦立庆', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1214', '202521124046', '蓝占戈', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1215', '202521124047', '李业珍', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1216', '202521124048', '黄金铭', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1217', '202521124049', '田钰杉', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1218', '202521124050', '曹梦婕', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1219', '202521124051', '顾若楠', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1220', '202521124052', '王丁丁', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1221', '202521124053', '吕政贤', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1222', '202521124054', '苏婷', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1223', '202521124055', '殷宁静', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1224', '202521124056', '邓雪慧', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1225', '202521124058', '冉绍涵', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1226', '202521124059', '郭丽', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1227', '202521124060', '李晨玺', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1228', '202521124061', '储欣妍', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1229', '202521124062', '方卓妮', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1230', '202521124063', '潘盛元', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1231', '202521124064', '赵佳妮', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1232', '202521124065', '高家诚', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1233', '202521124066', '雷苏颖', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1234', '202521124067', '许津铭', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1235', '202521124068', '汤佳慧', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1236', '202521124069', '马执桉', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1237', '202521124070', '乔逸', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1238', '202521124071', '田澜琦', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1239', '202521124072', '赵阳明珠', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1240', '202521124073', '陈依阳', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1241', '202521124074', '陈添', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1242', '202521124075', '陈梦淇', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1243', '202521124076', '祝昕冉', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1244', '202521124077', '程梓萌', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1245', '202521124078', '桂耀鑫', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1246', '202521124079', '程添', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1247', '202521124080', '徐靖婧', '25级', '智能医学工程', '智医2502班', '生物医学工程学院');
INSERT INTO `student` VALUES ('1248', '202561122001', '胡田田', '25级', '生物医学工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1249', '202561122002', '蓝宏昊', '25级', '生物医学工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1250', '202561122004', '郭英博', '25级', '生物医学工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1251', '202561122005', '李承羲', '25级', '生物医学工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1252', '202561123001', '奕莉娜', '25级', '医学信息工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1253', '202561123002', '毛书蓓', '25级', '医学信息工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1254', '202561123004', '桂泽鸿', '25级', '医学信息工程（第二学位）', '二学位', '生物医学工程学院');
INSERT INTO `student` VALUES ('1255', '202561123005', '杨贻杰', '25级', '医学信息工程（第二学位）', '二学位', '生物医学工程学院');

-- ----------------------------
-- Table structure for `team`
-- ----------------------------
DROP TABLE IF EXISTS `team`;
CREATE TABLE `team` (
  `team_id` int NOT NULL AUTO_INCREMENT COMMENT '团队ID（主键，自增生成）',
  `name` varchar(50) NOT NULL DEFAULT '' COMMENT '团队名称（可后补）',
  `leader_id` int DEFAULT NULL COMMENT '关联学生表ID（负责人，可后选）',
  `competition_id` int NOT NULL COMMENT '关联竞赛表ID（必选，绑定竞赛）',
  `has_sort` tinyint(1) NOT NULL DEFAULT '0' COMMENT '团队成员是否有排序（0=无，1=有）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`team_id`),
  KEY `leader_id` (`leader_id`),
  KEY `competition_id` (`competition_id`),
  CONSTRAINT `team_ibfk_1` FOREIGN KEY (`leader_id`) REFERENCES `student` (`student_id`) ON DELETE SET NULL,
  CONSTRAINT `team_ibfk_2` FOREIGN KEY (`competition_id`) REFERENCES `competition` (`competition_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='团队表（支持先建团队ID、后补名称/负责人、再加成员）';

-- ----------------------------
-- Records of team
-- ----------------------------
INSERT INTO `team` VALUES ('1', '1', null, '6', '0', '2026-02-09 19:26:31');
INSERT INTO `team` VALUES ('2', '创新队', null, '6', '0', '2026-02-10 15:34:42');

-- ----------------------------
-- Table structure for `team_member`
-- ----------------------------
DROP TABLE IF EXISTS `team_member`;
CREATE TABLE `team_member` (
  `team_member_id` int NOT NULL AUTO_INCREMENT COMMENT '成员关联ID（主键）',
  `team_id` int NOT NULL COMMENT '关联团队表ID',
  `student_id` int DEFAULT NULL COMMENT '本院学生ID（外院/外校留空，关联学生表取信息）',
  `is_leader` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否负责人（0=否，1=是；允许全0）',
  `sort_order` int DEFAULT NULL COMMENT '排序序号（团队has_sort=1时必填，否则留空）',
  `external_name` varchar(20) DEFAULT NULL COMMENT '外院/外校学生姓名',
  `external_number` varchar(20) DEFAULT NULL COMMENT '外院/外校学生学号',
  `external_school` varchar(50) DEFAULT NULL COMMENT '外院/外校学生学校/学院',
  PRIMARY KEY (`team_member_id`),
  KEY `idx_team_sort` (`team_id`,`sort_order`) COMMENT '团队+排序联合索引，优化查询',
  KEY `student_id` (`student_id`),
  CONSTRAINT `team_member_ibfk_1` FOREIGN KEY (`team_id`) REFERENCES `team` (`team_id`) ON DELETE CASCADE,
  CONSTRAINT `team_member_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='团队成员表（区分本院/外院/外校学生）';

-- ----------------------------
-- Records of team_member
-- ----------------------------
INSERT INTO `team_member` VALUES ('1', '1', null, '1', '1', '2', '3', null);
INSERT INTO `team_member` VALUES ('2', '1', null, '0', '2', '4', '4', '4');
INSERT INTO `team_member` VALUES ('3', '2', null, '1', '1', '唐小汝', '202321121059', null);
INSERT INTO `team_member` VALUES ('4', '2', null, '0', '2', '潘洁', '202321121058', null);

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT '用户ID（主键）',
  `username` varchar(30) NOT NULL COMMENT '登录账号（唯一）',
  `password` varchar(50) NOT NULL COMMENT '加密密码',
  `role` set('student','mentor','admin') NOT NULL COMMENT '用户角色（可多选，用逗号分隔）',
  `student_id` int DEFAULT NULL COMMENT '关联学生表ID（当角色包含student时非空）',
  `mentor_id` int DEFAULT NULL COMMENT '关联导师表ID（当角色包含mentor时非空）',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `status` enum('enabled','disabled') NOT NULL DEFAULT 'enabled' COMMENT '账号状态',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `student_id` (`student_id`),
  KEY `mentor_id` (`mentor_id`),
  CONSTRAINT `user_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `student` (`student_id`) ON DELETE CASCADE,
  CONSTRAINT `user_ibfk_2` FOREIGN KEY (`mentor_id`) REFERENCES `mentor` (`mentor_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_at_least_one_role` CHECK ((`role` <> _utf8mb3'')),
  CONSTRAINT `chk_mentor_role` CHECK ((((find_in_set(_utf8mb3'mentor',`role`) > 0) and (`mentor_id` is not null)) or ((find_in_set(_utf8mb3'mentor',`role`) = 0) and (`mentor_id` is null)))),
  CONSTRAINT `chk_student_role` CHECK ((((find_in_set(_utf8mb3'student',`role`) > 0) and (`student_id` is not null)) or ((find_in_set(_utf8mb3'student',`role`) = 0) and (`student_id` is null))))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户主表（支持多角色，单表实现）';

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', '202021121221', '202021121221', 'student,admin', '1', null, '2026-02-09 13:31:02', 'enabled');
INSERT INTO `user` VALUES ('2', '123456', '123456', 'mentor', null, '1', '2026-02-10 17:20:01', 'enabled');
