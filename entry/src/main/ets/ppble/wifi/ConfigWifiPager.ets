import { router } from '@kit.ArkUI';
import { PPWifiModel,PPDeviceModel,PPIceDeviceControl,PPTorreDeviceControl,PPLogger,PPConfigWifiStateMenu, PPConfigWifiStateMenuUtil } from 'ppsdkkit';
import { WifiHelper } from './WifiHelper';

@Entry
@Component
struct ConfigWifiPager {
  @State bleSwitch: boolean = false;
  @State scanSwitch: boolean = false;
  @State deviceModels: Array<PPWifiModel> = [];
  @State deviceModel: PPDeviceModel | null = null;
  @State ssid: string = "";
  @State pwd: string = "";
  @State errorCode: string = "";
  @State configState: string = "";

  aboutToAppear(): void {
    const wifiModel = getRouteParams<PPWifiModel>();
    this.ssid = wifiModel?.ssid ?? "";
  }

  onPageShow(): void {

  }

  aboutToDisappear(): void {
    if (WifiHelper.getInstance().deviceControl instanceof PPTorreDeviceControl) {
      const deviceControl = WifiHelper.getInstance().deviceControl as PPTorreDeviceControl;
      const result = deviceControl?.exitConfigWifi()
      PPLogger.d("exitConfigWifi 退出配网 result:" + result)
    } else if (WifiHelper.getInstance().deviceControl instanceof PPIceDeviceControl) {
      const deviceControl = WifiHelper.getInstance().deviceControl as PPIceDeviceControl;
      const result = deviceControl.exitConfigWifi();
      PPLogger.d("exitConfigWifi 退出配网 result:" + result)
    }
  }

  build() {
    Column({ space: 10 }) {

      Row() {
        Text("配网")
          .fontSize(20)
          .margin({ left: 2, right: 2 })
      }
      .width('100%')
      .height(50)
      .backgroundColor($r('sys.color.glass_material_outline_secondary'))

      Column({ space: 5 }) {

        TextInput({ text: this.ssid })
          .width('100%')
          .height(40)
          .fontColor($r('sys.color.black'))
          .enabled(false)

        TextInput({ placeholder: '请输入密码' })
          .width('100%')
          .height(40)
          .margin({ top: 10 })
          .fontColor($r('sys.color.black'))
          .onChange((value: string) => {
            this.pwd = value // 监听输入变化
          })

        Text(`result:${this.configState}\ncode:${this.errorCode}`)
          .fontSize(14)
          .margin({ top: 10 })
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Button() {
          Text('开始配网')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .width('50%')
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .height(40)
            .onClick(() => {
              if (WifiHelper.getInstance().deviceControl instanceof PPTorreDeviceControl) {
                const deviceControl = WifiHelper.getInstance().deviceControl as PPTorreDeviceControl;
                deviceControl.configWifi(WifiHelper.wifiDomainName, this.ssid, this.pwd,
                  (configState: PPConfigWifiStateMenu, resultCode: string) => {
                    this.errorCode = resultCode;
                    this.configState = PPConfigWifiStateMenuUtil.getDescription(configState);
                  })
              } else if (WifiHelper.getInstance().deviceControl instanceof PPIceDeviceControl) {
                const deviceControl = WifiHelper.getInstance().deviceControl as PPIceDeviceControl;

                deviceControl.modifyServerDomain(WifiHelper.wifiDomainName, (success: boolean) => {
                  if (success) {
                    PPLogger.d("modifyServerDomain 修改域名成功")
                    deviceControl.configWifi(this.ssid, this.pwd, (sn: string | null, stateMenu: PPConfigWifiStateMenu) => {
                      this.errorCode = `sn:${sn}`;
                      this.configState = PPConfigWifiStateMenuUtil.getDescription(stateMenu);
                    })
                  } else {
                    PPLogger.e("modifyServerDomain 修改域名失败")
                  }
                })
              }
            })
        }
        .margin({ top: 30 })
      }
      .cardStyle()
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 40, right: 40 })
      .justifyContent(FlexAlign.Center) // 垂直居中
      .alignItems(HorizontalAlign.Center) // 水平居中
    }
    .height(`calc(100% - 10vp)`)
    .width('100%')
    .padding(15)
    .backgroundColor($r('sys.color.comp_background_focus'))
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


function getRouteParams<T>(): T {
  return router.getParams() as T;
}
