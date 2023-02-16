//
//  HttpService.swift
//  Kobra
//
//  Created by Spencer SLiffe on 2/16/23.
//

import Alamofire

protocol HttpService {
    var sessionManager: Session { get set }
    func request( urlRequest: URLRequestConvertible) -> DataRequest
}
