//
//  File.swift
//  
//
//  Created by Герман Кунин on 01.07.2023.
//

import CocoaLumberjack

public protocol LoggerProtocol {
    func logInfo(_ message: String)
    func logError(_ message: String)
}

public class Logger {
    static let instance = Logger()

    let ddlog = DDLog()
    let fileLogger: DDFileLogger = DDFileLogger()

    init() {
        fileLogger.rollingFrequency = 60 * 60 * 24
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        ddlog.add(fileLogger, with: .all)
    }
}

extension Logger: LoggerProtocol {
    public func logInfo(_ message: String) {
        ddlog.log(asynchronous: true, message: DDLogMessage(message: message, level: .info, flag: .info, context: 0, file: #file, function: #function, line: #line, tag: nil, options: [.copyFile, .copyFunction], timestamp: nil))
    }

    public func logError(_ message: String) {
        ddlog.log(asynchronous: true, message: DDLogMessage(message: message, level: .error, flag: .error, context: 0, file: #file, function: #function, line: #line, tag: nil, options: [.copyFile, .copyFunction], timestamp: nil))
    }
}

