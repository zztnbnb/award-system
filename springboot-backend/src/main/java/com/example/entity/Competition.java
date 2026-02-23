package com.example.entity;

/**
 * 竞赛实体类
 * 对应数据库表：competition
 */
public class Competition {
    private Integer competitionId;     // 竞赛ID（主键）
    private String competitionName;    // 竞赛名称
    private String awardRank;          // 获奖等次（A/B/C/D）
    private String competitionType;    // 竞赛类型（个人赛/团体赛）

    // Getter and Setter
    public Integer getCompetitionId() {
        return competitionId;
    }

    public void setCompetitionId(Integer competitionId) {
        this.competitionId = competitionId;
    }

    public String getCompetitionName() {
        return competitionName;
    }

    public void setCompetitionName(String competitionName) {
        this.competitionName = competitionName;
    }

    public String getAwardRank() {
        return awardRank;
    }

    public void setAwardRank(String awardRank) {
        this.awardRank = awardRank;
    }

    public String getCompetitionType() {
        return competitionType;
    }

    public void setCompetitionType(String competitionType) {
        this.competitionType = competitionType;
    }
}
