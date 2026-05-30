import { ble, constant } from '@kit.ConnectivityKit';
import { promptAction, router, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LogDisplay } from '../../commonview/LogDisplay';
import {
  PPLogger,
  PPBorreDeviceControl,
  PPDeviceModel,
  PPUnitType,
  UnitUtil,
  TimeFormat,
  PPScaleHelper,
  PPUserModel,
  PPBodyBaseModel,
  PPScaleStateImpedanceType,
  PPScaleStateHeartRateType,
  PPScaleStatePowerType,
  PPUserGender,
  PPUserRecentBodyData,
  PPDeviceProtocolType,
  PPUserBodyDataType,
  PPDisplayMetrics
} from 'ppsdkkit';
import { CustomButton } from '../../../view/CustomButton';
import { systemDateTime } from '@kit.BasicServicesKit';
import { WifiHelper } from '../../wifi/WifiHelper';
import { InputDialog } from '../../res/InputDialog';
import { ByteUtil } from 'ppsdkkit/src/main/ets/utils/ByteUtil';

/**
 * 连接 -> 连接中 -> 断开
 * 1、根据deviceID初始化gattClient实例，失败会有提示，业务可以做微调
 * 2、当前不同连接状态显示不同文字，连接/断开
 */

@Entry
@Component
struct PPDeviceBorrePage {
  @State deviceId: string = '';
  @State deviceModel: PPDeviceModel | null = null;
  @State gattClient: ble.GattClientDevice | undefined = undefined;
  @State connectState: ble.ProfileConnectionState = constant.ProfileConnectionState.STATE_DISCONNECTED;
  @State btValue: string = '连接';
  @State logContent: string = ''
  deviceControl ?: PPBorreDeviceControl;
  @State pageTitle: string = "设备详情"
  @State pregnancyModeBtnState: boolean = false
  @State factoryPatternBtnState: boolean = false
  userModel: PPUserModel = new PPUserModel();
  dialogController: CustomDialogController | null = null;
  @StorageLink('filesDir') filesDir: string = ''; // 自动同步

