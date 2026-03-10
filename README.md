# Nova Browser (HarmonyOS / ArkTS)

基于 PRD V1.0 实现的鸿蒙浏览器示例工程，包含：

- 首页（搜索、快捷站点、最近访问）
- 浏览页（地址栏、WebView、加载控制）
- 标签系统（新建/切换/关闭/列表）
- 无痕模式（不写历史）
- 历史记录（查看/删除/清空）
- 浏览控制（前进、后退、刷新、停止、菜单）
- 设置（搜索引擎切换、Cookie 开关、清理缓存/历史）

## 目录

- `AppScope/app.json5`
- `entry/module.json5`
- `entry/src/main/ets/MainAbility/MainAbility.ets`
- `entry/src/main/ets/pages/Index.ets`
- `entry/src/main/ets/model/BrowserModels.ets`
- `entry/src/main/ets/store/BrowserStore.ets`

## 说明

本项目遵循 Stage 模型与 ArkTS 语法，适合作为 Nova Browser V1.0 的功能实现参考。
