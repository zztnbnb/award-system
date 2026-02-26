<template>
  <div class="application-record-page login-wrapper-style">
    <NavBar />
    
    <div class="content-container">
      <el-card class="record-card">
        <template #header>
          <div class="card-header">
            <h2>我的申请记录</h2>
            <el-button type="primary" @click="goToApply" :icon="Plus" class="premium-btn">
              新建申请
            </el-button>
          </div>
        </template>
        
        <!-- 大气优雅的数据看板 -->
        <div class="elegant-dashboard">
          <div class="elegant-card primary">
            <div class="card-info">
              <div class="card-title">总申请数</div>
              <div class="card-num">{{ statistics.total }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><Document /></el-icon></div>
          </div>
          
          <div class="elegant-card pending">
            <div class="card-info">
              <div class="card-title">待审核</div>
              <div class="card-num">{{ statistics.pending }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><Timer /></el-icon></div>
          </div>
          
          <div class="elegant-card approved">
            <div class="card-info">
              <div class="card-title">已通过</div>
              <div class="card-num">{{ statistics.approved }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><CircleCheck /></el-icon></div>
          </div>
          
          <div class="elegant-card rejected">
            <div class="card-info">
              <div class="card-title">已拒绝</div>
              <div class="card-num">{{ statistics.rejected }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><CircleClose /></el-icon></div>
          </div>
          
          <div class="elegant-card returned">
            <div class="card-info">
              <div class="card-title">已打回</div>
              <div class="card-num">{{ statistics.returned }}</div>
            </div>
            <div class="card-bg-icon"><el-icon><RefreshLeft /></el-icon></div>
          </div>
        </div>
        
        <!-- 筛选栏 -->
        <div class="filter-bar premium-filter-bar">
          <el-radio-group v-model="statusFilter" @change="handleFilterChange">
            <el-radio-button value="">全部</el-radio-button>
            <el-radio-button value="pending">待审核</el-radio-button>
            <el-radio-button value="approved">已通过</el-radio-button>
            <el-radio-button value="rejected">已拒绝</el-radio-button>
            <el-radio-button value="returned">已打回</el-radio-button>
          </el-radio-group>
          
          <el-input
            v-model="searchKeyword"
            placeholder="请输入竞赛名称搜索"
            clearable
            @input="handleSearch"
            style="width: 300px"
            :prefix-icon="Search"
          />
        </div>
        
        <!-- 申请列表 -->
        <el-table 
          :data="recordList" 
          v-loading="loading"
          stripe
          class="premium-table"
          style="width: 100%"
        >
          <el-table-column type="index" label="序号" width="60" align="center" />
          <el-table-column label="竞赛类型" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="row.teamId ? 'success' : 'primary'" effect="plain">
                {{ row.teamId ? '团体赛' : '个人赛' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="competitionName" label="竞赛名称" min-width="180" />
          <el-table-column prop="projectName" label="项目名称" min-width="150" />
          <el-table-column prop="competitionLevel" label="竞赛级别" width="100" />
          <el-table-column prop="awardRank" label="获奖等次" width="100" align="center">
            <template #default="{ row }">
              <el-tag :type="getAwardRankType(row.awardRank)">{{ row.awardRank }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="申请状态" width="100">
            <template #default="{ row }">
              <el-tag 
                :type="getStatusType(row.applicationStatus)"
                effect="dark"
              >
                {{ row.statusText }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="提交时间" width="180">
            <template #default="{ row }">
              {{ formatDateTime(row.createTime) }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" align="center" fixed="right">
            <template #default="{ row }">
              <div class="action-btn-group">
                <el-button 
                  type="primary" 
                  size="small" 
                  class="action-btn view-btn"
                  @click="viewDetail(row)"
                  :icon="View"
                >
                  查看
                </el-button>
                <el-button 
                  type="danger" 
                  size="small" 
                  class="action-btn withdraw-btn"
                  @click="handleDelete(row)"
                  :icon="Delete"
                  v-if="row.applicationStatus === 'pending'"
                >
                  撤回
                </el-button>
              </div>
            </template>
          </el-table-column>
        </el-table>
        
        <!-- 空状态 -->
        <el-empty 
          v-if="!loading && recordList.length === 0" 
          description="暂无申请记录"
        >
          <el-button type="primary" @click="goToApply">立即申请</el-button>
        </el-empty>
      </el-card>
    </div>
    
    <!-- 详情弹窗 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="申请详情"
      width="850px"
      :destroy-on-close="true"
      class="premium-dialog"
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
                  {{ currentDetail.applicationStatusText || getStatusText(currentDetail.applicationStatus) }}
                </el-tag>
              </el-descriptions-item>
              <el-descriptions-item label="竞赛名称">{{ currentDetail.competitionName }}</el-descriptions-item>
              <el-descriptions-item label="项目名称">{{ currentDetail.projectName }}</el-descriptions-item>
              <el-descriptions-item label="竞赛级别">{{ currentDetail.competitionLevel }}</el-descriptions-item>
              <el-descriptions-item label="获奖等次">{{ currentDetail.awardRank }}</el-descriptions-item>
              <el-descriptions-item label="获奖等级">{{ currentDetail.awardLevel }}</el-descriptions-item>
              <el-descriptions-item label="获奖时间">{{ currentDetail.awardTime }}</el-descriptions-item>
              <el-descriptions-item label="联系方式">{{ currentDetail.contact }}</el-descriptions-item>
              <el-descriptions-item label="提交时间">{{ formatDateTime(currentDetail.createTime) }}</el-descriptions-item>
            </el-descriptions>
          </div>
          
          <!-- 指导老师信息 -->
          <div class="premium-section">
            <h4 class="premium-title">指导老师</h4>
            <div v-if="currentDetail.teachers && currentDetail.teachers.length > 0">
              <el-table :data="currentDetail.teachers" border class="premium-inner-table">
                <el-table-column prop="teacherName" label="姓名" width="120" />
                <el-table-column prop="teacherDepartment" label="部门" min-width="150" />
                <el-table-column prop="teacherNo" label="工号" width="120" />
              </el-table>
            </div>
            <div v-else class="empty-text">无数据</div>
          </div>
          
          <!-- 团队成员信息（仅团体赛） -->
          <div class="premium-section" v-if="currentDetail.teamId || (currentDetail.teamMembers && currentDetail.teamMembers.length > 0)">
            <h4 class="premium-title">团队成员</h4>
            <div v-if="currentDetail.teamMembers && currentDetail.teamMembers.length > 0">
              <el-table :data="currentDetail.teamMembers" border class="premium-inner-table">
                <el-table-column prop="sortOrder" label="排序" width="80" align="center" />
                <el-table-column label="姓名" width="120">
                  <template #default="{ row }">{{ row.externalName || row.studentName || '-' }}</template>
                </el-table-column>
                <el-table-column label="学号" width="150">
                  <template #default="{ row }">{{ row.externalNumber || row.studentNumber || '-' }}</template>
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
            <div v-else class="empty-text">无数据</div>
          </div>
          
          <!-- 证明材料 -->
          <div class="premium-section">
            <h4 class="premium-title">证明材料</h4>
            <div v-if="currentDetail.files && currentDetail.files.length > 0">
              <div class="file-list">
                <div v-for="file in currentDetail.files" :key="file.fileId" class="premium-file-item" @click="handlePreviewFile ? handlePreviewFile(file) : null">
                  <div class="file-info">
                    <el-icon class="file-icon"><Document /></el-icon>
                    <div>
                      <div class="file-name">{{ file.fileName }}</div>
                      <div class="file-meta">
                        {{ formatFileSize(file.fileSize) }} | {{ formatDateTime(file.uploadTime) }}
                      </div>
                    </div>
                  </div>
                  <el-button v-if="handlePreviewFile" type="primary" size="small" class="action-btn view-btn" @click.stop="handlePreviewFile(file)">预览</el-button>
                </div>
              </div>
            </div>
            <div v-else class="empty-text">无附件材料</div>
          </div>
        </div>
      </div>
      <template #footer>
        <el-button class="action-btn" @click="detailDialogVisible = false">关 闭</el-button>
      </template>
    </el-dialog>

    <!-- 文件预览弹窗 -->
    <el-dialog
      v-model="previewDialogVisible"
      :title="previewFileData.fileName"
      width="800px"
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
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, View, Delete, Search, Document, Timer, CircleCheck, CircleClose, RefreshLeft } from '@element-plus/icons-vue'
import NavBar from '../components/NavBar.vue'
import request from '../utils/request'

const router = useRouter()
const loading = ref(false)
const recordList = ref([])
const allRecords = ref([])
const statusFilter = ref('')
const searchKeyword = ref('')
const detailDialogVisible = ref(false)
const previewDialogVisible = ref(false)
const detailLoading = ref(false)
const currentDetail = ref({})

const previewFileData = reactive({
  fileName: '',
  filePath: ''
})

// 获取用户信息
const userInfo = ref(JSON.parse(localStorage.getItem('saims_user') || '{}'))

// 状态文本映射
const statusTextMap = {
  'pending': '待审核',
  'approved': '已通过',
  'rejected': '已拒绝',
  'returned': '已打回'
}

const statistics = computed(() => {
  const stats = {
    total: allRecords.value.length,
    pending: 0,
    approved: 0,
    rejected: 0,
    returned: 0
  }
  
  allRecords.value.forEach(record => {
    if (record.applicationStatus === 'pending') stats.pending++
    else if (record.applicationStatus === 'approved') stats.approved++
    else if (record.applicationStatus === 'rejected') stats.rejected++
    else if (record.applicationStatus === 'returned') stats.returned++
  })
  
  return stats
})

onMounted(() => {
  loadRecords()
})

const loadRecords = async () => {
  loading.value = true
  try {
    const res = await request.get('/application/record/list', {
      params: {
        studentId: userInfo.value.studentId
      }
    })
    
    if (res.code === '200') {
      // 处理数据，添加状态文本
      allRecords.value = (res.data || []).map(record => ({
        ...record,
        statusText: statusTextMap[record.applicationStatus] || record.applicationStatus
      }))
      
      // 应用筛选
      filterRecords()
    } else {
      ElMessage.error(res.msg || '加载申请记录失败')
    }
  } catch (error) {
    console.error('加载申请记录失败:', error)
    ElMessage.error('加载申请记录失败')
  } finally {
    loading.value = false
  }
}

const filterRecords = () => {
  let filtered = allRecords.value
  
  // 按状态筛选
  if (statusFilter.value) {
    filtered = filtered.filter(
      record => record.applicationStatus === statusFilter.value
    )
  }
  
  // 按竞赛名称搜索
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    filtered = filtered.filter(
      record => record.competitionName && record.competitionName.toLowerCase().includes(keyword)
    )
  }
  
  recordList.value = filtered
}

const handleSearch = () => {
  // 应用搜索
  filterRecords()
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

const getStatusText = (status) => {
  return statusTextMap[status] || status;
};

const viewDetail = async (row) => {
  detailDialogVisible.value = true
  detailLoading.value = true
  
  try {
    const res = await request.get(`/application/record/detail/${row.applicationId}`)
    
    if (res.code === '200') {
      currentDetail.value = {
        ...res.data,
        competitionName: row.competitionName, // 使用列表中的竞赛名称
        applicationStatusText: statusTextMap[res.data.applicationStatus] || res.data.applicationStatus
      }
    } else {
      ElMessage.error(res.msg || '加载详情失败')
      detailDialogVisible.value = false
    }
  } catch (error) {
    console.error('加载详情失败:', error)
    ElMessage.error('加载详情失败')
    detailDialogVisible.value = false
  } finally {
    detailLoading.value = false
  }
}

const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(
      '确定要撤回申请吗？撤回后申请将被删除。',
      '撤回确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
    
    const res = await request.post('/application/record/withdraw', {
      applicationId: row.applicationId,
      studentId: userInfo.value.studentId
    })
    
    if (res.code === '200') {
      ElMessage.success('撤回成功')
      loadRecords()
    } else {
      ElMessage.error(res.msg || '撤回失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('撤回失败:', error)
      ElMessage.error('撤回失败')
    }
  }
}

const goToApply = () => {
  router.push('/student/award')
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
/* 使用与登录/申请页面统一的包装器样式 */
.application-record-page.login-wrapper-style {
  position: relative;
  width: 100%;
  min-height: 100vh;
  /* background 已交由 App.vue 统一接管 */
  padding-bottom: 40px;
}

/* 这部分卡片以及表格透明逻辑已迁移到 App.vue 全局样式，此处可以精简 */
.content-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.record-card {
  margin-top: 20px;
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
  margin-bottom: 8px;
}

.card-header h2 {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  color: #1e293b;
  letter-spacing: 0.5px;
}

/* 高级按钮样式 */
.premium-btn {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
  border: none !important;
  border-radius: 10px !important;
  padding: 18px 24px !important;
  font-size: 15px !important;
  font-weight: 600 !important;
  letter-spacing: 0.5px;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3) !important;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1) !important;
}

.premium-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(99, 102, 241, 0.4) !important;
  background: linear-gradient(135deg, #6d70f5 0%, #9366f9 100%) !important;
}

.premium-btn:active {
  transform: translateY(1px);
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

/* 过滤栏美化 */
.premium-filter-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  padding: 16px 24px;
  background: rgba(255, 255, 255, 0.45);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.6);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
}

/* 分段控制器风格修改 */
.premium-filter-bar :deep(.el-radio-group) {
  background: rgba(241, 245, 249, 0.6);
  padding: 6px;
  border-radius: 12px;
}

.premium-filter-bar :deep(.el-radio-button__inner) {
  border: none !important;
  border-radius: 8px !important;
  background: transparent;
  color: #64748b;
  font-weight: 600;
  box-shadow: none !important;
  padding: 8px 20px;
}

.premium-filter-bar :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
  background: #ffffff;
  color: #6366f1;
  box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05), 0 2px 4px -2px rgba(0,0,0,0.05) !important;
}

.premium-filter-bar :deep(.el-input__wrapper) {
  background-color: rgba(248, 250, 252, 0.8) !important;
  border-radius: 12px !important;
  box-shadow: 0 0 0 1px #e2e8f0 inset !important;
  padding: 4px 16px;
}

.premium-filter-bar :deep(.el-input__wrapper.is-focus) {
  background-color: #ffffff !important;
  box-shadow: 0 0 0 2px #6366f1 inset !important;
}

/* 高级表格定制 */
.premium-table {
  width: 100%;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -2px rgba(0, 0, 0, 0.05);
  background: white !important;
  /* 去除默认边框 */
  --el-table-border-color: transparent;
  --el-table-header-bg-color: #f8fafc;
}

:deep(.premium-table .el-table__header-wrapper th) {
  background-color: #f8fafc !important;
  color: #64748b;
  font-weight: 600;
  font-size: 14px;
  height: 54px;
  border-bottom: 1px solid #e2e8f0 !important;
}

:deep(.premium-table .el-table__row) {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

:deep(.premium-table .el-table__row td) {
  padding: 16px 0;
  border-bottom: 1px solid #f1f5f9 !important;
  background-color: white !important;
}

/* 斑马纹带点透色 */
:deep(.premium-table .el-table__row--striped td) {
  background-color: #f8fafc !important;
}

/* 惊艳的动态悬浮特效 */
:deep(.premium-table .el-table__row:hover td) {
  background-color: #e0e7ff !important;
}

:deep(.premium-table .el-table__row:hover) {
  transform: scale(1.002) translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.1), 0 4px 6px -4px rgba(99, 102, 241, 0.05);
  position: relative;
  z-index: 10;
}

/* 强制清除最底部的默认边线 */
:deep(.premium-table::before) {
  display: none;
}

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

/* 炫酷动画操作按钮 - 大品质软胶/药丸风格 */
.action-btn-group {
  display: flex;
  justify-content: center;
  gap: 12px;
}

.action-btn {
  border: 1px solid rgba(0, 0, 0, 0.04) !important;
  border-radius: 6px !important; /* 恢复为常规圆角长方形 */
  padding: 8px 18px !important;
  font-weight: 600 !important;
  font-size: 13px !important;
  letter-spacing: 0.5px;
  background: #ffffff !important;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.02) !important;
  transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1) !important;
}

.action-btn.view-btn {
  color: #6366f1 !important;
}

.action-btn.view-btn:hover {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
  color: white !important;
  border-color: transparent !important;
  transform: scale(1.04) !important;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35) !important;
}

.action-btn.withdraw-btn {
  color: #ef4444 !important;
}

.action-btn.withdraw-btn:hover {
  background: linear-gradient(135deg, #ef4444 0%, #f43f5e 100%) !important;
  color: white !important;
  border-color: transparent !important;
  transform: scale(1.04) !important;
  box-shadow: 0 4px 15px rgba(239, 68, 68, 0.35) !important;
}

.action-btn:active {
  transform: scale(0.96) !important;
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
```
