<template>
  <div class="team-page">
    <NavBar />
    <main class="team-shell">
      <header class="page-head">
        <div><h1>竞赛组队</h1><p>寻找互补的队友，组建可直接用于获奖申报的正式队伍</p></div>
        <el-button type="primary" :icon="Plus" @click="openCreate">创建队伍</el-button>
      </header>

      <el-tabs v-model="activeTab" class="team-tabs" @tab-change="tabChanged">
        <el-tab-pane label="组队广场" name="market">
          <div class="filters">
            <el-input v-model="filters.competition" placeholder="搜索竞赛或队伍" clearable :prefix-icon="Search" @keyup.enter="loadMarket" />
            <el-input v-model="filters.skill" placeholder="技能，如 Python" clearable @keyup.enter="loadMarket" />
            <el-input v-model="filters.major" placeholder="专业" clearable @keyup.enter="loadMarket" />
            <el-select v-model="filters.grade" placeholder="年级" clearable><el-option v-for="g in grades" :key="g" :label="g" :value="g" /></el-select>
            <el-select v-model="filters.status" placeholder="招募状态" clearable><el-option label="招募中" value="recruiting" /><el-option label="已关闭" value="closed" /><el-option label="已锁定" value="locked" /></el-select>
            <div class="filter-actions"><el-button type="primary" :icon="Search" @click="loadMarket">筛选</el-button><el-button @click="clearFilters">清除</el-button></div>
          </div>
          <p class="result-count">共找到 {{ market.total }} 支队伍</p>
          <div v-loading="loading" class="team-grid">
            <article v-for="team in market.list" :key="team.teamId" class="team-card">
              <div class="card-top"><el-tag effect="plain">{{ team.competitionName }}</el-tag><el-tag :type="team.status === 'recruiting' ? 'success' : 'info'">{{ statusText(team.status) }}</el-tag></div>
              <h2>{{ team.name }}</h2><p class="description">{{ team.description || '负责人暂未填写队伍介绍' }}</p>
              <dl><div><dt>负责人</dt><dd>{{ team.leaderName }}</dd></div><div><dt>专业年级</dt><dd>{{ team.major || '-' }} · {{ team.grade || '-' }}</dd></div><div><dt>队伍人数</dt><dd>{{ team.memberCount }}/{{ team.targetSize }}（上限 {{ team.maxTeamSize }}）</dd></div><div><dt>招募岗位</dt><dd>{{ team.positions || '暂未设置岗位' }}</dd></div></dl>
              <div class="skills" v-if="team.requiredSkills"><el-tag v-for="s in splitSkills(team.requiredSkills)" :key="s" size="small">{{ s }}</el-tag></div>
              <div class="deadline">截止：{{ formatTime(team.teamCloseTime) }}</div>
              <div class="card-actions"><el-button @click="showDetail(team.teamId)">查看详情</el-button><el-button type="primary" :disabled="!team.canApply" :title="team.unavailableReason || ''" @click="showDetail(team.teamId, true)">{{ team.canApply ? '申请加入' : team.unavailableReason }}</el-button></div>
            </article>
            <el-empty v-if="!market.list.length && !loading" description="暂无符合条件的招募" />
          </div>
          <el-pagination v-if="market.total" layout="prev, pager, next" :total="market.total" :page-size="market.pageSize" v-model:current-page="market.page" @current-change="loadMarket" />
        </el-tab-pane>

        <el-tab-pane label="适合我的队伍" name="recommended">
          <p class="section-note">按公开岗位条件、你填写的竞赛简历和系统认证经历排序；技能标签为学生自填。</p>
          <div v-loading="loading" class="team-grid">
            <article v-for="item in recommendations" :key="`${item.teamId}-${item.positionId}`" class="team-card">
              <div class="card-top"><el-tag>{{ item.competitionName }}</el-tag><strong class="match-score">{{ item.score }} 分</strong></div>
              <h2>{{ item.name }}</h2><p class="description">推荐岗位：{{ item.positionTitle }}</p>
              <div class="reason-list"><span v-for="reason in item.reasons" :key="reason">{{ reason }}</span></div>
              <div class="deadline">{{ item.memberCount }}/{{ item.targetSize }} 人 · 截止 {{ formatTime(item.teamCloseTime) }}</div>
              <div class="card-actions"><el-button @click="showDetail(item.teamId)">查看详情</el-button><el-button type="primary" @click="showDetail(item.teamId,true,item.positionId)">申请岗位</el-button></div>
            </article>
            <el-empty v-if="!recommendations.length && !loading" description="暂无适合的开放岗位，完善竞赛简历后再看看" />
          </div>
        </el-tab-pane>

        <el-tab-pane label="我的队伍" name="mine">
          <div class="section-tools"><el-segmented v-model="mineScope" :options="[{label:'我负责的',value:'leader'},{label:'我参加的',value:'member'},{label:'历史档案',value:'history'}]" /><el-button :icon="Refresh" @click="loadMine">刷新</el-button></div>
          <el-table :data="visibleMine" v-loading="loading" stripe class="desktop-table">
            <el-table-column prop="competitionName" label="竞赛" min-width="220" />
            <el-table-column prop="name" label="队伍" min-width="160" />
            <el-table-column label="身份" width="100"><template #default="{row}"><el-tag :type="row.isLeader ? 'warning' : ''">{{ row.isLeader ? '负责人' : '成员' }}</el-tag></template></el-table-column>
            <el-table-column label="人数" width="90"><template #default="{row}">{{ row.memberCount }}/{{ row.targetSize }}</template></el-table-column>
            <el-table-column label="状态" width="100"><template #default="{row}">{{ statusText(row.status) }}</template></el-table-column>
            <el-table-column label="操作" width="120"><template #default="{row}"><el-button link type="primary" @click="showDetail(row.teamId)">管理/查看</el-button></template></el-table-column>
          </el-table>
          <div class="mobile-list"><article v-for="row in visibleMine" :key="row.teamId" class="mobile-item"><strong>{{ row.name }}</strong><span>{{ row.competitionName }}</span><span>{{ row.isLeader ? '负责人' : '成员' }} · {{ statusText(row.status) }} · {{ row.memberCount }}/{{ row.targetSize }} 人</span><el-button type="primary" plain @click="showDetail(row.teamId)">查看队伍</el-button></article></div>
          <el-empty v-if="!visibleMine.length && !loading" description="这里还没有队伍" />
        </el-tab-pane>

        <el-tab-pane name="requests">
          <template #label><span>申请与邀请 <el-badge v-if="pendingCount" :value="pendingCount" /></span></template>
          <el-segmented v-model="requestScope" :options="[{label:'待我处理',value:'mine'},{label:'我负责的队伍',value:'managed'}]" @change="loadRequests" />
          <el-segmented v-model="requestView" :options="[{label:'待处理',value:'pending'},{label:'我发起的',value:'outgoing'},{label:'历史',value:'history'}]" class="request-view" />
          <el-table :data="visibleRequests" v-loading="loading" stripe class="request-table desktop-table">
            <el-table-column prop="competitionName" label="竞赛" min-width="200" /><el-table-column prop="teamName" label="队伍" min-width="140" />
            <el-table-column prop="studentName" label="学生" width="110" /><el-table-column prop="positionTitle" label="岗位" width="120" />
            <el-table-column label="类型" width="90"><template #default="{row}">{{ row.requestType === 'application' ? '申请' : '邀请' }}</template></el-table-column>
            <el-table-column label="状态" width="100"><template #default="{row}"><el-tag :type="requestTag(row.status)">{{ requestText(row.status) }}</el-tag></template></el-table-column>
            <el-table-column label="操作" width="190"><template #default="{row}"><template v-if="row.status === 'pending' && canDecide(row)"><el-button link type="success" @click="decide(row,'accept')">接受</el-button><el-button link type="danger" @click="decide(row,'reject')">拒绝</el-button></template><el-button v-if="row.status==='pending' && canCancel(row)" link type="warning" @click="decide(row,'cancel')">撤回</el-button></template></el-table-column>
          </el-table>
          <div class="mobile-list"><article v-for="row in visibleRequests" :key="row.requestId" class="mobile-item"><strong>{{ row.teamName }}</strong><span>{{ row.competitionName }} · {{ row.positionTitle || '队员' }}</span><span>{{ row.requestType==='application'?'申请':'邀请' }} · {{ requestText(row.status) }} · {{ row.studentName }}</span><div><el-button v-if="row.status==='pending' && canDecide(row)" type="success" plain @click="decide(row,'accept')">接受</el-button><el-button v-if="row.status==='pending' && canDecide(row)" type="danger" plain @click="decide(row,'reject')">拒绝</el-button><el-button v-if="row.status==='pending' && canCancel(row)" @click="decide(row,'cancel')">撤回</el-button></div></article></div>
        </el-tab-pane>

        <el-tab-pane label="竞赛简历" name="profile">
          <el-form :model="profile" label-position="top" class="profile-form" v-loading="loading">
            <div class="profile-summary"><div><strong>{{ profile.studentName }}</strong><span>{{ profile.studentNumber }}</span></div><div>{{ profile.grade }} · {{ profile.major }} · {{ profile.college }}</div></div>
            <el-form-item label="技能标签（学生自填）"><el-select v-model="profile.skills" multiple filterable allow-create default-first-option placeholder="输入技能后回车" /></el-form-item>
            <div class="two-col"><el-form-item label="擅长方向"><el-input v-model="profile.specialties" maxlength="500" /></el-form-item><el-form-item label="期望岗位"><el-input v-model="profile.preferredRoles" maxlength="500" /></el-form-item></div>
            <el-form-item label="个人简介"><el-input v-model="profile.bio" type="textarea" :rows="3" maxlength="500" show-word-limit /></el-form-item>
            <el-form-item label="竞赛经历"><el-input v-model="profile.competitionExperience" type="textarea" :rows="4" maxlength="1500" show-word-limit /></el-form-item>
            <div class="two-col"><el-form-item label="作品链接"><el-input v-model="profile.portfolioUrl" placeholder="https://" /></el-form-item><el-form-item label="每周可投入时间"><el-input-number v-model="profile.weeklyHours" :min="0" :max="168" /><span class="unit">小时</span></el-form-item></div>
            <div class="privacy-options"><strong>对其他学生公开</strong><el-switch v-model="profile.showBio" :active-value="1" :inactive-value="0" active-text="个人简介" /><el-switch v-model="profile.showPortfolio" :active-value="1" :inactive-value="0" active-text="作品链接" /><el-switch v-model="profile.showWeeklyHours" :active-value="1" :inactive-value="0" active-text="每周时间" /><p>默认不公开上述内容；完整学号仅队伍内部可见。</p></div>
            <el-button type="primary" :loading="saving" @click="saveProfile">保存竞赛简历</el-button>
            <el-divider content-position="left">系统认证获奖经历</el-divider>
            <el-table :data="profile.approvedAwards || []" size="small"><el-table-column prop="competitionName" label="竞赛" /><el-table-column prop="projectName" label="项目" /><el-table-column prop="awardLevel" label="奖项" width="120" /></el-table>
          </el-form>
        </el-tab-pane>
      </el-tabs>
    </main>

    <el-dialog v-model="createVisible" title="创建竞赛队伍" width="min(680px, 94vw)">
      <el-form :model="createForm" label-position="top">
        <el-form-item label="竞赛"><el-select v-model="createForm.competitionId" filterable placeholder="选择竞赛" style="width:100%"><el-option v-for="c in competitions" :key="c.competitionId" :label="c.competitionName" :value="c.competitionId" /></el-select></el-form-item>
        <div class="two-col"><el-form-item label="队伍名称"><el-input v-model="createForm.name" maxlength="50" /></el-form-item><el-form-item label="目标人数"><el-input-number v-model="createForm.targetSize" :min="1" :max="50" /></el-form-item></div>
        <el-form-item label="队伍介绍"><el-input v-model="createForm.description" type="textarea" :rows="3" maxlength="1000" /></el-form-item>
        <el-form-item label="我的岗位"><el-input v-model="createForm.leaderRole" placeholder="如：项目负责人" /></el-form-item>
        <div class="position-editor"><div class="position-head"><strong>招募岗位</strong><el-button link type="primary" :icon="Plus" @click="createForm.positions.push(blankPosition())">添加岗位</el-button></div><div v-for="(p,i) in createForm.positions" :key="i" class="position-row"><el-input v-model="p.title" placeholder="岗位名称" /><el-input-number v-model="p.vacancies" :min="1" :max="20" /><el-input v-model="p.requiredSkills" placeholder="所需技能，逗号分隔" /><el-button :icon="Delete" circle text type="danger" @click="createForm.positions.splice(i,1)" /></div></div>
      </el-form><template #footer><el-button @click="createVisible=false">取消</el-button><el-button type="primary" :loading="saving" @click="createTeam">创建并发布</el-button></template>
    </el-dialog>

    <el-drawer v-model="detailVisible" size="min(720px, 96vw)" :title="detail.name || '队伍详情'">
      <template v-if="detail.teamId">
        <div class="detail-head"><el-tag>{{ detail.competitionName }}</el-tag><el-tag :type="detail.status==='locked'?'warning':'success'">{{ statusText(detail.status) }}</el-tag></div><p>{{ detail.description || '暂无介绍' }}</p>
        <el-descriptions :column="2" border><el-descriptions-item label="人数">{{ detail.members?.length }}/{{ detail.targetSize }}</el-descriptions-item><el-descriptions-item label="截止">{{ formatTime(detail.teamCloseTime) }}</el-descriptions-item></el-descriptions>
        <h3>团队成员</h3><el-table :data="detail.members" class="desktop-table"><el-table-column prop="studentName" label="姓名" /><el-table-column v-if="detail.isMember" prop="studentNumber" label="学号" /><el-table-column prop="roleName" label="岗位" /><el-table-column v-if="detail.isLeader && editable" label="管理" width="210"><template #default="{row}"><template v-if="!row.isLeader"><el-button link type="primary" @click="transferLeader(row)">转让</el-button><el-button link @click="editMemberRole(row)">调整岗位</el-button><el-button link type="danger" @click="removeMember(row)">移除</el-button></template></template></el-table-column></el-table>
        <div class="mobile-list"><article v-for="row in detail.members" :key="row.studentId" class="mobile-item"><strong>{{ row.studentName }} <el-tag v-if="row.isLeader" size="small">负责人</el-tag></strong><span v-if="detail.isMember">学号：{{ row.studentNumber }}</span><span>岗位：{{ row.roleName || '队员' }}</span><div v-if="detail.isLeader && editable && !row.isLeader"><el-button link type="primary" @click="transferLeader(row)">转让</el-button><el-button link @click="editMemberRole(row)">调整岗位</el-button><el-button link type="danger" @click="removeMember(row)">移除</el-button></div></article></div>
        <div class="section-tools"><h3>招募岗位</h3><el-button v-if="detail.isLeader && editable" link type="primary" @click="openPosition()">新增岗位</el-button></div>
        <div v-for="p in detail.positions" :key="p.positionId" class="position-item"><div><strong>{{ p.title }}</strong><span>{{ p.occupied }}/{{ p.vacancies }} 人 · {{ p.requiredSkills || '不限技能' }} · {{ !editable?'历史岗位':p.status==='open'?(p.remainingSeats?'开放中':'已满员'):'已关闭' }}</span><p>{{ p.requirements || '暂无补充要求' }}</p></div><div class="position-actions"><el-button v-if="detail.isLeader && editable" link @click="openPosition(p)">编辑</el-button><el-button v-if="detail.isLeader && editable && p.status==='open'" link type="warning" @click="closePosition(p)">关闭</el-button><el-button v-if="!detail.isMember && detail.canApply && p.status==='open' && p.remainingSeats" type="primary" plain @click="openApply(p)">申请</el-button></div></div>
        <p v-if="!detail.canApply && !detail.isMember" class="section-note">{{ detail.unavailableReason }}</p>
        <div v-if="detail.isLeader && editable" class="leader-actions"><el-button @click="openEditTeam">编辑队伍</el-button><el-button :disabled="!detail.canApply" :title="detail.unavailableReason || ''" @click="openInvite">邀请学生</el-button><el-button @click="loadCandidates">推荐队员</el-button><el-button @click="toggleRecruiting">{{ detail.recruiting ? '关闭招募' : '开启招募' }}</el-button><el-button type="warning" @click="lockTeam">锁定队伍</el-button><el-button type="danger" plain @click="dissolveTeam">解散</el-button></div>
        <div v-if="detail.isMember && editable" class="leader-actions"><el-button type="danger" plain @click="leaveTeam">退出队伍</el-button></div>
        <el-button v-if="!detail.isMember && !['removed','dissolved'].includes(detail.status)" text type="danger" @click="reportTeam">举报招募</el-button>
        <section v-if="candidateVisible" class="candidate-list"><h3>适合本队的学生</h3><p class="section-note">技能由学生自行填写，系统认证经历单独标注。推荐名单不显示学号，可直接向候选人发送站内邀请。</p><article v-for="candidate in candidates" :key="candidate.studentId" class="candidate-item"><strong>{{ candidate.studentName }} · {{ candidate.major }} · {{ candidate.grade }}</strong><span>{{ candidate.score }} 分 · {{ candidate.positionTitle }}</span><div class="reason-list"><span v-for="reason in candidate.reasons" :key="reason">{{ reason }}</span></div><el-button link type="primary" @click="viewCandidate(candidate)">查看公开简历</el-button><el-button link type="primary" @click="inviteCandidate(candidate)">邀请此人</el-button></article><el-empty v-if="!candidates.length" description="暂无可推荐的学生" /></section>
      </template>
    </el-drawer>

    <el-dialog v-model="applyVisible" title="申请加入" width="min(480px, 92vw)"><p>申请岗位：{{ selectedPosition?.title }}</p><el-input v-model="actionForm.message" type="textarea" :rows="4" maxlength="500" placeholder="介绍你的能力和参赛计划" /><template #footer><el-button @click="applyVisible=false">取消</el-button><el-button type="primary" :loading="saving" @click="submitApply">提交申请</el-button></template></el-dialog>
    <el-dialog v-model="inviteVisible" title="邀请学生" width="min(480px, 92vw)"><el-form label-position="top"><el-form-item v-if="actionForm.targetStudentId" label="邀请对象"><span>{{ actionForm.targetStudentName }}（系统内学生）</span></el-form-item><el-form-item v-else label="学生学号"><el-input v-model="actionForm.studentNumber" /></el-form-item><el-form-item label="岗位"><el-select v-model="actionForm.positionId" style="width:100%"><el-option v-for="p in availablePositions" :key="p.positionId" :label="`${p.title}（剩余 ${p.remainingSeats}）`" :value="p.positionId" /></el-select></el-form-item><el-form-item label="邀请说明"><el-input v-model="actionForm.message" type="textarea" :rows="3" /></el-form-item></el-form><template #footer><el-button @click="inviteVisible=false">取消</el-button><el-button type="primary" :loading="saving" @click="submitInvite">发送邀请</el-button></template></el-dialog>
    <el-dialog v-model="editVisible" title="编辑队伍" width="min(520px,94vw)"><el-form label-position="top"><el-form-item label="队伍名称"><el-input v-model="editForm.name" maxlength="50" /></el-form-item><el-form-item label="队伍介绍"><el-input v-model="editForm.description" type="textarea" :rows="3" maxlength="1000" /></el-form-item><el-form-item label="目标人数"><el-input-number v-model="editForm.targetSize" :min="1" :max="50" /></el-form-item></el-form><template #footer><el-button @click="editVisible=false">取消</el-button><el-button type="primary" :loading="saving" @click="saveTeam">保存</el-button></template></el-dialog>
    <el-dialog v-model="positionVisible" :title="positionForm.positionId?'编辑岗位':'新增岗位'" width="min(520px,94vw)"><el-form label-position="top"><el-form-item label="岗位名称"><el-input v-model="positionForm.title" maxlength="50" /></el-form-item><el-form-item label="招募名额"><el-input-number v-model="positionForm.vacancies" :min="1" :max="50" /></el-form-item><el-form-item label="所需技能"><el-input v-model="positionForm.requiredSkills" placeholder="用逗号分隔" /></el-form-item><el-form-item label="补充要求"><el-input v-model="positionForm.requirements" type="textarea" /></el-form-item></el-form><template #footer><el-button @click="positionVisible=false">取消</el-button><el-button type="primary" :loading="saving" @click="savePosition">保存</el-button></template></el-dialog>
    <el-dialog v-model="candidateProfileVisible" :title="candidateProfile.studentName || '公开简历'" width="min(520px,94vw)"><p>{{ candidateProfile.major }} · {{ candidateProfile.grade }}</p><p>技能（自填）：{{ candidateProfile.skills?.join('、') || '暂未填写' }}</p><p v-if="candidateProfile.bio">简介：{{ candidateProfile.bio }}</p><p v-if="candidateProfile.portfolioUrl">作品：{{ candidateProfile.portfolioUrl }}</p><p v-if="candidateProfile.weeklyHours != null">每周时间：{{ candidateProfile.weeklyHours }} 小时</p><h3>系统认证获奖经历</h3><p v-for="award in candidateProfile.approvedAwards" :key="award.projectName">{{ award.competitionName }} · {{ award.awardLevel }}</p></el-dialog>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Delete, Plus, Refresh, Search } from '@element-plus/icons-vue'
