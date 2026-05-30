import { router } from '@kit.ArkUI';
import { PPIceDeviceControl,PPTorreDeviceControl,PPLogger,PPDeviceModel,PPWifiModel } from 'ppsdkkit';
import { WifiHelper } from './WifiHelper';

@Entry
@Component
struct WifiListPager {
  @State scanStateStr: string = "Wifi列表获取中...";
  @State deviceModels: Array<PPWifiModel> = [];
  @State deviceModel: PPDeviceModel | null = null;
  @State pageTitle: string = "Wifi列表"

  aboutToAppear(): void {
    this.deviceModel = getRouteParams<PPDeviceModel>();
    if (WifiHelper.getInstance().deviceControl instanceof PPTorreDeviceControl) {
      const deviceControl = WifiHelper.getInstance().deviceControl as PPTorreDeviceControl;
      const result = deviceControl.getWifiList((devices: Array<PPWifiModel> | null) => {
        if (devices && devices.length > 0) {
          this.scanStateStr = "Wifi列表获取成功";
          this.deviceModels = devices;
        } else {
          this.scanStateStr = "Wifi列表获取失败";
        }
      })
      if (!result) {
        this.scanStateStr = "Wifi列表获取失败";
      }
    } else if (WifiHelper.getInstance().deviceControl instanceof PPIceDeviceControl) {
      const deviceControl = WifiHelper.getInstance().deviceControl as PPIceDeviceControl;
      const result = deviceControl.getWifiList((devices: Array<PPWifiModel> | null) => {
        if (devices && devices.length > 0) {
          this.scanStateStr = "Wifi列表获取成功";
          this.deviceModels = devices;
        } else {
          this.scanStateStr = "Wifi列表获取失败";
        }
      })
      if (!result) {
        this.scanStateStr = "Wifi列表获取失败";
      }
    }

  }

  onPageShow(): void {

  }

  aboutToDisappear(): void {
    if (WifiHelper.getInstance().deviceControl instanceof PPTorreDeviceControl) {
      const deviceControl = WifiHelper.getInstance().deviceControl as PPTorreDeviceControl;
      const result = deviceControl.exitConfigWifi()
      PPLogger.d("exitConfigWifi 退出配网 result:" + result)
    } else if (WifiHelper.getInstance().deviceControl instanceof PPIceDeviceControl) {
      const deviceControl = WifiHelper.getInstance().deviceControl as PPIceDeviceControl;
      const result = deviceControl.exitWifiList()
      PPLogger.d("exitConfigWifi 退出配网 result:" + result)
    }
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.pageTitle)
          .fontSize(20)
          .margin({ left: 2, right: 2 })
      }
      .width('100%')
      .height(50)
      .backgroundColor('#f0f0f0')

      // Wifi列表区域
      Column() {
        if (this.deviceModels.length > 0) {
          List() {
            ForEach(this.deviceModels, (device: PPWifiModel, index: number) => {
              ListItem() {
                deviceItem({
                  device: device, itemClick: (device: PPWifiModel) => {
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
            Text(this.scanStateStr)
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .layoutWeight(1)
      .cardStyle()
      .width('100%')
    }
    .height(`calc(100% - 10vp)`)
    .width('100%')
    .padding(15)
    .backgroundColor('#f1f3f5')
  }

  private itemClick(index: number, device: PPWifiModel) {
    router.pushUrl({
      url: "ppble/wifi/ConfigWifiPager",
      params: device
    });
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
}


@Component
struct deviceItem {
  device: PPWifiModel | null = null;
  itemClick?: (device: PPWifiModel) => void

  build() {
    Column({ space: 5 }) {

      Text(`Name:${this.device?.ssid}`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .width('100%')

      Row() {
        Text(`sign:${(this.device?.sign ?? 0).toString()}`)
          .fontSize(12)
          .fontColor('#666666')
          .width('100%')


      }.width(`100%`)

    }
    .onClick(() => {
      if (this.device) {
        this.onItemClick(this.device);
      }
    })
    .width('100%')
    .padding(10)
    .backgroundColor($r('sys.color.white'))
    .borderRadius(8)
  }

  onItemClick: (device: PPWifiModel) => void = () => {
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


function getRouteParams<T>(): T {
  return router.getParams() as T;
}
