//
//  ViewController.swift
//  UMdsym
//
//  Created by dexiong on 2023/10/11.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var versionField: NSTextField!
    
    @IBOutlet var messageView: NSTextView!
    
    private var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    @IBAction func selectFile(_ sender: NSButton) {
        guard let window = view.window else { return }
        let pannel: NSOpenPanel = .init()
        pannel.directoryURL = URL(string: "/Users/***/Library/Developer/Xcode/Archives/")
        pannel.canChooseDirectories = true
        pannel.treatsFilePackagesAsDirectories = true
        pannel.beginSheetModal(for: window) { [weak pannel, weak self] resp in
            guard let panel = pannel, let this = self else { return }
            guard resp == .OK, let selectURL = panel.urls.first else { return }
            this.setMessage("选中文件路径:\(selectURL.path())")
            this.zip(at: selectURL) { result in
                switch result {
                case .success(let url):
                    this.setMessage("压缩完成: \(url)")
                case .failure(let error):
                    this.setMessage("压缩失败: \(error)")
                }
            }
        }
    }
    
    /// 压缩文件
    /// - Parameters:
    ///   - url: URL 文件路径
    ///   - complete: 回调
    private func zip(at url: URL, complete: @escaping (Result<URL, Error>) -> Void) {
        setMessage("开始压缩")
        DispatchQueue.global().async {
            let toURL = FileManager.default.temporaryDirectory.appending(path: "dsym.zip")
            try? FileManager.default.removeItem(at: toURL)
            let coordinator = NSFileCoordinator()
            var error: NSError?
            coordinator.coordinate(readingItemAt: url, options: .forUploading, error: &error) { atURL in
                do {
                    try FileManager.default.moveItem(at: atURL, to: toURL)
                } catch {
                    print(error)
                }
            }
            if let error = error {
                DispatchQueue.main.async {
                    complete(.failure(error))
                }
            } else {
                DispatchQueue.main.async {
                    complete(.success(toURL))
                }
            }
        }
    }
    
    /// setMessage
    /// - Parameter message: String
    private func setMessage(_ message: String) {
        DispatchQueue.main.async {
            let replacementRange = self.messageView.rangeForUserCompletion
            self.messageView.insertText("\(message)\n\n", replacementRange: replacementRange)
        }
    }
    
    @IBAction func upload(_ sender: Any) {
        getSymUploadParam()
    }
    
    private func getSymUploadParam() {
        guard var url = URL(string: "https://apm.openapi.umeng.com/getSymUploadParam") else { return }
        url.append(queryItems: [.init(name: "dataSourceId", value: ""),
                                .init(name: "appVersion", value: self.versionField.stringValue),
                                .init(name: "fileName", value: "dsym1.zip"),
                                .init(name: "fileType", value: "3"),
                                .init(name: "accessKeyId", value: ""),
                                .init(name: "accessKeySecret", value: ""),
                                .init(name: "version", value: "2022-02-14"),
                                .init(name: "action", value: "GetSymUploadParam"),
                                .init(name: "pathname", value: "/getSymUploadParam"),
                                .init(name: "authType", value: "AK"),
                                .init(name: "style", value: "ROA")])
        var request: URLRequest = .init(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("4106659", forHTTPHeaderField: "apiKey")
//        request.addValue("DUb5xyQY7lZ", forHTTPHeaderField: "apiSecret")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
            } else if let data = data, let wrapper = try? JSONDecoder().decode(UWrapper.self, from: data) {
                print(wrapper.data)
            }
        }.resume()
    }
}