import NavBar from '../components/NavBar.vue'
import request from '../utils/request'

const route=useRoute(),router=useRouter(),loading=ref(false),saving=ref(false)
const activeTab=ref(route.query.tab || 'market'), requestScope=ref('mine'),requestView=ref('pending'),mineScope=ref('leader'), grades=['21级','22级','23级','24级','25级','26级']
const filters=reactive({competition:'',skill:'',major:'',grade:'',status:''}),market=reactive({list:[],total:0,page:1,pageSize:12}),mine=reactive({teams:[]}),requests=ref([]),profile=reactive({skills:[],weeklyHours:0,approvedAwards:[],showBio:0,showPortfolio:0,showWeeklyHours:0}),recommendations=ref([])
const competitions=ref([]),createVisible=ref(false),detailVisible=ref(false),applyVisible=ref(false),inviteVisible=ref(false),editVisible=ref(false),positionVisible=ref(false),candidateVisible=ref(false),candidateProfileVisible=ref(false),candidates=ref([]),candidateProfile=reactive({}),detail=reactive({}),selectedPosition=ref(null),actionForm=reactive({message:'',studentNumber:'',targetStudentId:null,targetStudentName:'',positionId:null})
const editForm=reactive({name:'',description:'',targetSize:2,version:0}),positionForm=reactive({positionId:null,title:'',vacancies:1,requiredSkills:'',requirements:''})
const blankPosition=()=>({title:'',vacancies:1,requirements:'',requiredSkills:''})
const createForm=reactive({competitionId:null,name:'',description:'',targetSize:3,leaderRole:'负责人',positions:[blankPosition()]})
const pendingCount=computed(()=>requests.value.filter(v=>v.status==='pending').length)
const visibleMine=computed(()=>mine.teams.filter(t=>mineScope.value==='history'?t.historical:!t.historical&&(mineScope.value==='leader'?Boolean(t.isLeader):!t.isLeader)))
const currentUser=()=>JSON.parse(localStorage.getItem('saims_user')||'{}')
const visibleRequests = computed(() => requests.value.filter(r => {
  if (requestView.value === 'history') return r.status !== 'pending'
  if (requestView.value === 'outgoing') return r.status === 'pending' && r.operatorId === currentUser().userId
  return r.status === 'pending' && canDecide(r) &&
    (requestScope.value === 'mine' ? r.requestType === 'invitation' : r.requestType === 'application')
}))
const editable=computed(()=>['recruiting','closed'].includes(detail.status))
const availablePositions=computed(()=>(detail.positions||[]).filter(p=>p.status==='open'&&p.remainingSeats>0))
const unwrap=res=>{if(res.code!=='200')throw new Error(res.msg||'操作失败');return res.data}
const api=async(promise,success)=>{try{const data=unwrap(await promise);if(success)ElMessage.success(success);return data}catch(e){ElMessage.error(e.message||'操作失败');throw e}}
const statusText=s=>({recruiting:'招募中',closed:'已成队',locked:'已锁定',dissolved:'已解散',removed:'已下架'}[s]||s)
const requestText=s=>({pending:'待处理',accepted:'已接受',rejected:'已拒绝',cancelled:'已撤回',expired:'已失效'}[s]||s)
const requestTag=s=>({accepted:'success',rejected:'danger',pending:'warning',expired:'info'}[s]||'info')
const splitSkills=v=>[...new Set(String(v).split(/[,，]/).map(s=>s.trim()).filter(Boolean))].slice(0,8)
const formatTime=v=>v?new Date(v).toLocaleString('zh-CN',{month:'2-digit',day:'2-digit',hour:'2-digit',minute:'2-digit'}):'长期开放'

