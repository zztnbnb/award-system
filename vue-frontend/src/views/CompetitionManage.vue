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
        
        <!-- 高级数据大屏 -->
        <div class="premium-dashboard">
          <div class="elegant-card total" :class="{ active: activeCard === 'all' }" @click="handleCardClick('all')">
            <div class="card-content">
              <span class="card-title">竞赛总数</span>
              <div class="card-num">{{ statistics.totalCount }}</div>
            </div>
          </div>
          <div class="elegant-card level-a" :class="{ active: activeCard === 'A' }" @click="handleCardClick('A')">
            <div class="card-content">
              <span class="card-title">A等次赛事</span>
              <div class="card-num">{{ statistics.levelACount }}</div>
            </div>
          </div>
          <div class="elegant-card level-b" :class="{ active: activeCard === 'B' }" @click="handleCardClick('B')">
            <div class="card-content">
              <span class="card-title">B等次赛事</span>
              <div class="card-num">{{ statistics.levelBCount }}</div>
            </div>
          </div>
          <div class="elegant-card level-c" :class="{ active: activeCard === 'C' }" @click="handleCardClick('C')">
            <div class="card-content">
              <span class="card-title">C等次赛事</span>
              <div class="card-num">{{ statistics.levelCCount }}</div>
            </div>
          </div>
          <div class="elegant-card level-d" :class="{ active: activeCard === 'D' }" @click="handleCardClick('D')">
            <div class="card-content">
              <span class="card-title">D等次赛事</span>
              <div class="card-num">{{ statistics.levelDCount }}</div>
            </div>
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
      width="420px"
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

const API_BASE_URL = 'http://10.152.224.138:9998/api/competition-manage'

const loading = ref(false)
const submitLoading = ref(false)
const dialogVisible = ref(false)
const dialogTitle = ref('新增竞赛')
const formRef = ref(null)
const searchKeyword = ref('')
const selectedIds = ref([])
const activeCard = ref('all') // 当前高亮的统计类别，默认为 'all'

const statistics = reactive({
  totalCount: 0,
  levelACount: 0,
  levelBCount: 0,
  levelCCount: 0,
  levelDCount: 0
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
    statistics.levelACount = response.data.levelACount || 0
    statistics.levelBCount = response.data.levelBCount || 0
    statistics.levelCCount = response.data.levelCCount || 0
    statistics.levelDCount = response.data.levelDCount || 0
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
        awardRank: activeCard.value === 'all' ? null : activeCard.value,
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

const handleCardClick = (type) => {
  if (activeCard.value === type) return // 若已选则无视
  activeCard.value = type
  searchKeyword.value = '' // 清除搜索框状态，体验更好
  pagination.page = 1
  loadCompetitionList()
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
}

.content-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.manage-card {
  margin-top: 20px;
  margin-bottom: 20px;
  background: rgba(255, 255, 255, 0.65) !important;
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.8) !important;
  border-radius: 20px !important;
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.05) !important;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  font-size: 20px;
  color: #1e293b;
  font-weight: 600;
}

