const clouddb = require('@hw-agconnect/database-server/dist/index.js');
const agconnect = require('@hw-agconnect/common-server');
const path = require('path');
const CryptoJS = require('crypto-js');

/*
    配置区域
*/
//TODO 将AGC官网下载的配置文件放入resources文件夹下并将文件名替换为真实文件名
const credentialPath = "resources/agc-apiclient-1405382168431076736-7360961829656251174.json";
// 修改为在管理台创建的存储区名称
let zoneName = "ddDB"
// 修改为需要操作的对象
// let objectName = 'user';

let logger

let mCloudDBZone

class CloudDBZoneWrapper {

    // AGC & 数据库初始化
    constructor(log) {
        logger = log;

        let agcClient;

        try {
            agcClient = agconnect.AGCClient.getInstance();
        } catch (error) {
            agconnect.AGCClient.initialize(agconnect.CredentialParser.toCredential(path.join(__dirname, credentialPath)));
            agcClient = agconnect.AGCClient.getInstance();
        }

        clouddb.AGConnectCloudDB.initialize(agcClient);

        const cloudDBZoneConfig = new clouddb.CloudDBZoneConfig(zoneName);

        const agconnectCloudDB = clouddb.AGConnectCloudDB.getInstance(agcClient);
        mCloudDBZone = agconnectCloudDB.openCloudDBZone(cloudDBZoneConfig);
    }
    async add(payload) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        // 通过事务保证转账过程是完整的
        await mCloudDBZone.runTransaction({
            apply: (transaction) => this.doAdd(transaction, payload)
        })

    }

    async doAdd (transaction, payload) {
        try {
            const cardsOfPayee = await transaction.executeQuery(
                clouddb.CloudDBZoneQuery.where('bankCard')
                    .equalTo('uuid', payload.payee)
            )

            // 如果被付款人没有银行卡则中断事务
            if (!cardsOfPayee[0]) return false
            const cardsOfPayer = await transaction.executeQuery(
                clouddb.CloudDBZoneQuery.where('bankCard')
                    .equalTo('uuid', payload.payer)
            )
            // 如果付款人没有银行卡 或者 超出付款人余额 则中断事务
            if (!cardsOfPayer[0] || cardsOfPayer[0].getFieldValue('amount') < payload.amount) return false

            const cardOfPayer = cardsOfPayer[0]
            const cardOfPayee = cardsOfPayee[0]

            // 注意卡片对象为CloudDBZoneGenericObject，因此需要通过addFieldValue进行值的更新
            cardOfPayer.addFieldValue('amount', cardOfPayer.getFieldValue('amount') - payload.amount)
            cardOfPayee.addFieldValue('amount', cardOfPayee.getFieldValue('amount') + payload.amount)

            // 更新付款双方的余额
            transaction.executeUpsert([cardOfPayer])
            transaction.executeUpsert([cardOfPayee])

            // 创建支付记录
            const payRecord = clouddb.CloudDBZoneGenericObject.build('payRecords')
            const createdAt = Date.now()

            payRecord.addFieldValue('payer', payload.payer)
            payRecord.addFieldValue('payee', payload.payee)
            payRecord.addFieldValue('amount', payload.amount)
            payRecord.addFieldValue('createAt', createdAt)

            // 云数据库主键不会自增，我们要自己生成
            // 通过哈希算法 生成支付记录ID
            const payid = CryptoJS.SHA256(`${payload.payer}-${payload.payee}-${payload.amount}-${createdAt}`).toString()
            payRecord.addFieldValue('payid', payid)
            // // 新增支付记录
            transaction.executeUpsert([payRecord])
            return true

        } catch (e) {
            console.log('add =>', e)
        }

    }

    async query (payload) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it")
            console.log("CloudDBClient is null, try re-initialize it")
            return
        }

        const { page = 1, pageSize = 5 } = payload
        try {
            // 需要考虑 payer 和 payee 两种情况，也就是说 用户即需要展示自己的入帐记录，也需要展示自己的出账
            const outcomeResp = await mCloudDBZone.executeQuery(
                clouddb.CloudDBZoneQuery.where('payRecords')
                    .equalTo('payer', payload.uuid)
                    .orderByDesc('createAt')
                    .limit(pageSize, Math.max(0, page - 1) * pageSize)
            )
            const incomeResp = await mCloudDBZone.executeQuery(
                clouddb.CloudDBZoneQuery.where('payRecords')
                    .equalTo('payee', payload.uuid)
                    .orderByDesc('createAt')
                    .limit(pageSize, Math.max(0, page - 1) * pageSize)
            )
            // 将出入帐记录进行组装
            const outcomeData = outcomeResp.getSnapshotObjects()
            const incomeData = incomeResp.getSnapshotObjects()
            const totalData =  incomeData.concat(outcomeData)
            // 由于目前云数据库不支持join，因此只能先查询用户信息，进行补全
            let users = totalData.reduce((list, item) => {
                list.push(item.getFieldValue('payer'))
                list.push(item.getFieldValue('payee'))
                return list
            }, [])
            // 通过Set进行去重
            users = Array.from(new Set(users))
            // 获取所有的用户信息
            let userInfos = await mCloudDBZone.executeQuery(
                clouddb.CloudDBZoneQuery.where('user')
                    .in('uuid', users)
            )
            userInfos = userInfos.getSnapshotObjects()


            // 进行用户信息填补
            const data = totalData.map(a => {
                const originData = Object.fromEntries(a.getFieldMap())
                const payerInfo = userInfos.find(u => u.getFieldValue('uuid') === originData.payer)
                const payeeInfo = userInfos.find(u => u.getFieldValue('uuid') === originData.payee)
                return {
                    ...originData,
                    payerInfo: payerInfo ? Object.fromEntries(payerInfo.getFieldMap()) : {},
                    payeeInfo: payeeInfo ? Object.fromEntries(payeeInfo.getFieldMap()) : {},
                }
            })

            return data

        } catch (err) {
            console.log('query===>' , err)
        }

    }

    async queryTotal (payload) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }

        // 查出出账数据
        const outcomeResp = await mCloudDBZone.executeQuery(
            clouddb.CloudDBZoneQuery.where('payRecords')
                .equalTo('payer', payload.uuid)
        )

        // 查出进账数据
        const incomeResp = await mCloudDBZone.executeQuery(
            clouddb.CloudDBZoneQuery.where('payRecords')
                .equalTo('payee', payload.uuid)
        )

        // 将出入账数据进行一个组装
        const outcomeData = outcomeResp.getSnapshotObjects()
        const incomeData = incomeResp.getSnapshotObjects()

        const income = incomeData.reduce((total , item) => {
            return total + item.getFieldValue('amount')
        }, 0)

        const outcome = outcomeData.reduce((total , item) => {
            return total + item.getFieldValue('amount')
        }, 0)

        return {
            income,
            outcome,
            incomeRecords: outcomeData.map(item => Object.fromEntries(item.getFieldMap()))
        }
    }


    async queryAll() {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const resp = await mCloudDBZone.executeQuery(clouddb.CloudDBZoneQuery.where(objectName));
            return resp.getSnapshotObjects();
        } catch (error) {
            logger.info('queryAll=>', error);
            console.log(error)
        }
    }

    async queryCompound(data) {

        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            // 根据业务需要修改查询条件
            const cloudDBZoneQuery = this.setQuery(data);
            const resp = await mCloudDBZone.executeQuery(cloudDBZoneQuery);
            return resp.getSnapshotObjects();
        } catch (error) {
            logger.info('queryCompound=>', error);
            console.log(error)
        }

    }

    async queryAverage(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const cloudDBZoneQuery = this.setQuery(data);
            let target = data.target;
            const resp = await mCloudDBZone.executeAverageQuery(cloudDBZoneQuery, target);
            return resp;
        } catch (error) {
            logger.info('queryCompound=>', error);
            console.log(error)
        }
    }

    async querySum(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const cloudDBZoneQuery = this.setQuery(data);
            let target = data.target;
            const resp = await mCloudDBZone.executeSumQuery(cloudDBZoneQuery, target);
            return resp;
        } catch (error) {
            logger.info('querySum=>', error);
            console.log(error)
        }
    }

    async queryMax(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const cloudDBZoneQuery = this.setQuery(data);
            let target = data.target;
            const resp = await mCloudDBZone.executeMaximumQuery(cloudDBZoneQuery, target);
            return resp;
        } catch (error) {
            logger.info('querySum=>', error);
            console.log(error)
        }
    }

    async queryMin(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const cloudDBZoneQuery = this.setQuery(data);
            let target = data.target;
            const resp = await mCloudDBZone.executeMinimalQuery(cloudDBZoneQuery, target);
            return resp;
        } catch (error) {
            logger.info('querySum=>', error);
            console.log(error)
        }
    }

    async queryCount(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const cloudDBZoneQuery = this.setQuery(data);
            let target = data.target;
            const resp = await mCloudDBZone.executeCountQuery(cloudDBZoneQuery, target);
            return resp;
        } catch (error) {
            logger.info('querySum=>', error);
            console.log(error)
        }
    }

    async orderByAsc(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            let target = data.target;
            const cloudDBZoneQuery = this.setQuery(data).orderByAsc(target);
            const resp = await mCloudDBZone.executeQuery(cloudDBZoneQuery);
            return resp.getSnapshotObjects();
        } catch (error) {
            logger.info('querySum=>', error);
            console.log(error)
        }
    }

    async orderByDesc(data) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            let target = data.target;
            const cloudDBZoneQuery = this.setQuery(data).orderByDesc(target);
            const resp = await mCloudDBZone.executeQuery(cloudDBZoneQuery);
            return resp.getSnapshotObjects();
        } catch (error) {
            logger.info('querySum=>', error);
            console.log(error)
        }
    }

    setQuery(data) {
        const cloudDBZoneQuery = clouddb.CloudDBZoneQuery.where(objectName);

        if ("contains" in data) {
            let contains = data.contains;
            for (var key in contains) {
                cloudDBZoneQuery.contains(key, contains[key]);
            }
        }

        if ("equalTo" in data) {
            let equalTo = data.equalTo;
            for (var i in equalTo) {
                console.log("i = " + i);
                console.log("value = " + equalTo[i]);
                cloudDBZoneQuery.equalTo(i, equalTo[i]);
            }
        }

        if ("notEqualTo" in data) {
            let notEqualTo = data.notEqualTo;
            for (var i in notEqualTo) {
                console.log("i = " + i);
                console.log("value = " + notEqualTo[i]);
                cloudDBZoneQuery.notEqualTo(i, notEqualTo[i]);
            }
        }

        if ("greaterThan" in data) {
            let greaterThan = data.greaterThan;
            for (var i in greaterThan) {
                console.log("i = " + i);
                console.log("value = " + greaterThan[i]);
                cloudDBZoneQuery.greaterThan(i, greaterThan[i]);
            }
        }

        if ("greaterThanOrEqualTo" in data) {
            let greaterThanOrEqualTo = data.greaterThanOrEqualTo;
            for (var i in greaterThanOrEqualTo) {
                console.log("i = " + i);
                console.log("value = " + greaterThanOrEqualTo[i]);
                cloudDBZoneQuery.greaterThanOrEqualTo(i, greaterThanOrEqualTo[i]);
            }
        }

        if ("lessThan" in data) {
            let lessThan = data.lessThan;
            for (var i in lessThan) {
                console.log("i = " + i);
                console.log("value = " + lessThan[i]);
                cloudDBZoneQuery.lessThan(i, lessThan[i]);
            }
        }

        if ("lessThanOrEqualTo" in data) {
            let lessThanOrEqualTo = data.lessThanOrEqualTo;
            for (var i in lessThanOrEqualTo) {
                console.log("i = " + i);
                console.log("value = " + lessThanOrEqualTo[i]);
                cloudDBZoneQuery.lessThanOrEqualTo(i, lessThanOrEqualTo[i]);
            }
        }

        if ("in" in data) {
            let funcIn = data.in;
            for (var i in funcIn) {
                console.log("i = " + i);
                console.log("value = " + funcIn[i]);
                cloudDBZoneQuery.in(i, funcIn[i]);
            }
        }

        if ("beginsWith" in data) {
            let beginsWith = data.beginsWith;
            for (var i in beginsWith) {
                console.log("i = " + i);
                console.log("value = " + beginsWith[i]);
                cloudDBZoneQuery.beginsWith(i, beginsWith[i]);
            }
        }

        if ("endsWith" in data) {
            let endsWith = data.endsWith;
            for (var i in endsWith) {
                console.log("i = " + i);
                console.log("value = " + endsWith[i]);
                cloudDBZoneQuery.endsWith(i, endsWith[i]);
            }
        }

        if ("isNull" in data) {
            let isNull = data.isNull;
            cloudDBZoneQuery.isNull(isNull);
        }

        if ("isNotNull" in data) {
            let isNotNull = data.isNotNull;
            cloudDBZoneQuery.isNotNull(isNotNull);
        }

        return cloudDBZoneQuery;
    }
}

module.exports = CloudDBZoneWrapper;