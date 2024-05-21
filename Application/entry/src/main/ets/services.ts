import agconnect from '@hw-agconnect/api-ohos'
import '@hw-agconnect/core-ohos'
import '@hw-agconnect/function-ohos'


 // 添加用户

export const addUser = async (payload) => {
  const functionCallable = agconnect.function().wrap("user-$latest")
  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'add',
    payload
  })

  return result.getValue()
}



 // 添加银行卡

export const addBackCard = async (payload) => {
  const functionCallable = agconnect.function().wrap("add-card-$latest")
  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'add',
    payload
  })

  return result.getValue()
}

// 获取卡片信息
export const queryBackCard = async (payload) => {
  const functionCallable = agconnect.function().wrap("add-card-$latest")

  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'query',
    payload
  })
  return result.getValue()
}

// 查询用户信息
export const queryUser = async (payload) => {
  const functionCallable = agconnect.function().wrap("user-$latest")

  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'query',
    payload
  })
  return result.getValue()
}

// 修改用户的信息
export const patchUser = async (payload) => {
  const functionCallable = agconnect.function().wrap("user-$latest")

  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'patch',
    payload
  })
  return result.getValue()
}

// 支付
export const doPay = async (payload) => {
  const functionCallable = agconnect.function().wrap("pay-records-$latest")

  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'add',
    payload
  })
  return result.getValue()
}

// 转账记录汇总
export const queryPayRecordsTotal = async (payload) => {
  const functionCallable = agconnect.function().wrap("pay-records-$latest")

  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'queryTotal',
    payload
  })
  return result.getValue()
}

export const queryPayRecords = async (payload) => {
  const functionCallable = agconnect.function().wrap("pay-records-$latest")

  const result = await functionCallable.call({
    // 操作类型 新增还是删除等等
    action: 'query',
    payload
  })
  return result.getValue()
}