  last7List = new Array<PPUserRecentBodyData>();
  aboutToAppear(): void {
    this.deviceModel = getRouteParams<PPDeviceModel>();
    this.userModel.userID = "15820440625"
    this.userModel.memberID = "1886959"
    this.userModel.userName = "LF467704"
    this.userModel.PIndex = 12
    this.userModel.weightKg = 61.9
    this.userModel.targetWeight = 10

    this.userModel.age = 35

    this.userModel.sex = PPUserGender.PPUserGenderFemale

    this.userModel.userHeight = 158

    let oneWeight = new PPUserRecentBodyData();

    oneWeight.value = 59

    oneWeight.timeStamp = 1756970490000

    oneWeight.bmi = 0

    let twoWeight = new PPUserRecentBodyData();

    twoWeight.value = 60

    twoWeight.timeStamp = 1757922361005

    twoWeight.bmi = 0


    let Weight3 = new PPUserRecentBodyData();

    Weight3.value = 65

    Weight3.timeStamp = 1757990152279

    Weight3.bmi = 0

    let Weight4 = new PPUserRecentBodyData();

    Weight4.value = 65

    Weight4.timeStamp = 1757990467485

    Weight4.bmi = 0

    let Weight5 = new PPUserRecentBodyData();

    Weight5.value = 65

    Weight5.timeStamp = 1757990467485

    Weight5.bmi = 0


    let Weight6 = new PPUserRecentBodyData();

    Weight6.value = 62

    Weight6.timeStamp = 1758157622194

    Weight6.bmi = 0

    this.last7List.push(oneWeight)

    this.last7List.push(twoWeight)

    this.last7List.push(Weight3)

    this.last7List.push(Weight4)
    this.last7List.push(Weight5)

    this.last7List.push(Weight6)




    if (this.deviceModel) {
      this.pageTitle = (this.deviceModel?.deviceName ?? "设备详情") + "-Borre"
      this.deviceId = this.deviceModel?.deviceRemoteId ?? "";
      PPLogger.d(`准备连接:${this.deviceModel?.deviceName} ${this.deviceModel?.deviceRemoteId}`)
      this.deviceControl = new PPBorreDeviceControl(this.deviceModel);
      this.connectServer()
      this.deviceControl?.registerDataChangeListener({
        monitorProcessData: (bodyBaseModel: PPBodyBaseModel | null, deviceModel: PPDeviceModel | null) => {
          const scaleState = bodyBaseModel?.scaleState
          if (scaleState?.heartRateType === PPScaleStateHeartRateType.HEARTRATE_MEASURING) {
            this.addLog(`心率测量中 ${bodyBaseModel?.getPpWeightKg()}`);
          } else if (scaleState?.impedanceType === PPScaleStateImpedanceType.IMPEDANCE_MEASURING) {
            this.addLog(`阻抗测量中...${bodyBaseModel?.getPpWeightKg()}`);
          } else if (bodyBaseModel?.isOverload) {
            this.addLog(`超重`);
          } else {
            this.addLog(`实时数据:${bodyBaseModel?.getPpWeightKg()}`)
          }
          if (scaleState?.powerType === PPScaleStatePowerType.POWER_OFF) {
            this.addLog(`设备关机`);
          }
        },

        monitorLockData: (bodyBaseModel: PPBodyBaseModel | null, deviceModel: PPDeviceModel | null) => {
          if (bodyBaseModel?.isHeartRating) {
            this.addLog(`心率测量中`)
          } else {
            if (PPScaleHelper.isCalculate8(deviceModel?.deviceCalculateType)) {
              this.addLog(`稳定数据:${bodyBaseModel?.getPpWeightKg()}
              z100KhzLeftArmEnCode:${bodyBaseModel?.z100KhzLeftArmEnCode}
              z100KhzLeftLegEnCode:${bodyBaseModel?.z100KhzLeftLegEnCode}
              z100KhzRightArmEnCode:${bodyBaseModel?.z100KhzRightArmEnCode}
              z100KhzRightLegEnCode:${bodyBaseModel?.z100KhzRightLegEnCode}
              z100KhzTrunkEnCode:${bodyBaseModel?.z100KhzTrunkEnCode}
              z20KhzLeftArmEnCode:${bodyBaseModel?.z20KhzLeftArmEnCode}
              z20KhzLeftLegEnCode:${bodyBaseModel?.z20KhzLeftLegEnCode}
              z20KhzRightArmEnCode:${bodyBaseModel?.z20KhzRightArmEnCode}
              z20KhzRightLegEnCode:${bodyBaseModel?.z20KhzRightLegEnCode}
              z20KhzTrunkEnCode:${bodyBaseModel?.z20KhzTrunkEnCode}
              heartRate:${bodyBaseModel?.heartRate}
              `)
            } else if (PPScaleHelper.isCalculate4DualFrequency(deviceModel?.deviceCalculateType)) {
              this.addLog(`稳定数据:${bodyBaseModel?.getPpWeightKg()} impedance:${bodyBaseModel?.impedance}
              ppImpedance100EnCode:${bodyBaseModel?.ppImpedance100EnCode}
              heartRate:${bodyBaseModel?.heartRate}`)
            } else {
              this.addLog(`稳定数据:${bodyBaseModel?.getPpWeightKg()} impedance:${bodyBaseModel?.impedance} heartRate:${bodyBaseModel?.heartRate}`)
            }

            this.addLog(`测量结束`)
          }
        },

      })
      this.deviceControl?.registerHistoryChangeListener(() => {
        this.addLog("有新的历史数据产生")
        //此处可调用获取用户历史数据和获取游客历史数据，串行
      })

    }
  }

  aboutToDisappear(): void {
    this.disconnectServer()
  }

