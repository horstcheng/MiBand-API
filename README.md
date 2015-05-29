MiBand-API
========

[小米手环](http://www.mi.com/shouhuan) iOS API. 当前 API 基于固件版本 v1.0.6.3 (手机手环 iOS 客户端 v1.0.16)。

## 使用
工程中添加`CoreBluetooth.framework`，引入`MiBand`文件夹，`#import "MiBand.h"`。

```
self.centralManager = [MBCentralManager sharedCentralManager];
__weak typeof(self) this = self;
[self.centralManager scanForMiBandWithBlock:^(MBPeripheral *miband, NSNumber *RSSI, NSError *error) {
    [this.centralManager stopScan];
    [this.centralManager connectPeripheral:miband withResultBlock:^(MBPeripheral *peripheral, NSError *error) {
        MBUserInfoModel *me = ...
        [peripheral bindingWithUser:me withBlock:^(NSError *error) {
            //连接成功
        }];
    }];
}];
```

### 步数

```
// 获取当前总步数
__weak typeof(self) this = self;
[self.peripheral readRealtimeStepsWithBlock:^(NSUInteger steps, NSError *error) {
    this.realtimeStepsLabel.text = [NSString stringWithFormat:@"%tu", steps];
}];

// 实时更新步数
[self.peripheral subscribeRealtimeStepsWithBlock:^(NSUInteger steps, NSError *error) {
    this.realtimeStepsLabel.text = [NSString stringWithFormat:@"%tu", steps];
}];
```

### 睡眠 

```
// Todo
```

### 设置

```
//查找手环
[self.peripheral sendNotificationWithType:MBNotificationTypeNormal withBlock:^(NSError *error) {
}];

//目标设定
[self.peripheral setGoalSteps:8000 withBlock:^(NSError *error) {
}];

//指示灯颜色
[self.peripheral setColorWithRed:6 green:0 blue:0 blink:YES withBlock:^(NSError *error) {
}];

//佩戴方式
[self.peripheral setWearPosition:MBWearPositionLeft withBlock:^(NSError *error) {
}];

//来电提醒
[self.peripheral setCallRemindInterval:10 withBlock:^(NSError *error) {
}];
```

## 感谢
虽然通过 hook `CBCentralManager`和`CBPeripheral` 基本上获取了所有的蓝牙指令，但是部分指令的意义及解析还是不太清楚，感谢[stormluke](https://github.com/stormluke) 的 [Mili-iOS](https://github.com/stormluke/Mili-iOS) 让我对各指令的意义有了参考，同时大部分的实现都直接拿来或参考了Mili-iOS。

~~希望喜欢折腾的小伙伴们一起贡献代码，Thanks。~~
本人已入 **Apple Watch**, 小米手环已出，后面应该不会再维护该项目。如有兴趣，自行 Fork 代码。
