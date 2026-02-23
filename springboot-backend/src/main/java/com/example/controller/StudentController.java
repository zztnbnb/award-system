package com.example.controller;

import com.example.entity.Student;
import com.example.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/student")
@CrossOrigin(origins = "*")
public class StudentController {

    @Autowired
    private StudentService studentService;

    /**
     * 获取学生统计信息
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        try {
            Map<String, Object> statistics = studentService.getStatistics();
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * 分页查询学生列表
     */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getStudentList(
            @RequestParam(required = false) String studentNumber,
            @RequestParam(required = false) String grade,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize) {
        try {
            Map<String, Object> result = studentService.getStudentList(studentNumber, grade, page, pageSize);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * 根据ID查询学生
     */
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getStudentById(@PathVariable Integer id) {
        try {
            Student student = studentService.getStudentById(id);
            Map<String, Object> result = new HashMap<>();
            result.put("data", student);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * 新增学生
     */
    @PostMapping("/add")
    public ResponseEntity<Map<String, Object>> addStudent(@RequestBody Student student) {
        try {
            studentService.addStudent(student);
            Map<String, Object> result = new HashMap<>();
            result.put("message", "新增成功");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    /**
     * 更新学生
     */
    @PutMapping("/update")
    public ResponseEntity<Map<String, Object>> updateStudent(@RequestBody Student student) {
        try {
            studentService.updateStudent(student);
            Map<String, Object> result = new HashMap<>();
            result.put("message", "更新成功");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    /**
     * 删除学生
     */
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudent(@PathVariable Integer id) {
        try {
            studentService.deleteStudent(id);
            Map<String, Object> result = new HashMap<>();
            result.put("message", "删除成功");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    /**
     * 批量删除学生
     */
    @DeleteMapping("/batch-delete")
    public ResponseEntity<Map<String, Object>> batchDeleteStudents(@RequestBody List<Integer> ids) {
        try {
            studentService.batchDeleteStudents(ids);
            Map<String, Object> result = new HashMap<>();
            result.put("message", "批量删除成功");
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    /**
     * 导出学生数据
     */
    @GetMapping("/export")
    public ResponseEntity<byte[]> exportStudents(
            @RequestParam(required = false) String studentNumber,
            @RequestParam(required = false) String grade) {
        try {
            byte[] excelData = studentService.exportStudents(studentNumber, grade);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
            String filename = "学生列表.xlsx";
            try {
                filename = URLEncoder.encode(filename, "UTF-8");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            headers.setContentDispositionFormData("attachment", filename);
            
            return new ResponseEntity<>(excelData, headers, HttpStatus.OK);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * 导入学生数据
     */
    @PostMapping("/import")
    public ResponseEntity<Map<String, Object>> importStudents(@RequestParam("file") MultipartFile file) {
        try {
            Map<String, Object> result = studentService.importStudents(file);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        }
    }

    /**
     * 重置学生密码
     */
    @PostMapping("/reset-password")
    public ResponseEntity<Boolean> resetPassword(@RequestBody Map<String, Object> request) {
        try {
            Integer studentId = (Integer) request.get("studentId");
            String studentNumber = (String) request.get("studentNumber");
            
            if (studentId == null || studentNumber == null || studentNumber.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(false);
            }
            
            boolean result = studentService.resetPassword(studentId, studentNumber);
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(false);
        }
    }
}
