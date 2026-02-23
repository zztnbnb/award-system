<template>
  <div class="student-manage-page">
    <NavBar />
    
    <div class="content-container">
      <el-card class="manage-card">
        <template #header>
          <div class="card-header">
            <h2>学生管理</h2>
          </div>
        </template>
        
        <!-- 统计信息 -->
        <div class="statistics-bar">
          <div class="stat-item">
            <div class="stat-value">{{ statistics.totalCount }}</div>
            <div class="stat-label">学生总数</div>
          </div>
        </div>
        
        <!-- 操作栏 -->
        <div class="filter-bar">
          <div class="left-actions">
            <el-button type="primary" @click="handleAdd" :icon="Plus">
              新增学生
            </el-button>
            <el-button 
              type="danger" 
              :icon="Delete" 
              @click="handleBatchDelete"
            >
              批量删除
            </el-button>
            <el-upload
              action=""
              :show-file-list="false"
              :before-upload="handleImport"
              accept=".xlsx,.xls"
            >
              <el-button :icon="Upload">批量导入</el-button>
            </el-upload>
            <el-button :icon="Download" @click="handleExport">批量导出</el-button>
            <el-button type="warning" @click="handleResetPassword">重置学生密码</el-button>
          </div>
          <div class="right-filters">
            <el-input
              v-model="searchKeyword"
              placeholder="请输入学号查询"
              clearable
              @input="handleSearch"
              style="width: 200px; margin-right: 20px"
              :prefix-icon="Search"
            />
            <el-select
              v-model="filterGrade"
              placeholder="选择年级"
              clearable
              @change="handleSearch"
              style="width: 120px; margin-right: 20px"
            >
              <el-option label="22级" value="22级" />
              <el-option label="23级" value="23级" />
              <el-option label="24级" value="24级" />
              <el-option label="25级" value="25级" />
            </el-select>
            <span style="color: #606266; font-size: 14px; white-space: nowrap; display: inline-block; min-width: 100px;">
              共 {{ pagination.total }} 条信息
            </span>
          </div>
        </div>
        
        <!-- 学生列表 -->
        <el-table
          :data="studentList"
          stripe
          v-loading="loading"
          style="width: 100%"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" align="center" />
          <el-table-column type="index" label="序号" width="80" align="center" />
          <el-table-column prop="studentNumber" label="学号" width="120" />
          <el-table-column prop="studentName" label="姓名" width="100" />
          <el-table-column prop="grade" label="年级" width="100" align="center" />
          <el-table-column prop="major" label="专业" min-width="150" />
          <el-table-column prop="className" label="班级" min-width="280" show-overflow-tooltip />
          <el-table-column prop="college" label="学院" min-width="150" />
          <el-table-column label="操作" width="180" align="center" fixed="right">
            <template #default="{ row }">
              <el-button 
                type="primary" 
                size="small" 
                :icon="Edit"
                @click="handleEdit(row)"
              >
                编辑
              </el-button>
              <el-button 
                type="danger" 
                size="small" 
                :icon="Delete"
                @click="handleDelete(row)"
              >
                删除
              </el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :page-sizes="[20, 50, 100]"
          :total="pagination.total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handlePageChange"
          style="margin-top: 20px; justify-content: flex-end"
        />
      </el-card>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="学号" prop="studentNumber">
          <el-input
            v-model="formData.studentNumber"
            placeholder="请输入学号"
            maxlength="20"
          />
        </el-form-item>
        <el-form-item label="姓名" prop="studentName">
          <el-input
            v-model="formData.studentName"
            placeholder="请输入姓名"
            maxlength="20"
          />
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-select
            v-model="formData.grade"
            placeholder="请选择年级"
            style="width: 100%"
          >
            <el-option label="22级" value="22级" />
            <el-option label="23级" value="23级" />
            <el-option label="24级" value="24级" />
            <el-option label="25级" value="25级" />
          </el-select>
        </el-form-item>
        <el-form-item label="专业" prop="major">
          <el-input
            v-model="formData.major"
            placeholder="请输入专业"
            maxlength="30"
          />
        </el-form-item>
        <el-form-item label="班级" prop="className">
          <el-input
            v-model="formData.className"
            placeholder="请输入班级"
            maxlength="30"
          />
        </el-form-item>
        <el-form-item label="学院" prop="college">
          <el-input
            v-model="formData.college"
            placeholder="请输入学院"
            maxlength="50"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码弹窗 -->
    <el-dialog
      v-model="resetPasswordDialogVisible"
      title="重置学生密码"
      width="600px"
      @close="handleResetPasswordDialogClose"
    >
      <el-form
        ref="resetPasswordFormRef"
        :model="resetPasswordData"
        label-width="100px"
      >
        <el-form-item label="学号">
          <el-input
            v-model="resetPasswordData.studentNumber"
            placeholder="请输入学号，按回车搜索"
            @keyup.enter="handleStudentNumberSearch"
            @input="handleStudentNumberInput"
            clearable
          />
        </el-form-item>
        <el-form-item label="姓名">
          <el-input
            v-model="resetPasswordData.studentName"
            placeholder="姓名"
            disabled
          />
        </el-form-item>
        <el-form-item label="年级">
          <el-input
            v-model="resetPasswordData.grade"
            placeholder="年级"
            disabled
          />
        </el-form-item>
        <el-form-item label="专业">
          <el-input
            v-model="resetPasswordData.major"
            placeholder="专业"
            disabled
          />
        </el-form-item>
        <el-form-item label="班级">
          <el-input
            v-model="resetPasswordData.className"
            placeholder="班级"
            disabled
          />
        </el-form-item>
        <el-form-item label="学院">
          <el-input
            v-model="resetPasswordData.college"
            placeholder="学院"
            disabled
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetPasswordDialogVisible = false">关闭</el-button>
        <el-button 
          type="primary" 
          @click="confirmResetPassword"
          :disabled="!resetPasswordData.studentId"
        >
          重置密码
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Delete, Edit, Search, Upload, Download } from '@element-plus/icons-vue'
import axios from 'axios'
import NavBar from '../components/NavBar.vue'

