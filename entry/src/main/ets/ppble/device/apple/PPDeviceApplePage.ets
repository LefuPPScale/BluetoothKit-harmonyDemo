import { ble, constant } from '@kit.ConnectivityKit';
import { promptAction, router } from '@kit.ArkUI';
import { LogDisplay } from '../../commonview/LogDisplay';
import { PPLogger,PPAppleDeviceControl,PPUnitType,PPDeviceModel,PPBodyBaseModel,DateUtil, PPScaleStateHeartRateType } from 'ppsdkkit';
import { CustomButton } from '../../../view/CustomButton';
import { systemDateTime } from '@kit.BasicServicesKit';

import { WifiHelper } from '../../wifi/WifiHelper';

/**
 * 连接 -> 连接中 -> 断开
 * 1、根据deviceID初始化gattClient实例，失败会有提示，业务可以做微调
 * 2、当前不同连接状态显示不同文字，连接/断开
 */

@Entry
@Component
struct PPDeviceApplePage {
  @State deviceId: string = '';
  @State deviceModel: PPDeviceModel | null = null;
  @State gattClient: ble.GattClientDevice | undefined = undefined;
  @State connectState: ble.ProfileConnectionState = constant.ProfileConnectionState.STATE_DISCONNECTED;
  @State btValue: string = '连接';
  @State logContent: string = ''
  deviceControl: PPAppleDeviceControl | null = null;
  @State pageTitle: string = "设备详情"

