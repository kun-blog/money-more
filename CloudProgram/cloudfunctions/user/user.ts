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

  // 本地调试
  // const {payload, action} = event.body

  if (action === 'add') {
    // 添加用户
    await cloudDBZoneWrapper.add(payload)
    return callback({
      code: 0,
      status: true
    })
  }

  if (action === 'query') {
    // 查询用户
    const queryResult = await cloudDBZoneWrapper.query(payload)

    const userInfo = queryResult.map(item => Object.fromEntries(item.getFieldMap()))

    return callback({
      code: 0,
      status: userInfo[0] ? true : false,
      data: userInfo[0] ?? null   // 双问号 (??) 是空值合并运算符
    })
  }

  if (action === 'patch') {
    // 修改用户数据
    const queryResult = await cloudDBZoneWrapper.patch(payload)

    return callback({
      code: 0,
      status: true
    })
  }

  // callback({
  //   code: 0,
  //   desc: "Success."
  // });
};

export { myHandler };