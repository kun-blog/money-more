import router from '@ohos.router'
import TitleComponent from '../../components/TitleComponent'
import { BankCard } from '../../components/BankCard'
import Input from '../../components/Input'
import agconnect from '@hw-agconnect/api-ohos'
import { addBackCard } from '../../services'
import Notification from '@system.notification'

@Entry
@Component
struct Add {
  payload = {
    uuid: '123456789',
    bank: '招商银行',
    name: '小猪佩奇',
    cardNumber: '987654321',
    expiredAt: '2024',
    ccv: 'www'
  }

  /**
   * 添加银行卡的动作
   */
  async doAddBankCard() {
    try {
      // 要知道当前登录的人是谁
      const user = await agconnect.auth().getCurrentUser()
      if (!user) {
        router.replaceUrl({ url: 'pages/Login' })
        return
      }
      // 添加当前用户uuid
      this.payload.uuid = user.getUid()

      // 给登录的这个人添加银行卡

      // 拿到添加银行卡相关信息

      // 调用添加银行卡功能
      try {
        const res = await addBackCard(this.payload)
        if (res.status) {
          // 提示成功
          Notification.show({
            contentTitle: '添加成功'
          })
          // 返回上一页
          setTimeout(() => {
            router.back()
          }, 500)
        } else {
          // 提示失败
          Notification.show({
            contentTitle: '添加成功' + res.errMsg
          })
        }
      } catch (err) {
        console.log(err)
      }
    } catch (err) {
      console.error(err, '错误')
    }
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
      TitleComponent({ title: '添加银行卡', isBack: true })
      Flex({ justifyContent: FlexAlign.Start, direction: FlexDirection.Column }) {
        Text('卡片信息')
          .fontColor('#001749')
          .fontSize(21)
          .fontWeight(500)
        Column({ space: 20 }) {
          Input({
            title: '所属银行',
            placeholder: '请输入所属银行',
            change: (val: string) => {
              this.payload.bank = val
            }
          })
          Input({
            title: '银行卡号',
            placeholder: '请输入银行卡号',
            change: (val: string) => {
              this.payload.cardNumber = val
            }
          })
          Input({
            title: '持卡人姓名',
            placeholder: '请输入持卡人姓名',
            change: (val: string) => {
              this.payload.name = val
            }

          })
        }
        .margin({ top: 20 })

        Flex() {
          Input({
            title: "CCV",
            placeholder: '2544',
            change: (val: string) => {
              this.payload.ccv = val
            }

          })
          Input({
            title: "到期时间",
            placeholder: 'x年x月x日',
            change: (val: string) => {
              this.payload.expiredAt = val
            }
          })
        }
        .margin({ top: 20 })

        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          Text('添加银行卡')
            .fontColor(Color.White)
            .fontWeight(500)
            .fontSize(17)
            .width(228)
            .height(50)
            .backgroundColor('#38BFDA')
            .borderRadius(50)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.doAddBankCard()
            })
        }
        .margin({ top: 40 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.base_background'))
    .padding({ left: 20, right: 20 })
  }
}