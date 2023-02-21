//
//  HttpService.swift
//  Kobra
//
//  Created by Spencer Sliffe on 2/16/23.
//
import Foundation
import Alamofire

protocol HttpService {
    var sessionManger: Session { get set }
    func request(_ urlRequest: URLRequestConvertible) -> DataRequest
}

extension HttpService {
    var sessionManager: Session {return Session.default}
}
