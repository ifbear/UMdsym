//
//  Model.swift
//  UMdsym
//
//  Created by dexiong on 2023/10/11.
//

import Foundation

struct UWrapper: Codable {
    internal let msg: String?
    internal let traceId: String?
    internal let code: Int
    internal let success: Bool
    internal let data: UParams
}

struct UParams: Codable {
    internal let uploadAddress: String? // 文件上传地址
    internal let accessKeyId: String?
    internal let signature: String?
    internal let callback: String?
    internal let key: String?
    internal let policy: String
}
