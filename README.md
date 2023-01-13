# 配置文件说明

## 配置文件名
配置名根据配置类型进行命名，存在以下几种格式：
- `0_${base_config_name}.json`，基础配置，必需下载
- `1_${base_config_name}.json`，全局前置配置，互斥，按需下载
- `2_${base_config_name}.json`，全局后置配置，互斥，按需下载
- `${package}_${appname}.json`，应用配置，按需下载
- `${package}_${appname}_${optional_function}.json`，应用的可选配置，按需下载
    - `optional_function` 前缀相同的配置为互斥配置，下载其一即可
    - 例如以下两个文件互斥
        - `com.tencent.mobileqq_QQ_群消息整形-群名标题前添加发送者.json`
        - `com.tencent.mobileqq_QQ_群消息整形-群名移动至 subtext.json`

## 配置使用方式
1. 设置配置目录，入口位于：推送服务 - 设置
2. 下载所需配置放入该目录中
3. （可选）若需自定义通知图标，可以在配置目录下创建 `icon` 文件夹，将 [AndroidNotifyIconAdapt](https://github.com/fankes/AndroidNotifyIconAdapt) 仓库的 `json` 文件放入其中

## 配置类型
配置共分为两类：
- 主配置，具有实际包名的配置项
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
- 子配置，作为引用项被主配置
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
- 执行 `^` 配置
- 执行应用配置，如 `com.coolapk.market`
- 执行 `$` 配置

其中，只要遇到一个配置不存在 `"stop": false` 的配置，整个流程即会结束