async function loadMarket(){loading.value=true;try{const data=await api(request.get('/api/teams',{params:{...filters,page:market.page,pageSize:market.pageSize}}));Object.assign(market,data)}finally{loading.value=false}}
function clearFilters(){Object.assign(filters,{competition:'',skill:'',major:'',grade:'',status:''});market.page=1;loadMarket()}
async function loadRecommendations(){loading.value=true;try{recommendations.value=await api(request.get('/api/teams/recommendations'))}finally{loading.value=false}}
async function loadMine(){loading.value=true;try{const data=await api(request.get('/api/teams/mine'));mine.teams=data.teams||[]}finally{loading.value=false}}
async function loadRequests(){loading.value=true;try{const [mine,managed]=await Promise.all([api(request.get('/api/team-requests',{params:{scope:'mine'}})),api(request.get('/api/team-requests',{params:{scope:'managed'}}))]);requests.value=[...new Map([...mine,...managed].map(row=>[row.requestId,row])).values()]}finally{loading.value=false}}
async function loadProfile(){loading.value=true;try{Object.assign(profile,await api(request.get('/api/team-profiles/me')))}finally{loading.value=false}}
async function tabChanged(tab){router.replace({query:tab==='market'?{}:{tab}});if(tab==='market')loadMarket();if(tab==='recommended')loadRecommendations();if(tab==='mine')loadMine();if(tab==='requests')loadRequests();if(tab==='profile')loadProfile()}
async function openCreate(){if(!competitions.value.length)competitions.value=await api(request.get('/competition/all'));createVisible.value=true}
async function createTeam(){if(!createForm.competitionId||!createForm.name)return ElMessage.warning('请选择竞赛并填写队伍名称');saving.value=true;try{const data=await api(request.post('/api/teams',createForm),'队伍已发布');createVisible.value=false;activeTab.value='mine';await loadMine();showDetail(data.teamId)}finally{saving.value=false}}
async function showDetail(id,wantApply=false,positionId=null){Object.keys(detail).forEach(k=>delete detail[k]);Object.assign(detail,await api(request.get(`/api/teams/${id}`)));detailVisible.value=true;candidateVisible.value=false;if(wantApply&&!detail.isMember&&detail.canApply&&availablePositions.value.length)openApply(availablePositions.value.find(p=>p.positionId===positionId)||availablePositions.value[0])}
function openApply(position){selectedPosition.value=position;actionForm.message='';applyVisible.value=true}
async function submitApply(){if(saving.value)return;saving.value=true;try{await api(request.post(`/api/teams/${detail.teamId}/apply`,{positionId:selectedPosition.value.positionId,message:actionForm.message}),'申请已发送');applyVisible.value=false;loadRequests()}finally{saving.value=false}}
function openInvite(){Object.assign(actionForm,{studentNumber:'',targetStudentId:null,targetStudentName:'',positionId:availablePositions.value[0]?.positionId||null,message:''});inviteVisible.value=true}
function inviteCandidate(candidate){Object.assign(actionForm,{studentNumber:'',targetStudentId:candidate.studentId,targetStudentName:candidate.studentName,positionId:candidate.positionId,message:''});inviteVisible.value=true}
async function submitInvite(){if(saving.value)return;saving.value=true;try{await api(request.post(`/api/teams/${detail.teamId}/invite`,actionForm),'邀请已发送');inviteVisible.value=false;loadRequests()}finally{saving.value=false}}
async function decide(row,action){if(action==='cancel')await ElMessageBox.confirm('撤回后对方将无法再接受，确定继续？','撤回请求');await api(request.post(`/api/team-requests/${row.requestId}/${action}`),action==='accept'?'已接受':action==='cancel'?'已撤回':'已拒绝');loadRequests();if(detail.teamId)showDetail(detail.teamId)}
function canDecide(row){const user=currentUser();return row.requestType==='invitation'?row.studentId===user.studentId:row.leaderId===user.studentId}
function canCancel(row){return row.operatorId===currentUser().userId}
async function saveProfile(){saving.value=true;try{Object.assign(profile,await api(request.put('/api/team-profiles/me',profile),'竞赛简历已保存'))}finally{saving.value=false}}
async function toggleRecruiting(){await api(request.post(`/api/teams/${detail.teamId}/recruiting`,{recruiting:!detail.recruiting}),'招募状态已更新');showDetail(detail.teamId)}
async function lockTeam(){await ElMessageBox.confirm('锁定后仅管理员可以解锁，确定继续？','锁定队伍',{type:'warning'});await api(request.post(`/api/teams/${detail.teamId}/lock`),'队伍已锁定');showDetail(detail.teamId)}
async function dissolveTeam(){await ElMessageBox.confirm('解散后不可恢复，确定解散？','解散队伍',{type:'error'});await api(request.post(`/api/teams/${detail.teamId}/dissolve`),'队伍已解散');detailVisible.value=false;loadMine()}
async function transferLeader(row){await ElMessageBox.confirm(`将负责人转让给 ${row.studentName}？`,'转让负责人');await api(request.post(`/api/teams/${detail.teamId}/transfer`,{studentId:row.studentId}),'负责人已转让');showDetail(detail.teamId)}
async function removeMember(row){await ElMessageBox.confirm(`确定移除 ${row.studentName}？`,'移除成员',{type:'warning'});await api(request.delete(`/api/teams/${detail.teamId}/members/${row.studentId}`),'成员已移除');showDetail(detail.teamId)}
function openEditTeam(){Object.assign(editForm,{name:detail.name,description:detail.description||'',targetSize:detail.targetSize,version:detail.version});editVisible.value=true}
async function saveTeam(){saving.value=true;try{await api(request.put(`/api/teams/${detail.teamId}`,editForm),'队伍已更新');editVisible.value=false;await showDetail(detail.teamId);loadMine()}finally{saving.value=false}}
function openPosition(p){Object.assign(positionForm,p?{positionId:p.positionId,title:p.title,vacancies:p.vacancies,requiredSkills:p.requiredSkills||'',requirements:p.requirements||''}:{positionId:null,title:'',vacancies:1,requiredSkills:'',requirements:''});positionVisible.value=true}
async function savePosition(){saving.value=true;try{if(positionForm.positionId)await api(request.put(`/api/teams/${detail.teamId}/positions/${positionForm.positionId}`,positionForm),'岗位已更新');else await api(request.post(`/api/teams/${detail.teamId}/positions`,positionForm),'岗位已新增');positionVisible.value=false;showDetail(detail.teamId)}finally{saving.value=false}}
async function closePosition(p){await ElMessageBox.confirm(`关闭“${p.title}”后待处理请求将失效，确定继续？`,'关闭岗位',{type:'warning'});await api(request.post(`/api/teams/${detail.teamId}/positions/${p.positionId}/close`),'岗位已关闭');showDetail(detail.teamId)}
async function editMemberRole(row){const choices=(detail.positions||[]).filter(p=>p.status==='open');const {value}=await ElMessageBox.prompt(`填写 ${row.studentName} 的新岗位名称`,'调整岗位',{inputValue:row.roleName||'',inputValidator:v=>!!v.trim()||'请输入岗位名称'});const position=choices.find(p=>p.title===value.trim());await api(request.put(`/api/teams/${detail.teamId}/members/${row.studentId}/role`,{roleName:value.trim(),positionId:position?.positionId||null}),'岗位已调整');showDetail(detail.teamId)}
async function leaveTeam(){await ElMessageBox.confirm('退出后将失去队伍成员权限；若你是唯一成员，队伍将解散。确定继续？','退出队伍',{type:'warning'});await api(request.post(`/api/teams/${detail.teamId}/leave`),'已退出队伍');detailVisible.value=false;loadMine()}
async function loadCandidates(){candidates.value=await api(request.get(`/api/teams/${detail.teamId}/candidates`));candidateVisible.value=true}
async function viewCandidate(candidate){Object.keys(candidateProfile).forEach(k=>delete candidateProfile[k]);Object.assign(candidateProfile,await api(request.get(`/api/team-profiles/${candidate.studentId}`)));candidateProfileVisible.value=true}
async function reportTeam(){const {value}=await ElMessageBox.prompt('请说明举报原因','举报招募',{inputType:'textarea',inputValidator:v=>!!v.trim()||'请输入举报原因'});await api(request.post(`/api/teams/${detail.teamId}/reports`,{reason:value}),'举报已提交')}
onMounted(async()=>{await Promise.all([loadMarket(),loadRequests()]);if(activeTab.value!=='market')tabChanged(activeTab.value);if(route.query.teamId)showDetail(route.query.teamId)})
</script>

