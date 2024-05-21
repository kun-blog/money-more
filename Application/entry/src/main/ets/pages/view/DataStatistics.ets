import TitleComponent from '../../components/TitleComponent'
import web_webview from '@ohos.web.webview';
import { PayRecordTotal } from '../MainPage/type';

// 文档 https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/web-page-loading-with-web-components-0000001458307700-V3


/**
 * 实现两个方法提供给webView调用
 * 调用后可以得到相关的数据进行展示
 */


@Component
export struct DataStatistics {
  controller: web_webview.WebviewController = new web_webview.WebviewController();

  @Link payRecordTotal: PayRecordTotal

  // 准备给webView转的上下文
  context = {
    getPayRecordsTotal: () => {
      // 给webView传值的时候只能传字符串，所以这里需要进行转义
      return JSON.stringify(this.payRecordTotal)
    }
  }

  build(){
    Column() {
      TitleComponent({
        title:'数据统计'
      })

      Web({
        src: $rawfile("web/index.html"),
        controller: this.controller
      })
      /**
       * 整个webView可以说是一个沙箱环境
       * 我们通过注入JavaScriptProxy进行控制
       */
        .javaScriptProxy({
          // 注入上下文
          object: this.context,
          // 指定web端可以接受的key，简单理解就是web端window上挂在的key
          name:'context',
          // 显式的声明web端可以调用的方法
          methodList:['getPayRecordsTotal'],
          controller: this.controller
        })
        .onConsole((event) => {  // 注意：我们通过监听事件在ide控制台输出调试信息
          // 显示webView的调试结果
          console.log('--page log--', event.message.getMessage())
          return true
        })
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.base_background'))
  }
}