//
//  BeijingBusAPICache.swift
//  fucking-beijing-bus-api
//
//  Created by Gao on 2018/10/20.
//

import Foundation
import Alamofire

extension BeijingBusAPI.Static {
    
    public struct Cache {
        
        public struct Key {
            public static let allLines = "all_lines"
            public static let lineDetails = "line_detail"
        }
        
        /// 如果有缓存数据，先读缓存，否则再去请求网络。
        /// 如果想清空请求数据，可以使用 cache 函数设 Key.allLines 为 nil
        public static func getAllLinesSmartly(completion: @escaping ((Result<[LineMeta]>) -> Void)) {
            if let cached: [LineMeta] = cachedObject(for: Key.allLines) {
                completion(.success(cached))
                return
            }
            BeijingBusAPI.Static.getAllLines { (result) in
                result.withValue({ (data) in
                    cache(data, for: Key.allLines)
                })
                completion(result)
            }
        }
        
        /// 如果有缓存数据，先读缓存，否则再去请求网络。
        /// 如果想清空请求数据，可以使用 cache 函数设 Key.lineDetails 为 nil
        public static func getLineDetailSmartly(ofLine lineID:String, completion: @escaping ( Result<LineDetail?>) -> Void) {
            if let cached: LineDetail? = cachedObject(for: Key.lineDetails) {
                completion(.success(cached))
                return
            }
            BeijingBusAPI.Static.getLineDetail(ofLine: lineID) { (result) in
                result.withValue({ (data) in
                    cache(data, for: Key.lineDetails)
                })
                completion(result)
            }
        }

        
        
        // MARK:- private
        private static let cacheKey = "com.leavez.BeijingBusAPI."
        
        public static func cache<T:Codable>(_ object:T?, for key:String) {
            let key = cacheKey+key
            if let object = object {
                let data = try! JSONEncoder().encode(object)
                UserDefaults.standard.set(data, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        public static func cachedObject<T:Codable>(for key:String) -> T? {
            if let data = UserDefaults.standard.object(forKey: cacheKey+key) as? Data,
                let object = try? JSONDecoder().decode(T.self, from: data) {
                return object
            } else {
                return nil
            }
        }
    }
}
