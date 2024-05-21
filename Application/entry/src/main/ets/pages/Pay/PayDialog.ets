import Input from '../../components/Input'
import { queryBackCard, queryUser } from '../../services'
import agconnect from '@hw-agconnect/api-ohos'
import { Card } from '../MainPage/type'

// @Preview
@CustomDialog
export default struct PayDialog {
  controller: CustomDialogController
  // 收款方
  @Link payee: string
  @State cards: Card[] = []
  @State amount: number = 10

  @State payeeInfo: {
    name: string
    email: string
  } = { name: '', email: '' }


  getCardOptions() {
    return this.cards.map((item) => {
      return { value: `${item.bank}(${item.cardNumber})` }
    })
  }

  onConfirm  = (amount) => {}

  /**
   * 组件展示时触发
   *
   * 如 张三 给 李四付钱
   */
  async aboutToAppear() {
    // 获取被支付方的信息
    const res = await queryUser({
      uuid: this.payee
    })
    this.payeeInfo = res.data
    this.queryUserCards()
  }

  /**
   * 获取当前用户的银行卡信息
   */
  async queryUserCards() {
    const user = await agconnect.auth().getCurrentUser()
    const res = await queryBackCard({
      uuid: user.getUid()
    })

    // 银行卡扔进去
    this.cards = res.data
  }


  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Text('付款给')
        .fontSize(20)
        .fontWeight(500)
        .padding({ top: 20, bottom: 20 })
        .textAlign(TextAlign.Center)
        .width('100%')
        .border({ width: { bottom: 1 }, color: '#ddd' })

      Column({ space: 10 }) {
        Text(this.payeeInfo.name ||'收款方')
          .fontSize(20)
          .fontWeight(500)

        Text(this.payeeInfo.email || '120@qq.com')
          .fontSize(14)
          .fontWeight(400)
          .fontColor('#ddd')
      }
      .width(200)
      .height(100)
      .padding(20)
      .shadow({
        radius: 40,
        color: '#ddd'
      })
      .margin({ top: 20 })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start }) {
        Text('支付账户')
          .fontSize(20)
          .fontWeight(500)
          .textAlign(TextAlign.Start)

        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Image($r('app.media.card_cover'))
            .width(30)
            .height(20)
          if (this.getCardOptions().length) {
            Select(this.getCardOptions())
              .selected(1)
              .value(this.getCardOptions()[0]?.value)
              .font({ size: 16, weight: 500 })
              .selectedOptionFont({ size: 16, weight: 400 })
              .optionFont({ size: 16, weight: 400 })
          }
        }
        .width('100%')
        .margin({ top: 20, bottom: 20 })
        .shadow({ radius: 40, color: '#ddd' })
        .padding(20)


        Text('支付金额')
          .textAlign(TextAlign.Start)
          .fontSize(20)
          .fontWeight(500)

        Text(`￥${this.amount}`)
          .fontSize(20)
          .width('100%')
          .textAlign(TextAlign.Center)

        Column({ space: 20 }) {
          // Input({
          //   title: "用户订单姓名"
          // })
          //
          // Input({
          //   title: "用户订单电话"
          // })
        }.margin({ top: 20 })

        Flex({ justifyContent: FlexAlign.Center }) {
          Button('确定支付')
            .backgroundColor('#7AE4ED')
            .margin({ top: 20 })
        }
        .onClick(() => {
          this.onConfirm(this.amount)
        })

      }
      .margin({ top: 20 })
      .padding({ left: 20, right: 20 })
      .width('100%')

    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .margin({ top: 80 })
    .borderRadius({ topLeft: 20, topRight: 20 })

  }
}