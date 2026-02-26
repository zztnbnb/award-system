<template>
  <div class="navbar">
    <div class="navbar-container">
      <div class="navbar-left" @click="router.push('/')">
        <div class="logo">
          <div class="logo-icon-wrapper">
            <el-icon class="logo-icon"><Trophy /></el-icon>
          </div>
          <span class="logo-text">学生获奖系统</span>
        </div>
      </div>
      
      <div class="navbar-center">
        <el-menu
          :default-active="activeMenu"
          mode="horizontal"
          :ellipsis="false"
          @select="handleMenuSelect"
        >
          <el-menu-item index="/student/award" v-if="hasRole('student')">
            <span>申请填写</span>
          </el-menu-item>
          <el-menu-item index="/student/record" v-if="hasRole('student')">
            <span>申请记录</span>
          </el-menu-item>
          <el-menu-item index="/admin/review" v-if="hasRole('admin') || hasRole('mentor')">
            <span>审核管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/statistics" v-if="hasRole('admin') || hasRole('mentor')">
            <span>数据统计</span>
          </el-menu-item>
          <el-menu-item index="/admin/competition" v-if="hasRole('admin') || hasRole('mentor')">
            <span>竞赛管理</span>
          </el-menu-item>
          <el-menu-item index="/admin/student" v-if="hasRole('admin') || hasRole('mentor')">
            <span>学生管理</span>
          </el-menu-item>
        </el-menu>
      </div>
      
      <div class="navbar-right">
        <el-dropdown @command="handleCommand">
          <span class="user-dropdown">
            <el-icon><User /></el-icon>
            <span class="username">{{ userInfo?.name || userInfo?.username }}</span>
            <el-icon class="el-icon--right"><ArrowDown /></el-icon>
          </span>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item disabled class="user-info-item">
                <div class="user-info">
                  <p class="user-detail">学号：{{ userInfo?.username }}</p>
                  <p class="role-tags">
                    <el-tag v-for="role in getRoleArray()" :key="role" size="small" effect="light" round>
                      {{ getRoleText(role) }}
                    </el-tag>
                  </p>
                </div>
              </el-dropdown-item>
              <el-dropdown-item divided command="changePassword" class="action-item">
                <el-icon><Lock /></el-icon>
                <span>修改密码</span>
              </el-dropdown-item>
              <el-dropdown-item command="logout" class="logout-item action-item">
                <el-icon><SwitchButton /></el-icon>
                <span>退出登录</span>
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
    
    <!-- 修改密码对话框 -->
    <el-dialog 
      v-model="passwordDialogVisible" 
      title="修改密码" 
      width="500px"
      append-to-body
      class="premium-dialog"
    >
      <el-form :model="passwordForm" :rules="passwordRules" ref="passwordFormRef" label-width="95px">
        <el-form-item label="原密码" prop="oldPassword">
          <el-input v-model="passwordForm.oldPassword" type="password" show-password />
        </el-form-item>
        <el-form-item label="新密码" prop="newPassword">
          <el-input v-model="passwordForm.newPassword" type="password" show-password />
          <div class="password-hint">密码需由字母和数字组合构成，长度不少于 8 位</div>
        </el-form-item>
        <el-form-item label="确认密码" prop="confirmPassword">
          <el-input v-model="passwordForm.confirmPassword" type="password" show-password />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="passwordDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleChangePassword">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import request from '../utils/request'
import { Trophy, User, ArrowDown, Lock, SwitchButton } from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const userInfo = ref(null)
const activeMenu = ref('')
const passwordDialogVisible = ref(false)
const passwordFormRef = ref(null)

const passwordForm = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

const validatePassword = (rule, value, callback) => {
  if (!value) {
    callback(new Error('请输入新密码'))
  } else if (value.length < 8) {
    callback(new Error('密码长度不能少于8位'))
  } else if (!/(?=.*[A-Za-z])(?=.*\d)/.test(value)) {
    callback(new Error('密码需由字母和数字组合构成'))
  } else {
    callback()
  }
}

