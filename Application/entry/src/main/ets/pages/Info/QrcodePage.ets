import TitleComponent from '../../components/TitleComponent'
import agconnect from '@hw-agconnect/api-ohos'

@Entry
@Component
struct QrcodePage {
  @State uuid: string = ''
  async onPageShow() {
    // 根据用户的uid生成二维码，目前还不支持扫码，所以先模拟相关逻辑
    const user = await agconnect.auth().getCurrentUser()
    this.uuid = user.getUid()
  }

  build() {
    Column() {
      TitleComponent({title: '个人二维码', isBack:true })

      QRCode(this.uuid)
        .margin({top: 40})
    }
    .padding({left: 20, right:20})
    .backgroundColor($r('app.color.base_background'))
    .height('100%')
  }
}