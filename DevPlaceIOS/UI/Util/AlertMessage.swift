import Foundation
import SwiftUI
import DevPlaceSwiftSDK
import KreeRequest

struct AlertMessage {
    var isPresented: Bool
    let title: String
    let message: String
    let buttonText: String
}

extension AlertMessage {
    static func none() -> Self {
        AlertMessage(isPresented: false, title: "", message: "", buttonText: "")
    }
    
    static func presentedError(message: String) -> Self {
        AlertMessage(isPresented: true, title: "Error", message: message, buttonText: "OK")
    }
    
    static func presentedError(_ error: Error) -> Self {
        let localizedMessage: String
        
        switch error {
        case is CancellationError:
            return .none()
        case let dpError as DevPlaceError:
            localizedMessage = dpError.message
        case let dpApiError as KreeRequest.Error<DevPlaceApiError.CodingData>:
            switch dpApiError {
            case .generalError(status: _, error: let error1):
                switch error1 {
                case let error2 as KreeRequest.Error<DevPlaceApiError.CodingData>:
                    switch error2 {
                    case .generalError(_, let error3):
                        if let apiError = error3 as? KreeRequest.Error<DevPlaceSwiftSDK.DevPlaceApiError.CodingData> {
                            switch apiError {
                            case .apiError(status: let status, error: let error4):
                                localizedMessage = "(\(status)) \(error4.decoded.message)"
                            default:
                                localizedMessage = apiError.localizedDescription
                            }
                        } else {
                            localizedMessage = error3.localizedDescription
                        }
                    default:
                        localizedMessage = error2.localizedDescription
                    }
                default:
                    localizedMessage = error1.localizedDescription
                }
            default:
                localizedMessage = dpApiError.description
            }
        default:
            localizedMessage = error.localizedDescription
        }
        
        dlog("Error: \(error)")
        return presentedError(message: localizedMessage)
    }
    
    static func presentedMessage(_ message: String) -> Self {
        AlertMessage(isPresented: true, title: "", message: message, buttonText: "OK")
    }
}

extension View {
    func alert(_ alertMessage: Binding<AlertMessage>) -> some View {
        self.alert(
            alertMessage.wrappedValue.title,
            isPresented: alertMessage.isPresented,
            actions: {
                Button(alertMessage.wrappedValue.buttonText, role: .cancel) {
                    
                }
            },
            message: {
                Text(alertMessage.wrappedValue.message)
            }
        )
    }
}
