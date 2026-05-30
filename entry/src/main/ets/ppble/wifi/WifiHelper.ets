import { PPBaseDeviceControl } from 'ppsdkkit';

export class WifiHelper {
  private static instance: WifiHelper;
  deviceControl ?: PPBaseDeviceControl;

  static wifiDomainName = "http://120.79.144.170:6032";

  static getInstance(): WifiHelper {
    if (!WifiHelper.instance) {
      WifiHelper.instance = new WifiHelper();
    }
    return WifiHelper.instance;
  }
}