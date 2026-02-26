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
        
        <!-- 大气优雅的数据看板 -->
        <div class="elegant-dashboard">
          <div class="elegant-card primary" @click="filterByStatus('')">
            <div class="card-info">
              <div class="card-title">总申请数</div>
              <div class="card-num">{{ statistics.totalCount }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><Document /></el-icon></div>
          </div>
          
          <div class="elegant-card pending" @click="filterByStatus('pending')">
            <div class="card-info">
              <div class="card-title">待审核</div>
              <div class="card-num">{{ statistics.pendingCount }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><Timer /></el-icon></div>
          </div>
          
          <div class="elegant-card approved" @click="filterByStatus('approved')">
            <div class="card-info">
              <div class="card-title">已通过</div>
              <div class="card-num">{{ statistics.approvedCount }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><CircleCheck /></el-icon></div>
          </div>
          
          <div class="elegant-card rejected" @click="filterByStatus('rejected')">
            <div class="card-info">
              <div class="card-title">已拒绝</div>
              <div class="card-num">{{ statistics.rejectedCount }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><CircleClose /></el-icon></div>
          </div>
          
          <div class="elegant-card returned" @click="filterByStatus('returned')">
            <div class="card-info">
              <div class="card-title">已打回</div>
              <div class="card-num">{{ statistics.returnedCount }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><RefreshLeft /></el-icon></div>
          </div>
        </div>
        
        <!-- 操作栏 (高级重构) -->
        <div class="premium-filter-bar">
          <div class="left-actions">
            <el-button class="batch-btn batch-approve" @click="handleBatchReview('approved')">
              <el-icon><Check /></el-icon> 批量通过
            </el-button>
            <el-button class="batch-btn batch-return" @click="handleBatchReview('returned')">
              <el-icon><RefreshLeft /></el-icon> 批量打回
            </el-button>
            <el-button class="batch-btn batch-reject" @click="handleBatchReview('rejected')">
              <el-icon><Close /></el-icon> 批量拒绝
            </el-button>
            
            <div class="data-count-badge">
              <span>共 <b class="count-number">{{ pagination.total }}</b> 条信息</span>
            </div>
          </div>
          
          <div class="right-filters">
            <el-input
              v-model="searchStudentNumber"
              placeholder="请输入学号查询"
              clearable
              @input="handleSearch"
              class="premium-input search-number"
              :prefix-icon="Search"
            />
            <el-input
              v-model="searchCompetitionName"
              placeholder="请输入竞赛名称查询"
              clearable
              @input="handleSearch"
              class="premium-input search-name"
              :prefix-icon="Search"
            />
            <el-select
              v-model="filterStatus"
              placeholder="选择状态"
              clearable
              @change="handleSearch"
              class="premium-select"
            >
              <el-option label="待审核" value="pending" />
              <el-option label="已通过" value="approved" />
              <el-option label="已拒绝" value="rejected" />
              <el-option label="已打回" value="returned" />
            </el-select>
          </div>
        </div>
        
        <!-- 申请列表 -->
        <el-table
          :data="applicationList"
          v-loading="loading"
          class="premium-table"
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
          <el-table-column label="操作" width="340" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-btn-group">
                <el-button 
                  size="small" 
                  class="action-btn view-btn"
                  @click="handleViewDetail(row)"
                >
                  查看详情
                </el-button>
                <template v-if="row.applicationStatus === 'pending'">
                  <el-button 
                    size="small" 
                    class="action-btn approve-btn"
                    @click="handleReview(row, 'approved')"
                  >
                    通过
                  </el-button>
                  <el-button 
                    size="small" 
                    class="action-btn return-btn"
                    @click="handleReview(row, 'returned')"
                  >
                    打回
                  </el-button>
                  <el-button 
                    size="small" 
                    class="action-btn reject-btn"
                    @click="handleReview(row, 'rejected')"
                  >
                    拒绝
                  </el-button>
                </template>
                <template v-else>
                  <el-button 
                    size="small" 
                    class="action-btn return-btn"
                    @click="handleReReviewFromTable(row)"
                  >
                    重新审核
                  </el-button>
                </template>
              </div>
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
      :destroy-on-close="true"
      class="premium-dialog"
      @close="handleDetailDialogClose"
    >
      <div v-loading="detailLoading" style="min-height: 200px">
        <div v-if="currentDetail.applicationId">
          <!-- 基本信息 -->
          <div class="premium-section">
            <h4 class="premium-title">基本信息</h4>
            <el-descriptions :column="2" border class="premium-desc">
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
          <div class="premium-section" v-if="currentDetail.teamMembers && currentDetail.teamMembers.length > 0">
            <h4 class="premium-title">团队成员</h4>
            <el-table :data="currentDetail.teamMembers" border class="premium-inner-table">
              <el-table-column type="index" label="序号" width="60" align="center" />
              <el-table-column label="学号" width="140">
                <template #default="{ row }">{{ row.externalNumber || row.studentNumber || '-' }}</template>
              </el-table-column>
              <el-table-column label="姓名" width="100">
                <template #default="{ row }">{{ row.externalName || row.studentName || '-' }}</template>
              </el-table-column>
              <el-table-column label="学院" min-width="150">
                <template #default="{ row }">{{ row.college || '无' }}</template>
              </el-table-column>
              <el-table-column label="学校" min-width="150">
                <template #default="{ row }">{{ row.externalSchool || '本校' }}</template>
              </el-table-column>
              <el-table-column label="是否队长" width="100" align="center">
                <template #default="{ row }">
                  <el-tag v-if="row.isLeader === 1 || row.isLeader === true" type="success" size="small">队长</el-tag>
                  <span v-else>队员</span>
                </template>
              </el-table-column>
            </el-table>
          </div>
          
          <!-- 指导教师 -->
          <div class="premium-section" v-if="currentDetail.teachers && currentDetail.teachers.length > 0">
            <h4 class="premium-title">指导教师</h4>
            <el-table :data="currentDetail.teachers" border class="premium-inner-table">
              <el-table-column type="index" label="序号" width="60" align="center" />
              <el-table-column prop="teacherName" label="姓名" width="120" />
              <el-table-column prop="teacherNo" label="工号" width="120" />
              <el-table-column prop="teacherDepartment" label="所在单位" min-width="200" />
            </el-table>
          </div>
          
          <!-- 证明材料 -->
          <div class="premium-section">
            <h4 class="premium-title">证明材料</h4>
            <div v-if="currentDetail.files && currentDetail.files.length > 0">
              <div class="file-list">
                <div v-for="file in currentDetail.files" :key="file.fileId" class="premium-file-item" @click="handlePreviewFile(file)">
                  <div class="file-info">
                    <el-icon class="file-icon"><Document /></el-icon>
                    <div>
                      <div class="file-name">{{ file.fileName }}</div>
                      <div class="file-meta">
                        {{ formatFileSize(file.fileSize) }} | {{ formatDateTime(file.uploadTime) }}
                      </div>
                    </div>
                  </div>
                  <el-button type="primary" size="small" class="action-btn view-btn" @click.stop="handlePreviewFile(file)" plain>预览</el-button>
                </div>
              </div>
            </div>
            <div v-else class="empty-text">无附件材料</div>
          </div>
        </div>
      </div>
      <template #footer>
        <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
          <div>
            <el-button 
              v-if="currentDetail.applicationStatus === 'approved' || currentDetail.applicationStatus === 'rejected' || currentDetail.applicationStatus === 'returned'"
              class="action-btn return-btn" 
              @click="handleReReview"
            >
              重新审核
            </el-button>
          </div>
          <div style="display: flex; gap: 12px">
            <template v-if="currentDetail.applicationStatus === 'pending'">
              <el-button class="action-btn reject-btn" @click="handleReviewSingle('rejected')">拒绝</el-button>
              <el-button class="action-btn return-btn" @click="handleReviewSingle('returned')">打回</el-button>
              <el-button class="action-btn approve-btn" @click="handleReviewSingle('approved')">通过</el-button>
            </template>
            <el-button class="action-btn" @click="detailDialogVisible = false">关 闭</el-button>
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
      <div style="text-align: center; min-height: 500px; display: flex; align-items: center; justify-content: center; background-color: #f8fafc; border-radius: 8px;">
        <img 
          v-if="isPreviewImage" 
          :src="getFilePreviewUrl(previewFileData.filePath)" 
          style="max-width: 100%; max-height: 60vh; object-fit: contain; box-shadow: 0 4px 12px rgba(0,0,0,0.1);" 
          alt="预览图片" 
        />
        <iframe 
          v-else-if="previewFileData.filePath"
          :src="getFilePreviewUrl(previewFileData.filePath)"
          style="width: 100%; height: 60vh; border: none"
        ></iframe>
      </div>
      <template #footer>
        <el-button @click="previewDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Document, Check, Close, RefreshLeft } from '@element-plus/icons-vue'
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

const handleReviewSingle = async (status) => {
  const statusText = statusTextMap[status]
  
  try {
    await ElMessageBox.confirm(
      `确定要将申请"${currentDetail.value.competitionName}"${statusText}吗？`,
      '审核确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    await axios.post(`${API_BASE_URL}/single`, {
      applicationId: currentDetail.value.applicationId,
      status: status
    })
    
    ElMessage.success(`${statusText}成功`)
    detailDialogVisible.value = false
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

// 判断是否为图片
const isPreviewImage = computed(() => {
  if (!previewFileData.filePath) return false;
  const ext = previewFileData.filePath.split('.').pop().toLowerCase();
  return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(ext);
});

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
  /* background 交由 App.vue 处理 */
}

.content-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.review-card {
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
  color: #303133;
}

/* 大气优雅的数据看板 */
.elegant-dashboard {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 24px;
  margin-bottom: 32px;
}

.elegant-card {
  position: relative;
  background: rgba(255, 255, 255, 0.65);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.9);
  border-radius: 20px;
  padding: 30px 24px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03), inset 0 0 0 1px rgba(255, 255, 255, 0.5);
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  display: flex;
  flex-direction: column;
  justify-content: center;
  cursor: pointer;
}

.elegant-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.06), inset 0 0 0 1px rgba(255, 255, 255, 1);
  background: rgba(255, 255, 255, 0.9);
}

.card-info {
  position: relative;
  z-index: 2;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 16px;
  font-weight: 600;
  color: #64748b;
  margin-bottom: 12px;
  letter-spacing: 0.5px;
}

.card-title .el-icon {
  font-size: 18px;
}

.card-num {
  font-size: 46px;
  font-weight: 800;
  color: #0f172a;
  font-family: 'Inter', -apple-system, sans-serif;
  line-height: 1;
  letter-spacing: -1px;
}

.card-bg-icon {
  position: absolute;
  right: -24px;
  bottom: -30px;
  font-size: 140px;
  color: #cbd5e1;
  opacity: 0.15;
  z-index: 1;
  transition: all 0.5s cubic-bezier(0.16, 1, 0.3, 1);
}

.elegant-card:hover .card-bg-icon {
  transform: scale(1.1) rotate(-8deg);
  opacity: 0.25;
}

/* 专属色彩点缀：高级渐变与异色 */
.elegant-card.primary .card-num {
  background: linear-gradient(135deg, #4f46e5, #9333ea);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.elegant-card.primary .card-bg-icon { color: #818cf8; }

.elegant-card.pending .card-num { color: #d97706; }
.elegant-card.pending .card-bg-icon { color: #fcd34d; }

.elegant-card.approved .card-num { color: #059669; }
.elegant-card.approved .card-bg-icon { color: #6ee7b7; }

.elegant-card.rejected .card-num { color: #dc2626; }
.elegant-card.rejected .card-bg-icon { color: #fca5a5; }

.elegant-card.returned .card-num { color: #475569; }
.elegant-card.returned .card-bg-icon { color: #94a3b8; }

/* 高级重构工具栏 */
.premium-filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 12px;
  padding: 16px 20px;
  margin-bottom: 24px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.02);
}

.left-actions {
  display: flex;
  gap: 12px;
  align-items: center;
}

.batch-btn {
  border: none !important;
  color: white !important;
  font-weight: 600 !important;
  border-radius: 8px !important;
  padding: 8px 16px !important;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
}
.batch-btn .el-icon {
  margin-right: 4px;
}

.batch-approve { background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important; box-shadow: 0 4px 10px rgba(16, 185, 129, 0.2) !important; }
.batch-approve:hover { transform: translateY(-2px) !important; box-shadow: 0 6px 15px rgba(16, 185, 129, 0.35) !important; opacity: 0.95 !important; }

.batch-return { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%) !important; box-shadow: 0 4px 10px rgba(245, 158, 11, 0.2) !important; }
.batch-return:hover { transform: translateY(-2px) !important; box-shadow: 0 6px 15px rgba(245, 158, 11, 0.35) !important; opacity: 0.95 !important; }

.batch-reject { background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%) !important; box-shadow: 0 4px 10px rgba(239, 68, 68, 0.2) !important; }
.batch-reject:hover { transform: translateY(-2px) !important; box-shadow: 0 6px 15px rgba(239, 68, 68, 0.35) !important; opacity: 0.95 !important; }

.data-count-badge {
  margin-left: 10px;
  padding: 6px 16px;
  background: rgba(255, 255, 255, 0.7);
  border-radius: 20px;
  font-size: 14px;
  color: #64748b;
  border: 1px solid rgba(226, 232, 240, 0.8);
}
.data-count-badge .count-number {
  color: #6366f1;
  font-size: 16px;
  font-weight: 700;
  margin: 0 4px;
}

.right-filters {
  display: flex;
  align-items: center;
  gap: 12px;
}

:deep(.premium-input .el-input__wrapper), 
:deep(.premium-select .el-input__wrapper) {
  background-color: rgba(255, 255, 255, 0.8);
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.02) !important;
  border-radius: 8px;
  transition: all 0.3s;
}

:deep(.premium-input .el-input__wrapper:hover), 
:deep(.premium-select .el-input__wrapper:hover),
:deep(.premium-input .el-input__wrapper.is-focus),
:deep(.premium-select .el-input__wrapper.is-focus) {
  background-color: #ffffff;
  box-shadow: 0 0 0 1px #6366f1 !important;
}

.search-number, .search-name { width: 180px; }
.premium-select { width: 130px; }

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
/* ===== 现代高级透明表格核心逻辑 ===== */
.premium-table {
  width: 100%;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
  background: white !important;
  /* 去除默认边框 */
  --el-table-border-color: transparent;
  --el-table-header-bg-color: #f8fafc;
  margin-top: 15px;
}

:deep(.premium-table .el-table__header-wrapper th) {
  background-color: #f8fafc !important;
  color: #64748b;
  font-weight: 600;
  font-size: 14px;
  height: 54px;
  border-bottom: 1px solid #e2e8f0 !important;
}

/* 添加全行动画基础 */
:deep(.premium-table .el-table__row) {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background-color: white !important;
}

:deep(.premium-table .el-table__row td) {
  padding: 16px 0;
  border-bottom: 1px solid transparent !important;
}

/* 原有的特定审核状态上色层与悬停效果完美兼容 */
:deep(.premium-table .row-approved td) { background-color: #f0fdf4 !important; }
:deep(.premium-table .row-returned td) { background-color: #fffbeb !important; }
:deep(.premium-table .row-rejected td) { background-color: #fef2f2 !important; }

/* 动态悬浮突起发光：核心吸睛点 */
:deep(.premium-table .el-table__row:hover td) {
  background-color: #eef2ff !important;
}

:deep(.premium-table .el-table__row:hover) {
  transform: scale(1.002) translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.1), 0 4px 6px -4px rgba(99, 102, 241, 0.05);
  position: relative;
  z-index: 10;
}

/* 隐藏表格根部杂线 */
:deep(.premium-table::before) { display: none; }

/* 重新美化状态标签 */
:deep(.premium-table .el-tag) {
  border: none;
  border-radius: 8px;
  padding: 4px 12px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

:deep(.premium-table .el-tag--warning) { background: #fef3c7; color: #d97706; }
:deep(.premium-table .el-tag--success) { background: #d1fae5; color: #059669; }
:deep(.premium-table .el-tag--danger) { background: #fee2e2; color: #dc2626; }
:deep(.premium-table .el-tag--info) { background: #f1f5f9; color: #475569; }

/* ===== 炫酷动画操作按钮 - 药丸风格组群 ===== */
.action-btn-group {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.action-btn {
  border: 1px solid rgba(0, 0, 0, 0.04) !important;
  border-radius: 6px !important; /* 恢复为常规圆角长方形 */
  padding: 6px 14px !important;
  font-weight: 600 !important;
  font-size: 13px !important;
  letter-spacing: 0.5px;
  background: #ffffff !important;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02) !important;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1) !important;
}

/* 查看详情 -> 科技紫 */
.action-btn.view-btn { color: #6366f1 !important; }
.action-btn.view-btn:hover {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
  color: white !important; border-color: transparent !important;
  transform: scale(1.05) !important; box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35) !important;
}

/* 通过 -> 清新绿 */
.action-btn.approve-btn { color: #10b981 !important; }
.action-btn.approve-btn:hover {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
  color: white !important; border-color: transparent !important;
  transform: scale(1.05) !important; box-shadow: 0 4px 15px rgba(16, 185, 129, 0.35) !important;
}

/* 打回/重审 -> 阳光橙 */
.action-btn.return-btn { color: #f59e0b !important; }
.action-btn.return-btn:hover {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%) !important;
  color: white !important; border-color: transparent !important;
  transform: scale(1.05) !important; box-shadow: 0 4px 15px rgba(245, 158, 11, 0.35) !important;
}

/* 拒绝 -> 魅影红 */
.action-btn.reject-btn { color: #ef4444 !important; }
.action-btn.reject-btn:hover {
  background: linear-gradient(135deg, #ef4444 0%, #f43f5e 100%) !important;
  color: white !important; border-color: transparent !important;
  transform: scale(1.05) !important; box-shadow: 0 4px 15px rgba(239, 68, 68, 0.35) !important;
}

.action-btn:active {
  transform: scale(0.95) !important;
}

/* ======== 多选框组件(Checkbox)果冻悬浮特效 (全向弥散光圈) ======== */
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

/* ===== 高品质卡片式详情弹窗 ===== */
:deep(.premium-dialog) {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
}

:deep(.premium-dialog .el-dialog__header) {
  margin: 0;
  padding: 24px 24px 20px;
  background: linear-gradient(to right, #f8fafc, #ffffff);
  border-bottom: 1px solid #f1f5f9;
}

:deep(.premium-dialog .el-dialog__title) {
  font-size: 18px;
  font-weight: 700;
  color: #1e293b;
}

:deep(.premium-dialog .el-dialog__body) {
  padding: 20px 24px;
  background-color: #f8fafc; /* 使用灰色底衬托白色的内容卡片 */
}

:deep(.premium-dialog .el-dialog__footer) {
  padding: 16px 24px;
  background: #ffffff;
  border-top: 1px solid #f1f5f9;
}

/* 详情卡片块 */
.premium-section {
  background: #ffffff;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 20px;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.02);
  border: 1px solid rgba(226, 232, 240, 0.8);
}

.premium-section:last-child {
  margin-bottom: 0;
}

.premium-title {
  display: flex;
  align-items: center;
  font-size: 16px;
  font-weight: 600;
  color: #334155;
  margin-bottom: 20px;
  margin-top: 0;
}

.premium-title::before {
  content: '';
  display: block;
  width: 4px;
  height: 18px;
  background: linear-gradient(to bottom, #6366f1, #a855f7);
  border-radius: 4px;
  margin-right: 10px;
}

/* 美化描述列表表单 */
:deep(.premium-desc) {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid #e2e8f0;
}

:deep(.premium-desc .el-descriptions__body) {
  border-radius: 8px;
}

:deep(.premium-desc .el-descriptions__label) {
  background-color: #f8fafc !important;
  color: #64748b;
  font-weight: 600;
  width: 120px;
}

/* 内部小表格美化 */
:deep(.premium-inner-table) {
  border-radius: 8px;
  overflow: hidden;
  --el-table-border-color: #e2e8f0;
}

:deep(.premium-inner-table th) {
  background-color: #f8fafc !important;
  color: #475569;
  font-weight: 600;
}

/* 附件项美化 */
.file-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.premium-file-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background-color: #ffffff;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  cursor: pointer;
}

.premium-file-item:hover {
  background-color: #f8fafc;
  border-color: #cbd5e1;
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05);
}

.file-info {
  display: flex;
  align-items: center;
}

.file-icon {
  font-size: 32px;
  color: #6366f1;
  margin-right: 16px;
  opacity: 0.9;
}

.file-name {
  font-weight: 600;
  color: #334155;
  margin-bottom: 4px;
  font-size: 14px;
}

.file-meta {
  font-size: 12px;
  color: #94a3b8;
}

.empty-text {
  color: #94a3b8;
  padding: 20px 0;
  text-align: center;
  font-size: 14px;
  background: #f8fafc;
  border-radius: 8px;
  border: 1px dashed #e2e8f0;
}
</style>
