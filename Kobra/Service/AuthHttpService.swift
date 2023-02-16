//
//  AuthHttpService.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/16/23.
//

import Alamofire

final class AuthHttpService: HttpService {
    var sessionManager: Session = Session.default
    
    func request( urlRequest: URLRequestConvertible) -> DataRequest{
        return sessionManager.request(urlRequest).validate(statusCode: 200..<400)
    }
}
