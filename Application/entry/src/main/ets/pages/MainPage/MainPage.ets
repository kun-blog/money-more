import { NavBar } from './Component/NavBar'
// import { NavBarImage } from './Component/NavBarImage'
import { Home } from '../view/Home'
import { DataStatistics } from '../view/DataStatistics'
import { My } from '../view/My'
import { Wallet } from '../view/Wallet'
import { Card, PayRecord, PayRecordTotal, User } from './type'
import agconnect from '@hw-agconnect/api-ohos'
import { queryBackCard, queryPayRecords, queryPayRecordsTotal, queryUser } from '../../services'
import { formatTimestamp } from '../../utils'


@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0

  @State user: Partial<User> = {  // 构造类型User，并将它所有的属性设置为可选的。它的返回类型表示输入类型的所有子类型。
    uuid:""
  }

  @State cards:Card[] = []

  @State payRecordTotal:PayRecordTotal = {
    income: 0,
    outcome: 0,
    records: []
  }

  @State payRecords:PayRecord[] = []

  async  onPageShow(){
    await this.userInfo()
    await Promise.all([
    this.getCards(),
    this.getPayRecordsTotal(),
    this.getPayRecords()
    ])
  }

  async getCards () {
    const data = await queryBackCard({uuid:this.user.uuid})
    this.cards = data.data
  }

  async userInfo(){
    // 华为认证的用户信息
    const user = await agconnect.auth().getCurrentUser()

    const res = await queryUser({uuid: user.getUid()})
    this.user = res.data
    this.user.uuid = user.getUid()

  }
  // 获取总的出入账
  async getPayRecordsTotal () {
    const res =  await queryPayRecordsTotal({uuid: this.user.uuid})
    this.payRecordTotal = {
      ...res.data,
      records: this.convertPayRecords(res.data.incomeRecords)
    }
  }

  convertPayRecords (data) {
    // 将createAt转换为MM/DD的形式
    const formattedData = data.map(item => {
      const date = new Date(parseInt(item.createAt))
      const month = date.getMonth() + 1 < 10 ? '0' + (date.getMonth() + 1) :date.getMonth() + 1
      const day = date.getDate() < 10 ? '0' + date.getDate() : date.getDate()

      item.createAt = month + '/' + day
      return item
    })
  }

  // 获取支付记录
  async getPayRecords () {
    const res = await queryPayRecords({uuid: this.user.uuid})
    this.payRecords = res.data.map(item => {
      // 预处理 方便子组件直接渲染

      // 如果当前用户是付款人，责任师被付款人 反之亦然
      return {
        target: item.payer === this.user.uuid ? item.payeeInfo.name : item.payerInfo.name,
        email: item.payer === this.user.uuid ? item.payeeInfo.email : item.payerInfo.email,
        amount: item.payer === this.user.uuid ? `-￥${item.amount}` : `+${item.amount}`,
        createAt: formatTimestamp(item.createAt),
        avatar: item.payer === this.user.uuid ? item.payeeInfo.avatar : item.payerInfo.avatar
      }
    })

    console.log(JSON.stringify(this.payRecords), '-- page log --')
  }

  build() {
    Column() {
      // 展示内容
      Scroll() {
        if (this.currentIndex === 0) {
          // 首页
          Home({cards: $cards, records: $payRecords})
        }
        if (this.currentIndex === 1) {
          // 数据分析页
          DataStatistics({
            payRecordTotal: $payRecordTotal
          })
        }
        if (this.currentIndex === 2) {

        }
        if (this.currentIndex === 3) {
          // 钱包
          Wallet({cards: $cards,  records:$payRecords})
        }
        if (this.currentIndex === 4) {
          // 我的
          My({ user: $user})
        }

      }
      .padding({ bottom: 100 })

      // 导航栏
      NavBar({
        currentIndex: $currentIndex
      })
        .offset({ y: -50 })
    }
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.base_background'))
  }
}