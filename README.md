# 配置文件说明
配置文件可以做到以下事情：
- 修改通知显示效果
- 通知到来时唤醒屏幕
- 通知到来时触发通知被点击效果（仅触发效果，未实际点击通知）

## 配置文件名
配置名根据以下格式命名，共分为四个部分：

`${package}_${appname}_${optional_function}-${exclusive_description}.json`

不同部分的含义分别为：
- 必填：`${package}`，应用包名
    - 使用包名来区分配置针对的是什么应用
    - 特殊包名：
        - `0`，基础配置，必需下载
        - `1`，全局前置配置
        - `2`，全局后置配置
- 必填：`${appname}`，应用名
    - 用于快速识别配置针对的是什么应用
- 可选：`${optional_function}`，功能名
    - 一个应用的配置可以由多份配置文件组成，使用不同的 `${optional_function}` 来标识不同的能力
- 可选：`${exclusive_description}`，互斥能力描述
    - 配置中存在相同 `${optional_function}` 时，说明这一组配置文件为互斥配置，只有一个配置生效，此时应只保留其中一个配置文件
    - 互斥示例（`${optional_function}` = `群消息整形`）：
        - `com.tencent.mobileqq_QQ_群消息整形-群名标题前添加发送者.json`
        - `com.tencent.mobileqq_QQ_群消息整形-群名移动至 subtext.json`

## 配置使用方式
1. 设置配置目录，入口位于：推送服务 - 设置
2. 下载所需配置放入该目录中
3. （可选）若需自定义通知图标，可以在配置目录下创建 `icon` 文件夹，将 [AndroidNotifyIconAdapt](https://github.com/fankes/AndroidNotifyIconAdapt) 仓库的 `json` 文件放入其中

## 配置类型
配置共分为两类：
- 主配置，具有实际包名的配置项（`${package}_${appname}.json`）
``` json
{
  "version": "0.1.0",
  "configs": {
    "com.coolapk.market": [
      "大图标显示成圆形"
    ]
  }
}

```
- 子配置，提供引用项被主配置引用（`${package}_${appname}_${optional_function}-${exclusive_description}.json`）
``` json
{
  "version": "0.1.0",
  "configs": {
    "大图标显示成圆形": [
      {
        "newMetaInfo": {
          "extra": {
            "__mi_push_round_large_icon": ""
          }
        },
        "stop": false
      }
    ]
  }
}

```

## 配置执行流程
弹出通知时，通过会经过配置进行整行或忽略，执行流程如下：
- 执行 `^` 配置（`1_${appname}.json`）
- 执行应用配置，如 `com.coolapk.market`（`com.coolapk.market_酷安.json`）
- 执行 `$` 配置（`2_${appname}.json`）

在配置执行过程中，若遇到一个匹配成功的配置，其配置中未定义 `"stop": false`，则整个流程结束
