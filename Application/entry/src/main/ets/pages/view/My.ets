import router from '@ohos.router'
import TitleComponent from '../../components/TitleComponent'
import agconnect from '@hw-agconnect/api-ohos'
import { User } from '../MainPage/type'

@Component
export struct My {
  @Link user: Partial<User>

  async logout () {
   // 华为认证退出
   await agconnect.auth().signOut()
    // 回到登录页面
    router.pushUrl({url:'pages/Login'})
  }


  build() {
    Column() {
      TitleComponent({
        title:"个人资料"
      })
      Column() {
        Column() {
          Image(this.user.avatar || $r('app.media.avatar_icon'))
            .width(100)
            .height(100)
            .position({y: -50,  x: 77})
          Text(this.user.name || '小王子')
            .fontSize(19)
            .margin({top:65})
          Text(this.user.email || '@qq.com')
            .fontSize(13)
            .fontColor('#002884')
        }
        .margin({top:80})
        .width(254)
        .height(130)
        .borderRadius(20)
        .backgroundColor(Color.White)
        Flex({alignItems:ItemAlign.Center, justifyContent:FlexAlign.SpaceBetween}) {
          Image($r('app.media.edit_icon'))
            .width(24)
            .height(24)
          Text('编辑个人信息')
            .fontColor('#002884')
          Image($r('app.media.right_icon'))
            .width(24)
            .height(24)

        }
        .onClick(() =>{
          router.pushUrl({url:'pages/Info/Main'})
        })
        .backgroundColor(Color.White)
        .padding(10)
        .borderRadius(10)
        .margin({top:32})

        Flex({alignItems:ItemAlign.Center, justifyContent:FlexAlign.SpaceBetween}) {
          Image($r('app.media.qrcode_icon_external'))
            .width(24)
            .height(24)
          Text('个人二维码')
            .fontColor('#002884')
          Image($r('app.media.right_icon'))
            .width(24)
            .height(24)
        }
        .backgroundColor(Color.White)
        .padding(10)
        .borderRadius(10)
        .margin({top:32})
        .onClick(() =>{
          router.pushUrl({url:'pages/Info/QrcodePage'})
        })
      }

      Button('退出登录')
        .margin({top:120})
        .width(120)
        .backgroundColor('#7AE4ED')
        .onClick(() =>{
          this.logout()
        })
    }
    .padding({left:20, right: 20})
    .height('100%')
  }
}