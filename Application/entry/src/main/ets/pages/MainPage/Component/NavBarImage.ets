import { NavItem } from '../type'

@Component
export struct NavBarImage {
  navBarItem: NavItem
  @Prop isSelect: boolean

  build() {
    Column() {
      Image(this.isSelect ? this.navBarItem.selectImg : this.navBarItem.normalImg)
        .size({width: this.navBarItem.qrCode ? 54 : 25, height: this.navBarItem.qrCode ? 54 : 25})
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}