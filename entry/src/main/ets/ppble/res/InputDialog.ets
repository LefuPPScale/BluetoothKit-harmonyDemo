// CustomDialog.ets
@CustomDialog
export struct InputDialog {
  @State inputText: string = ''; // 绑定输入框内容
  controller: CustomDialogController; // 弹窗控制器
  onConfirm?: (text: string) => void; // 新增回调函数

  build() {
    Column() {
      // 输入框
      TextInput({ placeholder: '请输入内容', text: this.inputText })
        .width('80%')
        .height(40)
        .margin({ top: 20 })
        .onChange((value: string) => {
          this.inputText = value;
        })

      // 居中按钮
      Button('确定', { type: ButtonType.Capsule })
        .width(120)
        .margin(20)
        .alignSelf(ItemAlign.Center)// 水平居中
        .onClick(() => {
          // 点击事件
          console.log(`输入内容: ${this.inputText}`);
          this.onConfirm?.(this.inputText); // 触发回调
          this.controller.close(); // 关闭弹窗
        })
    }
    .width('100%')
    .padding(20)
  }
}