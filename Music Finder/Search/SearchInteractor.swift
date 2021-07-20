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

    
    var networkService = NetworkService()
  var presenter: SearchPresentationLogic?
  var service: SearchService?
  
  func makeRequest(request: Search.Model.Request.RequestType) {
    if service == nil {
      service = SearchService()
    }
    
    switch request {
    
    case .some:
        print("interactor. some")
        presenter?.presentData(response: Search.Model.Response.ResponseType.some)
    case .getTrack(let searchTerm):
        print("interactor. gerTracks")
        networkService.fetchTracks(searchText: searchTerm) { [weak self] (searchRensponce) in
            self?.presenter?.presentData(response: Search.Model.Response.ResponseType.presentTracks(searchResponse: searchRensponce))
        }
        
    }
  }
  
}
