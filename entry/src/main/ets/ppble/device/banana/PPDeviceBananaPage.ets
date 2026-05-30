import { ble, constant } from '@kit.ConnectivityKit';
import { promptAction, router } from '@kit.ArkUI';
import { LogDisplay } from '../../commonview/LogDisplay';
import { PPLogger,PPBananaDeviceControl,PPDeviceModel,PPBodyBaseModel,
  PPScaleStateHeartRateType, } from 'ppsdkkit';

/**
 * 连接 -> 连接中 -> 断开
 * 1、根据deviceID初始化gattClient实例，失败会有提示，业务可以做微调
 * 2、当前不同连接状态显示不同文字，连接/断开
 */

@Entry
@Component
struct PPDeviceBananaPage {
  @State deviceId: string = '';
  @State deviceModel: PPDeviceModel | null = null;
  @State gattClient: ble.GattClientDevice | undefined = undefined;
  @State connectState: ble.ProfileConnectionState = constant.ProfileConnectionState.STATE_DISCONNECTED;
  @State btValue: string = '扫描';
  @State logContent: string = ''
  deviceControl: PPBananaDeviceControl | null = null;
  @State pageTitle: string = "设备详情"

  aboutToAppear(): void {
    this.deviceModel = getRouteParams<PPDeviceModel>();
    if (this.deviceModel) {
      this.pageTitle = (this.deviceModel?.deviceName ?? "设备详情") + "-Banana"
      this.deviceId = this.deviceModel?.deviceRemoteId ?? "";
      this.addLog(`准备扫描:${this.deviceModel?.deviceName} ${this.deviceModel?.deviceRemoteId}`)
      this.deviceControl = new PPBananaDeviceControl(this.deviceModel);
      this.startSearch()
      this.deviceControl?.registerDataChangeListener({
        monitorProcessData: (bodyBaseModel: PPBodyBaseModel | null, deviceModel: PPDeviceModel | null) => {
          const scaleState = bodyBaseModel?.scaleState
          if (scaleState?.heartRateType === PPScaleStateHeartRateType.HEARTRATE_MEASURING) {
            this.addLog(`心率测量中 ${bodyBaseModel?.getPpWeightKg()}`);
          } else if (bodyBaseModel?.isOverload){
            this.addLog(`超重`);
          } else {
            this.addLog(`实时数据:${bodyBaseModel?.getPpWeightKg()}`)
          }
        },

        monitorLockData: (bodyBaseModel: PPBodyBaseModel | null, deviceModel: PPDeviceModel | null) => {
          if (bodyBaseModel?.isHeartRating) {
            this.addLog(`心率测量中`)
          } else {
            this.addLog(`稳定数据:${bodyBaseModel?.getPpWeightKg()} impedance:${bodyBaseModel?.impedance}`)
            this.addLog(`测量结束`)
          }
        },

      })
    }
  }

  aboutToDisappear(): void {
    this.stopSearch()
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.pageTitle)
          .fontSize(20)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(50)
      .backgroundColor('#f0f0f0')

      Column() {
        // 上半部分 - 日志显示区域
        LogDisplay({ logContent: (this.logContent) })
          .height("45%");

        // 下半部分 - 控制区域（示例）
        Column() {
          Row() {
            Button({ type: ButtonType.Normal, stateEffect: true }) {
              if (this.connectState === constant.ProfileConnectionState.STATE_CONNECTING) {
                LoadingProgress().color(Color.White).height(40)
              } else {
                Text(this.btValue).fontSize(12).fontColor(0xffffff)
              }
            }
            .onClick((event: ClickEvent) => {
              if (this.connectState === constant.ProfileConnectionState.STATE_DISCONNECTED) {
                this.startSearch()
              } else {
                this.stopSearch()
              }
            })
            .height(40)
            .borderRadius(8)
            .fontSize(12)
            .margin(2)
            .width('80%')


          }

        }
      }
      .width('100%')
      .height('100%')
      .padding(15)
      .backgroundColor('#f1f3f5')
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

  // 添加日志方法
  addLog(message: string) {
    // 添加新日志到数组开头
    this.logContent += `${message}\n`
    PPLogger.d(message)
  }

  /**
   * 广播设备，使用扫描即可。
   */
  startSearch() {
    if (!this.deviceControl?.isSearch()) {
      this.addLog('开始广播扫描')
      if (this.deviceControl) {
        this.deviceControl!.deviceModel = this.deviceModel ?? null
      }

      //延迟1000ms是因为上一个页面的蓝牙扫描状态还没更新，所以需要延迟一下
      setTimeout(() => {
        this.deviceControl?.startSearch();
      }, 1000); // 延迟1000ms

    } else {
      this.addLog('已经在广播扫描')
    }
  }

  /**
   * client端断开与远端蓝牙低功耗设备的连接
   */
  stopSearch() {
    this.deviceControl?.stopSearch()
  }

  showToast(msg: string) {
    promptAction.showToast({
      message: msg
    })
  }
}

function getRouteParams<T>(): T {
  return router.getParams() as T;
}

