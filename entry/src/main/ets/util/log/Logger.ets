import { LoggerPrinter, Printer } from './Printer';


export class Logger {
  // 控制是否打印
  static isEnable: boolean = true;
  /// 日志中是否含有文件名字
  static isShowFile: boolean = true;
  // 默认的打印，也可以
  private static _printer: Printer = new LoggerPrinter()

  /// 设置用户自己的打印
  static set printer(printer: Printer) {
    Logger._printer = printer;
  }


  static debug(tag: string, content: string): void {
    Logger._printer.debug(tag, content)
  }


  static info(tag: string, content: string): void {
    Logger._printer.info(tag, content)
  }

  static warn(tag: string, content: string): void {
    Logger._printer.warn(tag, content)
  }

  static error(tag: string, content: string): void {
    Logger._printer.error(tag, content)
  }


  static json(tag: string, content: string | object | null): void {
    Logger._printer.json(tag, content)
  }
}
