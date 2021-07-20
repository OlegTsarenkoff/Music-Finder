//
//  SearchPresenter.swift
//  Music Finder
//
//  Created by Oleg Tsarenkoff on 19.07.21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

protocol SearchPresentationLogic {
  func presentData(response: Search.Model.Response.ResponseType)
}

class SearchPresenter: SearchPresentationLogic {
  weak var viewController: SearchDisplayLogic?
  
  func presentData(response: Search.Model.Response.ResponseType) {
  
    switch response {
   
    case .some:
        print("presenter .some")
    case .presentTracks:
        print("presenter .presentTracks")
        viewController?.displayData(viewModel: Search.Model.ViewModel.ViewModelData.dispayTracks)
    }
  }
  
}