/* 高级数据大屏 */
.premium-dashboard {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.elegant-card {
  position: relative;
  border-radius: 16px;
  padding: 24px;
  overflow: hidden;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.elegant-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  background: inherit;
  filter: blur(20px);
  opacity: 0;
  transition: opacity 0.4s ease;
  z-index: 0;
}

.elegant-card:hover, .elegant-card.active {
  transform: scale(1.02);
  border-width: 1px;
}
.elegant-card:hover::before, .elegant-card.active::before { opacity: 0.2; }

.card-content {
  position: relative;
  z-index: 1;
  text-align: center;
}

.card-title {
  font-size: 15px;
  font-weight: 600;
  margin-bottom: 8px;
  display: block;
  letter-spacing: 0.5px;
}

.card-num {
  font-size: 36px;
  font-weight: 800;
  line-height: 1;
  background-clip: text;
  -webkit-background-clip: text;
  color: transparent;
  transition: all 0.3s ease;
}

/* 具体颜色主题：高级白透毛玻璃 + 主题亮彩文字 */
.elegant-card.total {
  background: linear-gradient(135deg, rgba(238, 242, 255, 0.65) 0%, rgba(255, 255, 255, 0.3) 100%);
  border-color: rgba(255, 255, 255, 0.8);
}
.elegant-card.total .card-title { color: #4f46e5; }
.elegant-card.total .card-num { background-image: linear-gradient(to right, #4338ca, #818cf8); }
.elegant-card.total:hover, .elegant-card.total.active { 
  background: linear-gradient(135deg, rgba(238, 242, 255, 0.85) 0%, rgba(224, 231, 255, 0.6) 100%);
  box-shadow: 0 10px 40px -10px rgba(79, 70, 229, 0.35);
  border-color: rgba(199, 210, 254, 0.9);
}

.elegant-card.level-a {
  background: linear-gradient(135deg, rgba(255, 241, 242, 0.65) 0%, rgba(255, 255, 255, 0.3) 100%);
  border-color: rgba(255, 255, 255, 0.8);
}
.elegant-card.level-a .card-title { color: #e11d48; }
.elegant-card.level-a .card-num { background-image: linear-gradient(to right, #be123c, #fb7185); }
.elegant-card.level-a:hover, .elegant-card.level-a.active { 
  background: linear-gradient(135deg, rgba(255, 241, 242, 0.85) 0%, rgba(255, 228, 230, 0.6) 100%);
  box-shadow: 0 10px 40px -10px rgba(225, 29, 72, 0.35);
  border-color: rgba(254, 205, 211, 0.9);
}

.elegant-card.level-b {
  background: linear-gradient(135deg, rgba(255, 247, 237, 0.65) 0%, rgba(255, 255, 255, 0.3) 100%);
  border-color: rgba(255, 255, 255, 0.8);
}
.elegant-card.level-b .card-title { color: #ea580c; }
.elegant-card.level-b .card-num { background-image: linear-gradient(to right, #c2410c, #fb923c); }
.elegant-card.level-b:hover, .elegant-card.level-b.active { 
  background: linear-gradient(135deg, rgba(255, 247, 237, 0.85) 0%, rgba(255, 237, 213, 0.6) 100%);
  box-shadow: 0 10px 40px -10px rgba(234, 88, 12, 0.35);
  border-color: rgba(254, 215, 170, 0.9);
}

.elegant-card.level-c {
  background: linear-gradient(135deg, rgba(254, 252, 232, 0.65) 0%, rgba(255, 255, 255, 0.3) 100%);
  border-color: rgba(255, 255, 255, 0.8);
}
.elegant-card.level-c .card-title { color: #ca8a04; }
.elegant-card.level-c .card-num { background-image: linear-gradient(to right, #a16207, #facc15); }
.elegant-card.level-c:hover, .elegant-card.level-c.active { 
  background: linear-gradient(135deg, rgba(254, 252, 232, 0.85) 0%, rgba(254, 249, 195, 0.6) 100%);
  box-shadow: 0 10px 40px -10px rgba(202, 138, 4, 0.35);
  border-color: rgba(254, 240, 138, 0.9);
}

.elegant-card.level-d {
  background: linear-gradient(135deg, rgba(240, 253, 244, 0.65) 0%, rgba(255, 255, 255, 0.3) 100%);
  border-color: rgba(255, 255, 255, 0.8);
}
.elegant-card.level-d .card-title { color: #16a34a; }
.elegant-card.level-d .card-num { background-image: linear-gradient(to right, #15803d, #4ade80); }
.elegant-card.level-d:hover, .elegant-card.level-d.active { 
  background: linear-gradient(135deg, rgba(240, 253, 244, 0.85) 0%, rgba(220, 252, 231, 0.6) 100%);
  box-shadow: 0 10px 40px -10px rgba(22, 163, 74, 0.35);
  border-color: rgba(187, 247, 208, 0.9);
}

.filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 15px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.5) 0%, rgba(255, 255, 255, 0.2) 100%);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  padding: 16px 24px;
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.8);
  box-shadow: 0 4px 24px -6px rgba(0, 0, 0, 0.05);
  margin-bottom: 20px;
}

.left-actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

/* ======== 表格与筛选区深度重构：现代玻璃与微缩阴影 ======== */

/* 搜索框与按钮拟态圆角化 */
:deep(.el-input__wrapper) {
  border-radius: 20px;
  background-color: rgba(255, 255, 255, 0.7);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04) !important;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.5);
  transition: all 0.3s ease;
}
:deep(.el-input__wrapper:hover), :deep(.el-input__wrapper.is-focus) {
  background-color: #ffffff;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.15) !important;
  border-color: rgba(99, 102, 241, 0.4);
}
:deep(.el-button) {
  border-radius: 8px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  border: none;
}
:deep(.el-button:hover) {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  filter: brightness(1.05); /* 仅用少许亮度变化代替位移，按客户要求不要往上跑 */
}

/* 主按钮定制光效（“新增竞赛/编辑” 等） - 调浅更温和的高级紫/蓝 */
:deep(.el-button--primary) {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.85) 0%, rgba(129, 140, 248, 0.9) 100%);
  color: #ffffff;
  box-shadow: 0 4px 12px -2px rgba(99, 102, 241, 0.2);
}
:deep(.el-button--primary:hover) {
  background: linear-gradient(135deg, #6366f1 0%, #818cf8 100%);
  box-shadow: 0 6px 16px -2px rgba(99, 102, 241, 0.35);
}

/* 危险按钮定制光效（“批量删除/删除” 等） - 调浅更通透的玫瑰色/水红 */
:deep(.el-button--danger) {
  background: linear-gradient(135deg, rgba(244, 63, 94, 0.85) 0%, rgba(251, 113, 133, 0.9) 100%);
  color: #ffffff;
  box-shadow: 0 4px 12px -2px rgba(244, 63, 94, 0.2);
}
:deep(.el-button--danger:hover) {
  background: linear-gradient(135deg, #f43f5e 0%, #fb7185 100%);
  box-shadow: 0 6px 16px -2px rgba(244, 63, 94, 0.35);
}

/* 默认按钮定制光效（“批量导入/导出” 等） */
:deep(.el-button--default) {
  background: rgba(255, 255, 255, 0.7);
  border: 1px solid rgba(226, 232, 240, 0.8);
  color: #475569;
  backdrop-filter: blur(4px);
}
:deep(.el-button--default:hover) {
  background: #ffffff;
  color: #4f46e5;
  border-color: #c7d2fe;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.1);
}

/* 主表格透明与拟态化 */
:deep(.el-table) {
  background-color: transparent !important;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0,0,0,0.03);
  margin-top: 10px;
  --el-table-border-color: rgba(226, 232, 240, 0.4);
  --el-table-row-hover-bg-color: rgba(241, 245, 249, 0.7);
}

:deep(.el-table tr), :deep(.el-table th.el-table__cell) {
  background-color: transparent !important;
}

/* 斑马隔行弱化处理，保持通透感 */
:deep(.el-table--striped .el-table__body tr.el-table__row--striped td.el-table__cell) {
  background-color: rgba(248, 250, 252, 0.4) !important;
}

/* 表头重塑：微透强对比度 */
:deep(.el-table th.el-table__cell) {
  background: linear-gradient(180deg, rgba(241, 245, 249, 0.8) 0%, rgba(248, 250, 252, 0.5) 100%) !important;
  color: #475569;
  font-weight: 700;
  font-size: 14px;
  height: 56px;
  border-bottom: 2px solid rgba(226, 232, 240, 0.8) !important;
}

/* 行悬浮高级高亮：毛玻璃呼吸光 */
:deep(.el-table tbody tr:hover > td.el-table__cell) {
  background: linear-gradient(90deg, rgba(238, 242, 255, 0.4) 0%, rgba(224, 231, 255, 0.6) 50%, rgba(238, 242, 255, 0.4) 100%) !important;
  backdrop-filter: blur(4px);
  transition: all 0.3s ease;
}

/* 单元格字体精修 */
:deep(.el-table td.el-table__cell) {
  padding: 14px 0;
  color: #334155;
  border-bottom: 1px solid rgba(226, 232, 240, 0.4);
}

/* ======== 多选框组件(Checkbox)果冻悬浮特效 ======== */
:deep(.el-checkbox__inner) {
  width: 18px;
  height: 18px;
  border-radius: 6px;
  border: 1px solid rgba(147, 197, 253, 0.8) !important; /* 浅蓝边框 */
  background-color: rgba(255, 255, 255, 0.6) !important;
  backdrop-filter: blur(4px);
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); /* Q弹缩放 */
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
}

/* 悬浮微扩与高亮 */
:deep(.el-checkbox:hover .el-checkbox__inner) {
  border-color: #3b82f6 !important; /* 亮蓝 */
  transform: scale(1.1);
  box-shadow: 0 0 10px rgba(59, 130, 246, 0.4);
}

/* 选中高定渐变背景及厚重阴影 */
:deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%) !important; /* 天蓝到深蓝渐变 */
  border-color: transparent !important; /* 不用 none 以免边界塌陷，用透明色即可 */
  transform: scale(1.1);
  box-shadow: 0 0 16px rgba(59, 130, 246, 0.5) !important; /* 更均匀的全向光晕，不再像切断的阴影 */
}

/* 解决原版 Element Plus 容器会截断大面积 hover shadow 的 Bug */
/* 必须穿透到单元格 .cell 级别，否则表格单元的 `overflow: hidden` 会将上下的发光完美一刀切 */
:deep(.el-table .cell),
:deep(.el-table th.el-table__cell),
:deep(.el-table td.el-table__cell),
:deep(.el-checkbox),
:deep(.el-checkbox__input) {
  overflow: visible !important;
}

/* 内部对勾精细居中对齐及发光重构 */
:deep(.el-checkbox__inner::after) {
  box-sizing: content-box;
  content: "";
  border: 2px solid white;
  border-left: 0;
  border-top: 0;
  height: 8px; 
  width: 4px;
  position: static !important; /* 弃用容易错位的绝对居中，采用外层 FLEX 对齐 */
  margin-top: -2px; /* 针对 L 形对勾进行视觉重心偏上微调补偿 */
  margin-left: -1px; /* 偏左视觉补偿 */
  transform: rotate(45deg) scaleY(0);
  transition: transform .15s ease-in .05s;
}

/* 强制重写组件原来的 transform 以确保绝对居中，避免 Element Plus 的默认覆盖 */
:deep(.el-checkbox__input.is-checked .el-checkbox__inner::after) {
  transform: rotate(45deg) scaleY(1) !important;
}

/* 单元格字体精修 */
:deep(.el-table td.el-table__cell) {
  padding: 14px 0;
  color: #334155;
  border-bottom: 1px solid rgba(226, 232, 240, 0.4);
}

/* 标签圆润化 */
:deep(.el-tag) {
  border-radius: 8px;
  border: none;
  font-weight: 600;
  letter-spacing: 0.5px;
  padding: 0 12px;
}
:deep(.el-tag--danger) { background-color: rgba(254, 226, 226, 0.8); color: #dc2626; }
:deep(.el-tag--warning) { background-color: rgba(254, 243, 199, 0.8); color: #d97706; }
:deep(.el-tag--success) { background-color: rgba(220, 252, 231, 0.8); color: #16a34a; }
:deep(.el-tag--info) { background-color: rgba(241, 245, 249, 0.8); color: #64748b; }

/* 分页器收尾圆角及悬浮加持 */
:deep(.el-pagination) {
  margin-top: 24px !important;
  padding: 10px;
  background: rgba(255, 255, 255, 0.5);
  border-radius: 12px;
  backdrop-filter: blur(10px);
}
:deep(.el-pagination button), :deep(.el-pager li) {
  background: transparent !important;
  border-radius: 8px;
  transition: all 0.2s ease;
}
:deep(.el-pager li:hover) {
  color: #4f46e5;
  background: rgba(238, 242, 255, 0.8) !important;
}
:deep(.el-pager li.is-active) {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%) !important;
  color: #fff;
  box-shadow: 0 4px 10px rgba(79, 70, 229, 0.3);
  font-weight: bold;
}
</style>
