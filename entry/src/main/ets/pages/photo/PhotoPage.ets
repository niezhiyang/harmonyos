import { http } from '@kit.NetworkKit';
import { url } from '@kit.ArkTS';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct PhotoPage {
  @State message: string = 'Hello World';
  url = "https://static.jiduapp.cn/v1/a9994116e83f428fbcecbc63c18b3f5d.mp4"

  build() {
    Column() {
      Button('下载').onClick(() => {

      })
      SaveButton().onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
        if (result == SaveButtonOnClickResult.SUCCESS) {

          download(this.url, async (buffer: ArrayBuffer) => {
            try {
              const context = getContext(this);
              let helper = photoAccessHelper.getPhotoAccessHelper(context);
              // onClick触发后10秒内通过createAsset接口创建图片文件，10秒后createAsset权限收回。
              let uri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4');
              // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制
              let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
              // 写入文件
              await fileIo.write(file.fd, buffer);
              // 关闭文件
              await fileIo.close(file.fd);
              promptAction.showToast({ message: '下载到相册' })
            } catch (error) {
              console.error("error is " + JSON.stringify(error));
            }
          })


        }
      })
      SaveButton().onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
        if (result == SaveButtonOnClickResult.SUCCESS) {
          try {
            const context = getContext(this);
            let helper = photoAccessHelper.getPhotoAccessHelper(context);
            // onClick触发后10秒内通过createAsset接口创建图片文件，10秒后createAsset权限收回。
            let uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'png');
            // 使用uri打开文件，可以持续写入内容，写入过程不受时间限制
            let file = await fileIo.open(uri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
            // 写入文件
            await fileIo.write(file.fd, context.resourceManager.getRawFileContentSync('img1.webp').buffer);
            // 关闭文件
            await fileIo.close(file.fd);
            console.log(TAG, "保存成功")
            promptAction.showToast({ message: '保存成功' })

          } catch (error) {
            console.error("error is " + JSON.stringify(error));
          }
        }
      })
    }
    .height('100%')
    .width('100%')
  }
}

let TAG = "download"

function download(url: string, callback: Callback<ArrayBuffer>) {
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
    callback(res)
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

// function saveFile(arrayBuffer: ArrayBuffer, urlReq: string) {
//   try {
//     let downUrl: url.URL = url.URL.parseURL(urlReq);
//     // 得到 文件在url中的名字
//     // "https://lf-web-assets.juejin.cn/obj/juejin-web/xitu_juejin_web/4ab562f.js"
//     // 比如上面得到的就是 4ab562f.js
//     let name: string = downUrl.pathname.split('/').pop() as string;
//     console.log(TAG, `名字是 ${name}`);
//     // 获取真正的路径
//     let path = urlReq.replace(PRX, '');
//     let pathDown = this.offlineFilePath + path;
//     // 打开，如果不存在 直接创建
//     console.log(TAG, `下载的路径是 ${pathDown}`);
//
//     // /data/storage/el2/base/haps/entry/cache/offline/static/rc-client-security-web-glue/1.0.0.19/sdk-glue.js
//     // 再判断 parent是否存在，不存在创建parent目录 ，否则再openSync会报错
//     this.makeParentDir(path)
//
//
//     let file = fs.openSync(pathDown, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
//     let fd = file.fd;
//     fs.writeSync(fd, arrayBuffer)
//     fs.closeSync(file)
//   } catch (e) {
//     console.error(JSON.stringify(e) + urlReq)
//   }
// }