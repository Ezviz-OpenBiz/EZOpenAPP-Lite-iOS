# EZOpenAPP-Lite-iOS
萤石开放平台开源APP


##运行准备
1.	工程中去除了appkey，需要自行去[萤石开放平台官网](https://open.ys7.com)申请appkey.
2. 修改工程中的OPENSDK_APPKEY宏定义，修改为申请或的appkey。
3. 修改bundleId，bundleId和appkey需要一一对应的。
4. 由于Realm库文件较大，需要找到Venders文件夹下的Realm.zip，解压到Venders文件夹中。
5. 更换调试证书。
6. 完成以上步骤方可编译运行。