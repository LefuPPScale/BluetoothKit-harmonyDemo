// LogDisplay.ets
@Component
export struct LogDisplay {
  @Prop logContent: string = ''; // 可以保留空字符串作为初始值

  // 私有方法：处理日志内容
  private getDisplayContent(): string {
    const lines = this.logContent.split('\n');
    // 超过500行时保留最新500行
    if (lines.length > 500) {
      return lines.slice(-500).join('\n');
    }
    return this.logContent;
  }

  build() {
    Scroll() {
      Column() {
        // 从左上角开始对齐
        Text(this.getDisplayContent())
          .fontSize(10)
          .fontColor('#333333')
          .textAlign(TextAlign.Start)// 左对齐
          .width('100%')// 占据全部宽度
          .padding(10) // 添加内边距
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start) // 列内容左对齐
    }
    .scrollBar(BarState.On) // 显示滚动条
    .scrollBarColor(Color.Gray) // 滚动条颜色
    .scrollBarWidth(6) // 滚动条宽度
    .edgeEffect(EdgeEffect.Spring) // 滚动边界效果
    .height('100%')
    .cardStyle()
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