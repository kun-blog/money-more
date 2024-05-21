import { NavItem } from '../type'
import { NavBarImage } from './NavBarImage'

@Component
export struct NavBar {
  @Link currentIndex: number

  nav: NavItem[] = [
    new NavItem($r('app.media.home_icon_select'), $r('app.media.home_icon_unselect'), 0),
    new NavItem($r('app.media.data_icon_select'), $r('app.media.data_icon_unselect'), -15),
    new NavItem($r('app.media.qrcode_icon'), $r('app.media.qrcode_icon'), 0, true),
    new NavItem($r('app.media.wallet_icon_select'), $r('app.media.wallet_icon_unselect'), 15),
    new NavItem($r('app.media.my_icon_select'), $r('app.media.my_icon_unselect'), 0),
  ]

  build() {
    Flex() {
      ForEach(this.nav, (item:NavItem, index: number) => {
        NavBarImage({navBarItem:item, isSelect: this.currentIndex === index })
          .offset({ x: item.x, y: item.qrCode ? -30 : 0 })
          .onClick(()=> {
          this.currentIndex = index
          })
      })
    }
    .height(50)
    .width('100%')
    .backgroundImage($r('app.media.Subtract'))
    .backgroundImageSize(ImageSize.Cover)
  }
}