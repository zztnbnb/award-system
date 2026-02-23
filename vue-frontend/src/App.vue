<template>
  <router-view />
</template>

<script>
/**
 * Vue应用根组件
 * 功能：
 * 1. 作为整个Vue应用的入口组件
 * 2. 通过RouterView实现单页应用的路由切换
 * 3. 所有页面组件都会在此处渲染
 */
export default {
  name: 'App'
}
</script>

<style>
/* 全局样式，应用于整个应用 */
</style>