<style scoped>
.team-page{min-height:100vh;color:#1e293b}.team-shell{max-width:1320px;margin:0 auto;padding:40px 20px 60px}.page-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding:0 4px}.page-head h1{font-size:22px;margin:0 0 6px;font-weight:700;letter-spacing:0;color:#1e293b}.page-head p{margin:0;color:#64748b}.page-head :deep(.el-button--primary),.filters :deep(.el-button--primary){border:0;border-radius:10px;background:linear-gradient(135deg,#6366f1,#818cf8);box-shadow:0 4px 12px -2px rgba(99,102,241,.28)}.team-tabs{padding:0 24px 26px;background:rgba(255,255,255,.65);backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,.85);border-radius:20px;box-shadow:0 10px 30px -10px rgba(15,23,42,.08)}.team-tabs :deep(.el-tabs__header){margin-bottom:20px}.team-tabs :deep(.el-tabs__item){height:52px;font-weight:600;color:#64748b}.team-tabs :deep(.el-tabs__item.is-active){color:#6366f1}.team-tabs :deep(.el-tabs__active-bar){background:#6366f1}.filters{display:grid;grid-template-columns:2fr 1.2fr 1.2fr 1fr 1fr;gap:12px;padding:16px 20px;margin-bottom:22px;background:rgba(255,255,255,.45);border:1px solid rgba(255,255,255,.7);border-radius:16px}.filters>*{min-width:0}.filter-actions{grid-column:1/-1;display:flex;justify-content:flex-end;gap:10px}.filter-actions :deep(.el-button){min-width:100px;margin-left:0}.filters :deep(.el-input__wrapper),.filters :deep(.el-select__wrapper){border-radius:12px;background:rgba(248,250,252,.82);box-shadow:0 0 0 1px #e2e8f0 inset}.team-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:18px;min-height:240px}.team-card{padding:20px;background:rgba(255,255,255,.82);border:1px solid rgba(226,232,240,.85);border-radius:16px;box-shadow:0 4px 16px rgba(15,23,42,.04);display:flex;flex-direction:column;min-width:0;transition:box-shadow .2s ease,border-color .2s ease}.team-card:hover{border-color:#c7d2fe;box-shadow:0 10px 24px rgba(99,102,241,.1)}.card-top,.card-actions,.section-tools,.detail-head,.position-head{display:flex;justify-content:space-between;align-items:center;gap:10px}.team-card h2{font-size:18px;margin:16px 0 8px;color:#1e293b}.description{color:#64748b;line-height:1.65;min-height:50px}.team-card dl{margin:8px 0}.team-card dl div{display:grid;grid-template-columns:72px 1fr;padding:5px 0}.team-card dt{color:#94a3b8}.team-card dd{margin:0;color:#475569;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.skills{display:flex;flex-wrap:wrap;gap:5px;margin:6px 0}.deadline{font-size:12px;color:#94a3b8;margin-top:auto;padding:14px 0}.card-actions{justify-content:flex-end;border-top:1px solid #edf0f2;padding-top:14px}.card-actions :deep(.el-button){border-radius:8px}.section-tools{margin:8px 0 16px;color:#64748b}.request-table{margin-top:18px}.team-tabs :deep(.el-table){border-radius:16px;overflow:hidden;background:transparent;--el-table-border-color:rgba(226,232,240,.45);--el-table-header-bg-color:rgba(248,250,252,.85)}.team-tabs :deep(.el-table tr){background:rgba(255,255,255,.4)}.team-tabs :deep(.el-table th.el-table__cell){height:54px;color:#475569;font-weight:700}.profile-form{max-width:900px;padding:12px 4px}.profile-summary{display:flex;justify-content:space-between;padding:18px 20px;margin-bottom:22px;background:rgba(238,242,255,.65);border:1px solid #e0e7ff;border-radius:14px}.profile-summary strong{font-size:20px;margin-right:12px}.profile-summary span,.unit{color:#64748b;margin-left:8px}.two-col{display:grid;grid-template-columns:1fr 1fr;gap:18px}.position-editor{border:1px solid #e2e8f0;border-radius:14px;padding:16px;background:#f8fafc}.position-row{display:grid;grid-template-columns:1fr 100px 1.4fr 40px;gap:8px;margin-top:10px}.detail-head{justify-content:flex-start}.team-page h3{font-size:16px;margin:24px 0 10px}.position-item{display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #eceff1;padding:12px 2px}.position-item span{display:block;color:#69737d;margin-top:4px}.position-item p{margin:5px 0;color:#8a939c}.leader-actions{display:flex;flex-wrap:wrap;gap:8px;border-top:1px solid #e4e8eb;margin-top:24px;padding-top:18px}
@media(max-width:960px){.team-grid{grid-template-columns:repeat(2,minmax(0,1fr))}.filters{grid-template-columns:1fr 1fr}.page-head{align-items:center}}
@media(max-width:640px){.team-shell{padding:18px 12px 40px}.page-head h1{font-size:22px}.page-head p{display:none}.team-tabs{padding:0 10px 18px;border-radius:16px}.team-tabs :deep(.el-tabs__nav-wrap.is-scrollable){padding:0}.team-tabs :deep(.el-tabs__nav-prev),.team-tabs :deep(.el-tabs__nav-next){display:none}.team-tabs :deep(.el-tabs__nav-scroll){overflow:visible}.team-tabs :deep(.el-tabs__nav){display:grid!important;grid-template-columns:repeat(2,minmax(0,1fr));width:100%;transform:none!important}.team-tabs :deep(.el-tabs__item){justify-content:center;padding:0 6px}.team-tabs :deep(.el-tabs__active-bar){display:none}.team-tabs :deep(.el-tabs__item.is-active){box-shadow:inset 0 -2px #6366f1}.team-grid{grid-template-columns:1fr}.filters,.two-col{grid-template-columns:1fr}.filters{padding:14px}.position-row{grid-template-columns:1fr 90px}.position-row :nth-child(3){grid-column:1/-1}.profile-summary{display:block}.profile-summary>div:last-child{margin-top:8px}}
.result-count,.section-note{color:#64748b;font-size:13px;line-height:1.6}.result-count{margin:-8px 0 16px}.reason-list{display:flex;gap:6px;flex-wrap:wrap;margin:12px 0}.reason-list span{background:#eef2ff;color:#4f46e5;padding:5px 9px;border-radius:8px;font-size:12px}.match-score{font-size:18px;color:#4f46e5}.privacy-options{display:flex;align-items:center;flex-wrap:wrap;gap:12px;padding:16px;border-radius:12px;background:#f8fafc;margin-bottom:16px}.privacy-options p{width:100%;margin:0;color:#64748b;font-size:12px}.position-actions{display:flex;flex-wrap:wrap;justify-content:flex-end}.candidate-item{padding:14px;border:1px solid #e2e8f0;border-radius:12px;margin:10px 0}.candidate-item strong,.candidate-item>span{display:block}.candidate-item>span{color:#64748b;margin-top:6px}.mobile-list{display:none}.request-view{margin-left:12px}.card-actions .el-button{white-space:normal;height:auto;min-height:32px}
@media(max-width:640px){.page-head{align-items:flex-start;gap:10px}.page-head :deep(.el-button){flex-shrink:0}.filters{grid-template-columns:1fr}.desktop-table{display:none}.mobile-list{display:grid;gap:12px}.mobile-item{display:grid;gap:8px;border:1px solid #e2e8f0;background:#fff;border-radius:12px;padding:14px}.mobile-item span{color:#64748b;font-size:13px}.request-view{margin:12px 0 0}.section-tools{flex-wrap:wrap}.position-item{align-items:flex-start;gap:8px;flex-direction:column}.team-tabs :deep(.el-tabs__nav){grid-template-columns:repeat(2,minmax(0,1fr))}}
</style>
