
export class NavItem {
  /**
   * 选中的图片
   */
  selectImg: Resource
  /**
   * 默认图片
   */
  normalImg:Resource

  /**
   * 样式小调
   */
  x: number

  /**
   * 是否是二维码
   */
  qrCode: boolean

  isSelect: boolean = false

  constructor(selectImg: Resource, normalImg:Resource, x: number, qrCode = false) {
    this.selectImg = selectImg
    this.normalImg = normalImg
    this.x = x
    this.qrCode = qrCode
  }
}

export interface User {
  uuid: string,
  name: string,
  email: string
  phone: string
  avatar:string
}

export interface Card {
  amount:number
  bank: string
  cardNumber:string
  ccv:string
  expiredAt: string
  name: string
  uuid:string
}

export interface PayRecordTotal {
  income: number
  outcome: number
  records: []
}

export interface PayRecord {
  amount: number
  target:string
  email:string
  crateAt:string
}