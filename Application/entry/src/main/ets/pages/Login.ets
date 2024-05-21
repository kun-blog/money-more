// src/main/ets/pages/Login.ets
import router from '@ohos.router'

import TitleComponent from '../components//TitleComponent'
import Input from '../components/Input'

import {
  EmailAuthProvider,
  VerifyCodeAction,
  VerifyCodeSettingBuilder,
  PhoneUserBuilder,
  PhoneAuthProvider,
  AGConnectAuth,
  AGConnectAuthCredentialProvider,
  EmailUserBuilder
} from "@hw-agconnect/auth-ohos"

import agconnect from '@hw-agconnect/api-ohos'
import { addUser } from '../services'

@Entry
@Component
struct Login {
  @State isRegister: boolean = false
  @State countDown: number = 60
  @State email: string = '1601042654@qq.com'
  @State password: string = 'xu123456'
  @State verifyCode: string = ''
  timer: number
  /**
   * 发送验证码
   */
  async sendCode() {
    this.startCountDown()
    // 发送邮箱验证码
    const verifyCodeSettings = new VerifyCodeSettingBuilder()
      .setAction(VerifyCodeAction.REGISTER_LOGIN) // 类型
      .setLang('zh_CN')
      .setSendInterval(60) // 有效日期
      .build();
    /**
     * 接收两个参数
     * 第一个参数发送右键的url地址
     * 当前的配置
     */
    agconnect.auth().requestEmailVerifyCode(this.email, verifyCodeSettings) // 发送动作
      .then(async verifyCodeResult => {
        // 发送验证码成功

      }).catch(error => {
      //验证码申请失败
      console.log(JSON.stringify(error), '错误了？')
    });
  }

  /**
   * 开始倒计时
   */
  startCountDown() {
    this.timer = setInterval(() => {
      this.countDown -= 1
      if (this.countDown === 0) {
        this.countDown = 60
        clearInterval(this.timer)
      }
    }, 1000)
  }

  register() {
    /**
     * 通过code + 密码 + 邮箱完成注册
     */
    const emailUser = new EmailUserBuilder()
      .setEmail(this.email)
      .setPassword(this.password)
      .setVerifyCode(this.verifyCode)
      .build()

    // 创建用户华为认证层面
    agconnect.auth().createEmailUser(emailUser)
      .then(async (result)=> {
        // 注册成功
        // 创建一个新用户到云端

        // 云端文档 https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/agc-harmonyos-clouddev-createproject-0000001439596128-V3

        const user = await agconnect.auth().getCurrentUser()

        const data =  await addUser({
          uuid:user.getUid(),
          email:this.email
        })

        router.replaceUrl({url: 'pages/MainPage/MainPage'})
      })
      .catch(async err => {
        // 注册失败
        console.log(JSON.stringify(err), '错误')
      })

  }

  /**
   * 登录
   */
  async doLogin() {
    // 使用APPGallery connect 进行用户身份登录

    // 多使用try catch app开发程序崩溃直接闪退，使用try catch及时发现原因
    try {
      // 使用邮箱密码登录
      const credential = EmailAuthProvider.credentialWithPassword(this.email, this.password)
      // 执行登录
      const user = await agconnect.auth().signIn(credential)
      // 如果用户已经登录那么可以你直接进入app
      if (user) {
        this.goMain()
      }
    }catch(err){
      console.error(err, '登录失败')
    }

  }

  goMain () {
    try {
      router.replaceUrl({url: 'pages/MainPage/MainPage'})
    } catch (err) {
      console.log(err, '错误')
    }
  }
  /**
   * 判断当前用户是否登录
   * @returns
   */

  async checkIfLogin () {
    const user = await agconnect.auth().getCurrentUser()
    return user !== null
  }

  async onPageShow() {
    try {
      const ifLogin = await this.checkIfLogin()
      if (ifLogin) {
        // 已经登录
        this.goMain()
      }
    } catch (err) {
      console.log(err, '未登录')
    }
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
      // 标题
      TitleComponent({ title: '登录' })
      // 表单内容
      Column() {
        // 钱币Logo浮在上面层叠布局
        Stack() {
          Image($r('app.media.Login_icon'))
            .width(88)
            .height(88)
            .offset({ y: -44 }) // 向上偏移
        }

        Input({
          title: "电子邮箱",
          icon: $r('app.media.mail_icon'),
          placeholder: "请输入您的邮箱",
          defaultValue: this.email,
          change: (val) => {
            this.email = val
          }
        })
        Input({
          title: "密码",
          icon: $r('app.media.pwd_icon'),
          placeholder: "请输入您的密码",
          inputType: InputType.Password,
          defaultValue: this.password,
          change: (val) => {
            this.password = val
          }
        })
          .margin({ top: 20 })
        if (this.isRegister) {
          Column() {
            Text('验证码')
              .width('100%')
              .textAlign(TextAlign.Start)
              .fontSize(16)
              .fontWeight(500)
              .fontColor($r('app.color.font_color'))
              .margin({ bottom: 14 })

            Flex({ alignItems: ItemAlign.Center }) {
              TextInput()
                .height(50)
                .margin({ right: 10 })
                .backgroundColor('#ffedf0f6')
                .onChange((val) =>{
                  this.verifyCode = val
                })
              Button(this.countDown == 60 ? '发送验证码' : `${this.countDown}s`)
                .onClick(() => {
                  if (this.countDown === 60) {
                    // 倒计时过程中不能再次点击
                    this.sendCode()
                  }
                })
            }
          }
          .margin({ top: 20 })
        }
        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          Text(this.isRegister ? '注册' : '登录')
            .fontColor(Color.White)
            .fontWeight(500)
            .fontSize(17)
        }
        .width(228)
        .height(50)
        .backgroundColor('#38BFDA')
        .borderRadius(50)
        .margin({ top: 100 })
        .onClick(() => {
          this.isRegister ? this.register() : this.doLogin()
        })

        Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          Text(this.isRegister ? '去登录' : '去注册')
            .fontWeight(500)
            .fontSize(17)
        }
        .width(228)
        .height(50)
        .backgroundColor('#fff9fafd')
        .borderRadius(50)
        .margin({ top: 20 })
        .onClick(() => {
          this.isRegister = !this.isRegister
        })
      }
      .width('90%')
      .height('100%')
      .borderRadius(20)
      .backgroundColor(Color.White)
      .margin({ top: 44 })
      .padding({ left: 14, right: 14 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.base_background'))
  }
}