<template>
  <div class="competition-manage-page">
    <NavBar />
    
    <div class="content-container">
      <el-card class="manage-card">
        <template #header>
          <div class="card-header">
            <h2>竞赛管理</h2>
          </div>
        </template>
        
        <!-- 统计信息 -->
        <div class="statistics-bar">
          <div class="stat-item">
            <div class="stat-value">{{ statistics.totalCount }}</div>
            <div class="stat-label">竞赛总数</div>
          </div>
        </div>
        
        <!-- 操作栏 -->
        <div class="filter-bar">
          <div class="left-actions">
            <el-button type="primary" @click="handleAdd" :icon="Plus">
              新增竞赛
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
          </div>
          <el-input
            v-model="searchKeyword"
            placeholder="请输入竞赛名称查询"
            clearable
            @input="handleSearch"
            style="width: 300px"
            :prefix-icon="Search"
          />
        </div>
        
        <!-- 竞赛列表 -->
        <el-table
          :data="competitionList"
          stripe
          v-loading="loading"
          style="width: 100%"
          @selection-change="handleSelectionChange"
        >
          <el-table-column type="selection" width="55" align="center" />
          <el-table-column type="index" label="序号" width="80" align="center" />
          <el-table-column prop="competitionName" label="竞赛名称" min-width="200" />
          <el-table-column prop="awardRank" label="获奖等次" width="150" align="center">
            <template #default="{ row }">
              <el-tag :type="getAwardRankType(row.awardRank)">{{ row.awardRank }}</el-tag>
            </template>
          </el-table-column>
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
      width="500px"
      @close="handleDialogClose"
    >
      <el-form
        ref="formRef"
        :model="formData"
        :rules="formRules"
        label-width="100px"
      >
        <el-form-item label="竞赛名称" prop="competitionName">
          <el-input
            v-model="formData.competitionName"
            placeholder="请输入竞赛名称"
            maxlength="50"
            show-word-limit
          />
        </el-form-item>
        <el-form-item label="获奖等次" prop="awardRank">
          <el-select
            v-model="formData.awardRank"
            placeholder="请选择获奖等次"
            style="width: 100%"
          >
            <el-option label="A" value="A" />
            <el-option label="B" value="B" />
            <el-option label="C" value="C" />
            <el-option label="D" value="D" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
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

const API_BASE_URL = 'http://localhost:9998/api/competition-manage'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增竞赛')
const formRef = ref(null)
const searchKeyword = ref('')
const selectedIds = ref([])

const statistics = reactive({
  totalCount: 0
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const competitionList = ref([])

const formData = reactive({
  competitionId: null,
  competitionName: '',
  awardRank: ''
})

const formRules = {
  competitionName: [
    { required: true, message: '请输入竞赛名称', trigger: 'blur' }
  ],
  awardRank: [
    { required: true, message: '请选择获奖等次', trigger: 'change' }
  ]
}

onMounted(() => {
  loadStatistics()
  loadCompetitionList()
})

const loadStatistics = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/statistics`)
    statistics.totalCount = response.data.totalCount || 0
  } catch (error) {
    console.error('加载统计信息失败:', error)
  }
}

const loadCompetitionList = async () => {
  loading.value = true
  try {
    const response = await axios.get(`${API_BASE_URL}/list`, {
      params: {
        competitionName: searchKeyword.value,
        page: pagination.page,
        pageSize: pagination.pageSize
      }
    })
    competitionList.value = response.data.list || []
    pagination.total = response.data.total || 0
  } catch (error) {
    ElMessage.error('加载竞赛列表失败')
    console.error('加载竞赛列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  dialogTitle.value = '新增竞赛'
  formData.competitionId = null
  formData.competitionName = ''
  formData.awardRank = ''
  dialogVisible.value = true
}

const handleEdit = (row) => {
  dialogTitle.value = '编辑竞赛'
  formData.competitionId = row.competitionId
  formData.competitionName = row.competitionName
  formData.awardRank = row.awardRank
  dialogVisible.value = true
}

const handleDelete = (row) => {
  ElMessageBox.confirm(`确定要删除竞赛"${row.competitionName}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await axios.delete(`${API_BASE_URL}/delete/${row.competitionId}`)
      ElMessage.success('删除成功')
      loadStatistics()
      loadCompetitionList()
    } catch (error) {
      ElMessage.error(error.response?.data?.error || '删除失败')
    }
  }).catch(() => {})
}

const handleBatchDelete = () => {
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请先选择要删除的竞赛')
    return
  }
  
  ElMessageBox.confirm(`确定要删除选中的 ${selectedIds.value.length} 个竞赛吗？`, '提示', {
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
      loadCompetitionList()
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
        if (formData.competitionId) {
          await axios.put(`${API_BASE_URL}/update`, formData)
          ElMessage.success('更新成功')
        } else {
          await axios.post(`${API_BASE_URL}/add`, formData)
          ElMessage.success('新增成功')
        }
        dialogVisible.value = false
        loadStatistics()
        loadCompetitionList()
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
  loadCompetitionList()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadCompetitionList()
}

const handleSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadCompetitionList()
}

const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.competitionId)
}

const handleDialogClose = () => {
  if (formRef.value) {
    formRef.value.resetFields()
  }
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
    loadCompetitionList()
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
        competitionName: searchKeyword.value
      },
      responseType: 'blob'
    })
    
    const blob = new Blob([response.data], { 
      type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
    })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = '竞赛列表.xlsx'
    link.click()
    window.URL.revokeObjectURL(url)
    
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
    console.error('导出失败:', error)
  }
}

const getAwardRankType = (rank) => {
  const typeMap = {
    'A': 'danger',
    'B': 'warning',
    'C': 'success',
    'D': 'info'
  }
  return typeMap[rank] || 'info'
}
</script>

<style scoped>
.competition-manage-page {
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

.header-actions {
  display: flex;
  gap: 10px;
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
</style>
