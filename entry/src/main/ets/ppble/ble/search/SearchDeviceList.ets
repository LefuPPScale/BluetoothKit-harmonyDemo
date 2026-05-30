import { router } from '@kit.ArkUI';
import { PPBleSearch, PPBluetoothKit, PPLogger, PPDeviceModel, PPDevicePeripheralType } from 'ppsdkkit';
import { access } from '@kit.ConnectivityKit';

@Entry
@Component
struct SearchDeviceList {
  @State bleSwitch: boolean = false;
  @State scanSwitch: boolean = false;
  @State deviceModels: Array<PPDeviceModel> = [];

  aboutToAppear(): void {
    PPBluetoothKit.addBleStateListener((state: number) => {
      this.changeBleState(access.BluetoothState.STATE_ON === state)
    })
  }

  onPageShow(): void {
    this.getBleState()
  }

  aboutToDisappear(): void {
    this.stopScan();
  }

  build() {
    Column({ space: 10 }) {
      // 蓝牙开关控制行
      Row() {
        Text('蓝牙状态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Toggle({ type: ToggleType.Switch, isOn: this.bleSwitch })
          .onChange((isOn: boolean) => {
            this.changeBleState(isOn);
            if (!isOn) {
              this.scanSwitch = false; // 关闭蓝牙时自动停止扫描
              this.stopScan();
            }
          })
      }
      .cardStyle()
      .justifyContent(FlexAlign.SpaceBetween)

      // 扫描开关控制行
      Row() {
        Text('扫描状态')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)

        Toggle({ type: ToggleType.Switch, isOn: this.scanSwitch })
          .onChange((isOn: boolean) => {
            if (isOn && this.bleSwitch) {
              this.startScan();
            } else {
              this.stopScan();
            }
            this.scanSwitch = isOn;
          })
          .enabled(this.bleSwitch) // 蓝牙未开启时禁用扫描开关
      }
      .cardStyle()
      .justifyContent(FlexAlign.SpaceBetween)

      // 设备列表区域
      Column() {
        if (this.deviceModels.length > 0) {
          List() {
            ForEach(this.deviceModels, (device: PPDeviceModel, index: number) => {
              ListItem() {
                deviceItem({
                  device: device, itemClick: (device: PPDeviceModel) => {
                    this.itemClick(index, device);
                  }
                })
              }
            })
          }
          .scrollBar(BarState.Off)
          .width('100%')
          .height('100%')
          .divider({
            strokeWidth: 1,
            color: '#f0f0f0',
            startMargin: 10,
            endMargin: 10
          })
        } else {
          Column() {
            Text(this.scanSwitch ? '扫描中...' : '暂无设备发现')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .cardStyle()
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .padding(15)
    .backgroundColor('#f1f3f5')
  }

  private itemClick(index: number, device: PPDeviceModel) {
    this.stopScan();
    if (device) {
      if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralApple) {
        router.pushUrl({
          url: "ppble/device/apple/PPDeviceApplePage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralTorre) {
        router.pushUrl({
          url: "ppble/device/torre/PPDeviceTorrePage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralCoconut) {
        router.pushUrl({
          url: "ppble/device/coconut/PPDeviceCoconutPage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralBanana) {
        router.pushUrl({
          url: "ppble/device/banana/PPDeviceBananaPage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralBorre) {
        router.pushUrl({
          url: "ppble/device/borre/PPDeviceBorrePage",
          params: device
        });

      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralBorre) {
        router.pushUrl({
          url: "ppble/device/borre/PPDeviceBorrePage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralDorre) {
        router.pushUrl({
          url: "ppble/device/apple/PPDeviceApplePage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralForre) {
        router.pushUrl({
          url: "ppble/device/apple/PPDeviceApplePage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralEgg) {
        router.pushUrl({
          url: "ppble/device/egg/PPDeviceEggPage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralJambul) {
        router.pushUrl({
          url: "ppble/device/jambul/PPDeviceJambulPage",
          params: device
        });
      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralIce) {
        router.pushUrl({
          url: "ppble/device/ice/PPDeviceIcePage",
          params: device


        });
      }else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralHamburger) {
        router.pushUrl({
          url: "ppble/device/hamburger/PPDeviceHamburgerPage",
          params: device
        })

      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralFish) {
        router.pushUrl({
          url: "ppble/device/fish/PPDeviceFishPage",
          params: device


        });

      } else if (device?.getDevicePeripheralType() == PPDevicePeripheralType.PeripheralGrapes) {
        router.pushUrl({
          url: "ppble/device/grapes/PPDeviceGrapesPage",
          params: device


        });

      }
    }

  }

  // 卡片样式
  @Styles
  cardStyle() {
    .width('100%')
    .padding(12)
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .shadow({
      radius: 2,
      color: '#f0f0f0',
      offsetX: 0,
      offsetY: 1
    })
  }

  /**
   * 开、关蓝牙
   */
  // 改变蓝牙状态
  private async changeBleState(isOn: boolean) {
    try {
      if (isOn) {
        PPBluetoothKit.enableBluetooth();
        this.bleSwitch = true;
        this.scanSwitch = true;
        this.startScan()
      } else {
        PPBluetoothKit.disableBluetooth();
        this.bleSwitch = false;
        this.deviceModels = []; // 清空设备列表
      }
    } catch (err) {
      console.error('蓝牙状态切换失败:', err);
      this.bleSwitch = !isOn; // 恢复切换前状态
    }
  }

  /**
   * 获取蓝牙开关状态
   */
  getBleState() {
    try {
      if (PPBluetoothKit.getStateIsOn()) {
        this.bleSwitch = true;
        this.scanSwitch = true;
        this.startScan()
      } else {
        this.bleSwitch = false;
      }
    } catch (err) {
      PPLogger.e("蓝牙开关异常")
    }
  }

  /**
   * 发起BLE扫描流程
   */
  startScan() {
    this.deviceModels = [];
    PPBleSearch.getInstance().startScan((deviceModel: PPDeviceModel) => {
      const existingIndex = this.deviceModels.findIndex(
        item => item.deviceMac === deviceModel.deviceMac
      );

      if (deviceModel) {
        //这里为了快速响应UI刷新暂时先采用双数组,BleDevice用于UI显示，后期开发优化会只有PPDeviceModel，
        // 在集成时可自行选择，SDK内部业务使用到的是PPDeviceModel
        if (existingIndex === -1) {
          this.deviceModels.push(deviceModel);
        } else {
          this.deviceModels[existingIndex] = deviceModel;
        }
      }
    });
  }

  /**
   * 关闭BLE扫描流程
   */
  stopScan() {
    PPBleSearch.getInstance().stopScan();
    this.scanSwitch = false;
  }
}


@Component
struct deviceItem {
  device: PPDeviceModel | null = null;
  itemClick?: (device: PPDeviceModel) => void

  build() {
    Column({ space: 5 }) {

      Text(`Name:${this.device?.deviceName}`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('100%')

      Row() {
        Text(`Mac:${this.device?.deviceMac}`)
          .fontSize(12)
          .fontColor('#666666')
          .width('100%')


      }.width(`100%`)

      Row() {
        Text(`advLength:${this.device?.advLength}`)
          .fontSize(12)
          .fontColor('#666666')
          .width('50%')

        Text(`sign:${this.device?.sign}`)
          .fontSize(12)
          .fontColor('#666666')
          .width('50%')

      }.width('100%')

      Text(`PeripheralType:${PPDevicePeripheralType[this.device?.getDevicePeripheralType()??0]}`)
        .fontSize(12)
        .fontColor('#666666')
        .width('100%')

    }
    .onClick(() => {
      if (this.device) {
        this.onItemClick(this.device);
      }
    })
    .width('100%')
    .padding(10)
    .backgroundColor('#ffffff')
    .borderRadius(8)
  }

  onItemClick: (device: PPDeviceModel) => void = () => {
    if (this.itemClick) {
      if (this.device) {
        this.itemClick(this.device)
      }
    }
  }

  /**
   * 连接状态回调
   * @param state
   */
  private getRssiColor(rssi: number): ResourceColor {
    if (rssi >= -50) {
      return '#4CAF50';
    } // 强信号-绿色
    if (rssi >= -70) {
      return '#FFC107';
    } // 中等信号-黄色
    return '#F44336'; // 弱信号-红色
  }
}