const API_BASE_URL = 'http://localhost:9998/api/student'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增学生')
const formRef = ref(null)
const searchKeyword = ref('')
const filterGrade = ref('')
const selectedIds = ref([])

const statistics = reactive({
  totalCount: 0
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const studentList = ref([])

const formData = reactive({
  studentId: null,
  studentNumber: '',
  studentName: '',
  grade: '',
  major: '',
  className: '',
  college: ''
})

const formRules = {
  studentNumber: [
    { required: true, message: '请输入学号', trigger: 'blur' }
  ],
  studentName: [
    { required: true, message: '请输入姓名', trigger: 'blur' }
  ],
  grade: [
    { required: true, message: '请选择年级', trigger: 'change' }
  ],
  major: [
    { required: true, message: '请输入专业', trigger: 'blur' }
  ]
}

// 重置密码相关
const resetPasswordDialogVisible = ref(false)
const resetPasswordFormRef = ref(null)
const resetPasswordData = reactive({
  studentId: null,
  studentNumber: '',
  studentName: '',
  grade: '',
  major: '',
  className: '',
  college: ''
})

onMounted(() => {
  loadStatistics()
  loadStudentList()
})

const loadStatistics = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/statistics`)
    statistics.totalCount = response.data.totalCount || 0
  } catch (error) {
    console.error('加载统计信息失败:', error)
  }
}

const loadStudentList = async () => {
  loading.value = true
  try {
    const response = await axios.get(`${API_BASE_URL}/list`, {
      params: {
        studentNumber: searchKeyword.value,
        grade: filterGrade.value,
        page: pagination.page,
        pageSize: pagination.pageSize
      }
    })
    studentList.value = response.data.list || []
    pagination.total = response.data.total || 0
  } catch (error) {
    ElMessage.error('加载学生列表失败')
    console.error('加载学生列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增学生'
  formData.studentId = null
  formData.studentNumber = ''
  formData.studentName = ''
  formData.grade = ''
  formData.major = ''
  formData.className = ''
  formData.college = ''
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑学生'
  formData.studentId = row.studentId
  formData.studentNumber = row.studentNumber
  formData.studentName = row.studentName
  formData.grade = row.grade
  formData.major = row.major
  formData.className = row.className
  formData.college = row.college
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要删除学生"${row.studentName}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await axios.delete(`${API_BASE_URL}/delete/${row.studentId}`)
      ElMessage.success('删除成功')
      loadStatistics()
      loadStudentList()
    } catch (error) {
      ElMessage.error(error.response?.data?.error || '删除失败')
    }
  }).catch(() => {})
}

const handleBatchDelete = () => {
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请先选择要删除的学生')
    return
  }
  
  ElMessageBox.confirm(`确定要删除选中的 ${selectedIds.value.length} 个学生吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await axios.delete(`${API_BASE_URL}/batch-delete`, {
        data: selectedIds.value
      })
      ElMessage.success('批量删除成功')
      selectedIds.value = []
      loadStatistics()
      loadStudentList()
    } catch (error) {
      ElMessage.error(error.response?.data?.error || '批量删除失败')
    }
  }).catch(() => {})
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitLoading.value = true
      try {
        if (formData.studentId) {
          await axios.put(`${API_BASE_URL}/update`, formData)
          ElMessage.success('更新成功')
        } else {
          await axios.post(`${API_BASE_URL}/add`, formData)
          ElMessage.success('新增成功')
        }
        dialogVisible.value = false
        loadStatistics()
        loadStudentList()
      } catch (error) {
        ElMessage.error(error.response?.data?.error || '操作失败')
      } finally {
        submitLoading.value = false
      }
    }
  })
}

