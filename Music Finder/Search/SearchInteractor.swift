//
//  SearchInteractor.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 19.07.21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchBusinessLogic {
  func makeRequest(request: Search.Model.Request.RequestType)
}

class SearchInteractor: SearchBusinessLogic {

  var presenter: SearchPresentationLogic?
  var service: SearchService?
  
  func makeRequest(request: Search.Model.Request.RequestType) {
    if service == nil {
      service = SearchService()
    }
    
    switch request {
    
    case .some:
        print("interactor. some")
        presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks)
    case .getTrack:
        print("interactor. gerTracks")
        presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks)
    }
  }
  
}
