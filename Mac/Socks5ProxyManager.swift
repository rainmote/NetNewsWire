import Foundation

class Socks5ProxyManager {
    
    static func configureSession() {
        guard let socks5ProxyString = ProcessInfo.processInfo.environment["SOCKS5_PROXY"] else {
            print("SOCKS5_PROXY环境变量未设置")
            return
        }
        
        let components = socks5ProxyString.components(separatedBy: ":")
        guard components.count == 2,
              let ip = components.first,
              let port = Int(components[1]) else {
            print("SOCKS5_PROXY环境变量格式错误")
            return
        }
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.connectionProxyDictionary = [
            kCFNetworkProxiesSOCKSProxy as AnyHashable: ip,
            kCFNetworkProxiesSOCKSPort as AnyHashable: port
        ]
        
        // 设置默认的共享会话配置
        URLSessionConfiguration.default = configuration
    }
}
