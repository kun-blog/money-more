const CloudDBZoneWrapper = require('./CloudDBZoneWrapper')

let myHandler = async function (event, context, callback, logger) {
  // 把参数信息注册到后台
  logger.info(event);

  // do something here
  // 集成数据库
  // https://developer.huawei.com/consumer/cn/doc/AppGallery-connect-Guides/agc-clouddb-sdk-integration-nodejs-0000001518387192

  // 初始化云数据库实例，并拿到相关操作方法
  const cloudDBZoneWrapper = new CloudDBZoneWrapper(logger)

  // const data = await cloudDBZoneWrapper.queryAll()

  /**
   * 本地调试不需要序列化
   * 远程需要序列化
   */
  const {payload, action} = JSON.parse(event.body)

  if (action === 'add') {
    // 添加银行卡
    await cloudDBZoneWrapper.add(payload)
    return callback({
      code: 0,
      status: true
    })
  }

  if (action === 'query') {
    // 查询
    try {
      const queryResult = await cloudDBZoneWrapper.query(payload)
      const data = queryResult.map(item => Object.fromEntries(item.getFieldMap()))
      return callback({
        code: 0,
        status: true,
        data
      })
    } catch (err) {
      console.log(err)
    }
  }

  // callback({
  //   code: 0,
  //   desc: "Success."
  // });
};

export { myHandler };