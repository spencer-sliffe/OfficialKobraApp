//
//  AuthHttpService.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/16/23.
//

import Alamofire

final class AuthHttpService: HttpService {
   
    var sessionManger: Alamofire.Session = Session.default
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest{
        return sessionManager.request(urlRequest).validate(statusCode: 200..<400)
    }
}
