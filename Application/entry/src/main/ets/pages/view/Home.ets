import TitleComponent from '../../components/TitleComponent'
import { BankCard } from '../../components/BankCard'
import { Card, PayRecord } from '../MainPage/type'
import router from '@ohos.router'
import { queryPayRecords } from '../../services'
import agconnect from '@hw-agconnect/api-ohos'


@Component
export struct Home {
  // arr = [1, 2, 3]
  page = 1
  pageSize = 10
  @Link cards: Card[]
  @Link records: PayRecord[]

  async nextPage() {
    this.page++

    const user = await agconnect.auth().getCurrentUser()
    const res = await queryPayRecords({
      uuid: user.getUid(),
      page: this.page,
      pageSize: this.pageSize
    })
    if (res.status) {
      this.records.push(...res.data)
    } else {
      AlertDialog.show({
        message: "已经分到最后一页"
      })
    }

  }

  build() {
    Column() {
      TitleComponent({ title: '首页' })
      Column() {
        Text('您好')
          .fontSize(18)
          .fontColor('#011749')
          .fontWeight(500)
          .textAlign(TextAlign.Start)
          .width('100%')
        Text('欢迎回来！')
          .fontSize(24)
          .fontColor('#011749')
          .fontWeight(500)
          .textAlign(TextAlign.Start)
          .width('100%')
      }

      Swiper() {
        if (this.cards && this.cards.length) {
          ForEach(this.cards, (item) => {
            BankCard({
              bank: item.bank,
              cardNumber: item.cardNumber,
              expiredAt: item.expiredAt,
              amount: item.amount,
              empty: false
            })
          })
        } else {
          BankCard()
        }


      }
      .loop(true)
      .indicatorStyle({
        size: 30,
        color: '#D7E1E8',
        selectedColor: '#D7E1E8',
      })
      .margin({ top: 30 })

      Flex({ justifyContent: FlexAlign.Start, direction: FlexDirection.Column }) {
        Text('功能分类')
          .fontColor('#001749')
          .fontSize(21)
          .fontWeight(500)
        Flex() {
          Column() {
            Image($r('app.media.zh_icon'))
              .width(60)
              .height(60)

            Text('转账')
              .fontSize(12)
              .fontColor('#011749')
              .margin({ top: 10 })
          }
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Pay/PayMain',
              params: { // 路由传参
                // 收款人id，由于目前鸿蒙支持不到暂时进行模拟
                payeeId: '1406811049423826624'
              }
            })
          })
        }
        .margin({ top: 10 })
      }
      .margin({ top: 30 })

      Flex({ justifyContent: FlexAlign.Start, direction: FlexDirection.Column }) {
        Text('交易信息')
          .fontColor('#001749')
          .fontSize(21)
          .fontWeight(500)
        List() {
          ForEach(this.records, (item) => {
            ListItem() {
              Flex(){
                Flex(){
                  Image( $r('app.media.avatar_icon'))
                    .width(45)
                    .height(45)
                  Flex({direction:FlexDirection.Column}) {
                    Text(`${item.target}(${item.email})`)
                      .fontColor('#001749')
                      .fontSize(12)
                    Text(`${item.createAt}`)
                      .fontColor('#ddd')
                      .fontSize(12)
                      .margin({top:20})
                  }
                }
                Text(`${item.amount}`)
                  .width(120)
                  .padding(10)
                  .backgroundColor('#f5ecf0')
                  .fontSize(14)
                  .fontColor('#ff4377')
                  .textAlign(TextAlign.Center)
                  .borderRadius(20)
              }
              .border({width:{bottom:1}, color:`rgba(99, 95,95,0.05)`})
              .padding({top:12, bottom: 12, left:8, right: 8})
              .margin({top:20})
              .backgroundColor('#fff')
            }
          })
        }
        .onReachEnd(()=> {
          // 列表尾部回调
          this.nextPage()
        })

      }
      .margin({ top: 30 })
    }
    // .height('100%')
    .padding({ left: 20, right: 20 })
  }
}