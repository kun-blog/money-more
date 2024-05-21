const CloudDBZoneWrapper = require('./CloudDBZoneWrapper')

let myHandler = async function (event, context, callback, logger) {
  logger.info(event);

  const cloudDBZoneWrapper = new CloudDBZoneWrapper(logger)
  /**
   * 本地调试不需要序列化
   * 远程需要序列化
   */
  const {payload, action} = JSON.parse(event.body)
  // const {payload, action} = event.body

  if (action === 'add') {
    if (payload.amount <= 0) {
      return callback({
        code: 0,
        status:false,
        errMsg:'金额不能为零'
      });
    }

    await cloudDBZoneWrapper.add(payload)

    return callback({
      code: 0,
      status: true,
    });

  }

  if (action === 'query') {

    const data = await cloudDBZoneWrapper.query(payload)

    return callback({
      code: 0,
      status: true,
      data
    });
  }


  if (action === 'queryTotal') {

    const data = await cloudDBZoneWrapper.queryTotal(payload)

    return callback({
      code: 0,
      status: true,
      data
    });
  }

};

export { myHandler };