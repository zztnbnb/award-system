package com.example.controller;

import com.example.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/review")
@CrossOrigin(origins = "*")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    /**
     * 获取审核统计信息
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        try {
            Map<String, Object> statistics = reviewService.getStatistics();
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    /**
     * 分页查询申请列表
     */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getApplicationList(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String competitionName,
            @RequestParam(required = false) String studentNumber,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize) {
        try {
            Map<String, Object> result = reviewService.getApplicationList(
                status, competitionName, studentNumber, page, pageSize
            );
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    /**
     * 获取申请详情
     */
    @GetMapping("/detail/{applicationId}")
    public ResponseEntity<Map<String, Object>> getApplicationDetail(@PathVariable Integer applicationId) {
        try {
            Map<String, Object> detail = reviewService.getApplicationDetail(applicationId);
            return ResponseEntity.ok(detail);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    /**
     * 单个审核申请
     */
    @PostMapping("/single")
    public ResponseEntity<Map<String, Object>> reviewApplication(@RequestBody Map<String, Object> request) {
        try {
            Integer applicationId = (Integer) request.get("applicationId");
            String status = (String) request.get("status");
            
            if (applicationId == null || status == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "参数不完整");
                return ResponseEntity.badRequest().body(error);
            }
            
            reviewService.reviewApplication(applicationId, status);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "审核成功");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }

    /**
     * 批量审核申请
     */
    @PostMapping("/batch")
    public ResponseEntity<Map<String, Object>> batchReviewApplications(@RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<Integer> applicationIds = (List<Integer>) request.get("applicationIds");
            String status = (String) request.get("status");
            
            if (applicationIds == null || applicationIds.isEmpty() || status == null) {
                Map<String, Object> error = new HashMap<>();
                error.put("error", "参数不完整");
                return ResponseEntity.badRequest().body(error);
            }
            
            reviewService.batchReviewApplications(applicationIds, status);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "批量审核成功");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(500).body(error);
        }
    }
}