  build() {
    Column({ space: 5 }) {
      Row() {
        Text(this.pageTitle)
          .fontSize(20)
          .margin({ left: 2, right: 2 })
      }
      .width('100%')
      .height(50)
      .backgroundColor('#f0f0f0')

      Column() {
        // 上半部分 - 日志显示区域
        LogDisplay({ logContent: (this.logContent) })
          .height("40%");

        // 下半部分 - 控制区域
        Scroll() {
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
              .width(`calc(25% - 4vp)`)
              .margin(2)

              CustomButton({
                buttonText: '启动测量',
                onButtonClick: () => {
                  this.addLog('启动测量')
                  /**
                   * 启动测量结果回调
                   * 0x00：成功
                   * 0x01：设备配网中，开始测量失败
                   * 0x02：设备OTA中，开始测量失败
                   *
                   * @param state
                   */
                  this.deviceControl?.startMeasure((state: number | null) => {

                    switch (state) {
                      case 0x00:
                        this.addLog('启动测量成功')
                        break;
                      case 0x01:
                        this.addLog('启动测量失败，设备配网中')
                        break;
                      case 0x02:
                        this.addLog('启动测量失败，设备OTA中')
                        break;
                      default:
                        this.addLog('启动测量失败')
                        break;
                    }
                  })
                }
              })

              CustomButton({
                buttonText: '停止测量',
                onButtonClick: async () => {
                  this.addLog('停止测量')
                  let result = await this.deviceControl?.stopMeasure();
                  if (result) {
                    this.addLog('停止测量成功')
                  } else {
                    this.addLog('停止测量失败')
                  }
                }
              })

              CustomButton({
                buttonText: '同步时间',
                onButtonClick: async () => {
                  this.addLog('同步时间')

                  const bytes = new Uint8Array([0x68, 0x40, 0x35, 0xDD]);
                  const timestamp = ByteUtil.bytesToTimeStamp(bytes, false, false); // 大端序，无符号
                  this.addLog('' + timestamp)
                  let result = await this.deviceControl?.syncTime(Date.now(), TimeFormat.HOUR_24) ?? false;
                  if (result) {
                    this.addLog('同步时间成功')
                  } else {
                    this.addLog('同步时间失败')
                  }
                }
              })

            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")
            .margin({ left: 0 }) // 明确设置左侧边距为0

            Row() {
              CustomButton({
                buttonText: '同步日志',
                onButtonClick: async () => {
                  this.addLog('开始同步日志')
                  let logFolder: string = this.filesDir;

                  const syncLogReslut = await this.deviceControl?.syncLog(logFolder, (progress: number, logFilePath: string, isEnd: boolean) => {
                    if (isEnd) {
                      this.addLog(`日志同步完成 filePath:${logFilePath}}`)
                    } else {
                      this.addLog(`进度:${progress}`)
                    }
                  });
                  if (!syncLogReslut) {
                    this.addLog(`日志同步失败`)
                  }

                }
              })

              CustomButton({
                buttonText: '恢复出厂',
                onButtonClick: () => {
                  this.addLog('恢复出厂')
                  this.deviceControl?.resetDevice((isSuccess: boolean | null) => {
                    if (isSuccess) {
                      this.addLog('恢复出厂成功')
                    } else {
                      this.addLog('恢复出厂失败')
                    }
                  })
                }
              })

              CustomButton({
                buttonText: '7天数据',
                onButtonClick:async  () => {
                  this.addLog('7天数据')

                  if (this.deviceModel?.deviceProtocolType == PPDeviceProtocolType.PPDeviceProtocolTypeBorre_C) {
                    const result = await this.deviceControl?.syncBorreCLast7DaysDataUserInfo(this.userModel, this.last7List,PPUserBodyDataType.PPUserBodyDataTypeWeight)
                    if (result) {

                      this.addLog('同步7天数据成功')
                    } else {
                      this.addLog('同步7天数据失败')
                    }
                  }else{
                    const result = await this.deviceControl?.syncLast7DaysDataUserInfo(this.userModel, this.last7List)
                    if (result) {
                      this.addLog('同步7天数据成功')
                    } else {
                      this.addLog('同步7天数据失败')
                    }
                  }



                }
              })


              CustomButton({
                buttonText: '清除用户',
                onButtonClick: () => {
                  this.addLog('清除用户')
                  this.deviceControl?.clearDeviceUserInfo((isSuccess: boolean | null) => {
                    if (isSuccess) {
                      this.addLog('清除用户成功')
                    } else {
                      this.addLog('清除用户失败')
                    }
                  })
                }
              })

            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Row(){
              CustomButton({
                buttonText: '阻抗状态',
                onButtonClick: () => {
                  this.addLog('阻抗状态')
                  this.deviceControl?.getImpedanceState((isSuccess: boolean | null) => {
                    if (isSuccess) {
                      this.addLog('阻抗状态 开')
                    } else {
                      this.addLog('阻抗状态 关')
                    }
                  })
                }
              })

              CustomButton({
                buttonText: '阻抗 开',
                onButtonClick: () => {
                  this.addLog('阻抗')
                  this.deviceControl?.controlImpedance2(true,(isSuccess: boolean | null) => {
                    if (isSuccess) {
                      this.addLog('阻抗 开成功')
                    } else {
                      this.addLog('阻抗状态 开失败')
                    }
                  })
                }
              })

              CustomButton({
                buttonText: '阻抗 关',
                onButtonClick: () => {
                  this.addLog('阻抗')
                  this.deviceControl?.controlImpedance2(false,(isSuccess: boolean | null) => {
                    if (isSuccess) {
                      this.addLog('阻抗 关成功')
                    } else {
                      this.addLog('阻抗状态 关失败')
                    }
                  })
                }
              })


            }

            Row() {
              CustomButton({
                buttonText: '同步用户数据',
                onButtonClick: async () => {
                  this.addLog(`同步多个用户需要递归同步`)
                  this.addLog(`syncUserInfo userName:${this.userModel.userName}`)
                  const result = await this.deviceControl?.syncUserInfo(this.userModel);
                  if (result) {
                    this.addLog('同步用户数据成功')
                  } else {
                    this.addLog('同步用户数据失败')
                  }
                }
              })

              CustomButton({
                buttonText: '删除用户数据',
                onButtonClick: () => {
                  this.addLog('删除用户数据')
                  this.addLog('删除该UserId下的所有用户')
                  const result = this.deviceControl?.deleteUserInfo(this.userModel);
                  if (result) {
                    this.addLog('删除用户数据成功')
                  } else {
                    this.addLog('删除用户数据失败')
                  }
                }
              })

              CustomButton({
                buttonText: '确认当前用户',
                onButtonClick: () => {
                  this.addLog('确认当前用户')
                  const result = this.deviceControl?.sendCurrentUserInfo(this.userModel);
                  if (result) {
                    this.addLog('确认当前用户成功')
                  } else {
                    this.addLog('确认当前用户失败')
                  }
                }
              })

              CustomButton({
                buttonText: '获取用户列表',
                onButtonClick: () => {
                  this.addLog('获取用户列表')
                  this.deviceControl?.getUserList((userIds: string[]) => {
                    if (userIds == null) {
                      this.addLog('获取用户列表失败')
                    } else {
                      this.addLog(`获取用户列表成功，数量:${userIds.length}`)
                      for (let i = 0; i < userIds.length; i++) {
                        this.addLog(`用户ID:${userIds[i]}`)
                      }
                    }
                  })
                }
              })

            }
            .width("100%")
            .constraintSize({ maxWidth: '100%' })
            .margin(0) // 清除边距

            Row() {
              CustomButton({
                buttonText: '获取单位',
                onButtonClick: async () => {
                  this.addLog('获取单位')
                  let cmdResult = await this.deviceControl?.getUnit((unitType: PPUnitType | null) => {
                    if (unitType == null) {
                      this.addLog(`单位获取失败`)
                    } else {
                      this.addLog(`单位:${UnitUtil.getUnitStr(unitType)}`)
                    }
                  })
                }
              })

              CustomButton({
                buttonText: '同步颜色',
                onButtonClick: async () => {
                  this.addLog('同步颜色')
                  let cmdResult = await this.deviceControl ?.setRGBMode(1,0,"#00FF00","#FF0000","#0000FF",((state: number | null)=>{

                    this.addLog(`${state}`)

                  }))


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

              CustomButton({
                buttonText: '获取电量',
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



            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Row() {
              CustomButton({
                buttonText: '用户历史数据',
                onButtonClick: () => {
                  this.addLog('用户历史数据')

                  const historyResult = this.deviceControl?.syncUserHistory(this.userModel, {
                    // 监控历史数据
                    monitorHistoryData: (bodyBaseModel: PPBodyBaseModel | null) => {
                      if (bodyBaseModel != null) {
                        this.addLog(`用户历史数据:${bodyBaseModel.getPpWeightKg()}`)
                      }
                    },

                    // 监控历史结束
                    monitorHistoryEnd: () => {
                      this.addLog(`用户历史数据结束`)
                    },

                    // 监控历史失败
                    monitorHistoryFail: () => {

                    },

                  })
                  if (!historyResult) {
                    this.addLog(`用户历史数据失败`)
                  }
                }
              })

              CustomButton({
                buttonText: '游客历史数据',
                onButtonClick: () => {
                  this.addLog('游客历史数据')

                  const historyResult = this.deviceControl?.syncTouristHistory({
                    // 监控历史数据
                    monitorHistoryData: (bodyBaseModel: PPBodyBaseModel | null) => {
                      if (bodyBaseModel != null) {
                        this.addLog(`游客历史数据:${bodyBaseModel.getPpWeightKg()}`)
                      }
                    },

                    // 监控历史结束
                    monitorHistoryEnd: () => {
                      this.addLog(`游客历史数据结束`)
                    },

                    // 监控历史失败
                    monitorHistoryFail: () => {
                      this.addLog(`游客历史数据失败`)
                    },

                  })
                  if (!historyResult) {
                    this.addLog(`游客历史数据失败`)
                  }
                }
              })



              CustomButton({
                buttonText: '启动保活',
                onButtonClick: () => {
                  this.addLog('启动保活')
                  this.deviceControl?.keepAlive()
                }
              })

            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Row() {
              CustomButton({
                buttonText: '绑定设备',
                onButtonClick: () => {
                  this.addLog('绑定设备')
                  const result = this.deviceControl?.getDeviceBindStatus((isBind: boolean) => {
                    this.addLog(`当前设备绑定状态:${isBind}`);
                    this.deviceControl?.deviceBindStatus(!isBind, (isSuccess: boolean) => {
                      if (isSuccess) {
                        this.addLog(`修改设备绑定状态成功`)
                      } else {
                        this.addLog(`修改设备绑定状态失败`)
                      }
                      this.addLog(`修改后设备绑定状态:${!isBind}`);
                    });
                  });
                  if (!result) {
                    this.addLog(`设备绑定状态:失败`)
                  }
                }
              })


              CustomButton({
                buttonText: '设置显示数据',
                onButtonClick: () => {
                  this.addLog('绑定设备')
                  const result = this.deviceControl?.setDisplayMetrics(5)
                  if (!result) {
                    this.addLog(`设备绑定状态:失败`)
                  }
                }
              })

              CustomButton({
                buttonText: '获取显示数据',
                onButtonClick: () => {
                  this.addLog('绑定设备')
                  const result = this.deviceControl?.getDisplayMetrics((met) => {


                    this.addLog(met?.toString() ?? "")

                  });
                  if (!result) {
                    this.addLog(`设备绑定状态:失败`)
                  }
                }
              })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Row() {
              CustomButton({
                buttonText: '开始配网',
                onButtonClick: () => {
                  this.addLog('开始配网')
                  if (PPScaleHelper.isFuncTypeWifi(this.deviceModel?.deviceFuncType)) {
                    WifiHelper.getInstance().deviceControl = this.deviceControl
                    router.pushUrl({
                      url: "ppble/wifi/WifiListPager",
                      params: this.deviceModel
                    });
                  } else {
                    this.addLog('设备不支持配网')
                  }
                }
              })

              CustomButton({
                buttonText: '获取SSID',
                onButtonClick: () => {
                  this.addLog('获取SSID')
                  const result = this.deviceControl?.getWifiSSID((ssid: string | null) => {
                    if (ssid != null) {
                      this.addLog(`获取SSID:${ssid}`)
                    } else {
                      this.addLog(`获取SSID失败`)
                    }
                  })
                  if (!result) {
                    this.addLog(`获取SSID失败`)
                  }
                }
              })

              CustomButton({
                buttonText: '获取WifiMac',
                onButtonClick: () => {
                  this.addLog('获取WifiMac')
                  const result = this.deviceControl?.getWifiMac((mac: string | null) => {
                    if (mac != null) {
                      this.addLog(`获取WifiMac:${mac}`)
                    } else {
                      this.addLog(`获取WifiMac失败`)
                    }
                  })
                  if (!result) {
                    this.addLog(`获取WifiMac失败`)
                  }
                }
              })

              CustomButton({
                buttonText: '修改域名',
                onButtonClick: () => {
                  this.addLog('修改域名后需重新配网生效，该方法只是本地缓存修改，配网时才出发指令')
                  this.addLog("当前域名：" + WifiHelper.wifiDomainName)
                  if (this.dialogController == null) {
                    // 调用时传递回调
                    this.dialogController = new CustomDialogController({
                      builder: InputDialog({
                        inputText: WifiHelper.wifiDomainName,
                        onConfirm: (text) => {
                          WifiHelper.wifiDomainName = text;
                          this.addLog(`修改域名:${text}`)
                        }
                      }),
                      autoCancel: true,
                      cancel: () => {
                        this.addLog(`取消修改域名`)
                      }
                    });
                  }

                }
              })

            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")


            Row() {
              CustomButton({
                buttonText: '测试OTA',
                onButtonClick: () => {
                  this.addLog('测试OTA')
                  if (PPScaleHelper.isFuncTypeWifi(this.deviceModel?.deviceFuncType)) {
                    this.addLog("startLocalOTA 本地必须有2.4G模式的Wifi,且名称:Test,密码:12345678,秤会自动连接该Wifi")
                    const result = this.deviceControl?.startLocalOTA({
                      onUpdateFail: (errorCode: number) => {
                        this.addLog(`用户OTA更新失败:${errorCode}`)
                      },
                      onUpdateSuccess: () => {
                        this.addLog(`用户OTA更新成功`)
                      },

                    })
                    if (result) {
                      this.addLog(`测试OTA启动成功`)
                    } else {
                      this.addLog(`测试OTA启动失败`)
                    }
                  } else {
                    this.addLog('设备不支持Wifi OTA')
                  }
                }
              })
              CustomButton({
                buttonText: '用户OTA',
                onButtonClick: () => {
                  this.addLog('用户OTA')
                  if (PPScaleHelper.isFuncTypeWifi(this.deviceModel?.deviceFuncType)) {
                    const result = this.deviceControl?.startUserOTA({
                      onUpdateFail: (errorCode: number) => {
                        this.addLog(`用户OTA更新失败:${errorCode}`)
                      },
                      onUpdateSuccess: () => {
                        this.addLog(`用户OTA更新成功`)
                      },

                    })
                    if (!result) {
                      this.addLog(`用户OTA启动失败`)
                    }
                  } else {
                    this.addLog('设备不支持Wifi OTA')
                  }
                }
              })

              CustomButton({
                buttonText: '选择DFU文件',
                onButtonClick: () => {
                  this.addLog('选择DFU文件')
                  if (!PPScaleHelper.isFuncTypeWifi(this.deviceModel?.deviceFuncType)) {

                  } else {
                    this.addLog('设备不支持DFU')
                  }
                }
              })

              CustomButton({
                buttonText: '启动DFU',
                onButtonClick: () => {
                  this.addLog('启动DFU')
                  if (!PPScaleHelper.isFuncTypeWifi(this.deviceModel?.deviceFuncType)) {
                    const result = this.deviceControl?.startUserOTA({
                      onUpdateFail: (errorCode: number) => {
                        this.addLog(`用户OTA更新失败:${errorCode}`)
                      },
                      onUpdateSuccess: () => {
                        this.addLog(`用户OTA更新成功`)
                      },

                    })
                    if (result) {
                      this.addLog(`用户OTA启动成功`)
                    } else {
                      this.addLog(`用户OTA启动失败`)
                    }
                  } else {
                    this.addLog('设备不支持DFU')
                  }
                }
              })
            }
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .width("100%")

            Row() {
              Text("孕妇模式")
                .fontSize(12)
              Button(this.pregnancyModeBtnState ? "ON" : "OFF")
                .width(50)
                .height(25)
                .margin({ left: 3 })
                .fontSize(12)
                .padding(0)
                .stateEffect(true)
                .backgroundColor(this.pregnancyModeBtnState ? '#007DFF' : '#EEE')
                .onClick(() => {
                  this.pregnancyModeBtnState = !this.pregnancyModeBtnState
                })

              Text("工厂模式")
                .fontSize(12)
                .margin({ left: 30 })
              Button(this.factoryPatternBtnState ? "ON" : "OFF")
                .width(50)
                .height(25)
                .margin({ left: 3 })
                .fontSize(12)
                .padding(0)
                .stateEffect(true)
                .backgroundColor(this.factoryPatternBtnState ? '#007DFF' : '#EEE')
                .onClick(() => {
                  this.factoryPatternBtnState = !this.factoryPatternBtnState
                })
            }
            .margin({ top: 10, left: 5 })

          }
          // .flexGrow(1)
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Start)
          .height('100%')
          .width('100%')
        }
        .margin({ top: 10, bottom: 350 })
        .flexGrow(1)
        .cardStyle()
        .scrollBar(BarState.Auto) // 自动显示滚动条
        .edgeEffect(EdgeEffect.Spring) // 弹性边缘效果
      }
      .flexGrow(1)
    }
    .height(`calc(100% - 10vp)`)
    .width('100%')
    .padding(10)
    .backgroundColor('#f1f3f5')

  }

  @Builder
  buildWrappingButton(text: string) {
    Button() {
      Text(text)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .flexGrow(1) // 均分宽度
    .height('auto')
    .constraintSize({
      minHeight: 40, // 设置最小高度为60vp
    })
    .margin(5)
  }

  // 卡片样式
  @Styles
  cardStyle() {
    .width('100%')
    .height('auto')
    .padding(5)
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
        hilog.info(0x0000, 'PPDeviceBorrePage bluetooth connect state changed', `connectState:${state}}`);
        if (this.connectState === constant.ProfileConnectionState.STATE_DISCONNECTED) {
          this.btValue = '连接'
          this.showToast('断开成功')
          this.addLog('PPDeviceBorrePage 设备断开')
        }

        if (this.connectState === constant.ProfileConnectionState.STATE_CONNECTED) {
          this.showToast('连接成功')
          this.btValue = '断开'
          this.addLog('PPDeviceBorrePage 连接成功')
        }

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

