<template>
  <div class="student-award-page">
    <NavBar />
    
    <div class="content-container">
      <el-card class="form-card">
        <template #header>
          <div class="card-header">
            <h2>竞赛获奖申请</h2>
            <el-radio-group v-model="applicationType" @change="handleTypeChange">
              <el-radio-button value="individual">个人赛</el-radio-button>
              <el-radio-button value="team">团体赛</el-radio-button>
            </el-radio-group>
          </div>
        </template>
        
        <el-form 
          ref="formRef" 
          :model="formData" 
          :rules="rules" 
          label-width="140px"
          class="application-form"
        >
          <!-- 基本信息 -->
          <div class="form-section">
            <h3 class="section-title">基本信息</h3>
            
            <el-form-item label="竞赛名称" prop="competitionName">
              <el-autocomplete
                v-model="formData.competitionName"
                :fetch-suggestions="querySearchAsync"
                placeholder="请输入竞赛名称搜索并选择"
                :trigger-on-focus="false"
                clearable
                style="width: 100%"
                @select="handleSelectCompetition"
                @change="handleCompetitionNameChange"
              />
            </el-form-item>
            
            <el-form-item label="项目名称" prop="projectName">
              <el-input 
                v-model="formData.projectName" 
                placeholder="请输入项目名称（没有则填“无”）"
                maxlength="100"
                show-word-limit
              />
            </el-form-item>
            
            <el-form-item label="团队名称" prop="teamName" v-if="applicationType === 'team'">
              <el-input 
                v-model="formData.teamName" 
                placeholder="请输入团队名称"
                maxlength="50"
                show-word-limit
              />
            </el-form-item>
            
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="竞赛级别" prop="competitionLevel">
                  <el-select v-model="formData.competitionLevel" placeholder="请选择" style="width: 100%">
                    <el-option label="国家级" value="国家级" />
                    <el-option label="省级" value="省级" />
                    <el-option label="校级" value="校级" />
                    <el-option label="院级" value="院级" />
                  </el-select>
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="获奖等次" prop="awardRank">
                  <el-input 
                    v-model="formData.awardRank" 
                    placeholder="选择竞赛后自动填充" 
                    readonly
                    disabled
                  />
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="获奖等级" prop="awardLevel">
                  <el-input v-model="formData.awardLevel" placeholder="如：金奖/一等奖/M奖" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="获奖时间" prop="awardTime">
                  <el-date-picker
                    v-model="formData.awardTime"
                    type="date"
                    placeholder="选择日期"
                    style="width: 100%"
                    format="YYYY-MM-DD"
                    value-format="YYYY-MM-DD"
                  />
                </el-form-item>
              </el-col>
            </el-row>
            
            <el-form-item label="联系方式" prop="contact">
              <el-input 
                v-model="formData.contact" 
                placeholder="请输入负责人手机号"
              />
            </el-form-item>
          </div>
          
          <!-- 指导老师信息 -->
          <div class="form-section">
            <h3 class="section-title">
              指导老师信息
              <el-button 
                type="primary" 
                size="small" 
                @click="openMentorDialog"
                :icon="Plus"
              >
                添加指导老师
              </el-button>
            </h3>
            
            <div v-if="!formData.teachers || formData.teachers.length === 0" class="empty-tip">
              <el-empty description="暂无指导老师信息" :image-size="60" />
            </div>
            
            <div v-else class="mentor-list">
              <div v-for="(teacher, index) in formData.teachers" :key="index" class="mentor-card">
                <span class="mentor-title">指导老师{{ index + 1 }}</span>
                <div class="info-item">
                  <span class="info-label">姓名：</span>
                  <span class="info-value">{{ teacher.teacherName }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">学院：</span>
                  <span class="info-value">{{ teacher.teacherDepartment }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">工号：</span>
                  <span class="info-value">{{ teacher.teacherNo }}</span>
                </div>
                <el-button 
                  type="danger" 
                  size="small"
                  :icon="Delete" 
                  @click="removeMentor(index)"
                >
                  删除
                </el-button>
              </div>
            </div>
          </div>
          
          <!-- 团队成员信息 (仅团体赛) -->
          <div class="form-section" v-if="applicationType === 'team'">
            <h3 class="section-title">
              团队成员信息
              <el-button 
                type="primary" 
                size="small" 
                @click="openMemberDialog"
                :icon="Plus"
              >
                添加成员
              </el-button>
            </h3>
            
            <div class="member-instruction-row">
              <span class="instruction-text">请添加所有团队成员的信息</span>
              <el-radio-group v-model="formData.confirmMemberOrder" size="small">
                <el-radio :value="false">组内无排序</el-radio>
                <el-radio :value="true">组内有排序，序号对应成员排序</el-radio>
              </el-radio-group>
            </div>
            
            <div v-if="!formData.teamMembers || formData.teamMembers.length === 0" class="empty-tip">
              <el-empty description="暂无团队成员信息" :image-size="60" />
            </div>
            
            <div v-else class="member-list">
              <div v-for="(member, index) in formData.teamMembers" :key="index" class="member-card">
                <span class="member-title">成员{{ index + 1 }}</span>
                <div class="info-item">
                  <el-tag :type="member.isExternal ? 'warning' : 'success'" size="small">
                    {{ member.isExternal ? '校外' : '校内' }}
                  </el-tag>
                </div>
                <div class="info-item">
                  <span class="info-label">姓名：</span>
                  <span class="info-value">{{ member.isExternal ? member.externalName : member.studentName }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">{{ member.isExternal ? '学校' : '学院' }}：</span>
                  <span class="info-value">{{ member.isExternal ? member.externalSchool : member.studentDepartment }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">学号：</span>
                  <span class="info-value">{{ member.isExternal ? member.externalNumber : member.studentNumber }}</span>
                </div>
                <div class="info-item" v-if="member.isLeader">
                  <el-tag type="danger" size="small">队长</el-tag>
                </div>
                <el-button 
                  type="danger" 
                  size="small"
                  :icon="Delete" 
                  @click="removeTeamMember(index)"
                >
                  删除
                </el-button>
              </div>
            </div>
          </div>
          
          <!-- 文件上传 -->
          <div class="form-section">
            <h3 class="section-title">证明材料上传</h3>
            <el-form-item label="上传文件">
              <el-upload
                ref="uploadRef"
                :auto-upload="false"
                :on-change="handleFileChange"
                :file-list="fileList"
                multiple
                :limit="5"
                accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
              >
                <el-button type="primary" :icon="Upload">选择文件</el-button>
                <template #tip>
                  <div class="upload-tip">
                    支持 PDF、图片、Word 格式，单个文件不超过 10MB，最多上传 5 个文件
                  </div>
                </template>
              </el-upload>
            </el-form-item>
          </div>
          
          <!-- 提交按钮 -->
          <el-form-item>
            <el-button type="primary" size="large" @click="handleSubmit" :loading="submitting">
              提交申请
            </el-button>
            <el-button size="large" @click="handleReset">重置</el-button>
          </el-form-item>
        </el-form>
      </el-card>
    </div>
    
    <!-- 添加指导老师弹窗 -->
    <el-dialog 
      v-model="mentorDialogVisible" 
      title="添加指导老师" 
      width="500px"
      @close="closeMentorDialog"
    >
      <el-form :model="mentorForm" :rules="mentorRules" ref="mentorFormRef" label-width="100px">
        <el-form-item label="姓名" prop="teacherName">
          <el-input v-model="mentorForm.teacherName" placeholder="请输入老师姓名" />
        </el-form-item>
        <el-form-item label="学院" prop="teacherDepartment">
          <el-input v-model="mentorForm.teacherDepartment" placeholder="请输入所属学院" />
        </el-form-item>
        <el-form-item label="工号" prop="teacherNo">
          <el-input v-model="mentorForm.teacherNo" placeholder="请输入工号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeMentorDialog">取消</el-button>
          <el-button type="primary" @click="saveMentor">保存</el-button>
        </div>
      </template>
    </el-dialog>
    
    <!-- 添加团队成员弹窗 -->
    <el-dialog 
      v-model="memberDialogVisible" 
      title="添加团队成员" 
      width="500px"
      @close="closeMemberDialog"
    >
      <el-form :model="memberForm" :rules="memberRules" ref="memberFormRef" label-width="100px">
        <el-form-item label="成员类型">
          <el-radio-group v-model="memberForm.isExternal" @change="handleMemberTypeChange">
            <el-radio :value="false">校内</el-radio>
            <el-radio :value="true">校外</el-radio>
          </el-radio-group>
        </el-form-item>
        
        <!-- 校内成员 -->
        <template v-if="!memberForm.isExternal">
          <el-form-item label="姓名" prop="studentName">
            <el-input v-model="memberForm.studentName" placeholder="请输入姓名" />
          </el-form-item>
          <el-form-item label="学院" prop="studentDepartment">
            <el-input v-model="memberForm.studentDepartment" placeholder="请输入所在学院" />
          </el-form-item>
          <el-form-item label="学号" prop="studentNumber">
            <el-input v-model="memberForm.studentNumber" placeholder="请输入学号" />
          </el-form-item>
        </template>
        
        <!-- 校外成员 -->
        <template v-else>
          <el-form-item label="姓名" prop="externalName">
            <el-input v-model="memberForm.externalName" placeholder="请输入姓名" />
          </el-form-item>
          <el-form-item label="学校" prop="externalSchool">
            <el-input v-model="memberForm.externalSchool" placeholder="请输入所在学校" />
          </el-form-item>
          <el-form-item label="学号" prop="externalNumber">
            <el-input v-model="memberForm.externalNumber" placeholder="请输入学号" />
          </el-form-item>
        </template>
        
        <el-form-item label="是否队长">
          <el-checkbox v-model="memberForm.isLeader">设为队长</el-checkbox>
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="closeMemberDialog">取消</el-button>
          <el-button type="primary" @click="saveMember">保存</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Delete, Upload } from '@element-plus/icons-vue'
import NavBar from '../components/NavBar.vue'
import request from '../utils/request'

const router = useRouter()
const formRef = ref(null)
const uploadRef = ref(null)
const submitting = ref(false)

const applicationType = ref('individual')
const competitions = ref([])
const individualFileList = ref([])  // 个人赛文件列表
const teamFileList = ref([])        // 团体赛文件列表
const fileList = computed(() => {
  return applicationType.value === 'individual' ? individualFileList.value : teamFileList.value
})
const searchLoading = ref(false)

// 指导老师弹窗相关
const mentorDialogVisible = ref(false)
const mentorFormRef = ref(null)
const mentorForm = reactive({
  teacherName: '',
  teacherDepartment: '',
  teacherNo: ''
})

const mentorRules = {
  teacherName: [
    { required: true, message: '请输入老师姓名', trigger: 'blur' }
  ],
  teacherDepartment: [
    { required: true, message: '请输入所属学院', trigger: 'blur' }
  ],
  teacherNo: [
    { required: true, message: '请输入工号', trigger: 'blur' }
  ]
}

// 团队成员弹窗相关
const memberDialogVisible = ref(false)
const memberFormRef = ref(null)
const memberForm = reactive({
  isExternal: false,
  studentName: '',
  studentDepartment: '',
  studentNumber: '',
  externalName: '',
  externalSchool: '',
  externalNumber: '',
  isLeader: false
})

const memberRules = computed(() => {
  if (memberForm.isExternal) {
    return {
      externalName: [
        { required: true, message: '请输入姓名', trigger: 'blur' }
      ],
      externalSchool: [
        { required: true, message: '请输入所在学校', trigger: 'blur' }
      ],
      externalNumber: [
        { required: true, message: '请输入学号', trigger: 'blur' }
      ]
    }
  } else {
    return {
      studentName: [
        { required: true, message: '请输入姓名', trigger: 'blur' }
      ],
      studentDepartment: [
        { required: true, message: '请输入所属学院', trigger: 'blur' }
      ],
      studentNumber: [
        { required: true, message: '请输入学号', trigger: 'blur' }
      ]
    }
  }
})

// 个人赛和团体赛分别保存数据
const individualFormData = reactive({
  competitionId: null,       // 竞赛ID
  competitionName: '',       // 竞赛名称（用于显示）
  projectName: '',
  competitionLevel: '',
  awardLevel: '',
  awardRank: '',
  awardTime: '',
  contact: '',
  teachers: [],
  isTeam: false
})

const teamFormData = reactive({
  competitionId: null,       // 竞赛ID
  competitionName: '',       // 竞赛名称（用于显示）
  projectName: '',
  teamName: '',
  competitionLevel: '',
  awardLevel: '',
  awardRank: '',
  awardTime: '',
  contact: '',
  teachers: [],
  teamMembers: [],
  confirmMemberOrder: false,
  isTeam: true
})

// 当前使用的表单数据
const formData = ref(individualFormData)

const rules = {
  competitionName: [
    { required: true, message: '请输入竞赛名称', trigger: 'blur' }
  ],
  projectName: [
    { required: true, message: '请输入项目名称', trigger: 'blur' }
  ],
  teamName: [
    { required: true, message: '请输入团队名称', trigger: 'blur' }
  ],
  competitionLevel: [
    { required: true, message: '请选择竞赛级别', trigger: 'change' }
  ],
  awardRank: [
    { required: true, message: '请选择竞赛后自动填充获奖等次', trigger: 'blur' }
  ],
  awardLevel: [
    { required: true, message: '请输入获奖等级', trigger: 'blur' }
  ],
  awardTime: [
    { required: true, message: '请选择获奖时间', trigger: 'change' }
  ],
  contact: [
    { required: true, message: '请输入联系方式', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
  ]
}

const querySearchAsync = async (queryString, cb) => {
  if (!queryString) {
    cb([])
    return
  }
  
  try {
    const res = await request.get('/competition/search', {
      params: { keyword: queryString }
    })
    if (res.code === '200' && res.data) {
      const suggestions = res.data.map(comp => ({
        value: comp.competitionName,
        competitionId: comp.competitionId,
        awardRank: comp.awardRank
      }))
      cb(suggestions)
    } else {
      cb([])
    }
  } catch (error) {
    console.error('搜索竞赛失败:', error)
    cb([])
  }
}

const handleSelectCompetition = (item) => {
  formData.value.competitionName = item.value
  formData.value.competitionId = item.competitionId  // 保存竞赛ID
  formData.value.awardRank = item.awardRank || ''    // 自动填充获奖等次
}

const handleCompetitionNameChange = (value) => {
  // 如果用户手动修改了竞赛名称（没有通过选择），清空竞赛ID和获奖等次
  if (!value) {
    formData.value.competitionId = null
    formData.value.awardRank = ''
  }
}

const handleTypeChange = () => {
  // 切换表单数据引用
  formData.value = applicationType.value === 'individual' ? individualFormData : teamFormData
  
  // 切换时清空表单验证
  if (formRef.value) {
    formRef.value.clearValidate()
  }
}

const openMentorDialog = () => {
  mentorDialogVisible.value = true
}

const closeMentorDialog = () => {
  mentorDialogVisible.value = false
  // 重置表单
  mentorForm.teacherName = ''
  mentorForm.teacherDepartment = ''
  mentorForm.teacherNo = ''
  if (mentorFormRef.value) {
    mentorFormRef.value.clearValidate()
  }
}

const saveMentor = async () => {
  if (!mentorFormRef.value) return
  
  await mentorFormRef.value.validate((valid) => {
    if (valid) {
      // 检查工号是否重复
      const isDuplicate = formData.value.teachers.some(
        teacher => teacher.teacherNo === mentorForm.teacherNo
      )
      
      if (isDuplicate) {
        ElMessage.warning('该工号已存在，请勿重复添加')
        return
      }
      
      // 添加到当前表单的指导老师列表
      formData.value.teachers.push({
        teacherName: mentorForm.teacherName,
        teacherDepartment: mentorForm.teacherDepartment,
        teacherNo: mentorForm.teacherNo
      })
      
      ElMessage.success('添加成功')
      closeMentorDialog()
    } else {
      ElMessage.warning('请完善指导老师信息')
    }
  })
}

const removeMentor = (index) => {
  ElMessageBox.confirm('确定要删除该指导老师吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    formData.value.teachers.splice(index, 1)
    formData.value.teachers.forEach((t, i) => {
      t.sortOrder = i + 1
    })
    ElMessage.success('删除成功')
  }).catch(() => {})
}

const openMemberDialog = () => {
  memberDialogVisible.value = true
}

const closeMemberDialog = () => {
  memberDialogVisible.value = false
  // 重置表单
  memberForm.isExternal = false
  memberForm.studentName = ''
  memberForm.studentDepartment = ''
  memberForm.studentNumber = ''
  memberForm.externalName = ''
  memberForm.externalSchool = ''
  memberForm.externalNumber = ''
  memberForm.isLeader = false
  if (memberFormRef.value) {
    memberFormRef.value.clearValidate()
  }
}

const handleMemberTypeChange = () => {
  // 切换类型时清空验证
  if (memberFormRef.value) {
    memberFormRef.value.clearValidate()
  }
}

const saveMember = async () => {
  if (!memberFormRef.value) return
  
  await memberFormRef.value.validate((valid) => {
    if (valid) {
      // 检查学号是否重复
      const currentNumber = memberForm.isExternal ? memberForm.externalNumber : memberForm.studentNumber
      const isDuplicate = formData.value.teamMembers.some(member => {
        const memberNumber = member.isExternal ? member.externalNumber : member.studentNumber
        return memberNumber === currentNumber
      })
      
      if (isDuplicate) {
        ElMessage.warning('该学号已存在，请勿重复添加')
        return
      }
      
      // 如果设置为队长，取消其他成员的队长身份
      if (memberForm.isLeader) {
        const hasLeader = formData.value.teamMembers.some(m => m.isLeader)
        if (hasLeader) {
          ElMessage.warning('已有队长，一个团队只能有一个队长')
          return
        }
      }
      
      // 添加到团队成员列表
      const newMember = {
        isExternal: memberForm.isExternal,
        studentName: memberForm.studentName,
        studentDepartment: memberForm.studentDepartment,
        studentNumber: memberForm.studentNumber,
        externalName: memberForm.externalName,
        externalSchool: memberForm.externalSchool,
        externalNumber: memberForm.externalNumber,
        isLeader: memberForm.isLeader,
        sortOrder: formData.value.teamMembers.length + 1
      }
      
      formData.value.teamMembers.push(newMember)
      ElMessage.success('添加成功')
      closeMemberDialog()
    } else {
      ElMessage.warning('请完善团队成员信息')
    }
  })
}

const removeTeamMember = (index) => {
  ElMessageBox.confirm('确定要删除该团队成员吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    formData.value.teamMembers.splice(index, 1)
    formData.value.teamMembers.forEach((m, i) => {
      m.sortOrder = i + 1
    })
    ElMessage.success('删除成功')
  }).catch(() => {})
}

const handleFileChange = (file, files) => {
  // 验证文件大小（10MB = 10 * 1024 * 1024 bytes）
  const maxSize = 10 * 1024 * 1024
  
  if (file.size > maxSize) {
    ElMessage.error(`文件 ${file.name} 大小超过10MB，请选择更小的文件`)
    // 从文件列表中移除超大文件
    const index = files.indexOf(file)
    if (index > -1) {
      files.splice(index, 1)
    }
    // 根据申请类型更新对应的文件列表
    if (applicationType.value === 'individual') {
      individualFileList.value = files
    } else {
      teamFileList.value = files
    }
    return false
  }
  
  // 根据申请类型更新对应的文件列表
  if (applicationType.value === 'individual') {
    individualFileList.value = files
  } else {
    teamFileList.value = files
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) {
      ElMessage.warning('请完善表单信息')
      return
    }
    
    // 团体赛必须至少有两名团队成员
    if (applicationType.value === 'team') {
      if (!formData.value.teamMembers || formData.value.teamMembers.length === 0) {
        ElMessage.warning('团体赛请至少添加两名团队成员')
        return
      }
      if (formData.value.teamMembers.length < 2) {
        ElMessage.warning('团体赛至少需要两名团队成员')
        return
      }
      
      // 检查是否有队长
      const hasLeader = formData.value.teamMembers.some(m => m.isLeader)
      if (!hasLeader) {
        ElMessage.warning('请指定一名队长')
        return
      }
    }
    
    // 团体赛需要确认排序选项
    if (applicationType.value === 'team' && formData.value.teamMembers && formData.value.teamMembers.length > 0) {
      const sortMessage = formData.value.confirmMemberOrder 
        ? '您已选择"组内有排序，序号对应成员排序"，请确认成员添加顺序是否正确？' 
        : '您已选择"组内无排序"，确认组内成员无先后顺序？'
      
      try {
        await ElMessageBox.confirm(sortMessage, '确认排序选项', {
          confirmButtonText: '确认',
          cancelButtonText: '取消',
          type: 'warning'
        })
      } catch {
        return
      }
    }
    
    try {
      await ElMessageBox.confirm('确认提交申请吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      submitting.value = true
      
      // 验证竞赛是否已选择
      if (!formData.value.competitionId) {
        ElMessage.error('请选择竞赛')
        submitting.value = false
        return
      }
      
      // 提取纯数据对象，避免循环引用
      const pureData = {
        competitionId: formData.value.competitionId,  // 传递竞赛ID
        projectName: formData.value.projectName,
        teamName: formData.value.teamName || '',
        competitionLevel: formData.value.competitionLevel,
        awardLevel: formData.value.awardLevel,
        awardRank: formData.value.awardRank,
        awardTime: formData.value.awardTime,
        contact: formData.value.contact,
        teachers: formData.value.teachers || [],
        teamMembers: formData.value.teamMembers || [],
        confirmMemberOrder: formData.value.confirmMemberOrder || false,
        isTeam: formData.value.isTeam
      }
      
      const formDataToSubmit = new FormData()
      formDataToSubmit.append('data', JSON.stringify(pureData))
      
      fileList.value.forEach(file => {
        formDataToSubmit.append('files', file.raw)
      })
      
      // 添加 studentId 参数（从登录用户信息获取）
      const currentUser = JSON.parse(localStorage.getItem('saims_user') || '{}')
      formDataToSubmit.append('studentId', currentUser.studentId)
      
      await request.post('/application/submit', formDataToSubmit, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      })
      
      ElMessage.success('申请提交成功！')
      
    } catch (error) {
      if (error !== 'cancel') {
        console.error('提交失败:', error)
      }
    } finally {
      submitting.value = false
    }
  })
}

