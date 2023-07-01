//
//  File.swift
//  
//
//  Created by Герман Кунин on 01.07.2023.
//

import Foundation

public protocol JSONConvertible {
    associatedtype TypeItem: JSONConvertible
    init?(json: [String: Any])
    var json: [String: Any] { get }
    static func parse(json: Any) -> TypeItem?
}

public protocol IdentifiableType {
    var id: String { get }
}

public protocol FileCacheProtocol {
    associatedtype TypeItem: JSONConvertible & IdentifiableType
    var todoItemsList: [String: TypeItem] { get }
    func addItem(_ item: TypeItem) -> TypeItem?
    func deleteItem(with id: String) -> TypeItem?
    func saveToJson(to file: String) throws
    func loadFromJson(from file: String) throws
}

enum FileCacheError: Error {
    case wrongNameOfFile
    case wrongData
}

public class FileCache<TypeItem: JSONConvertible & IdentifiableType> {
    private(set) var items: [String: TypeItem] = [:]
    
    private let logger: LoggerProtocol
    
    public init(logger: LoggerProtocol) {
        self.logger = logger
    }
    
    public convenience init() {
        self.init(logger: Logger.instance)
    }
    
    private func fetchFilePath(_ file: String, extensionPath: String) throws -> URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            logger.logError("Не удалось получить полный путь к директории")
            throw FileCacheError.wrongNameOfFile
        }
        
        let filePath = directory.appendingPathComponent("\(file).\(extensionPath)")
        return filePath
    }
}

extension FileCache: FileCacheProtocol {
    public var todoItemsList: [String: TypeItem] {
        return items
    }
    
    public func addItem(_ item: TypeItem) -> TypeItem? {
        let oldItem = items[item.id]
        items[item.id] = item
        return oldItem
    }
    
    public func deleteItem(with id: String) -> TypeItem? {
        let item = items[id]
        items[id] = nil
        return item
    }
    
    public func saveToJson(to file: String) throws {
        guard let fullPath = try? fetchFilePath(file, extensionPath: "json") else {
            logger.logError("Не удалось получить полный путь к директории")
            throw FileCacheError.wrongNameOfFile
        }
        
        let data = items.map { _, item in item.json }
        let dataJson = try JSONSerialization.data(withJSONObject: data)
        try dataJson.write(to: fullPath)
        logger.logInfo("todo успешно сохранены")
    }
    
    public func loadFromJson(from file: String) throws {
        guard let fullPath = try? fetchFilePath(file, extensionPath: "json") else {
            logger.logError("Не удалось получить полный путь к директории")
            throw FileCacheError.wrongNameOfFile
        }
        
        let data = try Data(contentsOf: fullPath)
        let dataJson = try JSONSerialization.jsonObject(with: data)
        
        guard let json = dataJson as? [Any] else {
            throw FileCacheError.wrongData
        }
        
        let todos = json.compactMap { TypeItem.parse(json: $0) as? TypeItem}
        self.items = todos.reduce(into: [:]) { dict, item in
            dict[item.id] = item
        }
        
        logger.logInfo("Загружены todo из файла")
    }
    
}

