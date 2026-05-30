import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { PPBluetoothKit,PPLogger } from 'ppsdkkit';

export default class EntryAbility extends UIAbility {
  NORMAL_APPKEY = "lefub60060202a15ac8a";
  NORMAL_APPSECRET = "UCzWzna/eazehXaz8kKAC6WVfcL25nIPYlV9fXYzqDM=";

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {


    PPLogger.i('Ability onCreate ');
    PPBluetoothKit.addLoggerListener({
      d:(msg: string) => {

      },
      e:(msg: string) => {

      },
      i:(msg: string) => {

      },
      w:(msg: string) => {

      }
    })
    //可控制SDK是否打印日志
    PPBluetoothKit.setDebug(true)
    ///SDK初始化Appkey和AppSecret在你自己的App中请替换为为你自己的Appkey和AppSecret,Appkey获取方式:https://xinzhiyun.feishu.cn/docx/VxXUdI86sorr96xSdn1cakkZndd?from=from_copylink
    //configPath内部配置文件路径，请替换为真实路径, SDK内部暂时未实现,下个版本会支持.后续更新时请更换为你自己的Appkey和AppSecret和configPath
    PPBluetoothKit.initSdk(this.context, this.NORMAL_APPKEY, this.NORMAL_APPSECRET, 'lefu.config');
  }

  onDestroy(): void {
    PPLogger.i('Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate('filesDir', this.context.filesDir); // 全局存储

    PPLogger.i('Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        PPLogger.e(`Failed to load the content. Cause: ${JSON.stringify(err)}`);
        return;
      }
     PPLogger.i('Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    PPLogger.i('Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    PPLogger.i('Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    PPLogger.i('Ability onBackground');
  }
}
