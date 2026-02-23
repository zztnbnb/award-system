<template>
  <div class="admin-review-page">
    <NavBar />
    
    <div class="content-container">
      <el-card class="review-card">
        <template #header>
          <div class="card-header">
            <h2>审核管理</h2>
          </div>
        </template>
        
        <!-- 统计信息 -->
        <div class="statistics-bar">
          <div class="stat-item" @click="filterByStatus('')">
            <div class="stat-value">{{ statistics.totalCount }}</div>
            <div class="stat-label">总申请数</div>
          </div>
          <div class="stat-item pending" @click="filterByStatus('pending')">
            <div class="stat-value">{{ statistics.pendingCount }}</div>
            <div class="stat-label">待审核</div>
          </div>
          <div class="stat-item approved" @click="filterByStatus('approved')">
            <div class="stat-value">{{ statistics.approvedCount }}</div>
            <div class="stat-label">已通过</div>
          </div>
          <div class="stat-item rejected" @click="filterByStatus('rejected')">
            <div class="stat-value">{{ statistics.rejectedCount }}</div>
            <div class="stat-label">已拒绝</div>
          </div>
          <div class="stat-item returned" @click="filterByStatus('returned')">
            <div class="stat-value">{{ statistics.returnedCount }}</div>
            <div class="stat-label">已打回</div>
          </div>
        </div>
        
        <!-- 操作栏 -->
        <div class="filter-bar">
          <div class="left-actions">
            <el-button 
              type="success" 
              @click="handleBatchReview('approved')"
            >
              批量通过
            </el-button>
            <el-button 
              type="warning" 
              @click="handleBatchReview('returned')"
            >
              批量打回
            </el-button>
            <el-button 
              type="danger" 
              @click="handleBatchReview('rejected')"
            >
              批量拒绝
            </el-button>
          </div>
          <div class="right-filters">
            <el-input
              v-model="searchStudentNumber"
              placeholder="请输入学号查询"
              clearable
              @input="handleSearch"
              style="width: 200px; margin-right: 10px"
              :prefix-icon="Search"
            />
            <el-input
              v-model="searchCompetitionName"
              placeholder="请输入竞赛名称查询"
              clearable
              @input="handleSearch"
              style="width: 200px; margin-right: 10px"
              :prefix-icon="Search"
            />
            <el-select
              v-model="filterStatus"
              placeholder="选择状态"
              clearable
              @change="handleSearch"
              style="width: 120px; margin-right: 20px"
            >
              <el-option label="待审核" value="pending" />
              <el-option label="已通过" value="approved" />
              <el-option label="已拒绝" value="rejected" />
              <el-option label="已打回" value="returned" />
            </el-select>
            <span style="color: #606266; font-size: 14px; white-space: nowrap; display: inline-block; min-width: 100px;">
              共 {{ pagination.total }} 条信息
            </span>
          </div>
        </div>
        
        <!-- 申请列表 -->
        <el-table
          :data="applicationList"
          stripe
          v-loading="loading"
          style="width: 100%"
          @selection-change="handleSelectionChange"
          :row-class-name="getRowClassName"
        >
          <el-table-column type="selection" width="55" align="center" :selectable="isSelectable" />
          <el-table-column type="index" label="序号" width="80" align="center" />
          <el-table-column prop="studentNumber" label="学生学号" width="120" />
          <el-table-column prop="competitionName" label="竞赛名称" min-width="180" />
          <el-table-column prop="competitionLevel" label="竞赛级别" width="100" />
          <el-table-column label="获奖等级" width="100">
            <template #default="{ row }">
              <el-tag :type="getAwardRankType(row.awardRank)">{{ row.awardRank }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="awardTime" label="获奖时间" width="120" />
          <el-table-column label="申请状态" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.applicationStatus)">
                {{ getStatusText(row.applicationStatus) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="提交时间" width="160">
            <template #default="{ row }">
              {{ formatDateTime(row.createTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="320" align="center" fixed="right">
            <template #default="{ row }">
              <el-button 
                type="primary" 
                size="small" 
                @click="handleViewDetail(row)"
              >
                查看详情
              </el-button>
              <template v-if="row.applicationStatus === 'pending'">
                <el-button 
                  type="success" 
                  size="small" 
                  @click="handleReview(row, 'approved')"
                >
                  通过
                </el-button>
                <el-button 
                  type="warning" 
                  size="small" 
                  @click="handleReview(row, 'returned')"
                >
                  打回
                </el-button>
                <el-button 
                  type="danger" 
                  size="small" 
                  @click="handleReview(row, 'rejected')"
                >
                  拒绝
                </el-button>
              </template>
              <template v-else>
                <el-button 
                  type="warning" 
                  size="small" 
                  @click="handleReReviewFromTable(row)"
                >
                  重新审核
                </el-button>
              </template>
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

    <!-- 详情弹窗 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="申请详情"
      width="900px"
      @close="handleDetailDialogClose"
    >
      <div v-loading="detailLoading" style="min-height: 200px">
        <div v-if="currentDetail.applicationId">
          <!-- 基本信息 -->
          <div class="detail-section">
            <h4 class="section-title">基本信息</h4>
            <el-descriptions :column="2" border>
              <el-descriptions-item label="申请编号">{{ currentDetail.applicationNumber }}</el-descriptions-item>
              <el-descriptions-item label="申请状态">
                <el-tag :type="getStatusType(currentDetail.applicationStatus)">
                  {{ getStatusText(currentDetail.applicationStatus) }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="竞赛名称">{{ currentDetail.competitionName }}</el-descriptions-item>
              <el-descriptions-item label="项目名称">{{ currentDetail.projectName }}</el-descriptions-item>
              <el-descriptions-item label="竞赛类型">{{ currentDetail.competitionType }}</el-descriptions-item>
              <el-descriptions-item label="竞赛级别">{{ currentDetail.competitionLevel }}</el-descriptions-item>
              <el-descriptions-item label="获奖等次">
                <el-tag :type="getAwardRankType(currentDetail.awardRank)">{{ currentDetail.awardRank }}</el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="获奖等级">{{ currentDetail.awardLevel }}</el-descriptions-item>
              <el-descriptions-item label="获奖时间">{{ currentDetail.awardTime }}</el-descriptions-item>
              <el-descriptions-item label="获奖数量">{{ currentDetail.awardQuantity }}</el-descriptions-item>
              <el-descriptions-item label="获奖人数">{{ currentDetail.awardPersonCount }}</el-descriptions-item>
              <el-descriptions-item label="联系方式">{{ currentDetail.contact }}</el-descriptions-item>
            </el-descriptions>
          </div>
          
          <!-- 团队成员 -->
          <div class="detail-section" style="margin-top: 20px">
            <h4 class="section-title">团队成员</h4>
            <div v-if="currentDetail.teamMembers && currentDetail.teamMembers.length > 0">
              <el-table :data="currentDetail.teamMembers" border>
                <el-table-column type="index" label="序号" width="60" align="center" />
                <el-table-column label="学号" width="140">
                  <template #default="{ row }">
                    {{ row.externalNumber || row.studentNumber || '-' }}
                  </template>
                </el-table-column>
                <el-table-column label="姓名" width="100">
                  <template #default="{ row }">
                    {{ row.externalName || row.studentName || '-' }}
                  </template>
                </el-table-column>
                <el-table-column label="学院" min-width="150">
                  <template #default="{ row }">
                    {{ row.college || '无' }}
                  </template>
                </el-table-column>
                <el-table-column label="学校" min-width="150">
                  <template #default="{ row }">
                    {{ row.externalSchool || '本校' }}
                  </template>
                </el-table-column>
                <el-table-column label="是否队长" width="100" align="center">
                  <template #default="{ row }">
                    <el-tag v-if="row.isLeader === 1 || row.isLeader === true" type="success" size="small">队长</el-tag>
                    <span v-else>队员</span>
                  </template>
                </el-table-column>
              </el-table>
            </div>
            <div v-else style="color: #999; padding: 10px 0">无</div>
          </div>
          
          <!-- 指导教师 -->
          <div class="detail-section" style="margin-top: 20px">
            <h4 class="section-title">指导教师</h4>
            <div v-if="currentDetail.teachers && currentDetail.teachers.length > 0">
              <el-table :data="currentDetail.teachers" border>
                <el-table-column type="index" label="序号" width="60" align="center" />
                <el-table-column prop="teacherName" label="姓名" width="120" />
                <el-table-column prop="teacherNo" label="工号" width="120" />
                <el-table-column prop="teacherDepartment" label="所在单位" min-width="200" />
              </el-table>
            </div>
            <div v-else style="color: #999; padding: 10px 0">无</div>
          </div>
          
          <!-- 证明材料 -->
          <div class="detail-section" style="margin-top: 20px">
            <h4 class="section-title">证明材料</h4>
            <div v-if="currentDetail.files && currentDetail.files.length > 0">
              <div class="file-list">
                <div v-for="file in currentDetail.files" :key="file.fileId" class="file-item">
                  <div class="file-info">
                    <i class="el-icon-document" style="font-size: 24px; color: #409eff; margin-right: 10px"></i>
                    <div>
                      <div style="font-weight: 500">{{ file.fileName }}</div>
                      <div style="font-size: 12px; color: #999">
                        {{ formatFileSize(file.fileSize) }} | {{ formatDateTime(file.uploadTime) }}
                      </div>
                    </div>
                  </div>
                  <el-button type="primary" size="small" @click="handlePreviewFile(file)">预览</el-button>
                </div>
              </div>
            </div>
            <div v-else style="color: #999; padding: 10px 0">无</div>
          </div>
        </div>
      </div>
      <template #footer>
        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
          <div>
            <el-button 
              v-if="currentDetail.applicationStatus === 'approved' || currentDetail.applicationStatus === 'rejected' || currentDetail.applicationStatus === 'returned'"
              type="warning" 
              @click="handleReReview"
            >
              重新审核
            </el-button>
          </div>
          <div>
            <el-button @click="detailDialogVisible = false">关闭</el-button>
          </div>
        </div>
      </template>
    </el-dialog>

    <!-- 文件预览弹窗 -->
    <el-dialog
      v-model="previewDialogVisible"
      :title="previewFileData.fileName"
      width="80%"
      @close="handlePreviewDialogClose"
    >
      <div style="text-align: center; min-height: 500px">
        <iframe 
          v-if="previewFileData.filePath"
          :src="getFilePreviewUrl(previewFileData.filePath)"
          style="width: 100%; height: 600px; border: none"
        ></iframe>
      </div>
      <template #footer>
        <el-button @click="previewDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search } from '@element-plus/icons-vue'
import axios from 'axios'
import NavBar from '../components/NavBar.vue'

const API_BASE_URL = 'http://localhost:9998/api/review'

const loading = ref(false)
const detailLoading = ref(false)
const detailDialogVisible = ref(false)
const previewDialogVisible = ref(false)
const searchStudentNumber = ref('')
const searchCompetitionName = ref('')
const filterStatus = ref('')
const selectedIds = ref([])

const statistics = reactive({
  totalCount: 0,
  pendingCount: 0,
  approvedCount: 0,
  rejectedCount: 0,
  returnedCount: 0
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const applicationList = ref([])
const currentDetail = ref({})
const previewFileData = reactive({
  fileName: '',
  filePath: ''
})

const statusTextMap = {
  'pending': '待审核',
  'approved': '已通过',
  'rejected': '已拒绝',
  'returned': '已打回'
}

onMounted(() => {
  loadStatistics()
  loadApplicationList()
})

const loadStatistics = async () => {
  try {
    const response = await axios.get(`${API_BASE_URL}/statistics`)
    Object.assign(statistics, response.data)
  } catch (error) {
    console.error('加载统计信息失败:', error)
  }
}

const loadApplicationList = async () => {
  loading.value = true
  try {
    const response = await axios.get(`${API_BASE_URL}/list`, {
      params: {
        status: filterStatus.value,
        competitionName: searchCompetitionName.value,
        studentNumber: searchStudentNumber.value,
        page: pagination.page,
        pageSize: pagination.pageSize
      }
    })
    applicationList.value = response.data.list || []
    pagination.total = response.data.total || 0
  } catch (error) {
    ElMessage.error('加载申请列表失败')
    console.error('加载申请列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  pagination.page = 1
  loadApplicationList()
}

const handlePageChange = (page) => {
  pagination.page = page
  loadApplicationList()
}

const handleSizeChange = (pageSize) => {
  pagination.pageSize = pageSize
  pagination.page = 1
  loadApplicationList()
}

const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.applicationId)
}

const isSelectable = (row) => {
  return row.applicationStatus === 'pending'
}

const filterByStatus = (status) => {
  filterStatus.value = status
  handleSearch()
}

const getRowClassName = ({ row }) => {
  if (row.applicationStatus === 'approved') {
    return 'row-approved'
  } else if (row.applicationStatus === 'returned') {
    return 'row-returned'
  } else if (row.applicationStatus === 'rejected') {
    return 'row-rejected'
  }
  return ''
}

const getStatusType = (status) => {
  const typeMap = {
    'pending': 'warning',
    'approved': 'success',
    'rejected': 'danger',
    'returned': 'info'
  }
  return typeMap[status] || 'info'
}

const getStatusText = (status) => {
  return statusTextMap[status] || status
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

const formatDateTime = (dateTime) => {
  if (!dateTime) return '-'
  const date = new Date(dateTime)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatFileSize = (bytes) => {
  if (!bytes) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

const handleViewDetail = async (row) => {
  detailDialogVisible.value = true
  detailLoading.value = true
  
  try {
    const response = await axios.get(`${API_BASE_URL}/detail/${row.applicationId}`)
    currentDetail.value = {
      ...response.data,
      competitionName: row.competitionName
    }
  } catch (error) {
    ElMessage.error('加载详情失败')
    console.error('加载详情失败:', error)
    detailDialogVisible.value = false
  } finally {
    detailLoading.value = false
  }
}

const handleReview = async (row, status) => {
  const statusText = statusTextMap[status]
  
  try {
    await ElMessageBox.confirm(
      `确定要将申请"${row.competitionName}"${statusText}吗？`,
      '审核确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await axios.post(`${API_BASE_URL}/single`, {
      applicationId: row.applicationId,
      status: status
    })
    
    ElMessage.success(`${statusText}成功`)
    loadStatistics()
    loadApplicationList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`${statusText}失败`)
      console.error('审核失败:', error)
    }
  }
}

const handleBatchReview = async (status) => {
  const statusText = statusTextMap[status]
  
  if (selectedIds.value.length === 0) {
    ElMessage.warning('请先选择要审核的申请')
    return
  }
  
  try {
    await ElMessageBox.confirm(
      `确定要将选中的 ${selectedIds.value.length} 个申请${statusText}吗？`,
      '批量审核确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await axios.post(`${API_BASE_URL}/batch`, {
      applicationIds: selectedIds.value,
      status: status
    })
    
    ElMessage.success(`批量${statusText}成功`)
    selectedIds.value = []
    loadStatistics()
    loadApplicationList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(`批量${statusText}失败`)
      console.error('批量审核失败:', error)
    }
  }
}

const handleDetailDialogClose = () => {
  currentDetail.value = {}
}

const handleReReview = async () => {
  try {
    await ElMessageBox.confirm(
      '确定要将此申请重新设置为待审核状态吗？',
      '重新审核确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await axios.post(`${API_BASE_URL}/single`, {
      applicationId: currentDetail.value.applicationId,
      status: 'pending'
    })
    
    ElMessage.success('已重新设置为待审核状态')
    detailDialogVisible.value = false
    loadStatistics()
    loadApplicationList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('重新审核失败')
      console.error('重新审核失败:', error)
    }
  }
}

const handleReReviewFromTable = async (row) => {
  try {
    await ElMessageBox.confirm(
      `确定要将申请"${row.competitionName}"重新设置为待审核状态吗？`,
      '重新审核确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await axios.post(`${API_BASE_URL}/single`, {
      applicationId: row.applicationId,
      status: 'pending'
    })
    
    ElMessage.success('已重新设置为待审核状态')
    loadStatistics()
    loadApplicationList()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('重新审核失败')
      console.error('重新审核失败:', error)
    }
  }
}

const handlePreviewFile = (file) => {
  previewFileData.fileName = file.fileName
  previewFileData.filePath = file.filePath
  previewDialogVisible.value = true
}

const getFilePreviewUrl = (filePath) => {
  if (!filePath) return ''
  // 如果filePath已经包含完整URL，直接返回
  if (filePath.startsWith('http')) {
    return filePath
  }
  // 否则拼接base URL
  return `http://localhost:9998${filePath}`
}

const handlePreviewDialogClose = () => {
  previewFileData.fileName = ''
  previewFileData.filePath = ''
}
</script>

<style scoped>
.admin-review-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.content-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.review-card {
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
  gap: 20px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  margin-bottom: 20px;
}

.stat-item {
  flex: 1;
  text-align: center;
  padding: 15px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 6px;
  color: #fff;
  transition: all 0.3s;
  cursor: pointer;
}

.stat-item:hover {
  transform: translateY(-5px);
  background-color: rgba(255, 255, 255, 0.3);
}

.stat-item.pending {
  background-color: rgba(230, 162, 60, 0.3);
}

.stat-item.approved {
  background-color: rgba(103, 194, 58, 0.3);
}

.stat-item.rejected {
  background-color: rgba(245, 108, 108, 0.3);
}

.stat-item.returned {
  background-color: rgba(144, 147, 153, 0.3);
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

.detail-section .section-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 2px solid #409eff;
}

.file-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.file-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  background-color: #f9f9f9;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
}

.file-info {
  display: flex;
  align-items: center;
}

/* 行颜色 */
:deep(.row-approved) {
  background-color: #f0f9ff !important;
}

:deep(.row-returned) {
  background-color: #fffbf0 !important;
}

:deep(.row-rejected) {
  background-color: #fef0f0 !important;
}

:deep(.row-approved:hover) {
  background-color: #e1f3ff !important;
}

:deep(.row-returned:hover) {
  background-color: #fff4d9 !important;
}

:deep(.row-rejected:hover) {
  background-color: #fde2e2 !important;
}
</style>
