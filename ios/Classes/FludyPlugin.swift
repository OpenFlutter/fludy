import Flutter
import UIKit
import DouyinOpenSDK

public class FludyPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "club.openflutter/fludy", binaryMessenger: registrar.messenger())
    let instance = FludyPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
    
    var channel:FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        DouyinOpenSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return false
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if DouyinOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: (options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String), annotation: options[UIApplication.OpenURLOptionsKey.annotation]) {
            return true
        }
        
        return false
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String, annotation: Any) -> Bool {
        if DouyinOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if DouyinOpenSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: nil, annotation: nil) {
            return true
        }
        
        return false
    }
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initializeApi":
        let args = call.arguments as? [String:String]

        if let clientKey = args?["clientKey"] {
            DouyinOpenSDKApplicationDelegate.sharedInstance().registerAppId(clientKey)
        }
      result(nil)
    case "isDouYinInstalled":
        result(DouyinOpenSDKApplicationDelegate.sharedInstance().isAppInstalled())
    case "authorization":
        let args = call.arguments as? Dictionary<String, Any>
        let scopeList = (args?["scope"] as? Array<String>) ?? []
        if scopeList.isEmpty == true {
            result(FlutterError.init(code: "BAD_SCOPE",
                                                 message: "Wrong argument - scope must be not blank" ,
                                                 details: nil))
        } else {
    
            
            if let viewController = viewController(with: nil) {
                let request : DouyinOpenSDKAuthRequest = DouyinOpenSDKAuthRequest()

                request.permissions = NSOrderedSet(array: scopeList)
                let additionalPermissions = args?["additionalPermissions"] as? [String:String]
                if let ap = additionalPermissions {
                    request.additionalPermissions = NSOrderedSet(objects: ap)
                }
                if let state = args?["state"] as? String {
                    request.state = state
                }
            
                request.send(viewController, complete: {[self] response in
                    if let resp = response {
//                        val result = mapOf(
//                            "state" to response.state,
//                            "cancel" to response.isCancel,
//                            "authCode" to response.authCode,
//                            "grantedPermissions" to response.grantedPermissions.split(","),
//                            "errorCode" to response.errorCode,
//                            "errorMsg" to response.errorMsg
//                        )
                        
                        var resultArguments: [String: Any] = [:]
                        if let state = resp.state {
                            resultArguments["state"] = state
                        }
                        if let authCode = resp.code {
                            resultArguments["authCode"] = authCode
                        }
                        if let grantedPermissions = resp.grantedPermissions?.array {
                            resultArguments["grantedPermissions"] = grantedPermissions
                        }
                        
                        resultArguments["errorCode"] = resp.errCode.rawValue
                        
                        if let errorMsg = resp.errString {
                            resultArguments["errorMsg"] = errorMsg
                        }
                        
                        self.channel.invokeMethod("onAuthResponse", arguments: resultArguments)
                    }
                })
                
//
//                request?.sendAuthRequestViewController(viewController) { [self] resp in
//                    var arguments: [StringLiteralConvertible : NSNumber]?
//                    if let code = resp?.code {
//                        arguments = [
//                            "code": NSNumber(value: resp?.errCode),
//                            "permission": resp?.grantedPermissions.array.joined(separator: ",") ?? "",
//                            "authCode": code
//                        ]
//                    }
//
//                    channel.invokeMethod("onAuthorCallback", arguments: arguments)
//                }
            }
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
    

    
    func viewController(with window: UIWindow?) -> UIViewController? {
        var windowToUse = window
        if windowToUse == nil {
            for window in UIApplication.shared.windows {
                if window.isKeyWindow {
                    windowToUse = window
                    break
                }
            }
        }
        
        var topController = windowToUse?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController
    }

}
