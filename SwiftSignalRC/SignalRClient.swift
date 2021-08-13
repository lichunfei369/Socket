//
//  SignalRClient.swift
//  EmedicineVideoDemo
//
//  Created by Mac on 2020/5/26.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import SwiftSignalRClient

protocol SignalRSwiftDelegate:AnyObject {
    func connectionDidOpen()
    func connectionDidClose()
    func connectionDidFailToOpen(error:Error)
}


typealias funcBlock = (String) -> ()
typealias resultErrorBlock = (Error) -> ()
typealias resultBlock = (Dictionary<String,Any>) -> ()

@objc class SignalRSwift: NSObject {
    
    private let dispatchQueue = DispatchQueue(label: "hubsamplephone.queue.dispatcheueuq")
    weak var delegate : SignalRSwiftDelegate?
    private var chatHubConnection: HubConnection?
    private var chatHubConnectionDelegate: HubConnectionDelegate?
    private var name = ""
    private var messages: [String] = []
    
    @objc public func signalROpen(url:String,headers: [String: String]?,hubName:String,blockfunc:funcBlock!){
        name=hubName
        self.chatHubConnectionDelegate = ChatHubConnectionDelegate(signalrswift: self)
        self.chatHubConnection = HubConnectionBuilder(url: URL(string: url)!)
            .withLogging(minLogLevel: .debug)
            .withHubConnectionDelegate(delegate: self.chatHubConnectionDelegate!)
            .withHttpConnectionOptions(configureHttpOptions: { (httpConnectionOptions) in
                if let header = headers {
                    for (key, value) in header {
                        httpConnectionOptions.headers[key] = value
                    }
                }
            })
            .build()
        
        //接收的方法
        self.chatHubConnection!.on(method: "Message", callback: {(message: String) in
             blockfunc(message)
        })
        self.chatHubConnection!.start()
    }
    @objc public func signalRClose(){
        chatHubConnection?.stop()
    }
    
//    @objc public func sendMessage(message:String) {
//        if message != "" {
//            chatHubConnection?.invoke(method:"SendMessage", name,message) { error in
//            }
//        }
//    }
   
    @objc public func sendMessage(message:String,arguments:[String],   resultBlock:resultBlock!,resultErrorBlock:resultErrorBlock!) {
            if message != "" {
                chatHubConnection?.invoke(method:message, arguments: arguments, resultType: String.self) { result, error in
                    if let error = error {
                        resultErrorBlock(error)
                    } else {
                        resultBlock(["result":result ?? ""])
                    }
                }
            }
    }

    
    // 接收方法
    @objc public func onMessage(message:String) {
        if message != "" {
            chatHubConnection?.on(method: "onMessage", callback: { error in
                
            })
        }
    }
    //连接成功
    fileprivate func connectionDidOpen() {

    }
    //连接错误失败
    fileprivate func connectionDidFailToOpen(error: Error) {
        self.delegate?.connectionDidFailToOpen(error: error)
    }
    //关闭连接
    fileprivate func connectionDidClose(error: Error?) {

        blockUI(message: "Connection is closed.", error: error)
    }
    //当连接将尝试重新连接时调用。
    fileprivate func connectionWillReconnect(error: Error?) {

    }
    //当连接重新连接成功时调用
    fileprivate func connectionDidReconnect() {

    }
    
    func blockUI(message: String, error: Error?) {
        var message = message
        if let e = error {
            message.append(" Error: \(e)")
        }
    }
}

class ChatHubConnectionDelegate: HubConnectionDelegate {
    
    weak var signalrswift: SignalRSwift?
    
    init(signalrswift: SignalRSwift) {
        self.signalrswift = signalrswift
    }
  
    func connectionDidOpen(hubConnection: HubConnection) {
        
        signalrswift?.connectionDidOpen()
    }
 
    func connectionDidFailToOpen(error: Error) {
        signalrswift?.connectionDidFailToOpen(error: error)
    }
  
    func connectionDidClose(error: Error?) {
        signalrswift?.connectionDidClose(error: error)
    }
    
    func connectionWillReconnect(error: Error) {
        signalrswift?.connectionWillReconnect(error: error)
    }
  
    func connectionDidReconnect() {
        signalrswift?.connectionDidReconnect()
    }
}