  aboutToAppear(): void {
    this.deviceModel = getRouteParams<PPDeviceModel>();
    if (this.deviceModel) {
      this.pageTitle = (this.deviceModel?.deviceName ?? "设备详情") + "-Apple"
      this.deviceId = this.deviceModel?.deviceRemoteId ?? "";
      this.addLog(`准备连接:${this.deviceModel?.deviceName} ${this.deviceModel?.deviceRemoteId}`)
      this.deviceControl = new PPAppleDeviceControl(this.deviceModel);
      this.connectServer()
      this.deviceControl?.registerDataChangeListener({
        monitorProcessData: (bodyBaseModel: PPBodyBaseModel | null, deviceModel: PPDeviceModel | null) => {
          const scaleState = bodyBaseModel?.scaleState
          if (scaleState?.heartRateType === PPScaleStateHeartRateType.HEARTRATE_MEASURING) {
            this.addLog(`心率测量中 ${bodyBaseModel?.getPpWeightKg()}`);
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
    this.disconnectServer()
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
                this.connectServer()
              } else {
                this.disconnectServer()
              }
            })
            .height(40)
            .borderRadius(8)
            .fontSize(12)
            .margin(2)
            .width('25%')

            CustomButton({
              buttonText: '切换单位',
              onButtonClick: () => {
                this.addLog('切换单位')
                this.deviceControl?.syncUnit(PPUnitType.Unit_KG)
              }
            })
            CustomButton({
              buttonText: '同步时间',
              onButtonClick: () => {
                this.addLog('同步时间')
                this.deviceControl?.syncTime(systemDateTime.getTime())
              }
            })

            CustomButton({
              buttonText: '设备信息',
              onButtonClick: async () => {
                this.addLog('读取设备信息')
                let deviceModel = await this.deviceControl?.readDeviceInfo()
                if (deviceModel != null) {
                  this.addLog(`设备信息返回:
                  modelNumber:${deviceModel.modelNumber}
                  firmwareRevision:${deviceModel.firmwareVersion}
                  hardwareRevision:${deviceModel.hardwareVersion}
                  softwareRevision:${deviceModel.softwareVersion}
                  serialNumber:${deviceModel.serialNumber}`)
                } else {
                  this.addLog(`设备信息:获取失败`)
                }
              }
            })

          }

          Row() {
            CustomButton({
              buttonText: '读取电量',
              onButtonClick: async () => {
                this.addLog('读取电量')
                const battery = await this.deviceControl?.readBatteryLevel()
                if (battery != null) {
                  this.addLog(`电量:${battery}`)
                } else {
                  this.addLog(`电量:获取失败`)
                }
              }
            })

            CustomButton({
              buttonText: '同步历史',
              onButtonClick: () => {
                this.addLog('同步历史')
                const result = this.deviceControl?.syncHistory({

                  monitorHistoryData: (bodyBaseModel: PPBodyBaseModel | null) => {
                    this.addLog(`历史数据:${bodyBaseModel?.getPpWeightKg()} ${DateUtil.timestampToYYYYMMDDHHMMSS(bodyBaseModel?.measureTime ??
                      0)}`);
                  },
                  monitorHistoryEnd: () => {
                    this.addLog(`历史数据结束`);
                  },
                  monitorHistoryFail: () => {
                    this.addLog(`同步历史数据失败`);
                  }
                })
                if (result) {
                } else {
                  this.addLog(`同步历史数据失败`)
                }
              }
            })

            CustomButton({
              buttonText: '删除历史',
              onButtonClick: () => {
                this.addLog('删除历史')
                const result = this.deviceControl?.deleteHistory()
                if (result) {
                  this.addLog('删除历史成功')
                } else {
                  this.addLog('删除历史失败')
                }
              }
            })

            CustomButton({
              buttonText: '恢复出厂',
              onButtonClick: async () => {
                this.addLog('恢复出厂')
                const result = await this.deviceControl?.resetDevice((result) => {
                  if (result) {
                    this.addLog(`恢复出厂成功`)
                  } else {
                    this.addLog(`恢复出厂失败`)
                  }
                });
                if (!result) {
                  this.addLog(`恢复出厂指令失败`)
                }
              }
            })
          }

          Row() {
            CustomButton({
              buttonText: '配置Wifi',
              onButtonClick: () => {
                this.addLog('配置Wifi')
                const ssid = "IT52"
                const password = "12345678"
                this.deviceControl?.configWifi(ssid, password, (sn, stateMenu) => {
                  this.addLog(`配置Wifi Success sn:${sn} ${stateMenu}`)
                })
              }
            })
            CustomButton({
              buttonText: 'Wifi信息',
              onButtonClick: () => {
                this.addLog('Wifi信息')
                this.deviceControl?.readWifiInfo((ssid) => {
                  this.addLog(`Wifi信息 ssid:${ssid}`)
                })
              }
            })
            CustomButton({
              buttonText: '修改域名',
              onButtonClick: () => {
                this.addLog('修改域名')
                //外网可以访问的域名地址
                //下发给秤的域名，用于秤访问服务器；自己项目中，请使用你自己的
                //The domain name issued to the scale for accessing the server; In your own project, please use your own
                //https://xinzhiyun.feishu.cn/docx/Xphpd83KyoSvHUxUZJUckBeqnJg?from=from_copylink
                this.deviceControl?.modifyServerDomain(WifiHelper.wifiDomainName, (result) => {
                  if (result) {
                    this.addLog(`修改域名成功`)
                  } else {
                    this.addLog(`修改域名失败`)
                  }
                })
              }
            })

          }
        }
        .margin({ top: 10 })
        .flexGrow(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .cardStyle()
      }
      .flexGrow(1)
    }
    .width('100%')
    .height('100%')
    .padding(15)
    .backgroundColor('#f1f3f5')

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
   * client端发起连接远端蓝牙低功耗设备
   */
  connectServer() {
    if (!this.deviceControl?.isConnect()) {
      this.addLog('Borre 设备未连接,开始连接')
      this.deviceControl?.startConnect((state: ble.ProfileConnectionState) => {
        this.connectState = state
        PPLogger.i('BluetoothPage bluetooth connect state changed');
        if (this.connectState === constant.ProfileConnectionState.STATE_DISCONNECTED) {
          this.btValue = '连接'
          this.showToast('断开成功')
          this.addLog('设备断开')
        }

        if (this.connectState === constant.ProfileConnectionState.STATE_CONNECTED) {
          this.showToast('连接成功')
          this.btValue = '断开'
          this.addLog('连接成功')
        }

        PPLogger.i('BluetoothPage bluetooth connectState ' + JSON.stringify(this.connectState));

      }, (isSuccess: boolean) => {
        if (isSuccess) {
          this.addLog('服务发现成功,可以调用指令')
        } else {
          this.addLog('服务发现失败')
        }
      })
    }
  }

  /**
   * client端断开与远端蓝牙低功耗设备的连接
   */
  disconnectServer() {
    this.deviceControl?.disConnect()
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

