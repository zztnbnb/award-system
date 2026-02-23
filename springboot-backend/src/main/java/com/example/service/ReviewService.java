package com.example.service;

import com.example.mapper.ApplicationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ReviewService {

    @Autowired
    private ApplicationMapper applicationMapper;

    @Autowired
    private ApplicationService applicationService;

    /**
     * 获取审核统计信息
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> statistics = new HashMap<>();
        
        // 统计各状态的申请数量
        int totalCount = applicationMapper.countApplicationsByStatus(null);
        int pendingCount = applicationMapper.countApplicationsByStatus("pending");
        int approvedCount = applicationMapper.countApplicationsByStatus("approved");
        int rejectedCount = applicationMapper.countApplicationsByStatus("rejected");
        int returnedCount = applicationMapper.countApplicationsByStatus("returned");
        
        statistics.put("totalCount", totalCount);
        statistics.put("pendingCount", pendingCount);
        statistics.put("approvedCount", approvedCount);
        statistics.put("rejectedCount", rejectedCount);
        statistics.put("returnedCount", returnedCount);
        
        return statistics;
    }

    /**
     * 分页查询申请列表
     */
    public Map<String, Object> getApplicationList(
            String status, String competitionName, String studentNumber,
            Integer page, Integer pageSize) {
        
        // 计算偏移量
        int offset = (page - 1) * pageSize;
        
        // 查询总数
        int total = applicationMapper.countApplicationsForReview(status, competitionName, studentNumber);
        
        // 查询列表
        List<Map<String, Object>> list = applicationMapper.selectApplicationsForReview(
            status, competitionName, studentNumber, offset, pageSize
        );
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        
        return result;
    }

    /**
     * 获取申请详情
     */
    public Map<String, Object> getApplicationDetail(Integer applicationId) {
        return applicationService.getApplicationDetail(applicationId);
    }

    /**
     * 单个审核申请
     */
    @Transactional
    public void reviewApplication(Integer applicationId, String status) {
        // 验证状态值
        if (!isValidStatus(status)) {
            throw new RuntimeException("无效的审核状态");
        }
        
        // 更新申请状态
        applicationMapper.updateApplicationStatus(applicationId, status);
    }

    /**
     * 批量审核申请
     */
    @Transactional
    public void batchReviewApplications(List<Integer> applicationIds, String status) {
        // 验证状态值
        if (!isValidStatus(status)) {
            throw new RuntimeException("无效的审核状态");
        }
        
        // 批量更新状态
        for (Integer applicationId : applicationIds) {
            applicationMapper.updateApplicationStatus(applicationId, status);
        }
    }

    /**
     * 验证状态值是否有效
     */
    private boolean isValidStatus(String status) {
        return "approved".equals(status) || 
               "rejected".equals(status) || 
               "returned".equals(status) ||
               "pending".equals(status);
    }
}
