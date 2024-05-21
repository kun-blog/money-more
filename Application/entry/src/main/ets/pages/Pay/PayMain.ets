import agconnect from '@hw-agconnect/api-ohos'
import router from '@ohos.router'
import TitleComponent from '../../components/TitleComponent'
import PayDialog from './PayDialog'
import { doPay } from '../../services'

@Entry
@Component
struct PayMain {

  @State payeeId:string = ''

  dialogController: CustomDialogController = new CustomDialogController({

    builder: PayDialog({
      payee: $payeeId,
      onConfirm: (amount) => {
        this.pay(amount)
      }
    }),
    alignment:DialogAlignment.Bottom,
    customStyle:true
  })

  onPageShow() {
    // 页面显示打开支付弹框
    this.dialogController.open()

    // 拿到传入的参数
    const params = router.getParams()
    this.payeeId = params['payeeId']
  }

  async pay (amount) {
    // 调用支付接口
    const user = await agconnect.auth().getCurrentUser()
    await doPay({
      payer:user.getUid(),
      payee: this.payeeId,
      // 暂时把数据写死
      amount,
    })

    setTimeout(() => {
      router.back()
    }, 100)
  }
  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
      TitleComponent({ title: "支付" })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.base_background'))
  }
}