import { HashMap, url } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';

let TAG = 'OfflineUtil'
let PRX = `https://lf-web-assets.juejin.cn/obj/juejin-web/xitu_juejin_web`

export class OfflineUtil {
  static instance: OfflineUtil = new OfflineUtil();
  map: HashMap<string, string> = new HashMap()
  // 要把 h5 下载到这里
  offlineFilePath = getContext(this).filesDir + '/offline';

  private constructor() {
  }


  init() {
    // 文件夹是否存在
    let exists = fs.accessSync(this.offlineFilePath)
    if (!exists) {
      // 创建文件夹
      fs.mkdirSync(this.offlineFilePath)
    }
  }

  download(url: string) {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 用于订阅HTTP响应头事件
    httpRequest.on('headersReceive', (header: Object) => {
      console.info(TAG, 'header: ' + JSON.stringify(header));
    });
    // 用于订阅HTTP流式响应数据接收事件
    let res = new ArrayBuffer(0);
    httpRequest.on('dataReceive', (data: ArrayBuffer) => {
      const newRes = new ArrayBuffer(res.byteLength + data.byteLength);
      const resView = new Uint8Array(newRes);
      resView.set(new Uint8Array(res));
      resView.set(new Uint8Array(data), res.byteLength);
      res = newRes;
    });
    // 用于订阅HTTP流式响应数据接收完毕事件
    httpRequest.on('dataEnd', () => {
      console.info(TAG, '下载完成');
      // 下载完成之后，保存
      this.saveFile(res, url)
    });

    let streamInfo: http.HttpRequestOptions = {
      method: http.RequestMethod.GET, // 可选，默认为http.RequestMethod.GET
    }
    // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定
    httpRequest.requestInStream(url, streamInfo).then((data: number) => {
      console.info("requestInStream OK!");
      console.info('ResponseCode :' + JSON.stringify(data));
      // 取消订阅HTTP响应头事件
      httpRequest.off('headersReceive');
      // 取消订阅HTTP流式响应数据接收事件
      httpRequest.off('dataReceive');
      // 取消订阅HTTP流式响应数据接收完毕事件
      httpRequest.off('dataEnd');
      // 当该请求使用完毕时，调用destroy方法主动销毁
      httpRequest.destroy();
    }).catch((err: Error) => {
      console.info("requestInStream ERROR : err = " + JSON.stringify(err));
    });

  }

  saveFile(arrayBuffer: ArrayBuffer, urlReq: string) {
    try {
      let downUrl: url.URL = url.URL.parseURL(urlReq);
      // 得到 文件在url中的名字
      // "https://lf-web-assets.juejin.cn/obj/juejin-web/xitu_juejin_web/4ab562f.js"
      // 比如上面得到的就是 4ab562f.js
      let name: string = downUrl.pathname.split('/').pop() as string;
      console.log(TAG, `名字是 ${name}`);
      // 获取真正的路径
      let path = urlReq.replace(PRX, '');
      let pathDown = this.offlineFilePath + path;
      // 打开，如果不存在 直接创建
      console.log(TAG, `下载的路径是 ${pathDown}`);

      // /data/storage/el2/base/haps/entry/cache/offline/static/rc-client-security-web-glue/1.0.0.19/sdk-glue.js
      // 再判断 parent是否存在，不存在创建parent目录 ，否则再openSync会报错
      this.makeParentDir(path)


      let file = fs.openSync(pathDown, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      let fd = file.fd;
      fs.writeSync(fd, arrayBuffer)
      fs.closeSync(file)
    } catch (e) {
      console.error(JSON.stringify(e) + urlReq)
    }
  }

  makeParentDir(path: string) {
    // 拿到 parent 路径
    // let parentPath = pathDown.replace(`/${pathDown.split('/').pop() as string}`, "")
    // let exists = fs.access(parentPath)
    // console.log('parent=' + parentPath)
    // if (!exists) {
    //   // 有可能是多级目录
    //   fs.mkdirSync(parentPath, true)
    // }
    try {
      let temp = ''
      let array = path.split('/')
      array.pop()
      array.forEach((value, index, array) => {
        if (value != "") {
          temp = temp + '/' + value
          let exists = fs.accessSync(this.offlineFilePath + temp)
          console.log(`这个是否存在 ${this.offlineFilePath + temp}  + ${exists}`)
          if (!exists) {
            console.log(`创建 ${this.offlineFilePath + temp}`)
            fs.mkdirSync(this.offlineFilePath + temp)
            console.log(`创建 成功`)
          }
        }

      })
    } catch (e) {
      console.error(JSON.stringify(e) + path)
    }
  }

  getLocalFile(url: string): WebResourceResponse | null {
    // 第一次需要先下载，模拟
    if (url.includes(PRX)) {
      // this.download(url)
    }
    // 表明是在离线包中
    try {
      // 如果包含这个前缀，就去寻找
      if (url.includes(PRX)) {
        // 判断 离线包下的这个文件是否存在
        let path = this.offlineFilePath + url.replace(PRX, '')
        if (fs.accessSync(path)) {
          // 证明存在
          let file = fs.openSync(path)
          let responseWeb: WebResourceResponse = new WebResourceResponse();
          // 加速JS执行，并且ResponseData如果有更新时必须更新该字段。不添加“ResponseDataID”字段的情况下默认不生成CodeCache。
          // 把这个responseDataID存在全局的HashMap中
          let responseDataID = '1'
          if (OfflineUtil.instance.map.hasKey(path)) {
            responseDataID = OfflineUtil.instance.map.get(path)
          } else {
            responseDataID = this.generateUniqueID().toString()
            OfflineUtil.instance.map.set(path, responseDataID)
          }
          responseWeb.setResponseHeader([
            {
              // 格式：不超过13位纯数字。js识别码，Js有更新时必须更新该字段
              headerKey: "ResponseDataID",
              headerValue: responseDataID
            }
          ]);
          // 2. number表示文件句柄, 此句柄由系统的Web组件负责关闭。
          responseWeb.setResponseData(file.fd);
          // 好像这里不用填写MimeType,如果有的网址强校验这个，请根据path来获取真正的mimetype
          // responseWeb.setResponseMimeType();
          responseWeb.setResponseEncoding('utf-8');
          responseWeb.setResponseCode(200);
          responseWeb.setReasonMessage('OK');
          responseWeb.setResponseIsReady(true);
          console.log('给的是本地数据 ' + url)
          return responseWeb;
        }
      }
    } catch (e) {
      console.error(`错误了=> ${JSON.stringify(e)}`)
    }
    return null
  }

  generateUniqueID(): string {
    // 获取当前时间戳（毫秒）
    const timestamp = Date.now(); // 当前时间戳
    const randomNum = Math.floor(Math.random() * 1000); // 生成 0 到 999 之间的随机数

    // 将时间戳和随机数组合成一个字符串
    const uniqueID = (timestamp % 1000000000000) + randomNum; // 确保不超过 13 位

    return uniqueID.toString();
  }
}