import { router } from '@kit.ArkUI';
import {
  PPBleSearch,
  PPBluetoothKit,
  PPLogger,
  PPDeviceModel,
  PPDevicePeripheralType,
  PPDeviceCalculateType,
  PPScaleHelper
} from 'ppsdkkit';
import { access } from '@kit.ConnectivityKit';

// These fields are optional extensions returned by some device payloads. They are
// intentionally kept local because older ppsdkkit versions do not declare them
// on PPDeviceModel yet.
interface DeviceNetworkPropertiesJson {
  needAuth?: boolean;
  httpType?: number;
  isSupportADN?: boolean;
}

@Extend(Text)
function deviceInfoText() {
  .fontSize(12)
  .fontColor('#FFFFFF')
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text)
function sectionTitle() {
  .fontSize(14)
  .fontWeight(FontWeight.Bold)
  .fontColor('#000000')
  .width('100%')
}

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
          List({ space: 12 }) {
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
        } else {
          Column() {
            Text(this.scanSwitch ? '正在扫描设备…' : '暂无设备发现')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#64748B')
            Text(this.scanSwitch ? '请保持设备靠近并开启蓝牙' : '开启扫描后，附近设备会显示在这里')
              .fontSize(13)
              .fontColor('#9AA4B2')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
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
    Column({ space: 4 }) {
      Text('Add Devices To The Platform')
        .sectionTitle()

      Column({ space: 4 }) {
        Row(){
          Text(`DeviceName: ${this.device?.deviceName || '--'}`)
            .deviceInfoText()
          Text('')
        }.width('100%') // Row撑满整行宽度
        .justifyContent(FlexAlign.Start) // 子元素【水平靠左】

        Row() {
          Text(`AdvLength: ${this.device?.advLength ?? 0}`)
            .deviceInfoText()
            .layoutWeight(1)
          Text(`Sign: ${this.device?.sign || '--'}`)
            .deviceInfoText()
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .deviceInfoPanel()

      Text('Basic Attributes')
        .sectionTitle()

      Column({ space: 4 }) {
        Row() {
          Text(`MAC: ${this.device?.deviceMac || '--'}`)
            .deviceInfoText()
            .layoutWeight(1)
          Text(`RSSI: ${this.device?.rssi ?? 0}db`)
            .deviceInfoText()
            .layoutWeight(1)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Row(){
          Text(`PeripheralType: ${this.getPeripheralType()}`)
            .deviceInfoText()
          Text('')
        }.width('100%') // Row撑满整行宽度
        .justifyContent(FlexAlign.Start) // 子元素【水平靠左】

        Row(){
          Text(`NeedAuth: ${this.getNeedAuthText()}`)
            .deviceInfoText()
          Text('')
        }.width('100%') // Row撑满整行宽度
        .justifyContent(FlexAlign.Start) // 子元素【水平靠左】
      }
      .deviceInfoPanel()

      if (PPScaleHelper.isFuncTypeWifi(this.device?.deviceFuncType)) {
        Text('Distribution Networks')
          .sectionTitle()

        Column({ space: 4 }) {

          Row(){
            Text(`WifiProtocolType: ${this.getWifiProtocolType()}`)
              .deviceInfoText()
            Text('')
          }.width('100%') // Row撑满整行宽度
          .justifyContent(FlexAlign.Start) // 子元素【水平靠左】

          Row(){
            Text(`HttpScheme: ${this.getHttpScheme()}`)
              .deviceInfoText()
            Text('')
          }.width('100%') // Row撑满整行宽度
          .justifyContent(FlexAlign.Start) // 子元素【水平靠左】

          Row(){
            Text(`SupportADN: ${this.getSupportAdnText()}`)
              .deviceInfoText()
            Text('')
          }.width('100%') // Row撑满整行宽度
          .justifyContent(FlexAlign.Start) // 子元素【水平靠左】




        }
        .deviceInfoPanel()
      }

      if (this.shouldShowComputingLibrary()) {
        Text('Computing Library')
          .sectionTitle()

        Column({ space: 4 }) {

          Row(){
            Text(`CalculateType: ${this.getCalculateType()}`)
              .deviceInfoText()
            Text('')
          }.width('100%') // Row撑满整行宽度
          .justifyContent(FlexAlign.Start) // 子元素【水平靠左】


          Row(){
              Text(`CalculateAPI: ${this.getCalculateAPI()}`)
              .deviceInfoText()
            Text('')
          }.width('100%') // Row撑满整行宽度
          .justifyContent(FlexAlign.Start) // 子元素【水平靠左】


          if (this.getProduct() >= 0) {
            Row(){
              Text(`Product: ${this.getProduct()}`)
                .deviceInfoText()
              Text('')
            }.width('100%') // Row撑满整行宽度
            .justifyContent(FlexAlign.Start) // 子元素【水平靠左】
          }




        }
        .deviceInfoPanel()
      }
    }
    .onClick(() => {
      if (this.device) {
        this.onItemClick(this.device);
      }
    })
    .width('100%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  @Styles
  deviceInfoPanel() {
    .width('100%')
    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
    .backgroundColor('#999999')
    .borderRadius(6)
  }

  private getPeripheralType(): string {
    const type = this.device?.getDevicePeripheralType() ?? 0;
    return `${PPDevicePeripheralType[type] || 'Unknown'}`;
  }

  private getWifiProtocolType(): string {
    switch (this.device?.getDevicePeripheralType()) {
      case PPDevicePeripheralType.PeripheralApple:
      case PPDevicePeripheralType.PeripheralCoconut:
        return 'V2.0/V3.0 Protocol';
      case PPDevicePeripheralType.PeripheralIce:
      case PPDevicePeripheralType.PeripheralTorre:
      case PPDevicePeripheralType.PeripheralBorre:
      case PPDevicePeripheralType.PeripheralDorre:
        return 'Torre/V4.0 Protocol';
      default:
        return 'Unknown';
    }
  }

  /**
   * Read optional network properties from the model's JSON representation.
   * This keeps the UI compatible with SDK versions that do not expose these
   * properties in the PPDeviceModel declaration.
   */
  private getNetworkProperties(): DeviceNetworkPropertiesJson {
    if (!this.device) {
      return {};
    }
    try {
      return JSON.parse(JSON.stringify(this.device)) as DeviceNetworkPropertiesJson;
    } catch (_) {
      return {};
    }
  }

  private getNeedAuthText(): string {
    return this.getNetworkProperties().needAuth ? 'Need' : 'No Need';
  }

  private getHttpScheme(): string {
    return this.getNetworkProperties().httpType === 1 ? 'https' : 'http';
  }

  private getSupportAdnText(): string {
    return this.getNetworkProperties().isSupportADN ? 'Yes' : 'No';
  }

  private getCalculateType(): string {
    const calculateType = this.device?.deviceCalculateType ?? 0;
    return `${PPDeviceCalculateType[calculateType] || 'Unknown'}`;
  }

  private getCalculateAPI(): string {
    switch (this.device?.deviceCalculateType) {
      case PPDeviceCalculateType.PPDeviceCalculateTypeDirect:
        return 'DC Four-Electrode Algorithm v2.0';
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate:
      case PPDeviceCalculateType.PPDeviceCalculateTypeNormal:
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate4_0:
        return 'AC Four-Electrode Algorithm';
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate4_1:
        return 'Dual-Frequency AC Four-Electrode Algorithm';
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8:
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_0:
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_1:
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_2:
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_3:
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_4:
        return 'AC Eight-Electrode Algorithm';
      // alternate8_5：当前 Harmony SDK 尚未声明该枚举值
      case 14:
        return 'AC Eight-Electrode Algorithm Smooth';
      default:
        return 'AC Four-Electrode Algorithm';
    }
  }

  private getProduct(): number {
    switch (this.device?.deviceCalculateType) {
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8:
        return 1;
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_0:
        return 4;
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_1:
        return 3;
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_2:
        return 7;
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_3:
        return 5;
      case PPDeviceCalculateType.PPDeviceCalculateTypeAlternate8_4:
        return 6;
      // alternate8_5 is not yet declared in this Harmony SDK, but remains compatible with its numeric value.
      case 14:
        return 6;
      default:
        return -1;
    }
  }

  private shouldShowComputingLibrary(): boolean {
    return this.device?.deviceCalculateType !== PPDeviceCalculateType.PPDeviceCalculateTypeNeedNot;
  }

  onItemClick: (device: PPDeviceModel) => void = () => {
    if (this.itemClick) {
      if (this.device) {
        this.itemClick(this.device)
      }
    }
  }

}
