package com.example.service;

import com.example.entity.Student;
import com.example.mapper.StudentMapper;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class StudentService {

    @Autowired
    private StudentMapper studentMapper;

    /**
     * 获取学生统计信息
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> statistics = new HashMap<>();
        int totalCount = studentMapper.countStudents(null, null);
        statistics.put("totalCount", totalCount);
        return statistics;
    }

    /**
     * 分页查询学生列表
     */
    public Map<String, Object> getStudentList(String studentNumber, String grade, Integer page, Integer pageSize) {
        int offset = (page - 1) * pageSize;
        
        List<Student> list = studentMapper.selectStudentList(studentNumber, grade, offset, pageSize);
        int total = studentMapper.countStudents(studentNumber, grade);
        
        Map<String, Object> result = new HashMap<>();
        result.put("list", list);
        result.put("total", total);
        result.put("page", page);
        result.put("pageSize", pageSize);
        
        return result;
    }

    /**
     * 根据ID查询学生
     */
    public Student getStudentById(Integer studentId) {
        return studentMapper.selectStudentById(studentId);
    }

    /**
     * 新增学生
     */
    public void addStudent(Student student) throws Exception {
        if (student.getStudentNumber() == null || student.getStudentNumber().trim().isEmpty()) {
            throw new Exception("学号不能为空");
        }
        if (student.getStudentName() == null || student.getStudentName().trim().isEmpty()) {
            throw new Exception("学生姓名不能为空");
        }
        if (student.getGrade() == null || student.getGrade().trim().isEmpty()) {
            throw new Exception("年级不能为空");
        }
        
        studentMapper.insertStudent(student);
    }

    /**
     * 更新学生
     */
    public void updateStudent(Student student) throws Exception {
        if (student.getStudentId() == null) {
            throw new Exception("学生ID不能为空");
        }
        if (student.getStudentNumber() == null || student.getStudentNumber().trim().isEmpty()) {
            throw new Exception("学号不能为空");
        }
        if (student.getStudentName() == null || student.getStudentName().trim().isEmpty()) {
            throw new Exception("学生姓名不能为空");
        }
        if (student.getGrade() == null || student.getGrade().trim().isEmpty()) {
            throw new Exception("年级不能为空");
        }
        
        studentMapper.updateStudent(student);
    }

    /**
     * 删除学生
     */
    public void deleteStudent(Integer studentId) throws Exception {
        if (studentId == null) {
            throw new Exception("学生ID不能为空");
        }
        
        studentMapper.deleteStudent(studentId);
    }

    /**
     * 批量删除学生
     */
    public void batchDeleteStudents(List<Integer> ids) throws Exception {
        if (ids == null || ids.isEmpty()) {
            throw new Exception("请选择要删除的学生");
        }
        
        studentMapper.batchDeleteStudents(ids);
    }

    /**
     * 导出学生数据为Excel
     */
    public byte[] exportStudents(String studentNumber, String grade) throws IOException {
        List<Student> students = studentMapper.selectAllStudents(studentNumber, grade);
        
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("学生列表");
        
        // 创建表头
        Row headerRow = sheet.createRow(0);
        CellStyle headerStyle = workbook.createCellStyle();
        Font headerFont = workbook.createFont();
        headerFont.setBold(true);
        headerStyle.setFont(headerFont);
        
        String[] headers = {"序号", "学号", "姓名", "年级", "专业", "班级", "学院"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(headerStyle);
        }
        
        // 填充数据
        int rowNum = 1;
        for (Student student : students) {
            Row row = sheet.createRow(rowNum);
            row.createCell(0).setCellValue(rowNum); // 序号从1开始
            row.createCell(1).setCellValue(student.getStudentNumber());
            row.createCell(2).setCellValue(student.getStudentName());
            row.createCell(3).setCellValue(student.getGrade());
            row.createCell(4).setCellValue(student.getMajor());
            row.createCell(5).setCellValue(student.getClassName());
            row.createCell(6).setCellValue(student.getCollege());
            rowNum++;
        }
        
        // 自动调整列宽
        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
        }
        
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        workbook.write(outputStream);
        workbook.close();
        
        return outputStream.toByteArray();
    }

    /**
     * 导入学生数据从Excel
     */
    public Map<String, Object> importStudents(MultipartFile file) throws Exception {
        if (file.isEmpty()) {
            throw new Exception("上传文件不能为空");
        }
        
        List<Student> successList = new ArrayList<>();
        List<String> errorList = new ArrayList<>();
        
        try (InputStream inputStream = file.getInputStream();
             Workbook workbook = new XSSFWorkbook(inputStream)) {
            
            Sheet sheet = workbook.getSheetAt(0);
            int rowCount = sheet.getPhysicalNumberOfRows();
            
            for (int i = 1; i < rowCount; i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                
                try {
                    // 第0列是序号，从第1列开始读取数据
                    Cell numberCell = row.getCell(1);
                    Cell nameCell = row.getCell(2);
                    Cell gradeCell = row.getCell(3);
                    Cell majorCell = row.getCell(4);
                    Cell classCell = row.getCell(5);
                    Cell collegeCell = row.getCell(6);
                    
                    if (numberCell == null || nameCell == null || gradeCell == null) {
                        errorList.add("第" + (i + 1) + "行：学号、姓名或年级为空");
                        continue;
                    }
                    
                    String studentNumber = getCellValueAsString(numberCell);
                    String studentName = getCellValueAsString(nameCell);
                    String grade = getCellValueAsString(gradeCell);
                    String major = getCellValueAsString(majorCell);
                    String className = getCellValueAsString(classCell);
                    String college = getCellValueAsString(collegeCell);
                    
                    if (studentNumber.trim().isEmpty() || studentName.trim().isEmpty() || grade.trim().isEmpty()) {
                        errorList.add("第" + (i + 1) + "行：学号、姓名或年级为空");
                        continue;
                    }
                    
                    Student student = new Student();
                    student.setStudentNumber(studentNumber);
                    student.setStudentName(studentName);
                    student.setGrade(grade);
                    student.setMajor(major);
                    student.setClassName(className);
                    student.setCollege(college);
                    
                    studentMapper.insertStudent(student);
                    successList.add(student);
                    
                } catch (Exception e) {
                    errorList.add("第" + (i + 1) + "行：" + e.getMessage());
                }
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("successCount", successList.size());
        result.put("errorCount", errorList.size());
        result.put("errors", errorList);
        
        return result;
    }

    /**
     * 重置学生密码
     */
    public boolean resetPassword(Integer studentId, String studentNumber) {
        try {
            // 新密码格式：SY + 学号
            String newPassword = "SY" + studentNumber;
            
            // 更新密码
            int result = studentMapper.updatePassword(studentId, newPassword);
            return result > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 获取单元格值为字符串
     */
    private String getCellValueAsString(Cell cell) {
        if (cell == null) return "";
        
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                return String.valueOf((int) cell.getNumericCellValue());
            case BOOLEAN:
                return String.valueOf(cell.getBooleanCellValue());
            case FORMULA:
                return cell.getCellFormula();
            default:
                return "";
        }
    }
}