const handleReset = () => {
  // 重置表单验证
  if (formRef.value) {
    formRef.value.resetFields()
  }
  
  // 根据当前类型重置对应的表单数据
  if (applicationType.value === 'individual') {
    // 重置个人赛数据
    individualFormData.competitionId = null
    individualFormData.competitionName = ''
    individualFormData.projectName = ''
    individualFormData.competitionLevel = ''
    individualFormData.awardLevel = ''
    individualFormData.awardRank = ''
    individualFormData.awardTime = ''
    individualFormData.contact = ''
    individualFormData.teachers = []
  } else {
    // 重置团体赛数据
    teamFormData.competitionId = null
    teamFormData.competitionName = ''
    teamFormData.projectName = ''
    teamFormData.teamName = ''
    teamFormData.competitionLevel = ''
    teamFormData.awardLevel = ''
    teamFormData.awardRank = ''
    teamFormData.awardTime = ''
    teamFormData.contact = ''
    teamFormData.teachers = []
    teamFormData.teamMembers = []
    teamFormData.confirmMemberOrder = false
  }
  
  // 重置文件列表
  fileList.value = []
  
  ElMessage.success('表单已重置')
}
</script>

<style scoped>
.student-award-page {
  min-height: 100vh;
  background-color: #f5f7fa;
}

