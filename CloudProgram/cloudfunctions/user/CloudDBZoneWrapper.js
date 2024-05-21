const clouddb = require('@hw-agconnect/database-server/dist/index.js');
const agconnect = require('@hw-agconnect/common-server');
const path = require('path');

/*
    配置区域
*/
//TODO 将AGC官网下载的配置文件放入resources文件夹下并将文件名替换为真实文件名
const credentialPath = "resources/agc-apiclient-1405382168431076736-7360961829656251174.json";
// 修改为在管理台创建的存储区名称
let zoneName = "ddDB"
// 修改为需要操作的对象
let objectName = 'user';

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

    // 添加新注册用户到数据库
    async add(payload) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            const user = clouddb.CloudDBZoneGenericObject.build('user')
            user.addFieldValue("email", payload.email)
            user.addFieldValue("uuid", payload.uuid)
            user.addFieldValue("name", payload.name)

            return mCloudDBZone.executeUpsert(user)
        } catch (error) {
            logger.info('queryAll=>', error);
            console.log(error)
        }
    }

    async query (payload) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }
        try {
            // 构建DB实例
            const resp =  await mCloudDBZone.executeQuery(
                clouddb.CloudDBZoneQuery.where(objectName)
                    .equalTo('uuid', payload.uuid)
            )
            return resp.getSnapshotObjects()

        } catch (error) {
            logger.info('queryAll=>', error);
            console.log(error)
        }
    }

    async patch (payload) {
        if (!mCloudDBZone) {
            logger.info("CloudDBClient is null, try re-initialize it");
            console.log("CloudDBClient is null, try re-initialize it")
            return;
        }

        try {
            const user = clouddb.CloudDBZoneGenericObject.build('user')
            user.addFieldValue("email", payload.email)
            user.addFieldValue("uuid", payload.uuid)
            user.addFieldValue("name", payload.name)
            user.addFieldValue("phone", payload.phone)
            user.addFieldValue("avatar", payload.avatar)

            return mCloudDBZone.executeUpsert(user)
        } catch (error) {
            logger.info('queryAll=>', error);
            console.log(error)
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