const validateConfirmPassword = (rule, value, callback) => {
  if (value !== passwordForm.value.newPassword) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入原密码', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, validator: validatePassword, trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

onMounted(() => {
  const user = localStorage.getItem('saims_user')
  userInfo.value = user ? JSON.parse(user) : null
  activeMenu.value = route.path
})

const hasRole = (role) => {
  if (!userInfo.value || !userInfo.value.role) return false
  return userInfo.value.role.includes(role)
}

const getRoleArray = () => {
  if (!userInfo.value || !userInfo.value.role) return []
  return userInfo.value.role.split(',').map(r => r.trim())
}

const getRoleText = (role) => {
  const roleMap = {
    'student': '学生',
    'mentor': '导师',
    'admin': '管理员'
  }
  return roleMap[role] || role
}

const handleMenuSelect = (index) => {
  router.push(index)
}

const handleCommand = (command) => {
  if (command === 'logout') {
    handleLogout()
  } else if (command === 'changePassword') {
    passwordDialogVisible.value = true
  }
}

const handleLogout = async () => {
  try {
    await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning',
      customClass: 'premium-message-box'
    })
    
    await request.post('/user/logout')
    localStorage.removeItem('saims_user')
    ElMessage.success('已退出登录')
    router.push('/login')
  } catch (error) {
    if (error !== 'cancel') {
      console.error('退出登录失败:', error)
    }
  }
}

const handleChangePassword = async () => {
  if (!passwordFormRef.value) return
  
  await passwordFormRef.value.validate(async (valid) => {
    if (valid) {
      try {
        await request.post('/user/changePassword', {
          username: userInfo.value.username,
          ...passwordForm.value
        })
        ElMessage.success('密码修改成功，请重新登录')
        passwordDialogVisible.value = false
        
        setTimeout(() => {
          localStorage.removeItem('saims_user')
          router.push('/login')
        }, 1500)
      } catch (error) {
        console.error('修改密码失败:', error)
      }
    }
  })
}
</script>

<style scoped>
.navbar {
  background: rgba(255, 255, 255, 0.75);
  backdrop-filter: blur(16px) saturate(180%);
  -webkit-backdrop-filter: blur(16px) saturate(180%);
  border-bottom: 1px solid rgba(255, 255, 255, 0.4);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.05);
  position: sticky;
  top: 0;
  z-index: 1000;
  transition: all 0.3s ease;
}

.navbar-container {
  max-width: 1440px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 32px;
  height: 64px;
}

.navbar-left {
  flex-shrink: 0;
  transition: transform 0.2s ease;
}

.navbar-left:hover {
  transform: scale(1.02);
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
}

.logo-icon-wrapper {
  width: 38px;
  height: 38px;
  background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
}

.logo-icon {
  font-size: 22px;
  color: white;
}

