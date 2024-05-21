import router from '@ohos.router'
import TitleComponent from '../../components/TitleComponent'
import Input from '../../components/Input'
import agconnect from '@hw-agconnect/api-ohos'
import { User } from '../MainPage/type'
import { queryUser, patchUser } from '../../services'
import Notification from '@system.notification'
import picker from '@ohos.file.picker'
import fs from '@ohos.file.fs'
import util from '@ohos.util'

@Entry
@Component
struct Main {
  @State message: string = 'Hello World'

  @State user:Partial<User> = {}

  @State avatar:string = ''

  onPageShow() {
    this.userInfo()
  }

  async userInfo () {
    // 华为认证的用户信息
    const user = await agconnect.auth().getCurrentUser()
    const res = await queryUser({uuid: user.getUid()})
    this.user = res.data
    this.user.uuid = user.getUid()

  }

  async save () {
    // 将文件读到buffer里
    // w文档：https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-file-fs-0000001451843016-V2#ZH-CN_TOPIC_0000001574088233__fsreadsync
    const file = fs.openSync(this.avatar, fs.OpenMode.READ_ONLY)
    const info = fs.statSync(file.fd)
    const buffer = new ArrayBuffer(info.size)
    fs.readSync(file.fd, buffer)

    // 参考文档 https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V2/js-apis-util-0000001428062016-V2#ZH-CN_TOPIC_0000001574128865__encodetostringsync9
    // 将buffer转成base64
    const base64 = new util.Base64Helper()
    const str = base64.encodeToStringSync(new Uint8Array(buffer))
    const avatar = `data:image/png;base64.${str}`


    await patchUser({...this.user, avatar: `data:image/png;base64,${str}`})
    Notification.show({
      contentTitle:"修改成功"
    })
    setTimeout(() => router.back(), 500)
  }


  doPickPhoto () {
    // 使用鸿蒙提供的图片选择器，进行用户头像的选择
    // 图库选择完后，会再次触发onPageShow
    let PhotoSelectOptions = new picker.PhotoSelectOptions();
    PhotoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
    PhotoSelectOptions.maxSelectNumber = 5;
    let photoPicker = new picker.PhotoViewPicker();

    return photoPicker.select(PhotoSelectOptions).then(PhotoSelectResult => {
      return PhotoSelectResult.photoUris[0]
    })
  }

  editAvatar () {
    this.doPickPhoto().then(filePath => {
      this.avatar = filePath
    })
  }

  build() {
    Column() {
      TitleComponent({
        title: '个人资料',
        isBack: true
      })

      Column() {
        Image(this.avatar)
          .width(100)
          .height(100)
          .onClick(() => {
            this.editAvatar()
          })

      }

      Flex({ justifyContent: FlexAlign.Start }) {
        Text('个人信息')
          .fontSize(21)
          .fontWeight(700)
          .textAlign(TextAlign.Start)
      }
      .margin({ top: 30 })

      Column({ space: 20 }) {
        Input({
          title: '用户名',
          defaultValue: this.user.name,
          change: (val) => {
            this.user.name = val
          }
        })
        Input({
          title: '联系电话',
          defaultValue: this.user.phone,
          change: (val) => {
            this.user.phone = val
          }

        })
        Input({
          title: '邮箱',
          defaultValue: this.user.email,
          change: (val) => {
            this.user.email = val
          }
        })
      }
      .margin({ top: 20 })

      Flex() {
        Button('取消')
          .backgroundColor('#FBFBFD')
          .fontColor('#ffb7b1b1')
          .width(160)
          .onClick(() => {
            router.back()
          })

        Button('保存')
          .backgroundColor('#7AE4ED')
          .width(160)
          .onClick(() => {
            this.save()
          })
      }
      .margin({
        top: 20
      })

    }
    .padding({ left: 20, right: 20 })
    .backgroundColor($r('app.color.base_background'))
    .height('100%')
  }
}