@Component
export struct CustomButton {
  @Prop buttonText: string = '' // 按钮文字（默认值避免未初始化错误）
  onButtonClick: () => void = () => {
  } // 点击回调（默认空函数）

  build() {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Text(this.buttonText)
        .fontSize(12)
        .maxLines(2)// 允许最多2行
        .textAlign(TextAlign.Center)// 文字居中
        .margin({ left: 5, right: 5 })
        .fontColor(Color.White)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .height('auto')
    .width(`calc(25% - 4vp)`)
    .margin(2)
    .borderRadius(8)
    .constraintSize({
      minHeight: 40, // 设置最小高度为60vp
    })
    .onClick(() => {
      this.onButtonClick()
    })
  }
}