.content-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.form-card {
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

.application-form {
  margin-top: 20px;
}

.form-section {
  margin-bottom: 30px;
  padding: 20px;
  background-color: #fafafa;
  border-radius: 8px;
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: #333;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #409eff;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.empty-tip {
  padding: 15px;
  text-align: center;
}

.mentor-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.mentor-card {
  background-color: #fff;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  padding: 15px 20px;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 30px;
}

.mentor-card:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.mentor-title {
  font-size: 15px;
  font-weight: 600;
  color: #409eff;
  min-width: 90px;
  flex-shrink: 0;
}

.info-item {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
}

.info-label {
  font-size: 14px;
  color: #909399;
  margin-right: 8px;
  white-space: nowrap;
  flex-shrink: 0;
}

.info-value {
  font-size: 14px;
  color: #303133;
  font-weight: 500;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mentor-card .el-button {
  flex-shrink: 0;
  margin-left: auto;
}

.member-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.member-card {
  background-color: #fff;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  padding: 15px 20px;
  transition: all 0.3s;
  display: flex;
  align-items: center;
  gap: 20px;
}

.member-card:hover {
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.member-title {
  font-size: 15px;
  font-weight: 600;
  color: #67c23a;
  min-width: 70px;
  flex-shrink: 0;
}

.member-card .el-button {
  flex-shrink: 0;
  margin-left: auto;
}

.member-instruction-row {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 15px;
  background-color: #f0f9ff;
  border-radius: 6px;
  border: 1px solid #b3d8ff;
  margin-bottom: 20px;
}

.instruction-text {
  font-size: 14px;
  font-weight: 500;
  color: #409eff;
  flex-shrink: 0;
}

.upload-tip {
  color: #999;
  font-size: 12px;
  margin-top: 5px;
}
</style>