.logo-text {
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.5px;
  background: linear-gradient(to right, #1e293b, #475569);
  -webkit-background-clip: text;
  background-clip: text;
  -webkit-text-fill-color: transparent;
  font-family: 'Inter', system-ui, sans-serif;
}

.navbar-center {
  flex: 1;
  display: flex;
  justify-content: center;
  padding: 0 40px;
}

.navbar-right {
  flex-shrink: 0;
}

.user-dropdown {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 6px 14px;
  border-radius: 99px;
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid rgba(0, 0, 0, 0.05);
  transition: all 0.3s ease;
}

.user-dropdown:hover {
  background: rgba(255, 255, 255, 0.9);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  border-color: rgba(99, 102, 241, 0.2);
}

.username {
  font-size: 15px;
  font-weight: 600;
  color: #1e293b;
}

.user-info {
  padding: 5px 0;
}

.user-info p {
  margin: 5px 0;
  font-size: 14px;
}

.user-detail {
  font-size: 14px;
  color: #475569;
  font-weight: 500;
  margin: 6px 0 !important;
}

.role-tags {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
  margin-top: 10px !important;
}

.el-menu--horizontal {
  background: transparent !important;
  border-bottom: none !important;
  height: 100%;
}

:deep(.el-menu-item) {
  height: 64px !important;
  line-height: 64px !important;
  padding: 0 24px !important;
  font-size: 16px !important;
  font-weight: 500 !important;
  color: #475569 !important;
  border-bottom: 2px solid transparent !important;
  transition: all 0.2s ease !important;
}

:deep(.el-menu-item.is-active) {
  color: #6366f1 !important;
  background: transparent !important;
  font-weight: 600 !important;
}

:deep(.el-menu-item.is-active::after) {
  content: '';
  position: absolute;
  bottom: 12px;
  left: 20px;
  right: 20px;
  height: 3px;
  background: linear-gradient(to right, #6366f1, #a855f7);
  border-radius: 3px;
}

:deep(.el-menu-item:hover) {
  color: #6366f1 !important;
  background: rgba(99, 102, 241, 0.05) !important;
}

</style>

<style>
/* 下拉菜单全局高级样式 */
.el-dropdown__popper.el-popper {
  border: none !important;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1) !important;
  border-radius: 16px !important;
}

.user-info-item {
  cursor: default !important;
  opacity: 1 !important;
  padding: 12px 20px !important;
  background: transparent !important;
}

.el-dropdown-menu__item.action-item {
  display: flex !important;
  justify-content: center !important;
  align-items: center !important;
  gap: 8px !important;
  padding: 12px 20px !important;
  font-size: 14px !important;
  color: #475569 !important;
  transition: all 0.2s ease;
  border-radius: 8px !important;
  margin: 2px 8px !important;
}

.el-dropdown-menu__item.action-item:hover {
  background-color: #f1f5f9 !important;
  color: #6366f1 !important;
}

/* 退出登录默认不红，悬浮时变红，增加 specificity 防止被覆盖 */
.el-dropdown-menu__item.action-item.logout-item:hover {
  background-color: #fee2e2 !important;
  color: #ef4444 !important;
}

/* 修改密码弹窗全局高级样式修正 */
.premium-dialog {
  border-radius: 12px !important;
  overflow: hidden;
  box-shadow: 0 20px 40px -8px rgba(0, 0, 0, 0.1) !important;
  background: rgba(255, 255, 255, 0.95) !important;
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.8) !important;
}

.premium-dialog .el-dialog__header {
  padding: 24px 28px 20px !important;
  margin-right: 0 !important;
  text-align: left;
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
}

.premium-dialog .el-dialog__title {
  font-size: 18px !important;
  font-weight: 600 !important;
  color: #1e293b !important;
  background: none !important;
  -webkit-text-fill-color: initial !important;
  letter-spacing: normal;
}

.premium-dialog .el-dialog__headerbtn {
  top: 22px !important;
  right: 28px !important;
}

.premium-dialog .el-dialog__headerbtn .el-dialog__close {
  color: #94a3b8 !important;
  font-size: 16px !important;
  transition: all 0.2s ease !important;
}

.premium-dialog .el-dialog__headerbtn:hover .el-dialog__close {
  color: #0f172a !important;
}

.premium-dialog .el-dialog__body {
  padding: 32px 40px 12px 20px !important;
}

.premium-dialog .el-form-item {
  margin-bottom: 24px !important;
}

.premium-dialog .el-form-item__label {
  font-weight: 500 !important;
  color: #475569 !important;
  font-size: 14px !important;
}

.premium-dialog .el-input__wrapper {
  background-color: rgba(248, 250, 252, 0.8) !important;
  border-radius: 6px !important;
  padding: 4px 12px !important;
  box-shadow: 0 0 0 1px #e2e8f0 inset !important;
  transition: all 0.2s ease !important;
  width: 100%;
}

.premium-dialog .el-input__wrapper:hover {
  background-color: #fff !important;
  box-shadow: 0 0 0 1px #cbd5e1 inset !important;
}

.premium-dialog .el-input__wrapper.is-focus {
  background-color: #fff !important;
  box-shadow: 0 0 0 2px #3b82f6 inset !important;
}

/* 密码提示文字紧贴下方，且不换行 */
.premium-dialog .password-hint {
  font-size: 12px;
  color: #64748b;
  margin-top: 8px;
  line-height: 1.4;
  white-space: nowrap;
}

