<template>
  <div class="application-record-page">
    <NavBar />
    
    <div class="content-container">
      <el-card class="record-card">
        <template #header>
          <div class="card-header">
            <h2>我的申请记录</h2>
            <el-button type="primary" @click="goToApply" :icon="Plus">
              新建申请
            </el-button>
          </div>
        </template>
        
        <!-- 统计信息 -->
        <div class="statistics-bar">
          <div class="stat-item">
            <div class="stat-value">{{ statistics.total }}</div>
            <div class="stat-label">总申请数</div>
          </div>
          <div class="stat-item pending">
            <div class="stat-value">{{ statistics.pending }}</div>
            <div class="stat-label">待审核</div>
          </div>
          <div class="stat-item approved">
            <div class="stat-value">{{ statistics.approved }}</div>
            <div class="stat-label">已通过</div>
          </div>
          <div class="stat-item rejected">
            <div class="stat-value">{{ statistics.rejected }}</div>
            <div class="stat-label">已拒绝</div>
          </div>
          <div class="stat-item returned">
            <div class="stat-value">{{ statistics.returned }}</div>
            <div class="stat-label">已打回</div>
          </div>
        </div>
        
        <!-- 筛选栏 -->
        <div class="filter-bar">
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
        
        <!-- 申请记录列表 -->
        <el-table 
          :data="recordList" 
          v-loading="loading"
          stripe
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
          <el-table-column label="操作" width="180" fixed="right">
            <template #default="{ row }">
              <el-button 
                type="primary" 
                size="small" 
                @click="viewDetail(row)"
                :icon="View"
              >
                查看
              </el-button>
              <el-button 
                type="danger" 
                size="small" 
                @click="handleDelete(row)"
                :icon="Delete"
                v-if="row.applicationStatus === 'pending'"
              >
                撤回
              </el-button>
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
      width="80%"
      :close-on-click-modal="false"
    >
      <div v-loading="detailLoading" class="detail-content">
        <el-descriptions :column="2" border v-if="currentDetail.applicationId">
          <el-descriptions-item label="申请编号">
            {{ currentDetail.applicationNumber }}
          </el-descriptions-item>
          <el-descriptions-item label="申请状态">
            <el-tag :type="getStatusType(currentDetail.applicationStatus)" effect="dark">
              {{ currentDetail.statusText }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="竞赛名称">
            {{ currentDetail.competitionName }}
          </el-descriptions-item>
          <el-descriptions-item label="项目名称">
            {{ currentDetail.projectName }}
          </el-descriptions-item>
          <el-descriptions-item label="竞赛级别">
            {{ currentDetail.competitionLevel }}
          </el-descriptions-item>
          <el-descriptions-item label="获奖等次">
            {{ currentDetail.awardRank }}
          </el-descriptions-item>
          <el-descriptions-item label="获奖等级">
            {{ currentDetail.awardLevel }}
          </el-descriptions-item>
          <el-descriptions-item label="获奖时间">
            {{ currentDetail.awardTime }}
          </el-descriptions-item>
          <el-descriptions-item label="联系方式">
            {{ currentDetail.contact }}
          </el-descriptions-item>
          <el-descriptions-item label="提交时间">
            {{ formatDateTime(currentDetail.createTime) }}
          </el-descriptions-item>
        </el-descriptions>
        
        <!-- 指导老师信息 -->
        <div class="detail-section" style="margin-top: 20px">
          <h4 class="section-title">指导老师</h4>
          <div v-if="currentDetail.teachers && currentDetail.teachers.length > 0">
            <el-table :data="currentDetail.teachers" border stripe size="small">
              <el-table-column prop="teacherName" label="姓名" width="120" />
              <el-table-column prop="teacherDepartment" label="部门" min-width="150" />
              <el-table-column prop="teacherNo" label="工号" width="120" />
            </el-table>
          </div>
          <div v-else style="color: #999; padding: 10px 0">无</div>
        </div>
        
        <!-- 团队成员信息（仅团体赛） -->
        <div class="detail-section" style="margin-top: 20px" v-if="currentDetail.teamId">
          <h4 class="section-title">团队成员</h4>
          <div v-if="currentDetail.teamMembers && currentDetail.teamMembers.length > 0">
            <el-table :data="currentDetail.teamMembers" border stripe size="small">
              <el-table-column prop="sortOrder" label="排序" width="80" align="center" />
              <el-table-column label="姓名" width="120">
                <template #default="{ row }">
                  {{ row.externalName || row.studentName || '-' }}
                </template>
              </el-table-column>
              <el-table-column label="学号" width="150">
                <template #default="{ row }">
                  {{ row.externalNumber || row.studentNumber || '-' }}
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
              </div>
            </div>
          </div>
          <div v-else style="color: #999; padding: 10px 0">无</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, View, Delete, Search } from '@element-plus/icons-vue'
import NavBar from '../components/NavBar.vue'
import request from '../utils/request'

const router = useRouter()
const loading = ref(false)
const recordList = ref([])
const allRecords = ref([])
const statusFilter = ref('')
const searchKeyword = ref('')
const detailDialogVisible = ref(false)
const detailLoading = ref(false)
const currentDetail = ref({})

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

const handleFilterChange = () => {
  // 应用筛选
  filterRecords()
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

const viewDetail = async (row) => {
  detailDialogVisible.value = true
  detailLoading.value = true
  
  try {
    const res = await request.get(`/application/record/detail/${row.applicationId}`)
    
    if (res.code === '200') {
      currentDetail.value = {
        ...res.data,
        competitionName: row.competitionName, // 使用列表中的竞赛名称
        statusText: statusTextMap[res.data.applicationStatus] || res.data.applicationStatus
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
</script>

<style scoped>
.application-record-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.content-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.record-card {
  margin-top: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-header h2 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.statistics-bar {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
}

.stat-item {
  flex: 1;
  text-align: center;
  padding: 15px;
  background-color: rgba(255, 255, 255, 0.2);
  border-radius: 6px;
  color: #fff;
  transition: transform 0.3s;
}

.stat-item:hover {
  transform: translateY(-5px);
  background-color: rgba(255, 255, 255, 0.3);
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 5px;
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
  padding: 15px;
  background-color: #f9f9f9;
  border-radius: 6px;
}

.el-table {
  margin-top: 20px;
}

.detail-section {
  margin-top: 20px;
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
  padding: 15px;
  background-color: #f9f9f9;
  border: 1px solid #e4e7ed;
  border-radius: 6px;
}

.file-info {
  display: flex;
  align-items: center;
}
</style>
