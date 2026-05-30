import { router } from '@kit.ArkUI';
import PermissionsUtil from '../utils/PermissionsUtil';
import { PPBluetoothKit } from 'ppsdkkit/src/main/ets/PPBluetoothKit';
import { OptimizedTextToBinary } from 'ppsdkkit';
import { ByteUtil } from 'ppsdkkit/src/main/ets/utils/ByteUtil';

@Entry
@Component
struct Index {

  aboutToAppear(): void {
    PermissionsUtil.requestPermissions(['ohos.permission.ACCESS_BLUETOOTH'])
  }

  build() {
    Column() {
      Button('蓝牙扫描').onClick((event: ClickEvent) => {
        router.pushUrl({
          url: "ppble/ble/search/SearchDeviceList"
        })
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }



  // private settings: RenderingContextSettings = new RenderingContextSettings(true);
  // private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  // private offCanvas: OffscreenCanvas = new OffscreenCanvas(32, 9.8)
  //
  // build() {
  //   Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
  //     Canvas(this.context)
  //       .width(32)
  //       .height(9.8)
  //       .borderWidth(1)
  //       .borderColor('#000000')
  //       .backgroundColor('#FFFFFF')
  //       .onReady(() =>  {
  //         const offContext = this.offCanvas.getContext("2d", this.settings);
  //
  //         // 1. 绘制白色背景
  //         offContext.fillStyle = '#FFFFFF';
  //         offContext.fillRect(0, 0, 32, 9.8); // 画布宽50，高25
  //
  //         // 2. 设置文字样式（修正字体语法和大小）
  //         offContext.fillStyle = '#000000'; // 文字颜色：黑色
  //         // 正确格式：font-weight font-size font-family（字体大小适配画布高度）
  //         offContext.font = 'bold 25px'; // 18px适合25px高度的画布
  //         offContext.textBaseline = "middle"; // 垂直居中（基线对齐中点）
  //         offContext.textAlign = "center"; // 水平居
  //         offContext.fillText("12", 32 / 2, 9.8 / 2);
  //         let image = this.offCanvas.transferToImageBitmap()
  //
  //         const imageData = offContext.getImageData(0, 0, this.offCanvas.width, this.offCanvas.height);
  //
  //
  //         const uint8Array = new Uint8Array(imageData.data.buffer);
  //
  //
  //         // 复制数据
  //         uint8Array.set(imageData.data);
  //
  //         const aa = ByteUtil.uint8ArrayToHex(uint8Array);
  //
  //         console.info(aa);
  //
  //         this.context.transferFromImageBitmap(image)
  //       })
  //   }
  //   .width('100%')
  //   .height('100%')
  // }

  }