const handleSearch = () => {
  pagination.page = 1
  loadStudentList()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadStudentList()
}

const handleSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadStudentList()
}

const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.studentId)
}

const handleDialogClose = () => {
  if (formRef.value) {
    formRef.value.clearValidate()
  }
  // 手动重置表单数据
  formData.studentId = null
  formData.studentNumber = ''
  formData.studentName = ''
  formData.grade = ''
  formData.major = ''
  formData.className = ''
  formData.college = ''
}

const handleImport = async (file) => {
  const formData = new FormData()
  formData.append('file', file)
  
  loading.value = true
  try {
    const response = await axios.post(`${API_BASE_URL}/import`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    
    const result = response.data
    if (result.errorCount > 0) {
      ElMessageBox.alert(
        `成功导入 ${result.successCount} 条，失败 ${result.errorCount} 条\n错误信息：\n${result.errors.join('\n')}`,
        '导入结果',
        { confirmButtonText: '确定' }
      )
    } else {
      ElMessage.success(`成功导入 ${result.successCount} 条数据`)
    }
    
    loadStatistics()
    loadStudentList()
  } catch (error) {
    ElMessage.error(error.response?.data?.error || '导入失败')
  } finally {
    loading.value = false
  }
  
  return false
}

const handleExport = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/export`, {
      params: {
        studentNumber: searchKeyword.value,
        grade: filterGrade.value
      },
      responseType: 'blob'
    })
    
    const blob = new Blob([response.data], { 
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
    })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = '学生列表.xlsx'
    link.click()
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
    console.error('导出失败:', error)
  }
}

// 重置密码相关方法
const handleResetPassword = () => {
  resetPasswordDialogVisible.value = true
}

const handleStudentNumberInput = () => {
  // 当学号输入框内容改变时，清空学生信息
  if (resetPasswordData.studentId) {
    resetPasswordData.studentId = null
    resetPasswordData.studentName = ''
    resetPasswordData.grade = ''
    resetPasswordData.major = ''
    resetPasswordData.className = ''
    resetPasswordData.college = ''
  }
}

const handleStudentNumberSearch = async () => {
  const studentNumber = resetPasswordData.studentNumber.trim()
  
  if (!studentNumber) {
    ElMessage.warning('请输入学号')
    return
  }
  
  try {
    const response = await axios.get(`${API_BASE_URL}/list`, {
      params: {
        studentNumber: studentNumber,
        page: 1,
        pageSize: 1
      }
    })
    
    if (response.data.list && response.data.list.length > 0) {
      const student = response.data.list[0]
      resetPasswordData.studentId = student.studentId
      resetPasswordData.studentName = student.studentName
      resetPasswordData.grade = student.grade
      resetPasswordData.major = student.major
      resetPasswordData.className = student.className
      resetPasswordData.college = student.college
    } else {
      // 未找到学生
      resetPasswordData.studentId = null
      resetPasswordData.studentName = ''
      resetPasswordData.grade = ''
      resetPasswordData.major = ''
      resetPasswordData.className = ''
      resetPasswordData.college = ''
      ElMessage.warning('未找到该学号对应的学生')
    }
  } catch (error) {
    console.error('搜索学生失败:', error)
    ElMessage.error('搜索学生失败')
  }
}

const confirmResetPassword = async () => {
  if (!resetPasswordData.studentId) {
    ElMessage.warning('请先搜索学生')
    return
  }
  
  try {
    await ElMessageBox.confirm(
      `确定要将学生 ${resetPasswordData.studentName}(${resetPasswordData.studentNumber}) 的密码重置为 SY${resetPasswordData.studentNumber} 吗？`,
      '重置密码确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const response = await axios.post(`${API_BASE_URL}/reset-password`, {
      studentId: resetPasswordData.studentId,
      studentNumber: resetPasswordData.studentNumber
    })
    
    if (response.data) {
      ElMessage.success('密码重置成功')
      resetPasswordDialogVisible.value = false
    } else {
      ElMessage.error('密码重置失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('重置密码失败:', error)
      ElMessage.error(error.response?.data?.error || '重置密码失败')
    }
  }
}

const handleResetPasswordDialogClose = () => {
  resetPasswordData.studentId = null
  resetPasswordData.studentNumber = ''
  resetPasswordData.studentName = ''
  resetPasswordData.grade = ''
  resetPasswordData.major = ''
  resetPasswordData.className = ''
  resetPasswordData.college = ''
}
</script>

<style scoped>
.student-manage-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.content-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.manage-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.statistics-bar {
  display: flex;
  gap: 40px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  margin-bottom: 20px;
}

.stat-item {
  text-align: center;
  color: white;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
}

.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 10px;
}

.left-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.right-filters {
  display: flex;
  align-items: center;
}
</style>