/* 避免错误信息把表单撑高 */
.premium-dialog .el-form-item__error {
  position: absolute;
  top: 100%;
  left: 0;
  padding-top: 4px;
}

.premium-dialog .el-dialog__footer {
  padding: 16px 28px 24px !important;
  border-top: none !important;
  display: flex !important;
  justify-content: flex-end !important;
  gap: 12px !important;
}

.premium-dialog .el-button {
  border-radius: 6px !important;
  padding: 8px 24px !important;
  font-size: 14px !important;
  font-weight: 500 !important;
  border: none !important;
  transition: all 0.2s ease !important;
  margin: 0 !important;
  height: 36px !important;
}

.premium-dialog .el-button--default {
  background: #f1f5f9 !important;
  color: #475569 !important;
}

.premium-dialog .el-button--default:hover {
  background: #e2e8f0 !important;
  color: #0f172a !important;
}

.premium-dialog .el-button--primary {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%) !important;
  color: white !important;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.25) !important;
}

.premium-dialog .el-button--primary:hover {
  background: linear-gradient(135deg, #60a5fa 0%, #3b82f6 100%) !important;
  box-shadow: 0 6px 16px rgba(59, 130, 246, 0.35) !important;
  transform: translateY(-1px);
}

/* ==================================
   全局 - 退出登录/消息确认框高级版 
================================== */
.premium-message-box {
  border-radius: 16px !important;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.2) !important;
  background: rgba(255, 255, 255, 0.95) !important;
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.8) !important;
  padding-bottom: 8px !important;
  width: 420px !important;
}

/* 头部 Header */
.premium-message-box .el-message-box__header {
  padding: 24px 24px 12px 24px !important;
}
.premium-message-box .el-message-box__title {
  font-size: 18px !important;
  font-weight: 700 !important;
  color: #1e293b !important;
  justify-content: flex-start !important;
}
.premium-message-box .el-message-box__headerbtn {
  top: 24px !important;
  right: 24px !important;
}
.premium-message-box .el-message-box__headerbtn .el-message-box__close {
  color: #94a3b8 !important;
  font-size: 16px !important;
  transition: all 0.2s ease !important;
}
.premium-message-box .el-message-box__headerbtn:hover .el-message-box__close {
  color: #0f172a !important;
  transform: rotate(90deg);
}

/* 主干内容 Body */
.premium-message-box .el-message-box__content {
  padding: 16px 24px 24px 24px !important;
  font-size: 16px !important;
  color: #334155 !important;
}
.premium-message-box .el-message-box__container {
  align-items: center !important;
}
/* 警告标识Icon美化 */
.premium-message-box .el-message-box__status {
  font-size: 28px !important;
  color: #f59e0b !important; /* 琥珀橘，比默认黄更有质感 */
}
.premium-message-box .el-message-box__message {
  padding-left: 12px !important;
}

/* 底部操作区 Footer */
.premium-message-box .el-message-box__btns {
  padding: 12px 24px 16px 24px !important;
}

/* 按键重塑 */
.premium-message-box .el-message-box__btns .el-button {
  border-radius: 8px !important;
  padding: 8px 24px !important;
  font-size: 14px !important;
  font-weight: 500 !important;
  height: 38px !important;
  border: none !important;
  transition: all 0.3s ease !important;
  margin-left: 12px !important;
}
/* 取消按钮 */
.premium-message-box .el-message-box__btns .el-button--default {
  background: #f1f5f9 !important;
  color: #475569 !important;
}
.premium-message-box .el-message-box__btns .el-button--default:hover {
  background: #e2e8f0 !important;
  color: #0f172a !important;
}
/* 确定/警告按钮 */
.premium-message-box .el-message-box__btns .el-button--primary {
  background: linear-gradient(135deg, #f59e0b 0%, #ea580c 100%) !important;
  color: white !important;
  box-shadow: 0 4px 12px rgba(245, 158, 11, 0.25) !important;
}
.premium-message-box .el-message-box__btns .el-button--primary:hover {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%) !important;
  box-shadow: 0 6px 16px rgba(245, 158, 11, 0.35) !important;
  transform: translateY(-1px);
}
</style>
