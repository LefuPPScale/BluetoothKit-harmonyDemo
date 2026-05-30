import { ble, constant } from '@kit.ConnectivityKit';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 连接 -> 连接中 -> 断开
 * 1、根据deviceID初始化gattClient实例，失败会有提示，业务可以做微调
 * 2、当前不同连接状态显示不同文字，连接/断开
 */

@Entry
@Component
export default struct BleConnect {
  @State deviceId: string = '';
  @State gattClient: ble.GattClientDevice | undefined = undefined;
  @State connectState: ble.ProfileConnectionState = constant.ProfileConnectionState.STATE_DISCONNECTED;
  @State btValue: string = '连接';
  private connectStateChange: Callback<ble.ProfileConnectionState> = () => {
  }

  aboutToAppear(): void {
    this.initGattClient()
  }

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      if (this.connectState === constant.ProfileConnectionState.STATE_CONNECTING) {
        LoadingProgress().color(Color.White)
      } else {
        Text(this.btValue).fontSize(14).fontColor(0xffffff)
      }
    }
    .borderRadius(8)
    .width(90).height(40)
    .onClick((event: ClickEvent) => {
      if (this.connectState === constant.ProfileConnectionState.STATE_DISCONNECTED) {
        this.connectServer()
      } else {
        this.disconnectServer()
      }
    })
  }

  /**
   * 初始化gattClient实例
   */
  initGattClient() {
    if (this.gattClient) {
      return;
    }

    try {
      this.gattClient = ble.createGattClientDevice(this.deviceId);
      this.onBLEConnectionStateChange()
    } catch (err) {
      this.showToast('连接失败，请重试！')
      hilog.error(0x0000, 'errCode: ' + (err as BusinessError).code + ', errMessage: ' + (err as BusinessError).message,
        '');
    }
  }

  /**
   * client端发起连接远端蓝牙低功耗设备
   */
  connectServer() {
    if (this.gattClient && this.connectState !== constant.ProfileConnectionState.STATE_CONNECTED) {
      this.gattClient.connect()
    }
  }

  /**
   * client端断开与远端蓝牙低功耗设备的连接
   */
  disconnectServer() {
    if (this.gattClient && this.connectState !== constant.ProfileConnectionState.STATE_DISCONNECTED) {
      this.gattClient.disconnect()
    }
  }

  /**
   * client端订阅蓝牙低功耗设备的连接状态变化事件
   */
  onBLEConnectionStateChange() {
    if (!this.gattClient) {
      this.showToast('连接失败，请重试！')
      return;
    }

    this.gattClient.on('BLEConnectionStateChange', (state: ble.BLEConnectionChangeState) => {
      hilog.info(0x0000, 'BleConnect BluetoothPage bluetooth connect state changed', '');
      this.connectState = state.state;
      this.connectStateChange(this.connectState)
      if (this.connectState === constant.ProfileConnectionState.STATE_DISCONNECTED) {
        this.btValue = '连接';
        this.showToast('断开成功')
      }

      if (this.connectState === constant.ProfileConnectionState.STATE_CONNECTED) {
        this.showToast('连接成功')
        this.btValue = '断开';
      }
      hilog.info(0x0000, 'BleConnect BluetoothPage bluetooth connectState ' + JSON.stringify(this.connectState), '');
    })
  }

  showToast(msg: string) {
    promptAction.showToast({
      message: msg
    })
  }
}